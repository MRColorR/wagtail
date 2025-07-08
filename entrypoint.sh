#!/bin/bash
set -euo pipefail

# 1️⃣ Validate required secrets and credentials
: "${DJANGO_SECRET_KEY:?❌ DJANGO_SECRET_KEY not set. Aborting.}"
: "${DJANGO_SUPERUSER_USERNAME:?❌ DJANGO_SUPERUSER_USERNAME not set. Aborting.}"
: "${DJANGO_SUPERUSER_EMAIL:?❌ DJANGO_SUPERUSER_EMAIL not set. Aborting.}"
: "${DJANGO_SUPERUSER_PASSWORD:?❌ DJANGO_SUPERUSER_PASSWORD not set. Aborting.}"

# 2️⃣ Defaults for optional vars
PROJECT_NAME=${PROJECT_NAME:-mysite}
DEST_DIR=${DEST_DIR:-$PROJECT_NAME}
WAGTAIL_TEMPLATE_PATH=${WAGTAIL_TEMPLATE_PATH:-}

echo "🔧 Using PROJECT_NAME='${PROJECT_NAME}'"
echo "🔧 Using DEST_DIR='${DEST_DIR}'"

# 3️⃣ Prepare project root
if [ ! -d "$DEST_DIR" ]; then
  echo "⚠️ Destination directory '$DEST_DIR' does not exist. Creating..."
  mkdir -p "$DEST_DIR"
fi

# 4️⃣ Generate Wagtail project if missing and if manage.py does not exist
echo "⚙️ Checking project..."
if [ ! -d "$DEST_DIR/$PROJECT_NAME" ] || [ ! -f "$DEST_DIR/manage.py" ]; then
  echo "❗ Project directory '$DEST_DIR/$PROJECT_NAME' does not exist or manage.py is missing. Creating Wagtail project..."
  echo "⚙️ Running 'wagtail start' to create project '$PROJECT_NAME'..."
  if [ -n "$WAGTAIL_TEMPLATE_PATH" ]; then
    echo "Using user defined custom Wagtail template path: $WAGTAIL_TEMPLATE_PATH as template for project creation."
    wagtail start --template "$WAGTAIL_TEMPLATE_PATH" $PROJECT_NAME $DEST_DIR
  else
    wagtail start $PROJECT_NAME $DEST_DIR
  fi
  cd $DEST_DIR
else
  echo "✔️ Project directory '$DEST_DIR/$PROJECT_NAME' already exists. Skipping project creation."
  cd $DEST_DIR
fi

# 5️⃣ Install Python dependencies
echo "⚙️ Installing Python dependencies..."
pip install --no-cache-dir -r requirements.txt

# 6️⃣ Export Django env
export SECRET_KEY="$DJANGO_SECRET_KEY"
# export ALLOWED_HOSTS=${ALLOWED_HOSTS:-*}

# 7️⃣ Generate and Apply migrations
echo "⚙️ Checking for migrations..."
python manage.py makemigrations
echo "⚙️ Applying migrations..."
python manage.py migrate

# 8️⃣ Create superuser if missing
echo "🛠️ Generating create_superuser.sh..."
cat << 'TEMPLATE' > create_superuser_template.sh
#!/usr/bin/env bash
set -e
echo "👤 Creating superuser if not exists..."
python manage.py shell <<EOF
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='${DJANGO_SUPERUSER_USERNAME}').exists():
    User.objects.create_superuser(
        username='${DJANGO_SUPERUSER_USERNAME}',
        email='${DJANGO_SUPERUSER_EMAIL}',
        password='${DJANGO_SUPERUSER_PASSWORD}'
    )
EOF
TEMPLATE

# Expand variables into the real script
envsubst < create_superuser_template.sh > create_superuser.sh
chmod +x create_superuser.sh

echo "✅ Running create_superuser.sh"
./create_superuser.sh

# 9️⃣ Collect static files
echo "⚙️ Collecting static files..."
python manage.py collectstatic --noinput --clear

# 🔟 Start the server
echo "🚀 Starting application"
exec "$@"
