# 🎯 Wagtail Image Starter Kit

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/mrcolorr/wagtail/build-push-images.yml?style=flat-square&link=https%3A%2F%2Fhub.docker.com%2Fr%2Fmrcolorrain%2Fwagtail)
![Docker Pulls](https://img.shields.io/docker/pulls/mrcolorrain/wagtail?style=flat-square&link=https://hub.docker.com/r/mrcolorrain/wagtail)
![Docker Stars](https://img.shields.io/docker/stars/mrcolorrain/wagtail?style=flat-square&link=https://hub.docker.com/r/mrcolorrain/wagtail)

> **🔍 Overview:** The easiest way to run Wagtail CMS in Docker or Kubernetes. Launch a simple Wagtail CMS website in minutes with persistent storage (Docker volumes, bind mounts, or Kubernetes PVCs), automated setup, and zero manual configuration. **Keywords:** wagtail docker image, wagtail starter kit, wagtail cms, wagtail kubernetes, wagtail docker-compose, wagtail quickstart, wagtail CMS, wagtail website, wagtail blog, wagtail image

⭐️ If you found this project helpful, please give it a star on GitHub! ⭐️

## Table of Contents

- [🌟 Key Features](#-key-features)
- [🚀 Quick Start](#-quick-start)
- [📚 Usage](#-usage)
- [🔧 Configuration](#-configuration)
- [📦 Modules and Plugins](#-modules-and-plugins)
- [📝 Examples](#-examples)
- [❓ FAQ](#-faq)
- [🤝 Contributing](#-contributing)
- [🫶 Support the Project](#-support-the-project)
- [📄 License](#-license)
- [🔗 Links and Support](#-links-and-support)

## 🌟 Key Features

- **🚀 Instant Wagtail Setup:** Start a new Wagtail CMS project with a single Docker command—no manual steps required.
- **💾 Persistent Storage:** Supports Docker volumes, bind mounts, and Kubernetes PVCs for database and media files.
- **🔒 Secure by Default:** Secrets and admin credentials set via environment variables.
- **🖼️ Media Management:** Store uploads and static files outside the container for easy backup and migration.
- **⚡ Automated Admin Creation:** Superuser is created automatically on first run with your provided credentials.
- **🐳 Docker & ☸️ Kubernetes Ready:** Use as a standalone Docker image or deploy with Kubernetes manifests.
- **🦄 Customizable:** Easily override project name, data directory, and admin credentials.

> _Why choose Wagtail Image Starter Kit?_ Launch your Wagtail CMS in minutes—just pull, run, and go! ⭐️

## 🚀 Quick Start

Get up and running in less than 5 minutes:

### 🐳 Docker

If you have Docker installed, you can run Wagtail with a single command:

```bash
docker pull mrcolorrain/wagtail:latest
docker run -d --name wagtail \
  -v $PWD/app/data:/app/data \
  -e DJANGO_SECRET_KEY=your-secret \
  -e DJANGO_SUPERUSER_USERNAME=admin \
  -e DJANGO_SUPERUSER_EMAIL=admin@example.com \
  -e DJANGO_SUPERUSER_PASSWORD=supersecret \
  -p 8000:8000 \
  mrcolorrain/wagtail:latest
```

### ☸️ Kubernetes

If you prefer Kubernetes, you can deploy Wagtail using the provided manifests:

1. **Edit manifests** (if needed):

   - Update `k8s/pvc.yaml` for your storage class.
   - Set secrets and credentials in `k8s/secret.yaml`.
   - Set the other variables in `k8s/configmap.yaml`.
   - (Optional) Customize other manifests like `deployment.yaml`, `service.yaml`, and `ingress.yaml` as needed.

   > **Tip:** Use a custom domain or host for the Ingress.

2. **Apply manifests**
   ```bash
   kubectl apply -f k8s/pvc.yaml
   kubectl apply -f k8s/configmap.yaml
   kubectl apply -f k8s/secret.yaml
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   kubectl apply -f k8s/ingress.yaml
   ```

> **Tip:** Use Docker volumes or bind mounts for local dev, and PVCs for Kubernetes.

### 📦 Build from Source

If you want to customize the image or contribute to the project, you can build it from source:

```bash
git clone https://github.com/MRColorR/wagtail.git
cd wagtail
docker build -t mrcolorrain/wagtail:latest -f Dockerfile .
```

Then run the image as shown above.

## 📚 Usage

To customize your project name and data directory, add the `PROJECT_NAME` and `DEST_DIR` environment variables and adjust the volume mount:

```bash
docker run -d --name wagtail \
  -v $PWD/mydata:/app/data/custom \
  -e DJANGO_SECRET_KEY=your-secret \
  -e DJANGO_SUPERUSER_USERNAME=admin \
  -e DJANGO_SUPERUSER_EMAIL=admin@example.com \
  -e DJANGO_SUPERUSER_PASSWORD=supersecret \
  -e PROJECT_NAME=myproject \
  -e DEST_DIR=/app/data/custom \
  -p 8000:8000 \
  mrcolorrain/wagtail:latest
```

_For a full list of `manage.py` commands, open a shell inside the container and run:_

```bash
python manage.py --help
```

## ▶️ Run the Example Project

The included Wagtail example `/app/examples/your-first-wagtail-site/`  is available in both image and source code.

### 🐍 Run locally from source code with Python

You can run it directly with Python for local development, or copy it to your data directory to start a new project:

1. **Install dependencies**
   ```bash
   cd app/examples/your-first-wagtail-site
   pip install -r ../requirements.txt
   ```

2. **Apply migrations and create a superuser**
   ```bash
   python manage.py migrate
   python manage.py createsuperuser
   ```

3. **Run the development server**
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

4. **Access the site**
   - Website: [http://localhost:8000/](http://localhost:8000/)
   - Admin: [http://localhost:8000/admin/](http://localhost:8000/admin/)

> **Note:** The example is tracked in `app/examples/your-first-wagtail-site/` in the repo, and always available at `/app/examples/your-first-wagtail-site/` inside the container, even if you mount a volume over `/app/data`.

### 🐳 Run using Docker image

If you want to run the included example project in Docker, you can use it from the `/app/examples/your-first-wagtail-site/` path, even if you mount a volume over `/app/data`:

```bash
# Run the example directly from the image (no need to copy anything):
docker run -d --name wagtail \
  -v $PWD/app/data:/app/data \
  -e DJANGO_SECRET_KEY=your-secret \
  -e DJANGO_SUPERUSER_USERNAME=admin \
  -e DJANGO_SUPERUSER_EMAIL=admin@example.com \
  -e DJANGO_SUPERUSER_PASSWORD=supersecret \
  -e PROJECT_NAME=mysite \
  -e DEST_DIR=/app/examples/your-first-wagtail-site \
  -p 8000:8000 \
  mrcolorrain/wagtail:latest
```

Or, to start a new project based on the example, copy it to your data directory and set `DEST_DIR` accordingly:

```bash
# Example: copy the example to your data directory
# Option 1: copy example from inside the container shell to data directory
cp -r /app/examples/your-first-wagtail-site /app/data/my-new-site
# Option 2: copy example from source code to data directory
cp -r app/examples/your-first-wagtail-site app/data/my-new-site
# Then run the image again with:
docker run -d --name wagtail \
  -v $PWD/app/data:/app/data \
  -e DJANGO_SECRET_KEY=your-secret \
  -e DJANGO_SUPERUSER_USERNAME=admin \
  -e DJANGO_SUPERUSER_EMAIL=admin@example.com \
  -e DJANGO_SUPERUSER_PASSWORD=supersecret \
  -e PROJECT_NAME=mysite \
  -e DEST_DIR=/app/data/my-new-site \
  -p 8000:8000 \
  mrcolorrain/wagtail:latest
```

> **Tip:** The ready to use example is always available at `/app/examples/your-first-wagtail-site/` inside the container, so you can copy it out at any time, even if `/app/data` is mounted as a volume.

## 🔧 Configuration

Set environment variables to customize your instance:

| Variable                  | Description          | Required | Default          |
| ------------------------- | -------------------- | -------- | ---------------- |
| DJANGO_SECRET_KEY         | Django secret key    | Yes      | -                |
| PROJECT_NAME              | Wagtail project name | No       | myawesomewebsite |
| DEST_DIR                  | Data directory path  | No       | /app/data        |
| DJANGO_SUPERUSER_USERNAME | Admin username       | Yes      | -                |
| DJANGO_SUPERUSER_EMAIL    | Admin email          | Yes      | -                |
| DJANGO_SUPERUSER_PASSWORD | Admin password       | Yes      | -                |

## 📦 Modules and Plugins

| Module/Plugin | Description       | Enabled by Default |
| ------------- | ----------------- | ------------------ |
| Wagtail       | CMS core          | Yes                |
| Gunicorn      | Production server | Yes                |
| SQLite        | Default DB        | Yes                |
| wagtail-markdown | Markdown support for content fields (choose between RichText and Markdown editors) | Yes |

> **Tip:** Use your own database and add your desired plugins by overriding settings or mounting a custom config. This makes it easy to extend your Wagtail project with any third-party or custom modules you prefer.

## ✍️ Markdown Support

This starter kit includes built-in support for Markdown content editing using the [wagtail-markdown](https://github.com/torchbox/wagtail-markdown) plugin.

- **Per-page editor selection:** For all main content types (homepage, blog, knowledge base), you can choose between the standard Wagtail RichText editor or a Markdown editor for each page.
- **How it works:** In the Wagtail admin, select your preferred editor type ("RichText" or "Markdown") when creating or editing a page. If you select Markdown, the content field will use a Markdown editor and render Markdown on the site.
- **Technical details:**
  - The example project models include both RichText and Markdown fields, plus an `editor_type` selector.
  - Templates use `{% load wagtailmarkdown %}` and render the correct content type based on the selector.
  - The `wagtail-markdown` package is included in `requirements.txt` and enabled in `INSTALLED_APPS`.
- **Extending:** You can apply this pattern to your own models and templates for flexible Markdown/RichText support.

> See the example project in `app/examples/your-first-wagtail-site/` for implementation details.

## 📝 Examples

- **Run with Docker Compose:**

  ```yaml
  version: "3.8"
  services:
    wagtail:
      image: mrcolorrain/wagtail:latest
      ports:
        - "8000:8000"
      volumes:
        - ./app/data:/app/data
      environment:
        DJANGO_SECRET_KEY: your-secret
        DJANGO_SUPERUSER_USERNAME: admin
        DJANGO_SUPERUSER_EMAIL: admin@example.com
        DJANGO_SUPERUSER_PASSWORD: supersecret
  ```

- **Backup your data:**
  ```bash
  tar czvf wagtail-backup.tar.gz ./data
  ```

## ❓ FAQ

**Q: Can I use this for production?**
A: This is a starter kit for easy Wagtail deployment. For high-traffic or production use, consider switching to PostgreSQL and customizing security settings.

**Q: How do I persist data?**
A: Use Docker volumes, bind mounts, or Kubernetes PVCs to store `/app/data` (the default value for `DEST_DIR`) outside the container. You can override this path by setting the `DEST_DIR` environment variable.

**Q: How do I backup my site?**
A: Backup the `/app/data` directory (contains SQLite DB and media files). If you changed `DEST_DIR`, backup that directory instead.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🫶 Support the Project

Your support helps keep this project alive and accessible for everyone. Here’s how you can help:

### 💖 Ways to Support

- ⭐️ Star the project
- 🐛 Reporting bugs
- 💡 Suggesting enhancements
- 🤝 Contributing code
- 📝 Writing documentation
- 📢 Sharing with friends and online on social media
- 💖 Donating to support development

### ☕️ Donate

If you find value in this project, consider making a donation

### Cryptocurrency Wallets

- **Bitcoin (BTC):** `1EzBrKjKyXzxydSUNagAP8XLeRzBTxfHcg`
- **Ethereum (ETH):** `0xE65c32004b968cd1b4084bC3484C0dA051eeD3ee`
- **Solana (SOL):** `6kUAWW8q5169qnUJdxxLsNMPpaKPvbUSmryKDYTb9epn`
- **Polygon (MATIC):** `0xE65c32004b968cd1b4084bC3484C0dA051eeD3ee`
- **BNB (Binance Smart Chain):** `0xE65c32004b968cd1b4084bC3484C0dA051eeD3ee`

### Support via Other Platforms

- **Patreon:** [Support me on Patreon](https://patreon.com/mrcolorrain)
- **Buy Me a Coffee:** [Buy me a coffee](https://buymeacoffee.com/mrcolorrain)
- **Ko-fi:** [Support me on Ko-fi](https://ko-fi.com/mrcolorrain)

Your support, no matter how small, is enormously appreciated and directly fuels ongoing and future developments. Thank you for your generosity! 🙏

## Disclaimer ⚠️

This project and its artifacts are provided "as is" and without warranty of any kind.

The author makes no warranties, express or implied, that this Wagtail Docker Starter Kit is free of errors, defects, or suitable for any particular purpose.

The author shall not be held liable for any damages suffered by any user of this project or its documentation, whether direct, indirect, incidental, consequential, or special, arising from the use of or inability to use this project.

## 📄 License

Distributed under the **GNU General Public License v3.0**. See `LICENSE` for more information.

## 🔗 Links and Support

- **Documentation:** [Wagtail Docs](https://docs.wagtail.org/)
- **Issues:** [GitHub Issues](https://github.com/MRColorR/wagtail/issues)
- **DockerHub:** [DockerHub Image](https://hub.docker.com/r/mrcolorrain/wagtail)
- **Author:** [MRColorR]

---

_Made with ❤️ for the community_
