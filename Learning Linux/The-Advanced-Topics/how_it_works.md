



# How Linux Works - Essential Concepts for DevOps

## Table of Contents

1. [Linux Boot Process](#linux-boot-process)
2. [BIOS vs UEFI](#bios-vs-uefi)
3. [Boot Sequence Explained](#boot-sequence-explained)
4. [Package Managers](#package-managers)
5. [How SSH Works](#how-ssh-works)
6. [DevOps Relevance](#devops-relevance)

---

## Linux Boot Process

Understanding how Linux boots is crucial for troubleshooting system issues, optimizing startup, and working with containerization and virtualization technologies.

### Overview of Boot Stages

```
Power On → POST → BIOS/UEFI → Bootloader (GRUB) → Kernel → initramfs → systemd → Login
```

**Timeline:**
1. **Hardware initialization** (BIOS/UEFI)
2. **Bootloader** loads kernel
3. **Kernel** initializes hardware
4. **initramfs** provides temporary filesystem
5. **systemd** starts services
6. **User space** becomes available

---

## BIOS vs UEFI

### What is BIOS?

**BIOS (Basic Input/Output System)**

**Purpose:**
- Firmware that initializes hardware during boot
- Tests hardware components
- Loads and transfers control to bootloader

**Characteristics:**
- ✅ Simple and well-understood
- ✅ Works with older hardware
- ❌ Limited to 2TB disk support (MBR)
- ❌ Slower boot times
- ❌ 16-bit processor mode
- ❌ No secure boot
- ❌ Limited to 4 primary partitions

**How BIOS Works:**
1. Power on
2. POST (Power-On Self-Test)
3. Reads first 512 bytes of disk (MBR - Master Boot Record)
4. MBR contains bootloader code
5. Bootloader loads operating system

### What is UEFI?

**UEFI (Unified Extensible Firmware Interface)**

**Purpose:**
- Modern replacement for BIOS
- More features and security
- Faster boot times
- Better hardware support

**Characteristics:**
- ✅ Supports disks larger than 2TB (GPT)
- ✅ Faster boot times
- ✅ 32-bit or 64-bit processor mode
- ✅ Secure Boot (prevents malware)
- ✅ Network boot support
- ✅ Mouse support in firmware
- ✅ Graphical interface
- ✅ Unlimited partitions (GPT)

**How UEFI Works:**
1. Power on
2. UEFI firmware initializes
3. Reads EFI System Partition (ESP)
4. ESP contains bootloader files (.efi)
5. Bootloader loads operating system

### BIOS vs UEFI Comparison

| Feature | BIOS | UEFI |
|---------|------|------|
| **Year Introduced** | 1970s | 2005 |
| **Interface** | Text-based | Graphical + Text |
| **Boot Time** | Slower | Faster |
| **Max Disk Size** | 2TB (MBR) | 9.4 ZB (GPT) |
| **Partitions** | 4 primary | Unlimited |
| **Processor Mode** | 16-bit | 32/64-bit |
| **Secure Boot** | No | Yes |
| **Network Boot** | Limited | Built-in |
| **Mouse Support** | No | Yes |
| **Extensibility** | Limited | Highly extensible |

### Check if Your System Uses BIOS or UEFI

**Method 1: Check for EFI directory**
```bash
# If this directory exists, you're using UEFI
ls /sys/firmware/efi

# If it doesn't exist, you're using BIOS
```

**Method 2: Check boot mode**
```bash
# UEFI systems will show output
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS"
```

**Method 3: Using efibootmgr (UEFI only)**
```bash
# This only works on UEFI systems
sudo efibootmgr -v
```

**Method 4: Check disk partition table**
```bash
# GPT = UEFI, MBR = BIOS (usually)
sudo fdisk -l

# Look for "Disklabel type: gpt" (UEFI) or "dos" (BIOS)
sudo parted -l
```

### Partition Schemes

**MBR (Master Boot Record) - BIOS**
- First 512 bytes of disk
- 4 primary partitions max (or 3 primary + 1 extended)
- 2TB disk size limit
- No redundancy (single point of failure)

**GPT (GUID Partition Table) - UEFI**
- Modern partitioning scheme
- Unlimited partitions (128 by default)
- Supports disks up to 9.4 ZB
- Stores partition data redundantly
- Includes CRC checksums for data integrity

---

## Boot Sequence Explained

### Stage 1: POST (Power-On Self-Test)

**What happens:**
- CPU initializes
- Firmware (BIOS/UEFI) loads
- Hardware components tested:
  - Memory (RAM)
  - CPU
  - Storage devices
  - Keyboard
  - Graphics card
  - Other peripherals

**What you see:**
- Manufacturer logo
- Memory count
- Beep codes (if errors)

**Duration:** 1-3 seconds

**Troubleshooting POST:**
- **No display:** Graphics card or cable issue
- **Beep codes:** Check motherboard manual
  - 1 beep: Normal (successful POST)
  - 2 beeps: Memory error
  - 3 beeps: Memory error
  - Long beeps: Memory not detected
- **POST hangs:** Disconnect peripherals one by one

---

### Stage 2: GRUB (Grand Unified Bootloader)

**What is GRUB?**
- Bootloader that loads the Linux kernel
- Allows choosing between multiple operating systems
- Can pass parameters to the kernel

**GRUB Versions:**
- **GRUB Legacy** (GRUB 1) - Old, rarely used
- **GRUB2** - Current version, more features

**What GRUB Does:**
1. Displays boot menu
2. Loads selected kernel into memory
3. Passes kernel parameters
4. Transfers control to kernel

**GRUB Configuration:**

**Main config file:**
```bash
# Ubuntu/Debian
/boot/grub/grub.cfg        # Generated, don't edit directly!
/etc/default/grub          # Edit this file

# RHEL/CentOS
/boot/grub2/grub.cfg       # Generated, don't edit directly!
/etc/default/grub          # Edit this file
```

**View GRUB config:**
```bash
cat /etc/default/grub
```

**Common settings:**
```bash
GRUB_TIMEOUT=5                    # Seconds to show menu
GRUB_DEFAULT=0                    # Default menu entry
GRUB_CMDLINE_LINUX="quiet"        # Kernel parameters
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
```

**Update GRUB after changes:**
```bash
# Debian/Ubuntu
sudo update-grub
# Or
sudo grub-mkconfig -o /boot/grub/grub.cfg

# RHEL/CentOS/AlmaLinux
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
# UEFI systems
sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
```

**Common GRUB Tasks:**

**Access GRUB menu:**
- Hold `Shift` during boot (BIOS)
- Press `Esc` during boot (UEFI)

**Boot into single-user mode (recovery):**
1. Select kernel in GRUB menu
2. Press `e` to edit
3. Find line starting with `linux`
4. Add `single` or `1` at end
5. Press `Ctrl+X` or `F10` to boot

**Disable quiet mode (see boot messages):**
1. Edit `/etc/default/grub`
2. Remove `quiet` from `GRUB_CMDLINE_LINUX_DEFAULT`
3. Run `sudo update-grub`

**GRUB files location:**
```bash
# Kernel images
ls /boot/vmlinuz-*

# Initial RAM disk
ls /boot/initrd.img-*
ls /boot/initramfs-*

# GRUB files
ls /boot/grub/
```

---

### Stage 3: Kernel

**What is the Kernel?**
- Core of the operating system
- Manages hardware resources
- Provides interface between hardware and software
- Handles processes, memory, devices, file systems

**Kernel Loading Process:**
1. GRUB loads kernel into RAM
2. Kernel decompresses itself
3. Kernel initializes hardware
4. Kernel mounts initramfs
5. Kernel executes /init from initramfs
6. Control transfers to init system (systemd)

**What Kernel Does:**
- **Hardware detection:** Recognizes CPU, RAM, devices
- **Device drivers:** Loads necessary drivers
- **Memory management:** Allocates RAM to processes
- **Process scheduling:** Manages CPU time for processes
- **File system mounting:** Prepares to access files

**Kernel Parameters:**

View current kernel:
```bash
uname -r
uname -a
```

View kernel command line:
```bash
cat /proc/cmdline
```

View kernel messages:
```bash
dmesg | less
dmesg | grep -i error
dmesg | grep -i fail
```

**Kernel files:**
```bash
# Kernel image
ls -lh /boot/vmlinuz-*

# Example: vmlinuz-5.15.0-56-generic
```

**Common Kernel Parameters:**
- `quiet` - Suppress boot messages
- `splash` - Show graphical splash screen
- `ro` - Mount root filesystem read-only initially
- `single` - Boot into single-user mode
- `init=/bin/bash` - Emergency shell access
- `nomodeset` - Disable graphics mode setting (troubleshooting)
- `acpi=off` - Disable ACPI (power management issues)

---

### Stage 4: initramfs (Initial RAM Filesystem)

**What is initramfs?**
- Temporary root filesystem loaded into RAM
- Contains essential drivers and tools
- Necessary to mount the real root filesystem

**Why initramfs is Needed:**
- Real root might be on:
  - RAID array
  - LVM volume
  - Encrypted partition
  - Network filesystem (NFS)
- Kernel needs drivers to access these
- initramfs contains those drivers

**What initramfs Contains:**
- Essential kernel modules (drivers)
- Basic binaries (busybox)
- Init script
- Libraries
- Device nodes

**Location:**
```bash
# Ubuntu/Debian
ls -lh /boot/initrd.img-*

# RHEL/CentOS/AlmaLinux
ls -lh /boot/initramfs-*
```

**View initramfs contents:**
```bash
# Ubuntu/Debian
lsinitramfs /boot/initrd.img-$(uname -r) | less

# RHEL/CentOS/AlmaLinux
lsinitrd /boot/initramfs-$(uname -r).img | less

# Extract initramfs (Ubuntu/Debian)
mkdir /tmp/initrd
cd /tmp/initrd
zcat /boot/initrd.img-$(uname -r) | cpio -idmv

# Extract initramfs (RHEL/CentOS)
mkdir /tmp/initramfs
cd /tmp/initramfs
/usr/lib/dracut/skipcpio /boot/initramfs-$(uname -r).img | zcat | cpio -idmv
```

**Regenerate initramfs:**
```bash
# Ubuntu/Debian (when you add/change modules)
sudo update-initramfs -u

# RHEL/CentOS/AlmaLinux
sudo dracut --force
```

**initramfs Process:**
1. Kernel loads initramfs into RAM
2. Kernel executes `/init` from initramfs
3. Init script loads necessary drivers
4. Init script discovers real root device
5. Init script mounts real root filesystem
6. Init script switches to real root (pivot_root)
7. Init script starts systemd on real root

---

### Stage 5: systemd (Init System)

**What is systemd?**
- System and service manager
- First process (PID 1) after kernel
- Manages all other processes
- Starts services in parallel (fast boot)

**systemd Responsibilities:**
- Start system services
- Mount filesystems
- Activate network
- Manage user sessions
- Handle system logging
- Schedule tasks
- Monitor processes

**systemd vs Traditional Init:**

| Feature | systemd | SysV Init |
|---------|---------|-----------|
| **PID** | 1 | 1 |
| **Boot Speed** | Fast (parallel) | Slow (sequential) |
| **Service Files** | Unit files | Init scripts |
| **Dependencies** | Automatic | Manual |
| **On-Demand Start** | Yes | No |
| **Logging** | journald (binary) | syslog (text) |
| **Cgroups** | Yes | No |

**systemd Units:**
- `service` - System services (daemons)
- `target` - Group of units (like runlevels)
- `mount` - Mount points
- `socket` - IPC sockets
- `timer` - Scheduled tasks (like cron)
- `device` - Device units
- `path` - File/directory monitoring

**Common systemd Commands:**
```bash
# Check systemd version
systemctl --version

# View boot time
systemd-analyze
systemd-analyze blame    # See what took longest

# View boot process
systemd-analyze plot > boot.svg    # Generate visual timeline

# List all units
systemctl list-units
systemctl list-unit-files

# Service management
systemctl status service-name
systemctl start service-name
systemctl stop service-name
systemctl restart service-name
systemctl enable service-name     # Start on boot
systemctl disable service-name    # Don't start on boot

# Check if service is running
systemctl is-active service-name
systemctl is-enabled service-name

# View service logs
journalctl -u service-name
journalctl -u service-name -f     # Follow logs
```

**systemd Targets (like runlevels):**
```bash
# Current target
systemctl get-default

# Available targets
systemctl list-units --type=target

# Change target
sudo systemctl isolate multi-user.target    # Text mode
sudo systemctl isolate graphical.target     # GUI mode

# Set default target
sudo systemctl set-default multi-user.target
sudo systemctl set-default graphical.target
```

**Common Targets:**
- `poweroff.target` - Shutdown
- `rescue.target` - Single-user mode
- `multi-user.target` - Multi-user, no GUI (like runlevel 3)
- `graphical.target` - Multi-user with GUI (like runlevel 5)
- `reboot.target` - Reboot

**systemd Boot Process:**
1. systemd starts as PID 1
2. Reads default target (usually graphical.target)
3. Activates all dependencies
4. Starts services in parallel
5. Mounts filesystems
6. Activates network
7. Starts login manager

**Service Files Location:**
```bash
# System services
/lib/systemd/system/
/usr/lib/systemd/system/

# User-modified services
/etc/systemd/system/

# View service file
systemctl cat service-name
```

**Example Service File:**
```ini
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/start.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

---

## Complete Boot Timeline

**Visual Boot Process:**

```
┌─────────────┐
│ Power Button│
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ POST (1-3 seconds)  │  ← Hardware check
│ BIOS/UEFI           │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ GRUB (1-5 seconds)  │  ← Bootloader
│ Load Kernel         │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Kernel (2-5 sec)    │  ← Hardware init
│ Load initramfs      │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ initramfs (1-3 sec) │  ← Load drivers
│ Mount root FS       │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ systemd (3-10 sec)  │  ← Start services
│ Start services      │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ Login Prompt        │  ← Ready!
└─────────────────────┘
```

**Total Boot Time: ~10-25 seconds** (modern systems with SSD)

**Check your boot time:**
```bash
systemd-analyze
systemd-analyze blame | head -20    # Top 20 slowest services
```

---

## Package Managers

### What is a Package Manager?

**Definition:**
A package manager is a tool that automates installing, updating, configuring, and removing software packages on Linux.

**Why Package Managers Matter:**
- ✅ **Dependency resolution** - Automatically installs required libraries
- ✅ **Version management** - Tracks installed versions
- ✅ **Security updates** - Easy system-wide updates
- ✅ **Consistency** - Same software across systems
- ✅ **Rollback** - Can downgrade if issues occur
- ✅ **Verification** - Checks package integrity (signatures)

**Without Package Manager:**
```bash
# Manual installation (painful!)
1. Find software website
2. Download source code
3. Install dependencies manually
4. Compile from source
5. Resolve compilation errors
6. Install to correct location
7. Configure manually
8. Track for updates yourself
```

**With Package Manager:**
```bash
# Automatic installation (easy!)
sudo apt install nginx
# Done! Dependencies, configuration, everything handled.
```

---

### Package Manager Types

**By Distribution:**

| Distribution | Package Format | Low-Level Tool | High-Level Tool |
|--------------|----------------|----------------|-----------------|
| **Debian/Ubuntu** | .deb | dpkg | apt, apt-get |
| **RHEL/CentOS/Fedora** | .rpm | rpm | yum, dnf |
| **Arch Linux** | .tar.xz | pacman | pacman |
| **OpenSUSE** | .rpm | rpm | zypper |
| **Alpine** | .apk | apk | apk |

**Universal Package Managers:**
- **snap** - Ubuntu's universal packages
- **flatpak** - Cross-distro app distribution
- **AppImage** - Self-contained applications

**Language-Specific:**
- **pip** - Python packages
- **npm** - Node.js packages
- **gem** - Ruby packages
- **cargo** - Rust packages
- **composer** - PHP packages
- **maven/gradle** - Java packages

---

### APT (Advanced Package Tool)

**What is APT?**
- High-level package manager for Debian/Ubuntu
- Frontend for dpkg
- Handles dependencies automatically
- Downloads from repositories

**APT vs APT-GET:**
- `apt` - Modern, user-friendly (use this!)
- `apt-get` - Traditional, script-friendly
- `apt` = simplified interface of `apt-get` + `apt-cache`

**Where Packages Come From:**

**Repository sources:** `/etc/apt/sources.list`

```bash
# View repositories
cat /etc/apt/sources.list
ls /etc/apt/sources.list.d/
```

**Example sources.list:**
```
deb http://archive.ubuntu.com/ubuntu jammy main restricted
deb http://archive.ubuntu.com/ubuntu jammy universe multiverse
deb http://security.ubuntu.com/ubuntu jammy-security main restricted
```

**Repository Components:**
- `main` - Officially supported open-source
- `restricted` - Proprietary drivers
- `universe` - Community-maintained
- `multiverse` - Restricted by copyright

---

### Essential APT Commands

**Update Package Lists:**
```bash
# Download latest package information
sudo apt update

# Always run this before installing/upgrading!
```

**Upgrade Packages:**
```bash
# Upgrade all packages
sudo apt upgrade

# Upgrade with package removal if needed
sudo apt full-upgrade

# Upgrade specific package
sudo apt install --only-upgrade package-name
```

**Install Packages:**
```bash
# Install single package
sudo apt install nginx

# Install multiple packages
sudo apt install nginx mysql-server php

# Install specific version
sudo apt install nginx=1.18.0-0ubuntu1

# Install without prompts (scripts)
sudo apt install -y nginx

# Reinstall package
sudo apt install --reinstall nginx
```

**Remove Packages:**
```bash
# Remove package (keep config files)
sudo apt remove nginx

# Remove package and config files
sudo apt purge nginx

# Remove package, config, and unused dependencies
sudo apt autoremove --purge nginx
```

**Search Packages:**
```bash
# Search in package names and descriptions
apt search keyword

# Search in package names only
apt search --names-only keyword

# Example
apt search web server
```

**Show Package Information:**
```bash
# Show package details
apt show nginx

# Show installed files
dpkg -L nginx

# Which package provides a file?
dpkg -S /usr/sbin/nginx
```

**List Packages:**
```bash
# List all available packages
apt list

# List installed packages
apt list --installed

# List upgradable packages
apt list --upgradable

# Check if specific package is installed
apt list nginx
```

**Clean Up:**
```bash
# Remove downloaded package files
sudo apt clean

# Remove old package versions
sudo apt autoclean

# Remove unused dependencies
sudo apt autoremove
```

**Fix Broken Dependencies:**
```bash
# Fix broken packages
sudo apt --fix-broken install
sudo dpkg --configure -a
```

---

### APT How It Works

**Installation Process:**
```
1. sudo apt update
   ↓
   Downloads package lists from repositories
   Updates local cache: /var/lib/apt/lists/

2. sudo apt install nginx
   ↓
   Checks dependencies
   ↓
   Downloads .deb package to: /var/cache/apt/archives/
   ↓
   Extracts package
   ↓
   Runs pre-install scripts
   ↓
   Copies files to system
   ↓
   Runs post-install scripts
   ↓
   Updates package database: /var/lib/dpkg/
   ↓
   Done!
```

**Important Directories:**
```bash
# Package cache
/var/cache/apt/archives/        # Downloaded .deb files

# Package lists
/var/lib/apt/lists/             # Repository package lists

# Package database
/var/lib/dpkg/                  # Installed package info
/var/lib/dpkg/status            # Package status database

# Configuration
/etc/apt/sources.list           # Repository sources
/etc/apt/sources.list.d/        # Additional sources
/etc/apt/preferences            # Package pinning
```

---

### YUM/DNF (RHEL/CentOS/Fedora)

**What is YUM/DNF?**
- **YUM** (Yellowdog Updater Modified) - Traditional
- **DNF** (Dandified YUM) - Modern replacement (faster)
- Frontend for RPM (Red Hat Package Manager)

**Common DNF/YUM Commands:**
```bash
# Update package lists
sudo dnf update        # or: sudo yum update

# Install package
sudo dnf install nginx

# Remove package
sudo dnf remove nginx

# Search packages
dnf search nginx

# Show package info
dnf info nginx

# List installed
dnf list installed

# List updates
dnf list updates

# Clean cache
sudo dnf clean all

# Remove unused
sudo dnf autoremove
```

**Configuration:**
```bash
# Repositories
/etc/yum.repos.d/

# View repos
dnf repolist
```

---

### Package Manager Comparison

**APT (Debian/Ubuntu):**
```bash
sudo apt update
sudo apt install package
sudo apt remove package
sudo apt search package
apt list --installed
```

**DNF/YUM (RHEL/CentOS/Fedora):**
```bash
sudo dnf update
sudo dnf install package
sudo dnf remove package
dnf search package
dnf list installed
```

**Pacman (Arch):**
```bash
sudo pacman -Syu
sudo pacman -S package
sudo pacman -R package
pacman -Ss package
pacman -Q
```

---

## How SSH Works

### What is SSH?

**SSH (Secure Shell)**
- Protocol for secure remote access
- Encrypted communication
- Replaces insecure telnet, rlogin
- Port 22 (default)

**Uses:**
- Remote server administration
- Secure file transfer (SCP, SFTP)
- Port forwarding / tunneling
- Running remote commands
- Git operations
- DevOps automation

---

### SSH Components

**Client-Server Model:**
```
┌──────────────┐                    ┌──────────────┐
│  SSH Client  │ ←──encrypted────→  │  SSH Server  │
│ (your laptop)│     connection     │ (remote host)│
└──────────────┘                    └──────────────┘
```

**SSH Client:**
- Installed on your computer
- Examples: `ssh`, PuTTY, Terminal
- Initiates connection

**SSH Server:**
- Runs on remote machine
- Daemon: `sshd`
- Listens on port 22
- Authenticates users

---

### SSH Connection Process

**Step-by-Step:**

```
1. Client connects to server on port 22
   ssh user@hostname

2. Server sends its public key
   (Host key verification)

3. Client verifies server identity
   "The authenticity of host can't be established..."
   → If accepted, fingerprint saved to ~/.ssh/known_hosts

4. Encrypted channel established
   (Using symmetric encryption)

5. Client authentication
   → Password authentication, OR
   → Public key authentication

6. Authenticated session starts
   → You get a shell prompt!
```

---

### SSH Authentication Methods

**1. Password Authentication**
```bash
ssh user@hostname
# Prompts for password
```

**Pros:**
- ✅ Simple
- ✅ No setup needed

**Cons:**
- ❌ Less secure
- ❌ Vulnerable to brute force
- ❌ Not good for automation

---

**2. Public Key Authentication (Recommended)**

**Concept:**
- You have a key pair:
  - **Private key** - Keep secret (never share!)
  - **Public key** - Can share freely
- Private key stays on your computer
- Public key goes on server
- Math magic proves you have private key (without transmitting it!)

**Generate SSH Keys:**
```bash
# Generate RSA key (4096-bit, more secure)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Or Ed25519 (modern, faster, more secure)
ssh-keygen -t ed25519 -C "your_email@example.com"

# You'll be asked:
# 1. Where to save (default: ~/.ssh/id_rsa or ~/.ssh/id_ed25519)
# 2. Passphrase (optional but recommended)
```

**Key Files Created:**
```bash
~/.ssh/id_rsa           # Private key (KEEP SECRET!)
~/.ssh/id_rsa.pub       # Public key (share this)

# Or for Ed25519:
~/.ssh/id_ed25519       # Private key
~/.ssh/id_ed25519.pub   # Public key
```

**Copy Public Key to Server:**
```bash
# Method 1: ssh-copy-id (easiest)
ssh-copy-id user@hostname

# Method 2: Manual
cat ~/.ssh/id_rsa.pub | ssh user@hostname "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Method 3: Copy-paste
cat ~/.ssh/id_rsa.pub
# Copy output, then on server:
nano ~/.ssh/authorized_keys
# Paste and save
```

**Connect with Key:**
```bash
# Now you can connect without password!
ssh user@hostname

# Specify key manually
ssh -i ~/.ssh/id_rsa user@hostname
```

**SSH Directory Permissions (Important!):**
```bash
# On server
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# On client
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 644 ~/.ssh/known_hosts
```

---

### SSH Configuration

**Client Config:** `~/.ssh/config`

**Example config:**
```bash
# General defaults
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Specific host
Host myserver
    HostName 192.168.1.100
    User admin
    Port 22
    IdentityFile ~/.ssh/id_rsa

# Another host with custom port
Host webserver
    HostName example.com
    User webadmin
    Port 2222
    IdentityFile ~/.ssh/web_key

# Using jump host
Host internal-server
    HostName 10.0.0.50
    User admin
    ProxyJump jumphost.example.com
```

**Now you can connect simply:**
```bash
ssh myserver        # Instead of: ssh admin@192.168.1.100
ssh webserver       # Automatically uses port 2222 and web_key
```

**Server Config:** `/etc/ssh/sshd_config`

**Important settings:**
```bash
# Port
Port 22

# Disable root login (security!)
PermitRootLogin no

# Disable password auth (force keys)
PasswordAuthentication no

# Allow public key auth
PubkeyAuthentication yes

# Authorized keys location
AuthorizedKeysFile .ssh/authorized_keys

# Disable empty passwords
PermitEmptyPasswords no

# Login grace time
LoginGraceTime 1m

# Max auth attempts
MaxAuthTries 3

# Allowed users
AllowUsers user1 user2
```

**Restart SSH after config changes:**
```bash
# Ubuntu/Debian
sudo systemctl restart ssh

# RHEL/CentOS/AlmaLinux
sudo systemctl restart sshd
```

---

### Common SSH Commands

**Basic Connection:**
```bash
# Connect as current user
ssh hostname

# Connect as specific user
ssh user@hostname

# Connect with specific port
ssh -p 2222 user@hostname

# Verbose output (debugging)
ssh -v user@hostname
ssh -vv user@hostname    # More verbose
ssh -vvv user@hostname   # Very verbose
```

**Execute Remote Commands:**
```bash
# Run command and return
ssh user@hostname 'uptime'
ssh user@hostname 'df -h'

# Multiple commands
ssh user@hostname 'cd /var/log && ls -l'

# With sudo
ssh user@hostname 'sudo systemctl status nginx'
```

**File Transfer (SCP):**
```bash
# Copy TO remote
scp file.txt user@hostname:/path/

# Copy FROM remote
scp user@hostname:/path/file.txt ./

# Copy directory
scp -r directory/ user@hostname:/path/

# Multiple files
scp file1 file2 user@hostname:/path/
```

**Port Forwarding:**
```bash
# Local port forwarding
# Access remote service locally
ssh -L 8080:localhost:80 user@hostname
# Now: localhost:8080 → remote:80

# Remote port forwarding
# Expose local service to remote
ssh -R 8080:localhost:3000 user@hostname
# Now: remote:8080 → local:3000

# Dynamic port forwarding (SOCKS proxy)
ssh -D 8080 user@hostname
# Use localhost:8080 as SOCKS proxy
```

**SSH Tunneling:**
```bash
# Access database through jump host
ssh -L 3306:db-server:3306 jump-host

# Now connect locally:
mysql -h 127.0.0.1 -P 3306
```

**Keep SSH Session Alive:**
```bash
# In ~/.ssh/config
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3

# Or on command line
ssh -o ServerAliveInterval=60 user@hostname
```

**SSH Agent (Manage Keys):**
```bash
# Start agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_rsa

# List loaded keys
ssh-add -l

# Remove all keys
ssh-add -D
```

---

### SSH Security Best Practices

**1. Use SSH Keys (Not Passwords)**
```bash
# Generate strong key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Disable password auth in /etc/ssh/sshd_config
PasswordAuthentication no
```

**2. Change Default Port**
```bash
# In /etc/ssh/sshd_config
Port 2222    # Use non-standard port
```

**3. Disable Root Login**
```bash
# In /etc/ssh/sshd_config
PermitRootLogin no
```

**4. Use Fail2ban**
```bash
# Install
sudo apt install fail2ban

# Automatically bans IPs after failed attempts
```

**5. Limit User Access**
```bash
# In /etc/ssh/sshd_config
AllowUsers user1 user2
# Or
AllowGroups sshusers
```

**6. Use Two-Factor Authentication**
```bash
# Install Google Authenticator
sudo apt install libpam-google-authenticator

# Configure PAM for 2FA
```

**7. Keep Software Updated**
```bash
sudo apt update
sudo apt upgrade openssh-server
```

**8. Monitor SSH Logs**
```bash
# View SSH attempts
sudo journalctl -u ssh
sudo tail -f /var/log/auth.log    # Debian/Ubuntu
sudo tail -f /var/log/secure      # RHEL/CentOS
```

**9. Use SSH Certificate Authorities**
- For large organizations
- Centralized key management

**10. Firewall Rules**
```bash
# Allow SSH only from specific IPs
sudo ufw allow from 192.168.1.0/24 to any port 22
```

---

### Troubleshooting SSH

**Connection refused:**
```bash
# Check if SSH server is running
sudo systemctl status sshd

# Check if port is listening
sudo ss -tlnp | grep :22

# Check firewall
sudo ufw status
sudo iptables -L -n | grep 22
```

**Permission denied:**
```bash
# Check file permissions
ls -la ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# On server
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

**Host key verification failed:**
```bash
# Remove old host key
ssh-keygen -R hostname

# Or edit known_hosts
nano ~/.ssh/known_hosts
```

**Verbose debugging:**
```bash
ssh -vvv user@hostname
```

---

## DevOps Relevance

### Why These Concepts Matter in DevOps

**1. Boot Process Knowledge**

**Use Cases:**
- **Container initialization** - Understanding init processes in containers
- **VM deployment** - Configuring cloud instances to boot correctly
- **Troubleshooting** - Debug boot failures in production
- **Automation** - Configure systems to boot with correct settings
- **Security** - Implement secure boot, disk encryption

**Examples:**
```bash
# Kubernetes init containers (similar to initramfs)
initContainers:
  - name: init-myservice
    image: busybox
    command: ['sh', '-c', 'until nslookup myservice; do sleep 2; done;']

# Cloud-init (boot-time configuration)
# Configure server on first boot
#cloud-config
packages:
  - nginx
  - docker
runcmd:
  - systemctl enable nginx
```

---

**2. systemd in DevOps**

**Service Management:**
```bash
# Deploy application as systemd service
sudo systemctl enable myapp.service
sudo systemctl start myapp.service

# Automatic restart on failure
[Service]
Restart=on-failure
RestartSec=5s
```

**Container Management:**
```bash
# Podman generates systemd units
podman generate systemd container_name

# Start containers on boot
systemctl enable container-myapp.service
```

**Timers (Cron alternative):**
```bash
# Run backups with systemd timers
sudo systemctl enable backup.timer
sudo systemctl start backup.timer
```

---

**3. Package Managers in DevOps**

**Infrastructure as Code:**
```yaml
# Ansible playbook
- name: Install web server
  apt:
    name:
      - nginx
      - certbot
      - python3-certbot-nginx
    state: present
    update_cache: yes
```

**Container Images:**
```dockerfile
# Dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    && rm -rf /var/lib/apt/lists/*
```

**CI/CD Pipelines:**
```bash
# Install dependencies in pipeline
- name: Install dependencies
  run: |
    sudo apt-get update
    sudo apt-get install -y build-essential
```

**Configuration Management:**
```ruby
# Puppet manifest
package { 'nginx':
  ensure => 'installed',
}
```

**Package Repositories:**
```bash
# Host internal package repository
# For consistent deployments across infrastructure
```

---

**4. SSH in DevOps**

**Critical Uses:**
- **Server access** - Remote administration
- **Deployment** - Push code to servers
- **Automation** - Ansible, scripts
- **Git operations** - Clone, push, pull
- **Tunneling** - Secure connections
- **CI/CD** - Pipeline access to servers

**Ansible via SSH:**
```yaml
# Ansible inventory
[webservers]
web1 ansible_host=192.168.1.10 ansible_user=admin
web2 ansible_host=192.168.1.11 ansible_user=admin

[webservers:vars]
ansible_ssh_private_key_file=~/.ssh/deploy_key
```

**CI/CD Deployment:**
```yaml
# GitLab CI
deploy:
  script:
    - ssh-add <(echo "$SSH_PRIVATE_KEY")
    - ssh user@server 'cd /app && git pull && docker-compose up -d'
```

**SSH for Git:**
```bash
# Clone private repo
git clone git@github.com:company/repo.git

# Configure SSH for GitHub
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_key
```

**Bastion/Jump Hosts:**
```bash
# Access internal servers through jump host
Host internal-*
  ProxyJump bastion.example.com
  User admin

# Connect to internal server
ssh internal-server1
```

**SSH in Docker:**
```dockerfile
# Add SSH key to container
FROM ubuntu:22.04
RUN mkdir -p ~/.ssh && chmod 700 ~/.ssh
COPY id_rsa ~/.ssh/id_rsa
RUN chmod 600 ~/.ssh/id_rsa
```

**Remote Command Execution:**
```bash
# Restart services on multiple servers
for server in web{1..5}; do
  ssh admin@$server 'sudo systemctl restart nginx'
done

# Parallel execution with GNU parallel
parallel ssh {} 'sudo apt update' ::: web{1..5}
```

---

### DevOps Workflow Example

**Complete Deployment Scenario:**

```bash
# 1. Developer pushes code
git push origin main

# 2. CI/CD pipeline triggered (GitHub Actions)
name: Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      # 3. Install dependencies (package manager)
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y rsync

      # 4. SSH to server (key-based auth)
      - name: Deploy to server
        run: |
          echo "$SSH_PRIVATE_KEY" > key
          chmod 600 key
          ssh -i key user@server << 'EOF'
            cd /app
            git pull
            # 5. systemd restart service
            sudo systemctl restart myapp
          EOF
```

**Infrastructure Automation:**
```bash
# Terraform provisions server
# Cloud-init configures boot
# Ansible installs packages
# systemd manages services
# SSH provides access
# All working together!
```

---

### DevOps Skills Summary

**Must Know:**

1. **Boot Process**
   - Troubleshoot boot issues
   - Configure GRUB for recovery
   - Understand systemd units
   - Use cloud-init

2. **systemd**
   - Create service units
   - Manage dependencies
   - Configure automatic restart
   - Use timers
   - Check service logs

3. **Package Managers**
   - Install/update packages
   - Manage repositories
   - Create custom packages
   - Use in automation
   - Handle dependencies

4. **SSH**
   - Key-based authentication
   - SSH config files
   - Port forwarding
   - Jump hosts
   - Secure configuration
   - Automation with SSH

**Real-World Applications:**
- Deploy applications
- Configure servers
- Automate tasks
- Monitor systems
- Troubleshoot issues
- Secure infrastructure
- Scale infrastructure
- Maintain consistency

---

## Quick Reference

### Boot Sequence
```
Power → POST → BIOS/UEFI → GRUB → Kernel → initramfs → systemd → Login
```

### systemd Commands
```bash
systemctl status service-name
systemctl start|stop|restart service-name
systemctl enable|disable service-name
journalctl -u service-name
systemd-analyze blame
```

### Package Manager (APT)
```bash
sudo apt update
sudo apt upgrade
sudo apt install package
sudo apt remove package
apt search package
apt show package
```

### SSH Essentials
```bash
# Generate key
ssh-keygen -t ed25519

# Copy key to server
ssh-copy-id user@host

# Connect
ssh user@host

# Config file
~/.ssh/config
```

---

## Summary

**Key Takeaways:**

1. **Boot Process** - Know the stages for troubleshooting and optimization
2. **BIOS vs UEFI** - Modern UEFI offers better features and security
3. **systemd** - Manages services, faster than old init systems
4. **Package Managers** - Essential for software management and automation
5. **SSH** - Secure remote access, critical for DevOps
6. **DevOps Integration** - All concepts interconnected in daily DevOps work

**For DevOps Success:**
- Master systemd service management
- Automate with package managers
- Secure SSH properly
- Understand boot process for troubleshooting
- Use these skills in CI/CD pipelines
- Apply to container and cloud environments

---

**These fundamentals are the foundation of DevOps engineering!**