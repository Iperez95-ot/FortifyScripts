[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Iperez95-ot/FortifyScripts)
# <img width="25" height="25" alt="image" src="https://github.com/user-attachments/assets/d10482ad-8bff-452f-a65f-9882c5bceed3" /> FortifyScripts

A collection of automation scripts designed to simplify and optimize the **installation and upgrade** tasks across all **Fortify On-Premise Components** of **OpenText Application Security**, including:

- 🏢 **OpenText Application Security (Fortify Software Security Center (SSC))**.
- 💻 **OpenText Static Application Security Testing (Fortify Static Code Analyzer (SCA)**.
- 🌐 **OpenText Dynamic Application Security Testing (Fortify WebInspect)**.
- ⚙️ **OpenText Fortify ScanCentral Controller (SAST & DAST)**.
- 🧰 **OpenText Static Application Security Testing Application Security Tools (Fortify Tools)**.

## ⚡ Overview

These scripts automate key DevSecOps and infrastructure activities such as:

- ☕ **Installing Java** (any version required for the Fortify release version you are going to install/upgrade).
- 🪄 **Installing Helm** (latest version).
- 🔒 **Installing, configuring (Service, SSL & memory) for Apache Tomcat (9 or 10)** for Fortify SSC deploy on it.
- 🐬 **Installing MySQL 8.0 Client** on a Linux system.
- 🛢️ **Creating a MySQL Server Docker Container** to host the **Fortify SSC database**.
- 🗂️ **Creating an OpenText eDirectory Docker Container** for **LDAP authentication to Fortify SSC**.
- 🌐 **Creating an OpenText eDirectory API Docker Containers** providing **API REST and LDAP endpoints to the eDirectory Docker Container**.
- 🖥️ **Creating an OpenText IdentityConsole Docker Container** to manage **directory data of the eDirectory Docker Container**.
- ☁️ **Pulling the binary installation files from an OneDrive backup Sharepoint** from Fortfy SSC, eDirectory and IdentityConsole.
- 📦 **Deploying a Private Docker Registry** to storage Fortify Lab server related Docker Images.
  - [FrontEnd (Joxit UI)](https://github.com/Joxit/docker-registry-ui)  
  - [BackEnd (Docker Hub Registry)](https://hub.docker.com/_/registry)
- 🐳 **Pulling all Fortify Docker Images** from **Fortify Docker Hub** into the **Private Docker Registry**
- ⌨️ **Installing Fortify Command Line Interface (FCLI)** latest version in a Linux system.

---

## 📌 Prerequisites

Before using the scripts, ensure you have:

- 🖥️ A **fully functional Linux Server** with:
  - 🌐 **Internet connection**.
  - 🪟 **Graphical User Interface (GUI)**.
  - 🔑 **SSH access**.
- 🌍 Any **web browser** installed.
- 🐳 **Docker** properly installed and running.

---

## 🔗 Useful Resources

- [🛡️ OpenText Application Security (Fortify Software Security Center (SSC) documentation](https://www.microfocus.com/es-es/documentation/fortify-software-security-center/)
- [⌨️ Fortify Command Line Interface (FCLI) – GitHub Repository](https://github.com/fortify/fcli)
- [🐳 Docker Hub – Fortify Images](https://hub.docker.com/orgs/fortifydocker/repositories)
- [🗂️ NetIQ eDirectory documentation](https://www.netiq.com/documentation/edirectory/)
- [🗂️ OpenText eDirectory documentation](https://docs.microfocus.com/doc/40/25.4/home)
- [🖥️ NetIQ IdentityConsole documentation](https://www.netiq.com/documentation/identity-console/)
- [🖥️ OpenText IdentityConsole documentation](https://docs.microfocus.com/doc/29/25.4/home)

---

## 🤝 Support

💬 For general assistance, please contact me at 📧 [my email](mailto:iperez@ot-latam.com) to get tips and tricks from Fortify and usage of the scripts.
 
- 🆘 OpenText/OT-Latam customers can contact our [support team](https://portal.microfocus.com) for questions, enhancement requests and bug reports.
- 🙋 You can also raise questions and issues through your OpenText/OT-Latam Fortify representative like Customer Success Manager or Technical Account Manager if applicable.
- 🧭 You may also consider raising questions or issues through the [GitHub Issues page](https://github.com/Iperez95-ot/FortifyScripts/issues) (if available for this repository), providing public visibility and allowing anyone (including all contributors) to review and comment on your question or issue. Note that this requires a GitHub account, and given public visibility, you should refrain from posting any confidential data through this channel. 

---

🧾 License

This repository is intended for internal automation and integration use with OpenText Fortify products.
Ensure compliance with your organization’s licensing and security policies.

---

🛠️ Maintained by Ignacio Perez Civeira – OT-Latam Support Consultant Engineer
