# Base image with Python & system deps
FROM python:3.12-slim

# Add user that will be used in the container with fixed UID/GID and no home directory.
RUN groupadd -g 1000 wagtail && useradd -u 1000 -g 1000 wagtail

# Port used by this container to serve HTTP.
EXPOSE 8000

# Unbuffered logs + default values
ENV PYTHONUNBUFFERED=1 \
    PORT=8000 \
    PROJECT_NAME=myawesomewebsite \
    DEST_DIR="/app/data"

# Install OS level Wagtail dependencies
RUN apt-get update --yes --quiet && apt-get install --yes --quiet --no-install-recommends \
    build-essential \
    libpq-dev \
    libmariadb-dev \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libwebp-dev \
    # Include envsubst via gettext-base as is required by the entrypoint script
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Use /app folder as a directory where the source code is stored.
WORKDIR /app

# Copy bootstrap requirements and install them
COPY --chown=wagtail:wagtail bootstrap-requirements.txt /app/
RUN pip install --no-cache-dir -r bootstrap-requirements.txt
# Copy the entrypoint script
COPY --chown=wagtail:wagtail entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh



# Prepare directories and permissions
# Set directories to be owned by the "wagtail" user. This Wagtail project
# uses SQLite, the folder needs to be owned by the user that
# will be writing to the database file.
RUN chown -R wagtail:wagtail /app

# Copy the example project into the image at /app/examples/your-first-wagtail-site
COPY --chown=wagtail:wagtail app/examples/your-first-wagtail-site /app/examples/your-first-wagtail-site

# Switch to non-root user for runtime
# USER wagtail

# Entrypoint will handle install, migrations, superuser, static, server
ENTRYPOINT ["/app/entrypoint.sh"]

# Default command
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
