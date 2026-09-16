# 🐱 Tomcat9Config (Fortify SSC Tomcat 10.x Configurator)

This Bash script automates the **installation and configuration of Apache Tomcat 10.x** for **OpenText Application Security (Fortify SSC)** on Linux system.
It sets up environment variables, systemd services, Tomcat options, and required firewall rules to ensure Fortify SSC runs smoothly.

---

## ⚙️ Features

* 🔧 Automatically sets up `CATALINA_HOME` in `/etc/environment`.
* 🐚 Creates the `setenv.sh` file for Tomcat JVM options.
* 🧩 Generates and enables a `systemd` service for Fortify SSC Tomcat.
* 🚀 Copies the `ssc.war` file to Tomcat’s `webapps` directory.
* 🔁 Reloads and starts Tomcat as a managed Linux service.
* 🔓 Opens and persists ports **8080** and **8443** in the firewall.
* 💾 Verifies configuration files and provides informative logs.

---

## 📋 Requirements

* 🐧 Linux system (RHEL, CentOS, or compatible).
* ☕ Java JDK installed and accessible through `$JAVA_HOME`.
* 🔥 Apache Tomcat 10.x installed in the Fortify SSC directory.
* 🧱 FirewallD installed and running.
* 🛠️ Root privileges for service and firewall configuration.

---

## 📁 Directory Structure

```
Tomcat9Config/
|   ├── tomcat9_config.sh     # Shell script that configures Apache Tomcat 9 with the required configuration to run Fortify SSC.
|   └── .env                  # Environment variables file used by the Apache Tomcat 9 configuration script.
└────────────────────────
```

## 🧰 Script Details

| Variable                              | Description                                      |
| ------------------------------------- | ------------------------------------------------ |
| `FORTIFY_SSC_VERSION`                 | Current Fortify SSC version (eg: `25.2`)    	   |
| `FORTIFY_SSC_DIR`                     | Base directory for Fortify SSC (`/opt`)          |
| `FORTIFY_SSC_TOMCAT_DIR`              | Tomcat directory path                            |
| `FORTIFY_SSC_FILES_DIR`               | Directory containing `ssc.war`                   |
| `SERVICES_DIR`                        | Path to systemd services (`/etc/systemd/system`) |
| `SETENV_BASH_FILE_DIR`                | Path for `setenv.sh` configuration file          |
| `FORTIFY_SSC_TOMCAT_SERVICE_FILE_DIR` | Path to generated service file                   |
| `ENVIRONMENT_FILE_DIR`                | Path to `/etc/environment` file                  |

---

## 🚀 Usage

Make executable and run the script as **root** or with **sudo** privileges:

```bash
chmod +x ./tomcat10_config.sh
sudo ./tomcat10_config.sh
```

You’ll be prompted at the end to reboot the system.
If you choose **not** to reboot, you can manually start the service:

```bash
sudo systemctl start ot_application_security_tomcat
```

---

## 🔍 Verifications

After execution, verify that:

* The service is active:

  ```bash
  systemctl status ot_application_security_tomcat
  ```
* The web application is deployed:

  ```bash
  ls -L /opt/OpenText_Application_Security/OpenText_Application_Security_Apache_Tomcat_10/webapps/
  ```
* The ports are open:

  ```bash
  firewall-cmd --list-ports
  ```

---

## 🧾 License

This project is part of the **Fortify SSC Scripts Utilities** suite.
Use according to your organization’s internal deployment and licensing guidelines.
