#!/bin/bash

# Script that installs Dev Tools (packages and build tools)

# Exits immediately if a command exits with a non-zero status
set -e

# Defines color codes for better terminal output readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# Prints the first message
echo -e "${CYAN}Proceeding to install Dev Tools on the system at $(date)...${RESET}"

echo ""

# Step 1: Updates the system packages
echo -e "${CYAN}Updating the system packages...${RESET}"
  
dnf update -y
  
echo ""

# Step 2: Installs system development tools (C and C++ Compilers (GCC/G++))
echo -e "${YELLOW}Installing system development tools...${RESET}"

dnf groupinstall -y "Development Tools"

echo ""

# Verifies the installed C, C++ installed pacakges
echo -e "${CYAN}Installed development tools:${RESET}"
echo "GCC: $(gcc -dumpversion)"
echo "G++: $(g++ -dumpversion)"

echo ""

# Step 3: Installs languages, interpreters and Databases Services
echo -e "${YELLOW}Installing languages and interpreters...${RESET}"

dnf install -y \
  python3 python3-pip python3-devel \
  ruby ruby-devel \
  php \
  golang \
  perl \
  rust cargo \
  lua \
  sqlite sqlite-devel \
  postgresql postgresql-server \
  mysql mysql-server 

echo ""

# Installs MongoDB
echo -e "${YELLOW}Installing MongoDB...${RESET}"

cat <<EOF | sudo tee /etc/yum.repos.d/mongodb-org-7.0.repo
[mongodb-org-7.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/7.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-7.0.asc
EOF

dnf install -y mongodb-org

echo ""

# Starts the DB Services (MySQL, MongoDB and PostgreSQL)
echo -e "${YELLOW}Starting MySQL, MongoDB and PostgreSQL...${RESET}"

echo ""

# PostgreSQL: Initialize DB before starting
if [ ! -d "/var/lib/pgsql/data/base" ]; then
    echo -e "${CYAN}Initializing PostgreSQL database cluster...${RESET}"

    postgresql-setup --initdb
fi

systemctl enable --now postgresql
systemctl enable --now mysqld
systemctl enable --now mongod

echo ""

# Installs Android SDK and Android CLI
echo -e "${YELLOW}Installing Android SDK...${RESET}"

echo ""

# Dynamically fetches the latest Android SDK Command-Line Tools Build ID
echo -e "${CYAN}Fetching latest Android SDK version ID...${RESET}"

SDK_VERSION=$(curl -s https://developer.android.com/studio | grep -oP 'commandlinetools-linux-\K[0-9]+(?=_latest.zip)'  | head -n 1)

# Checks if the SDK_VERSION is empty, use a fallback version
if [ -z "$SDK_VERSION" ]; then
    echo -e "${RED}Error: Could not detect the latest Android SDK version. Using fallback ID.${RESET}"
    
    SDK_VERSION="11076708"
fi

echo -e "Latest Version ID detected: ${GREEN}$SDK_VERSION${RESET}"

echo ""

# Sets the Android SDK directory
ANDROID_HOME="/opt/android-sdk"
mkdir -p "$ANDROID_HOME/cmdline-tools"

# Downloads Android SDK Command-Line Tools
echo -e "${CYAN}Downloading Android Command Line Tools...${RESET}"

wget "https://dl.google.com/android/repository/commandlinetools-linux-${SDK_VERSION}_latest.zip" -O /tmp/cmdline-tools.zip

echo ""

# Extracts Android SDK Command-Line Tools
unzip -q /tmp/cmdline-tools.zip -d "$ANDROID_HOME/cmdline-tools"
rm -rf "$ANDROID_HOME/cmdline-tools/latest"
mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
rm -f /tmp/cmdline-tools.zip

echo ""

# Sets Android environment variables system-wide
echo -e "${CYAN}Setting up Android environment variables...${RESET}"

cat <<EOF | tee /etc/profile.d/android.sh
export ANDROID_HOME=$ANDROID_HOME
export ANDROID_SDK_ROOT=$ANDROID_HOME
export PATH=\$PATH:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/emulator:\$ANDROID_HOME/build-tools
EOF

echo ""

# Sets the environment variables for the current shell
export ANDROID_HOME="$ANDROID_HOME"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/build-tools"

echo ""

# Installs the new Android CLI
echo -e "${CYAN}Installing Android CLI...${RESET}"

curl -fsSL https://dl.google.com/android/cli/latest/linux_x86_64/install_root.sh | bash

echo ""

# Accepts the licenses and installs essential Android SDK components
echo -e "${CYAN}Installing essential Android SDK components...${RESET}"

android --sdk="$ANDROID_HOME" sdk install  platform-tools "build-tools;34.0.0"  "platforms;android-34"

echo ""

# Installs the latest Node.js and NPM versions (LTS or current)
echo -e "${YELLOW}Installing NodeJS and NPM latest versions...${RESET}"

curl -fsSL https://rpm.nodesource.com/setup_22.x | bash
dnf install -y nodejs
npm install -g npm@12.0.2

echo ""

# Verifies the installed languages packages and interpreters
echo -e "${CYAN}Installed languages and interpreters:${RESET}"
echo "Python3: $(python3 --version 2>&1)"
echo "Pip: $(pip3 --version | awk '{print $2}')"
echo "Ruby: $(ruby --version | awk '{print $2}')"
echo "PHP: $(php --version | awk 'NR==1{print $2}')"
echo "Go: $(go version | awk '{print $3}')"
echo "Perl: $(perl -e 'print $^V')"
echo "Rust: $(rustc --version | awk '{print $2}')"
echo "Cargo: $(cargo --version | awk '{print $2}')"
echo "Lua: $(lua -v | awk '{print $2}')"
echo "SQLite: $(sqlite3 --version | awk '{print $1}')"
echo "Git: $(git --version | awk '{print $3}')"
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"
echo "MySQL: $(mysql --version | awk '{print $5}' | sed 's/,//')"
echo "MongoDB: $(mongod --version | grep 'db version' | awk '{print $3}')"
echo "PostgreSQL: $(psql --version | awk '{print $3}')"
echo "Android SDK Manager: $($ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --version)"
echo "Android: $(android --version)"
echo "ADB Version: $(adb --version | head -n 1 | awk '{print $5}')"

echo ""

# Verifies Python development headers
echo -e "${CYAN}Python Development Headers:${RESET}"
python3-config --includes

echo ""

# Step 4: Installs Scala
echo -e "${YELLOW}Installing Scala...${RESET}"
mkdir -p /opt/scala
curl -fL https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz | gzip -d > /opt/scala/cs && chmod +x /opt/scala/cs && /opt/scala/cs setup -y

echo ""

# Step 5: Installs Groovy
echo -e "${YELLOW}Installing Groovy...${RESET}"
GROOVY_LATEST_VERSION=$(curl -s https://downloads.apache.org/groovy/ | grep -oP '(?<=href=")[0-9]+\.[0-9]+\.[0-9]+(?=/")' | sort -V | tail -1) && \
curl -L http://downloads.apache.org/groovy/${GROOVY_LATEST_VERSION}/distribution/apache-groovy-binary-${GROOVY_LATEST_VERSION}.zip -o /tmp/apache-groovy-binary-${GROOVY_LATEST_VERSION}.zip && \
mkdir /opt/groovy && \
unzip /tmp/apache-groovy-binary-${GROOVY_LATEST_VERSION}.zip -d /opt/groovy && \
rm "/tmp/apache-groovy-binary-${GROOVY_LATEST_VERSION}.zip"

echo ""

# Adds Groovy to system PATH
echo "export PATH=/opt/groovy/groovy-${GROOVY_LATEST_VERSION}/bin:\$PATH" | tee /etc/profile.d/groovy.sh
source /etc/profile.d/groovy.sh

echo ""

# Verifies Groovy installation
echo -e "${CYAN}Installed Groovy version:${RESET}"
echo "Groovy: $(groovy --version | awk 'NR==1{print $3}')"

echo ""

# Step 6: Installs Cobol
echo -e "${YELLOW}Installing Cobol...${RESET}"
COBOL_LATEST_VERSION=$(curl -s https://ftp.gnu.org/gnu/gnucobol/ | grep -oP 'gnucobol-\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1) && \
wget https://ftp.gnu.org/gnu/gnucobol/gnucobol-${COBOL_LATEST_VERSION}.tar.gz -O /tmp/gnucobol-${COBOL_LATEST_VERSION}.tar.gz && \
mkdir -p /opt/cobol && \
tar -xzf /tmp/gnucobol-${COBOL_LATEST_VERSION}.tar.gz --strip-components=1 -C /opt/cobol && \
rm "/tmp/gnucobol-${COBOL_LATEST_VERSION}.tar.gz"

echo ""

# Installs GMP and Berkeley DB development libraries 
echo -e "${CYAN}Installing GMP and Berkeley DB development libraries...${RESET}"
dnf install -y gmp-devel libdb-devel

echo ""

# Configures Cobol and Updates library cache
echo -e "${CYAN}Configuring GNUCobol...${RESET}"
cd /opt/cobol
./configure --prefix=/usr/local
make
make install
ldconfig

echo ""

# Verifies Cobol installation
echo -e "${CYAN}Installed Cobol version:${RESET}"
echo "Cobol: $(cobc --version | head -n 1 | grep -oP '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')"

echo ""

# Step 6: Installs C# Development Tools
echo -e "${YELLOW}Installing C# development tools...${RESET}"

dnf install -y dotnet-sdk-8.0

echo ""

echo -e "${YELLOW}Installing Mono (Open Source .NET Implementation)...${RESET}"
dnf config-manager --add-repo https://download.mono-project.com/repo/centos8-stable.repo
dnf install -y mono-complete --nogpgcheck

echo ""

# Verifies the installed C# packages
echo -e "${CYAN}Installed C# development tools:${RESET}"
echo ".NET: $(dotnet --version)"
echo "Mono: $(mono --version | head -n 1 | sed -E 's/.*version ([^ ]+).*/\1/')"
echo "MCS: $(mcs --version | head -n 1 | sed -E 's/.*version ([^ ]+).*/\1/')"

echo ""

: <<'COMMENT'
# Step 7: Installs Dart
echo -e "${YELLOW}Installing Dart...${RESET}"
LATEST_DART_VERSION=$(curl -s https://dart.dev/get-dart | grep -oP 'https://storage.googleapis.com/dart-archive/channels/stable/release/[0-9.]+/sdk/dartsdk-linux-x64-release.zip') && \
wget "$LATEST_DART_VERSION" -O /tmp/dart-sdk.zip && \
unzip /tmp/dart-sdk.zip -d /opt && \
ln -s /opt/dart-sdk/bin/dart /usr/bin/dart && \
rm "/tmp/dart-sdk.zip"

echo ""

# Adds Dart to PATH
echo 'export PATH="$PATH:/opt/dart-sdk/bin"' >> ~/.bashrc
source ~/.bashrc

echo ""

# Verifies Dart Installation 
echo "Dart: $(dart --version | awk 'NR==1{print $2}')"
COMMENT

echo ""

# Step 7: Installs Terraform
echo -e "${CYAN}Installing Terraform...${RESET}"
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
dnf install -y terraform

echo ""

# Verifies Terraform installation
echo -e "${CYAN}Installed Terraform version:${RESET}"
echo "Terraform: $(terraform version | head -n 1 | sed 's/^Terraform v//')"

echo ""

# Step 8: Install Docker
echo -e "${CYAN}Installing Docker...${RESET}"
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io
systemctl enable --now docker

echo ""

# Verifies Docker installation
echo -e "${CYAN}Installed Docker version:${RESET}"
echo "Docker: $(docker --version | awk '{print $3}' | sed 's/,//')"

echo ""

# Step 9: Installs Build Tools and Frameworks
echo -e "${YELLOW}Installing Build Tools & Frameworks...${RESET}"

echo ""

echo -e "${CYAN}Installing Maven...${RESET}"
dnf install -y maven

echo ""

# Verifies Maven installation
echo -e "${CYAN}Installed Maven version:${RESET}"
echo "Maven: $(mvn -version | awk 'NR==1{print $3}')"

echo ""

echo -e "${CYAN}Installing Gradle...${RESET}"
GRADLE_LATEST_VERSION=$(curl -s https://services.gradle.org/versions/current | jq -r '.version') && \
wget https://services.gradle.org/distributions/gradle-${GRADLE_LATEST_VERSION}-bin.zip -P /tmp && \
unzip -d /opt/gradle /tmp/gradle-${GRADLE_LATEST_VERSION}-bin.zip && \
ln -s /opt/gradle/gradle-${GRADLE_LATEST_VERSION}/bin/gradle /usr/bin/gradle && \
rm "/tmp/gradle-${GRADLE_LATEST_VERSION}-bin.zip"

echo ""

# Verifies Gradle installation
echo -e "${CYAN}Installed Gradle version:${RESET}"
echo "Gradle: $(gradle --version | grep '^Gradle ' | awk '{print $2}')"

echo ""

echo -e "${CYAN}Installing Apache Ant...${RESET}"
dnf install -y ant

echo ""

# Verifies Ant installation
echo -e "${CYAN}Installed Apache Ant version:${RESET}"
echo "Ant: $(ant -version | awk 'NR==1{print $4}')"

echo ""

echo -e "${CYAN}Installing Poetry and Django...${RESET}"
pip3 install poetry django

echo ""

# Verifies Poetry and Djang installations
echo -e "${CYAN}Installed Python development tools:${RESET}"
echo "Poetry: $(poetry --version | sed -E 's/.* ([0-9]+\.[0-9]+\.[0-9]+).*/\1/')"
echo "Django: $(django-admin --version)"

echo ""

echo -e "${CYAN}Installing Javascript Frameworks (Vue JS, React JS and Angular JS)...${RESET}"
npm install -g @vue/cli && \
npm install -g create-next-app && \
npm install -g @angular/cli

echo ""

# Verifies the Javascript Frameworks installation
echo -e "${CYAN}Installed Javascript frameworks:${RESET}"
echo "Vue JS: $(vue --version)"
echo "React JS (Next.js): $(npm list -g create-next-app --depth=0 | grep create-next-app | awk -F@ '{print $2}')"
echo "Angular JS: $(ng version | grep 'Angular CLI' | awk '{print $3}')"

echo ""

echo -e "${Cyan}Installing Ruby Tools...${RESET}"
gem install bundler rake

echo ""

# Verifies the Bundler & Rake installations
echo -e "${CYAN}Installed Ruby development tools:${RESET}"
echo "Bundler: $(bundler --version | awk '{print $3}')"
echo "Rake: $(rake --version | awk '{print $3}' | sed 's/,//')"

echo ""

# Verifies MsBuild installation
echo -e "${CYAN}Installed MsBuild version:${RESET}"
echo "MsBuild: $(dotnet msbuild --version | tail -n 1 | cut -d+ -f1)"

echo ""

# Prints the final message
echo -e "${GREEN}Execution completed successfully!${RESET}" 