# Installing Software on Linux

## Introduction

Installing software on Linux differs from Windows or macOS. Instead of downloading executable installers from websites, Linux uses **package managers** - command-line tools that automate software installation, updates, and removal while managing dependencies automatically.

**Why use package managers?**
- ✅ Automatic dependency resolution
- ✅ Centralized software repositories
- ✅ Easy updates and removal
- ✅ Security through verified packages
- ✅ Consistent installation process

---

## Package Managers Overview

### Distribution-Specific Package Managers

| Distribution | Package Manager | Package Format | Command |
|--------------|----------------|----------------|---------|
| **Debian/Ubuntu** | APT | `.deb` | `apt`, `apt-get` |
| **RHEL/CentOS/Fedora** | DNF/YUM | `.rpm` | `dnf`, `yum` |
| **Arch Linux** | Pacman | `.pkg.tar.xz` | `pacman` |
| **openSUSE** | Zypper | `.rpm` | `zypper` |
| **Alpine Linux** | APK | `.apk` | `apk` |

**We'll focus on APT (Debian/Ubuntu) and DNF/YUM (RHEL/CentOS/Fedora) as they're most common.**

---

## APT - Debian/Ubuntu

### What is APT?

**APT (Advanced Package Tool)** is the package management system used by Debian and Debian-based distributions (Ubuntu, Linux Mint, Pop!_OS, etc.).

**Two commands:**
- `apt` - Modern, user-friendly interface (recommended)
- `apt-get` - Traditional command (still widely used in scripts)

### Basic APT Commands

#### Update Package List

```bash
# Update package database (fetch latest package information)
sudo apt update

# Output shows repositories being contacted
Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease
Get:2 http://security.ubuntu.com/ubuntu jammy-security InRelease [110 kB]
Reading package lists... Done
```

**Important:** Always run `apt update` before installing software to ensure you get the latest versions.

#### Install Packages

```bash
# Install single package
sudo apt install package_name

# Example: Install vim
sudo apt install vim

# Install multiple packages
sudo apt install vim git curl wget

# Install specific version
sudo apt install package=version

# Example
sudo apt install nginx=1.18.0-0ubuntu1
```

#### Remove Packages

```bash
# Remove package (keep configuration files)
sudo apt remove package_name

# Remove package and configuration files
sudo apt purge package_name

# Example
sudo apt purge vim
```

#### Update Packages

```bash
# Update all installed packages
sudo apt update && sudo apt upgrade

# Upgrade with smart conflict resolution (may remove packages)
sudo apt full-upgrade

# Update single package
sudo apt install --only-upgrade package_name
```

#### Search for Packages

```bash
# Search package database
apt search keyword

# Example: Search for Python packages
apt search python3

# Show package details
apt show package_name

# Example
apt show nginx
```

#### List Packages

```bash
# List all installed packages
apt list --installed

# List upgradable packages
apt list --upgradable

# List all available packages
apt list
```

#### Clean Up

```bash
# Remove packages that were automatically installed but no longer needed
sudo apt autoremove

# Remove downloaded package files
sudo apt clean

# Remove only outdated package files
sudo apt autoclean

# Full cleanup
sudo apt autoremove && sudo apt clean
```

### APT Configuration

**Repository sources:** `/etc/apt/sources.list` and `/etc/apt/sources.list.d/`

```bash
# View sources
cat /etc/apt/sources.list

# Example content
deb http://archive.ubuntu.com/ubuntu jammy main restricted
deb http://security.ubuntu.com/ubuntu jammy-security main restricted
```

**Add repository:**
```bash
# Add PPA (Personal Package Archive)
sudo add-apt-repository ppa:repository/name

# Example: Add latest Git PPA
sudo add-apt-repository ppa:git-core/ppa
sudo apt update
sudo apt install git
```

---

## YUM - RHEL/CentOS 7

### What is YUM?

**YUM (Yellowdog Updater Modified)** is the traditional package manager for RHEL, CentOS, and Fedora (up to version 21).

**Note:** RHEL 8+ and CentOS 8+ use DNF, which is YUM's successor with better performance.

### Basic YUM Commands

#### Update Package List

```bash
# Check for updates
sudo yum check-update
```

#### Install Packages

```bash
# Install package
sudo yum install package_name

# Example: Install httpd (Apache)
sudo yum install httpd

# Install multiple packages
sudo yum install httpd mysql-server php

# Assume yes to all prompts
sudo yum install -y package_name

# Install from local RPM file
sudo yum localinstall package.rpm
```

#### Remove Packages

```bash
# Remove package
sudo yum remove package_name

# Example
sudo yum remove httpd

# Remove package and dependencies
sudo yum autoremove package_name
```

#### Update Packages

```bash
# Update all packages
sudo yum update

# Update single package
sudo yum update package_name

# Example
sudo yum update kernel
```

#### Search for Packages

```bash
# Search for package
yum search keyword

# Example
yum search python3

# Show package information
yum info package_name

# Example
yum info httpd

# List all available packages
yum list available

# List installed packages
yum list installed
```

#### Clean Up

```bash
# Clean cached package data
sudo yum clean all

# Remove orphaned dependencies
sudo yum autoremove
```

### YUM Repository Configuration

**Repository files:** `/etc/yum.repos.d/`

```bash
# List enabled repositories
yum repolist

# List all repositories (including disabled)
yum repolist all
```

**Add repository:**
```bash
# Example: Add EPEL (Extra Packages for Enterprise Linux)
sudo yum install epel-release
```

---

## DNF - RHEL/CentOS 8+, Fedora

### What is DNF?

**DNF (Dandified YUM)** is the next-generation package manager for Fedora and RHEL 8+. It's a drop-in replacement for YUM with better performance and improved dependency resolution.

### Basic DNF Commands

**Note:** DNF commands are nearly identical to YUM commands.

```bash
# Update package list
sudo dnf check-update

# Install package
sudo dnf install package_name

# Remove package
sudo dnf remove package_name

# Update all packages
sudo dnf update

# Search for packages
dnf search keyword

# Show package info
dnf info package_name

# List installed packages
dnf list installed

# Clean up
sudo dnf clean all
sudo dnf autoremove
```

### DNF vs YUM

**Key improvements in DNF:**
- Faster dependency resolution
- Better memory usage
- Cleaner, more consistent command output
- Strict dependency checking

**Compatibility:**
```bash
# On RHEL 8+, yum is aliased to dnf
which yum
# Output: /usr/bin/yum -> /usr/bin/dnf
```

---

## Package Dependencies

### What Are Dependencies?

**Dependencies** are other packages required for a package to work properly.

**Example:**
```bash
# Installing nginx might require
# - libc6 (standard C library)
# - libssl (SSL/TLS support)
# - zlib (compression)
# - etc.
```

**Package managers automatically resolve and install dependencies.**

### Viewing Dependencies

```bash
# APT (Debian/Ubuntu)
apt show package_name | grep Depends

# Example
apt show nginx | grep Depends

# YUM/DNF (RHEL/CentOS)
yum deplist package_name

# Example
yum deplist httpd
```

### Handling Broken Dependencies

**APT:**
```bash
# Fix broken dependencies
sudo apt --fix-broken install

# Or
sudo apt -f install

# Reconfigure packages
sudo dpkg --configure -a
```

**YUM/DNF:**
```bash
# Fix dependencies
sudo yum check
sudo yum deplist package_name
```

---

## Installing from Source

Sometimes packages aren't available in repositories, so you must compile from source.

### Prerequisites

**Install build tools:**

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install build-essential
# Includes: gcc, g++, make, etc.
```

**RHEL/CentOS:**
```bash
sudo yum groupinstall "Development Tools"
# Or
sudo dnf group install "Development Tools"
```

### Typical Build Process

```bash
# 1. Download source code
wget https://example.com/software-1.0.tar.gz

# 2. Extract archive
tar -xzf software-1.0.tar.gz
cd software-1.0

# 3. Read README and INSTALL files
less README
less INSTALL

# 4. Configure (check dependencies, set options)
./configure

# Common configure options:
# --prefix=/usr/local  (installation location)
# --help               (show all options)

# 5. Compile
make

# 6. Install
sudo make install

# 7. Clean up build files (optional)
make clean
```

### Example: Installing from Source

**Install `htop` from source:**
```bash
# Install dependencies
sudo apt install libncurses5-dev autotools-dev autoconf

# Download source
wget https://github.com/htop-dev/htop/releases/download/3.2.1/htop-3.2.1.tar.gz

# Extract
tar -xzf htop-3.2.1.tar.gz
cd htop-3.2.1

# Build and install
./configure
make
sudo make install

# Verify
htop --version
```

---

## Alternative Installation Methods

### Snap Packages

**Snap** is a universal package format that works across distributions.

```bash
# Install snapd
sudo apt install snapd  # Debian/Ubuntu
sudo dnf install snapd  # Fedora

# Search for snaps
snap find keyword

# Install snap
sudo snap install package_name

# Example: Install VS Code
sudo snap install code --classic

# List installed snaps
snap list

# Update snaps
sudo snap refresh

# Remove snap
sudo snap remove package_name
```

### Flatpak

**Flatpak** is another universal package format with sandboxed applications.

```bash
# Install Flatpak
sudo apt install flatpak  # Debian/Ubuntu
sudo dnf install flatpak  # Fedora

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Search for apps
flatpak search keyword

# Install application
flatpak install flathub application_id

# Example: Install GIMP
flatpak install flathub org.gimp.GIMP

# Run application
flatpak run org.gimp.GIMP

# Update apps
flatpak update

# Remove application
flatpak uninstall application_id
```

### AppImage

**AppImage** is a portable application format that doesn't require installation.

```bash
# Download AppImage
wget https://example.com/app.AppImage

# Make executable
chmod +x app.AppImage

# Run
./app.AppImage
```

### Manual Installation (Binary)

**Pre-compiled binaries:**
```bash
# Example: Install Go language
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz

# Extract to /usr/local
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz

# Add to PATH
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# Verify
go version
```

---

## Common Software Installation Examples

### Web Servers

**Install Apache:**
```bash
# Debian/Ubuntu
sudo apt install apache2

# RHEL/CentOS
sudo yum install httpd
sudo systemctl start httpd
sudo systemctl enable httpd
```

**Install Nginx:**
```bash
# Debian/Ubuntu
sudo apt install nginx

# RHEL/CentOS
sudo yum install nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

### Databases

**Install MySQL:**
```bash
# Debian/Ubuntu
sudo apt install mysql-server

# RHEL/CentOS
sudo yum install mysql-server
sudo systemctl start mysqld
sudo systemctl enable mysqld
```

**Install PostgreSQL:**
```bash
# Debian/Ubuntu
sudo apt install postgresql postgresql-contrib

# RHEL/CentOS
sudo yum install postgresql-server postgresql-contrib
sudo postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Development Tools

**Install Git:**
```bash
# Debian/Ubuntu
sudo apt install git

# RHEL/CentOS
sudo yum install git
```

**Install Python:**
```bash
# Python 3 (usually pre-installed)
sudo apt install python3 python3-pip  # Debian/Ubuntu
sudo yum install python3 python3-pip  # RHEL/CentOS

# Verify
python3 --version
pip3 --version
```

**Install Node.js:**
```bash
# Debian/Ubuntu (from NodeSource)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs

# RHEL/CentOS (from NodeSource)
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo yum install nodejs

# Verify
node --version
npm --version
```

**Install Docker:**
```bash
# Debian/Ubuntu
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# RHEL/CentOS
sudo yum install docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

---

## DevOps Tools

### Configuration Management

**Install Ansible:**
```bash
# Debian/Ubuntu
sudo apt install ansible

# RHEL/CentOS
sudo yum install epel-release
sudo yum install ansible

# Verify
ansible --version
```

**Install Terraform:**
```bash
# Add HashiCorp repository
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install
sudo apt update
sudo apt install terraform

# Verify
terraform --version
```

### Container Orchestration

**Install kubectl:**
```bash
# Debian/Ubuntu
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install kubectl

# Verify
kubectl version --client
```

### Monitoring

**Install Prometheus:**
```bash
# Download binary
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz

# Extract
tar -xzf prometheus-2.45.0.linux-amd64.tar.gz

# Move to /opt
sudo mv prometheus-2.45.0.linux-amd64 /opt/prometheus

# Create symlink
sudo ln -s /opt/prometheus/prometheus /usr/local/bin/

# Verify
prometheus --version
```

---

## Best Practices

### 1. Always Update Package Lists

```bash
# Before installing anything
sudo apt update && sudo apt install package
sudo yum check-update && sudo yum install package
```

### 2. Keep System Updated

```bash
# Regular updates
sudo apt update && sudo apt upgrade  # Debian/Ubuntu
sudo yum update                       # RHEL/CentOS

# Schedule automatic updates (Ubuntu)
sudo apt install unattended-upgrades
```

### 3. Use Official Repositories

**Priority:**
1. Official distribution repositories (highest trust)
2. Official application repositories (e.g., Docker, NodeSource)
3. Well-known third-party repositories (e.g., EPEL)
4. Snap/Flatpak from official stores
5. Manual compilation from source (lowest convenience)

### 4. Verify Package Authenticity

```bash
# APT verifies GPG signatures automatically
# Check repository keys
apt-key list

# YUM/DNF also verifies GPG signatures
yum repolist
```

### 5. Clean Up Regularly

```bash
# Remove unused packages
sudo apt autoremove
sudo yum autoremove

# Clear package cache
sudo apt clean
sudo yum clean all

# Check disk usage
du -sh /var/cache/apt/archives
du -sh /var/cache/yum
```

### 6. Document Installed Software

**Create an inventory:**
```bash
# List installed packages to file
dpkg -l > installed_packages.txt  # Debian/Ubuntu
rpm -qa > installed_packages.txt  # RHEL/CentOS

# Create requirements file (Python)
pip3 freeze > requirements.txt

# Docker images
docker images > docker_images.txt
```

---

## Troubleshooting

### Package Not Found

**Problem:** `E: Unable to locate package` or `No package available`

**Solutions:**
```bash
# Update package lists
sudo apt update

# Check spelling
apt search keyword

# Check if repository is enabled
sudo add-apt-repository universe  # Enable universe repo

# Add required repository
sudo add-apt-repository ppa:repository/name
```

### Dependency Issues

**Problem:** `The following packages have unmet dependencies`

**Solutions:**
```bash
# Fix broken dependencies
sudo apt --fix-broken install

# Force install (last resort)
sudo apt install -f
```

### Lock File Error

**Problem:** `Could not get lock /var/lib/dpkg/lock-frontend`

**Solution:**
```bash
# Wait for other package managers to finish, or

# Check what's using it
sudo lsof /var/lib/dpkg/lock-frontend

# If nothing, remove lock (careful!)
sudo rm /var/lib/dpkg/lock-frontend
sudo dpkg --configure -a
```

### Insufficient Disk Space

**Problem:** `No space left on device`

**Solutions:**
```bash
# Check disk usage
df -h

# Clean package cache
sudo apt clean
sudo apt autoremove

# Remove old kernels (Debian/Ubuntu)
sudo apt autoremove --purge
```

---

## Quick Reference

### APT (Debian/Ubuntu)

```bash
sudo apt update                    # Update package lists
sudo apt install package           # Install package
sudo apt remove package            # Remove package
sudo apt purge package             # Remove package + config
sudo apt upgrade                   # Update all packages
apt search keyword                 # Search packages
apt show package                   # Show package details
sudo apt autoremove                # Remove unused packages
sudo apt clean                     # Clean cache
```

### YUM/DNF (RHEL/CentOS)

```bash
sudo yum check-update              # Check for updates
sudo yum install package           # Install package
sudo yum remove package            # Remove package
sudo yum update                    # Update all packages
yum search keyword                 # Search packages
yum info package                   # Show package details
sudo yum autoremove                # Remove unused packages
sudo yum clean all                 # Clean cache
```

---

## Summary

**Key Concepts:**

1. **Package managers** - Automated software installation tools
2. **Repositories** - Centralized software sources
3. **Dependencies** - Required packages for software to function
4. **APT** - Debian/Ubuntu package manager
5. **YUM/DNF** - RHEL/CentOS package manager

**Installation Methods Priority:**

1. Official repository packages (safest, easiest)
2. Official PPAs/third-party repos
3. Snap/Flatpak (universal packages)
4. Pre-compiled binaries
5. Compile from source (most control, most complex)

**Best Practices:**

1. Always update package lists before installing
2. Keep system regularly updated
3. Use official repositories when possible
4. Clean up unused packages and cache
5. Document installed software
6. Verify package authenticity
7. Test in development before production

**Essential Commands to Remember:**

```bash
# Debian/Ubuntu
sudo apt update && sudo apt upgrade
sudo apt install package
sudo apt remove package

# RHEL/CentOS
sudo yum update
sudo yum install package
sudo yum remove package
```

---

**Master package management to efficiently maintain your Linux systems!**