# 🐳 FortifyDockerImagesPull (Docker Images Puller)

This Bash script automates the process of **pulling Fortify Docker images from Docker Hub**, **tagging them**, and **pushing them into a private Docker Registry** for secure internal use.

---

## 🚀 Features

* ✅ Automatically logs in to **Docker Hub** and your **private Docker Registry** (both via Docker and Helm).
* 🌀 Pulls **all image tags** for each Fortify Docker image.
* 🧩 Detects and skips **Windows-only images** automatically.
* 📦 Handles both **Docker Images** and **Helm Charts (OCI artifacts)**.
* 🧹 Cleans up local images after upload to save space.
* 📜 Displays the final Docker Registry repository catalog when done.

---

## 🧰 Requirements

Before running the script, ensure the following tools are installed and configured on your Linux host:

* 🐚 **Bash shell**
* 🐳 **Docker**
* ⛵ **Helm 3**
* 🔧 **jq** and **curl**

You must also have valid credentials for both:

* Docker Hub
* Your private Docker Registry

---

## ⚙️ Environment Configuration (.env)

All required variables are loaded from the `.env` file in the same directory as the script.

Example:

```makefile
# Docker Hub Credentials
DOCKER_HUB_USER=mydockerhubuser
DOCKER_HUB_TOKEN=mydockerhubtoken

# Private Registry Credentials
REGISTRY_USER=registryuser
REGISTRY_PASSWORD=registrypassword

# Registry Configuration
FORTIFY_DOCKER_HUB_ORG=fortify
CUSTOM_REGISTRY_URL=myregistry.example.com
```

> 📝 **Note:** The `.env` file must be placed in the same folder as the script and should not contain trailing spaces or comments after variable assignments.

---

## 🚀 Usage Overview

1. **Ensure `.env` is configured correctly** with valid credentials and URLs.
2. **Make the script executable and run the script** with:

   ```bash
   chmod +x fortify_docker_images_pull.sh
   ./fortify_docker_images_pull.sh
   ```
3. The script will:

   * Log in to Docker Hub and the private registry.
   * Pull, tag, and push all Fortify images and Helm charts.
   * Display the pushed repositories at the end.

> 💡 You can monitor progress in real time as each image or chart is processed.

---

## 📁 Directory Structure

 ```
 FortifyDockerImagesPull/                            
 ├── .env                                             # Environment variables file containing Docker Hub, Registry credentials, and URLs
 └── fortify_docker_images_pull.sh                    # Bash script that automates pulling Fortify Docker images from Docker Hub and pushing them to a private registry
 └────────────────────────────────
 ```

---

## 🔐 Authentication & Security

* The script reads credentials securely from the `.env` file.
* All connections to the private registry use HTTPS.

---

## 📝 Notes

* Helm charts are stored temporarily in a `charts/` folder and automatically cleaned up.
* Windows-only images (e.g., `*windows*`) are skipped for compatibility.
* Errors during image pulls or pushes stop the execution (due to `set -e`).
* The list of Fortify Docker images can be customized in the `FORTIFY_DOCKER_IMAGES` array inside the script.

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
