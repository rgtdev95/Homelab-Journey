# Linux Filesystems and Storage Management Guide

## Introduction

Understanding filesystems and storage is fundamental for Linux administration and DevOps. Whether you're managing local disks, configuring network shares, or working with container storage, mastering these concepts is essential.

**What you'll learn:**
- Linux filesystem types and concepts
- Mounting and unmounting filesystems
- Network filesystems (NFS, SMB/CIFS, SSHFS)
- Disk partitioning and management
- LVM (Logical Volume Manager)
- Storage in DevOps environments

---

## Table of Contents

1. [Filesystem Basics](#filesystem-basics)
2. [Common Linux Filesystems](#common-linux-filesystems)
3. [Mounting and Unmounting](#mounting-and-unmounting)
4. [The /etc/fstab File](#the-etcfstab-file)
5. [Disk Management](#disk-management)
6. [Network Filesystems](#network-filesystems)
7. [LVM (Logical Volume Manager)](#lvm-logical-volume-manager)
8. [Advanced Topics](#advanced-topics)
9. [DevOps Applications](#devops-applications)

---

## Filesystem Basics

### What is a Filesystem?

**Definition:**
A filesystem is a method of organizing and storing files on a storage device. It defines how data is stored, organized, and retrieved.

**Key Concepts:**

**Files and Directories:**
- Everything in Linux is a file
- Directories are special files containing other files
- Single root directory (`/`) - all filesystems mount under it

**Inodes:**
- Data structure storing file metadata
- Contains: permissions, ownership, timestamps, size, pointers to data blocks
- Each file has one inode
- Inode number uniquely identifies a file

**Blocks:**
- Fixed-size chunks where actual data is stored
- Typical size: 4KB
- Files use one or more blocks

**Superblock:**
- Metadata about the filesystem itself
- Size, free space, mount status
- Critical for filesystem operation

### View Filesystem Information

**Check mounted filesystems:**
```bash
# Modern way
findmnt

# Traditional way
mount

# Show only specific type
mount -t ext4
```

**Filesystem disk usage:**
```bash
# Human-readable format
df -h

# Show inodes
df -i

# Specific filesystem
df -h /home

# Show filesystem type
df -T
```

**Directory disk usage:**
```bash
# Current directory
du -sh

# All subdirectories
du -h

# Top level only
du -h --max-depth=1

# Largest directories first
du -h | sort -hr | head -10
```

**Block device information:**
```bash
# List all block devices
lsblk

# With filesystem info
lsblk -f

# Show UUIDs
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,UUID

# Block device attributes
sudo blkid
```

---

## Common Linux Filesystems

### Filesystem Types Overview

| Filesystem | Type | Use Case | Pros | Cons |
|------------|------|----------|------|------|
| **ext4** | Journaling | General purpose | Stable, mature, widely supported | Not the newest features |
| **XFS** | Journaling | Large files, high performance | Excellent for large files, scalable | Can't shrink |
| **Btrfs** | Copy-on-write | Modern features | Snapshots, compression, RAID | Less mature |
| **ZFS** | Copy-on-write | Enterprise storage | Data integrity, snapshots, RAID | Not in mainline kernel |
| **NTFS** | Windows | Windows compatibility | Windows interop | License issues on Linux |
| **FAT32** | Simple | USB drives, compatibility | Universal compatibility | 4GB file size limit |
| **exFAT** | Simple | Large USB drives | No size limits, compatible | Fewer features |
| **tmpfs** | RAM-based | Temporary files | Very fast | Lost on reboot |
| **NFS** | Network | Network shares | Unix/Linux native | Network dependent |
| **CIFS/SMB** | Network | Windows shares | Windows compatibility | Complex setup |

---

### ext4 (Fourth Extended Filesystem)

**Most common Linux filesystem**

**Features:**
- ✅ Journaling (crash recovery)
- ✅ Large file support (up to 16TB)
- ✅ Large filesystem support (up to 1EB)
- ✅ Extent-based allocation
- ✅ Delayed allocation
- ✅ Fast fsck
- ✅ Backward compatible with ext3/ext2

**When to use:**
- General purpose Linux systems
- Boot partitions
- When you need stability
- Most desktop/server installations

**Create ext4 filesystem:**
```bash
sudo mkfs.ext4 /dev/sdb1

# With label
sudo mkfs.ext4 -L MyData /dev/sdb1
```

---

### XFS

**High-performance filesystem**

**Features:**
- ✅ Excellent for large files
- ✅ High throughput
- ✅ Online defragmentation
- ✅ Scalable to very large sizes
- ✅ Fast allocation
- ❌ Cannot shrink (only grow)

**When to use:**
- Large files (video, databases)
- High I/O workloads
- RHEL/CentOS default filesystem
- Enterprise storage

**Create XFS filesystem:**
```bash
sudo mkfs.xfs /dev/sdb1

# With label
sudo mkfs.xfs -L MyData /dev/sdb1
```

---

### Btrfs (B-tree Filesystem)

**Modern copy-on-write filesystem**

**Features:**
- ✅ Built-in snapshots
- ✅ Transparent compression
- ✅ Built-in RAID support
- ✅ Online defragmentation
- ✅ Subvolumes
- ✅ Data integrity checking
- ⚠️ Less mature than ext4/XFS

**When to use:**
- Need snapshots
- Want compression
- Desktop systems
- Development environments
- When experimenting with modern features

**Create Btrfs filesystem:**
```bash
sudo mkfs.btrfs /dev/sdb1

# With label
sudo mkfs.btrfs -L MyData /dev/sdb1

# RAID1 across two disks
sudo mkfs.btrfs -d raid1 -m raid1 /dev/sdb1 /dev/sdc1
```

---

### tmpfs (Temporary Filesystem)

**RAM-based filesystem**

**Features:**
- ✅ Very fast (RAM speed)
- ✅ Automatically grows/shrinks
- ✅ Data lost on reboot
- ✅ Perfect for temporary files

**Common mounts:**
```bash
# Already mounted by default
/dev/shm          # Shared memory
/run              # Runtime data
/tmp              # Temporary files (optional)
```

**Create tmpfs mount:**
```bash
# Mount 1GB tmpfs
sudo mount -t tmpfs -o size=1G tmpfs /mnt/ramdisk

# In /etc/fstab
tmpfs  /mnt/ramdisk  tmpfs  size=1G,mode=1777  0  0
```

**Use cases:**
- Build directories (faster compilation)
- Temporary file processing
- Cache directories
- Development work
- Containers (Docker uses tmpfs)

---

## Mounting and Unmounting

### Understanding Mount Points

**Mount point:**
- An empty directory where a filesystem is attached
- After mounting, the directory contains the filesystem's contents
- Original directory contents hidden until unmounted

**Example:**
```bash
# Before mount
ls /mnt/data
# (empty directory)

# After mounting USB drive
sudo mount /dev/sdb1 /mnt/data
ls /mnt/data
# (shows USB drive contents)
```

---

### The mount Command

**Basic syntax:**
```bash
sudo mount [options] device mount_point
```

**Mount by device:**
```bash
# Mount /dev/sdb1 to /mnt/usb
sudo mount /dev/sdb1 /mnt/usb
```

**Mount by UUID (recommended):**
```bash
# Find UUID
sudo blkid /dev/sdb1

# Mount by UUID
sudo mount UUID=1234-5678 /mnt/usb
```

**Mount by label:**
```bash
# Mount filesystem with label "MyUSB"
sudo mount LABEL=MyUSB /mnt/usb
```

**Mount with options:**
```bash
# Read-only
sudo mount -o ro /dev/sdb1 /mnt/usb

# Read-write
sudo mount -o rw /dev/sdb1 /mnt/usb

# No execute permissions
sudo mount -o noexec /dev/sdb1 /mnt/usb

# Multiple options
sudo mount -o ro,noexec,nosuid /dev/sdb1 /mnt/usb
```

**Mount specific filesystem type:**
```bash
# Mount NTFS
sudo mount -t ntfs-3g /dev/sdb1 /mnt/windows

# Mount FAT32
sudo mount -t vfat /dev/sdb1 /mnt/usb

# Mount ISO image
sudo mount -o loop disk.iso /mnt/iso
```

---

### Common Mount Options

| Option | Description | Use Case |
|--------|-------------|----------|
| `rw` | Read-write (default) | Normal operation |
| `ro` | Read-only | Protect from changes |
| `noexec` | Prevent execution | Security (USB drives) |
| `nosuid` | Ignore SUID bits | Security |
| `nodev` | Ignore device files | Security |
| `auto` | Mount at boot | Normal filesystems |
| `noauto` | Don't mount at boot | Removable media |
| `user` | Allow users to mount | USB drives |
| `nouser` | Only root can mount | System filesystems |
| `defaults` | rw,suid,dev,exec,auto,nouser,async | Standard options |
| `sync` | Synchronous I/O | Ensure data written immediately |
| `async` | Asynchronous I/O (default) | Better performance |
| `relatime` | Update access time | Performance |
| `nofail` | Don't fail boot if missing | Network filesystems |

---

### View Mounted Filesystems

**All mounts:**
```bash
# Detailed view
mount

# Tree view
findmnt

# Only show specific types
mount -t ext4
findmnt -t ext4

# Specific mount point
findmnt /home
```

**Disk usage:**
```bash
# All filesystems
df -h

# Human-readable, filesystem type
df -hT

# Exclude types (tmpfs, devtmpfs)
df -h -x tmpfs -x devtmpfs

# Specific mount point
df -h /home
```

**Mount options for mounted filesystem:**
```bash
# Show mount options
mount | grep /dev/sdb1
findmnt /mnt/usb
```

---

### The umount Command

**Unmount filesystem:**
```bash
# By mount point
sudo umount /mnt/usb

# By device
sudo umount /dev/sdb1
```

**Force unmount:**
```bash
# If filesystem busy
sudo umount -f /mnt/usb

# Lazy unmount (detach now, cleanup later)
sudo umount -l /mnt/usb
```

**Check what's using filesystem:**
```bash
# See which processes using mount point
sudo lsof /mnt/usb

# See which processes using device
sudo fuser -m /dev/sdb1

# Kill processes using mount point
sudo fuser -km /mnt/usb
```

**Safe unmount procedure:**
```bash
# 1. Check if busy
lsof /mnt/usb

# 2. Kill processes if needed
sudo fuser -k /mnt/usb

# 3. Unmount
sudo umount /mnt/usb

# 4. Verify
mount | grep /mnt/usb
```

---

### Remounting

**Remount with different options:**
```bash
# Remount read-only (useful for maintenance)
sudo mount -o remount,ro /mnt/data

# Remount read-write
sudo mount -o remount,rw /mnt/data

# Add options to existing mount
sudo mount -o remount,noexec /mnt/data
```

---

## The /etc/fstab File

### What is /etc/fstab?

**Purpose:**
- Configuration file for automatic mounting
- Defines which filesystems mount at boot
- Specifies mount options

**Format:**
```
device  mount_point  filesystem_type  options  dump  pass
```

### Understanding /etc/fstab Fields

**Field 1: Device**
- `/dev/sdb1` - Device name (not recommended, can change)
- `UUID=xxxx` - UUID (recommended)
- `LABEL=name` - Filesystem label
- `//server/share` - Network share

**Field 2: Mount Point**
- Directory where filesystem mounts
- Must exist before mounting
- Example: `/mnt/data`, `/home`

**Field 3: Filesystem Type**
- `ext4`, `xfs`, `btrfs`, `ntfs`, `vfat`
- `nfs`, `cifs`
- `swap`
- `tmpfs`

**Field 4: Options**
- Mount options (comma-separated)
- `defaults` - standard options
- See mount options table above

**Field 5: Dump**
- `0` - Don't backup (most common)
- `1` - Backup with dump command

**Field 6: Pass (fsck order)**
- `0` - Don't check
- `1` - Check first (root filesystem)
- `2` - Check after root

---

### Example /etc/fstab

```bash
# Root filesystem
UUID=abc123  /  ext4  defaults  0  1

# Home partition
UUID=def456  /home  ext4  defaults  0  2

# Swap
UUID=ghi789  none  swap  sw  0  0

# Data drive (XFS)
UUID=jkl012  /mnt/data  xfs  defaults,noatime  0  2

# USB drive (don't mount at boot)
UUID=mno345  /mnt/usb  ext4  defaults,noauto  0  0

# Temporary filesystem (RAM)
tmpfs  /mnt/ramdisk  tmpfs  size=1G,mode=1777  0  0

# Network share (NFS)
server:/export  /mnt/nfs  nfs  defaults,_netdev,nofail  0  0

# Windows share (CIFS)
//server/share  /mnt/windows  cifs  credentials=/root/.smbcreds,uid=1000,gid=1000  0  0

# ISO image
/home/user/disk.iso  /mnt/iso  iso9660  loop,ro,noauto  0  0
```

---

### Working with /etc/fstab

**View current fstab:**
```bash
cat /etc/fstab
```

**Backup before editing:**
```bash
sudo cp /etc/fstab /etc/fstab.backup
```

**Edit fstab:**
```bash
sudo nano /etc/fstab
```

**Get UUID of device:**
```bash
# Show all UUIDs
sudo blkid

# Specific device
sudo blkid /dev/sdb1

# Formatted output
lsblk -f
```

**Test fstab without rebooting:**
```bash
# Mount all entries in fstab
sudo mount -a

# Check for errors
echo $?    # 0 = success

# Unmount all
sudo umount -a
```

**Mount specific fstab entry:**
```bash
# If device in fstab, just specify mount point
sudo mount /mnt/data
```

**Common fstab errors:**
```bash
# Syntax error - system won't boot!
# Always backup and test!

# If system doesn't boot:
# 1. Boot into recovery mode
# 2. Remount root read-write:
mount -o remount,rw /
# 3. Fix /etc/fstab
nano /etc/fstab
# 4. Reboot
```

---

### Add New Filesystem to /etc/fstab

**Step-by-step:**

```bash
# 1. Create mount point
sudo mkdir -p /mnt/data

# 2. Get device UUID
sudo blkid /dev/sdb1
# Output: /dev/sdb1: UUID="abc-123-def-456" TYPE="ext4"

# 3. Add to /etc/fstab
sudo nano /etc/fstab

# Add line:
UUID=abc-123-def-456  /mnt/data  ext4  defaults  0  2

# 4. Test without rebooting
sudo mount -a

# 5. Verify
df -h /mnt/data
findmnt /mnt/data

# 6. Reboot to test boot-time mounting
sudo reboot
```

---

## Disk Management

### List Block Devices

**lsblk - List block devices:**
```bash
# Basic listing
lsblk

# With filesystem info
lsblk -f

# Custom columns
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,UUID

# Include empty devices
lsblk -a
```

**Example output:**
```
NAME   SIZE TYPE MOUNTPOINT
sda    500G disk
├─sda1   1G part /boot
├─sda2  16G part [SWAP]
└─sda3 483G part /
sdb    1TB  disk
└─sdb1  1TB part /mnt/data
```

**blkid - Block device attributes:**
```bash
# All devices
sudo blkid

# Specific device
sudo blkid /dev/sdb1

# Output UUIDs only
sudo blkid -s UUID -o value /dev/sdb1
```

**fdisk - List partitions:**
```bash
# List all disks
sudo fdisk -l

# Specific disk
sudo fdisk -l /dev/sdb
```

---

### Partitioning Disks

**⚠️ WARNING: Partitioning destroys data! Backup first!**

#### Using fdisk (MBR and GPT)

**Interactive mode:**
```bash
sudo fdisk /dev/sdb
```

**Common fdisk commands:**
- `p` - Print partition table
- `n` - Create new partition
- `d` - Delete partition
- `t` - Change partition type
- `w` - Write changes and exit
- `q` - Quit without saving
- `m` - Help

**Example - Create single partition:**
```bash
sudo fdisk /dev/sdb

# Inside fdisk:
Command (m for help): n              # New partition
Partition type: p                     # Primary
Partition number: 1                   # First partition
First sector: (press Enter)           # Default (start)
Last sector: (press Enter)            # Default (use all space)
Command (m for help): w               # Write and exit
```

**Example - Create multiple partitions:**
```bash
sudo fdisk /dev/sdb

# Create 100GB partition:
Command: n
Partition type: p
Partition number: 1
First sector: (Enter)
Last sector: +100G

# Create second partition with remaining space:
Command: n
Partition type: p
Partition number: 2
First sector: (Enter)
Last sector: (Enter)

# Write changes:
Command: w
```

---

#### Using parted (More features)

**Interactive mode:**
```bash
sudo parted /dev/sdb
```

**Command-line mode:**
```bash
# Create GPT partition table
sudo parted /dev/sdb mklabel gpt

# Create partition
sudo parted /dev/sdb mkpart primary ext4 0% 100%

# Show partition table
sudo parted /dev/sdb print
```

**Complete example:**
```bash
# 1. Create partition table (GPT)
sudo parted /dev/sdb mklabel gpt

# 2. Create partition (entire disk)
sudo parted /dev/sdb mkpart primary ext4 0% 100%

# 3. Create filesystem
sudo mkfs.ext4 /dev/sdb1

# 4. Label filesystem
sudo e2label /dev/sdb1 MyData

# 5. Create mount point
sudo mkdir -p /mnt/data

# 6. Get UUID
sudo blkid /dev/sdb1

# 7. Add to fstab
echo "UUID=xxx-yyy /mnt/data ext4 defaults 0 2" | sudo tee -a /etc/fstab

# 8. Mount
sudo mount /mnt/data

# 9. Verify
df -h /mnt/data
```

---

### Creating Filesystems

**ext4:**
```bash
sudo mkfs.ext4 /dev/sdb1

# With label
sudo mkfs.ext4 -L MyData /dev/sdb1

# With specific inode size
sudo mkfs.ext4 -I 256 /dev/sdb1

# Reserve less space for root (default 5%)
sudo mkfs.ext4 -m 1 /dev/sdb1
```

**XFS:**
```bash
sudo mkfs.xfs /dev/sdb1

# With label
sudo mkfs.xfs -L MyData /dev/sdb1

# Force (overwrite existing)
sudo mkfs.xfs -f /dev/sdb1
```

**Btrfs:**
```bash
sudo mkfs.btrfs /dev/sdb1

# With label
sudo mkfs.btrfs -L MyData /dev/sdb1

# Multiple devices (RAID1)
sudo mkfs.btrfs -m raid1 -d raid1 /dev/sdb1 /dev/sdc1
```

**FAT32 (USB drives):**
```bash
sudo mkfs.vfat /dev/sdb1

# With label (11 chars max)
sudo mkfs.vfat -n MYUSB /dev/sdb1
```

**exFAT:**
```bash
# Install tools first
sudo apt install exfat-fuse exfat-utils  # Debian/Ubuntu
sudo yum install exfat-utils             # RHEL/CentOS

# Create filesystem
sudo mkfs.exfat /dev/sdb1

# With label
sudo mkfs.exfat -n MyUSB /dev/sdb1
```

**NTFS:**
```bash
# Install tools
sudo apt install ntfs-3g  # Debian/Ubuntu
sudo yum install ntfs-3g  # RHEL/CentOS

# Create filesystem
sudo mkfs.ntfs /dev/sdb1

# With label
sudo mkfs.ntfs -L MyData /dev/sdb1

# Quick format
sudo mkfs.ntfs -f /dev/sdb1
```

---

### Filesystem Labels

**View labels:**
```bash
lsblk -f
blkid
```

**Set label:**
```bash
# ext4
sudo e2label /dev/sdb1 MyData

# XFS
sudo xfs_admin -L MyData /dev/sdb1

# Btrfs
sudo btrfs filesystem label /dev/sdb1 MyData

# NTFS
sudo ntfslabel /dev/sdb1 MyData

# FAT32
sudo fatlabel /dev/sdb1 MYUSB
```

---

### Checking and Repairing Filesystems

**⚠️ IMPORTANT: Unmount filesystem before checking!**

**fsck - Filesystem check:**
```bash
# Check and repair
sudo fsck /dev/sdb1

# Automatic yes to all
sudo fsck -y /dev/sdb1

# Check without fixing
sudo fsck -n /dev/sdb1
```

**Filesystem-specific tools:**
```bash
# ext4
sudo e2fsck -f /dev/sdb1
sudo e2fsck -fy /dev/sdb1    # Force, auto-fix

# XFS
sudo xfs_repair /dev/sdb1

# Btrfs
sudo btrfs check /dev/sdb1
```

**Check root filesystem:**
```bash
# Schedule fsck on next boot
sudo touch /forcefsck
sudo reboot

# Or pass to kernel
# Edit GRUB, add: fsck.mode=force
```

---

## Network Filesystems

### NFS (Network File System)

**NFS Overview:**
- Native Linux/Unix network filesystem
- Shares directories over network
- Client mounts remote directory as local
- Good performance on LAN

**Use cases:**
- Share files between Linux servers
- Home directories on network
- Shared application data
- Container persistent storage

---

#### NFS Server Setup

**Install NFS server:**
```bash
# Debian/Ubuntu
sudo apt update
sudo apt install nfs-kernel-server

# RHEL/CentOS/AlmaLinux
sudo yum install nfs-utils
sudo systemctl enable nfs-server
sudo systemctl start nfs-server
```

**Configure exports:**
```bash
# Edit exports file
sudo nano /etc/exports
```

**Export syntax:**
```
/path/to/share  client(options)
```

**Example exports:**
```bash
# Share to specific IP
/srv/nfs/data  192.168.1.100(rw,sync,no_subtree_check)

# Share to subnet
/srv/nfs/data  192.168.1.0/24(rw,sync,no_subtree_check)

# Share to multiple clients
/srv/nfs/data  192.168.1.100(rw,sync) 192.168.1.101(rw,sync)

# Share read-only
/srv/nfs/public  *(ro,sync,no_subtree_check)

# Share with root squash disabled (security risk!)
/srv/nfs/root  192.168.1.100(rw,sync,no_subtree_check,no_root_squash)
```

**Common NFS export options:**
- `rw` - Read-write
- `ro` - Read-only
- `sync` - Synchronous writes (safer)
- `async` - Asynchronous writes (faster)
- `no_subtree_check` - Disable subtree checking (faster)
- `root_squash` - Map root to nobody (default, secure)
- `no_root_squash` - Don't map root (insecure!)
- `all_squash` - Map all users to nobody

**Apply changes:**
```bash
# Reload exports
sudo exportfs -ra

# View active exports
sudo exportfs -v

# Show what's exported
showmount -e localhost
```

**Firewall configuration:**
```bash
# Ubuntu (ufw)
sudo ufw allow from 192.168.1.0/24 to any port nfs

# RHEL/CentOS (firewalld)
sudo firewall-cmd --permanent --add-service=nfs
sudo firewall-cmd --permanent --add-service=rpc-bind
sudo firewall-cmd --permanent --add-service=mountd
sudo firewall-cmd --reload
```

---

#### NFS Client Setup

**Install NFS client:**
```bash
# Debian/Ubuntu
sudo apt install nfs-common

# RHEL/CentOS/AlmaLinux
sudo yum install nfs-utils
```

**Show available shares:**
```bash
showmount -e nfs-server
```

**Mount NFS share:**
```bash
# Create mount point
sudo mkdir -p /mnt/nfs/data

# Mount temporarily
sudo mount -t nfs nfs-server:/srv/nfs/data /mnt/nfs/data

# With options
sudo mount -t nfs -o rw,soft,intr nfs-server:/srv/nfs/data /mnt/nfs/data
```

**Add to /etc/fstab (permanent):**
```bash
# Add to /etc/fstab
nfs-server:/srv/nfs/data  /mnt/nfs/data  nfs  defaults,_netdev,nofail  0  0

# With options
nfs-server:/srv/nfs/data  /mnt/nfs/data  nfs  rw,soft,intr,_netdev,nofail  0  0

# Mount all fstab entries
sudo mount -a
```

**Common NFS mount options:**
- `soft` - Return error if server doesn't respond (vs `hard`)
- `hard` - Keep trying until server responds (default)
- `intr` - Allow interrupting hung operations
- `_netdev` - Mount after network is available
- `nofail` - Don't fail boot if server unavailable
- `timeo=n` - Timeout in tenths of a second
- `retrans=n` - Number of retries
- `rsize=n` - Read buffer size
- `wsize=n` - Write buffer size

**Unmount NFS:**
```bash
sudo umount /mnt/nfs/data

# Force unmount if hung
sudo umount -f /mnt/nfs/data

# Lazy unmount
sudo umount -l /mnt/nfs/data
```

---

#### NFS Troubleshooting

**Check NFS service:**
```bash
# Server
sudo systemctl status nfs-server
sudo systemctl status nfs-kernel-server

# Check exports
sudo exportfs -v
showmount -e localhost
```

**Test connectivity:**
```bash
# From client
showmount -e nfs-server

# Ping test
ping nfs-server

# Port test
telnet nfs-server 2049
```

**Check NFS mounts:**
```bash
# Show NFS mounts
mount | grep nfs
findmnt -t nfs

# NFS statistics
nfsstat
```

**Common issues:**
- **Permission denied:** Check export options, file permissions
- **Mount hangs:** Check network, firewall, server status
- **Stale file handle:** Server rebooted, remount share
- **Performance issues:** Tune rsize/wsize, check network

---

### CIFS/SMB (Windows Shares)

**CIFS/SMB Overview:**
- Windows native file sharing
- Access Windows shares from Linux
- Share Linux directories to Windows

**Install CIFS tools:**
```bash
# Debian/Ubuntu
sudo apt install cifs-utils

# RHEL/CentOS/AlmaLinux
sudo yum install cifs-utils
```

**Mount Windows share:**
```bash
# Create mount point
sudo mkdir -p /mnt/windows

# Mount with username/password
sudo mount -t cifs //server/share /mnt/windows -o username=user,password=pass

# Mount with credentials file (more secure)
sudo mount -t cifs //server/share /mnt/windows -o credentials=/root/.smbcreds

# With domain
sudo mount -t cifs //server/share /mnt/windows -o username=user,password=pass,domain=DOMAIN
```

**Credentials file:**
```bash
# Create credentials file
sudo nano /root/.smbcreds

# Content:
username=myuser
password=mypassword
domain=MYDOMAIN

# Secure permissions
sudo chmod 600 /root/.smbcreds
```

**Add to /etc/fstab:**
```bash
# Add to /etc/fstab
//server/share  /mnt/windows  cifs  credentials=/root/.smbcreds,uid=1000,gid=1000,_netdev,nofail  0  0

# Mount
sudo mount -a
```

**Common CIFS mount options:**
- `username=` - Username
- `password=` - Password (not recommended in fstab)
- `credentials=` - Path to credentials file
- `domain=` - Windows domain
- `uid=` - Local user ID for files
- `gid=` - Local group ID for files
- `file_mode=` - File permissions (e.g., 0755)
- `dir_mode=` - Directory permissions
- `vers=` - SMB version (1.0, 2.0, 2.1, 3.0)

---

### SSHFS (SSH Filesystem)

**SSHFS Overview:**
- Mount remote directory over SSH
- No server setup needed (just SSH access)
- Encrypted by default
- Easy to use

**Install SSHFS:**
```bash
# Debian/Ubuntu
sudo apt install sshfs

# RHEL/CentOS/AlmaLinux
sudo yum install fuse-sshfs
```

**Mount remote directory:**
```bash
# Create mount point
mkdir -p ~/remote

# Mount
sshfs user@remote-host:/remote/path ~/remote

# With specific port
sshfs -p 2222 user@remote-host:/remote/path ~/remote

# With SSH key
sshfs -o IdentityFile=~/.ssh/id_rsa user@remote-host:/remote/path ~/remote
```

**Unmount:**
```bash
fusermount -u ~/remote
```

**Add to /etc/fstab:**
```bash
# Add to /etc/fstab (for user mounts)
user@remote-host:/remote/path  /home/user/remote  fuse.sshfs  noauto,x-systemd.automount,_netdev,user,idmap=user,identityfile=/home/user/.ssh/id_rsa  0  0
```

**Common SSHFS options:**
- `port=` - SSH port
- `IdentityFile=` - SSH key
- `reconnect` - Auto-reconnect
- `compression=yes` - Enable compression
- `allow_other` - Allow other users to access
- `default_permissions` - Enable permission checking

---

## LVM (Logical Volume Manager)

### What is LVM?

**LVM Overview:**
- Flexible disk management
- Resize filesystems without downtime
- Create snapshots
- Span filesystems across multiple disks

**LVM Layers:**
```
Physical Volumes (PV)  →  Volume Groups (VG)  →  Logical Volumes (LV)
      /dev/sdb1                  vg_data               lv_storage
      /dev/sdc1         ┌────────────────────┐
         ↓              │                     │
    [Physical]    →     │   [Volume Group]   │   →   [Logical Volume]
                        │                     │         (Formatted as
                        └────────────────────┘          ext4, xfs, etc.)
```

**Benefits:**
- ✅ Resize volumes online
- ✅ Add storage without downtime
- ✅ Create snapshots
- ✅ Migrate data between disks
- ✅ Better than traditional partitions

---

### LVM Concepts

**Physical Volume (PV):**
- Physical disk or partition
- Building block of LVM
- Example: `/dev/sdb1`, `/dev/sdc`

**Volume Group (VG):**
- Pool of physical volumes
- Like a virtual disk
- Example: `vg_data`

**Logical Volume (LV):**
- Virtual partition from volume group
- What you format and mount
- Example: `lv_storage`

**Physical Extent (PE):**
- Chunk size in volume group (default 4MB)
- Smallest unit of allocation

---

### LVM Installation

```bash
# Debian/Ubuntu
sudo apt install lvm2

# RHEL/CentOS/AlmaLinux
sudo yum install lvm2
```

---

### Creating LVM Step-by-Step

**Complete example:**

```bash
# 1. Create physical volumes
sudo pvcreate /dev/sdb
sudo pvcreate /dev/sdc

# 2. Create volume group (combining both disks)
sudo vgcreate vg_data /dev/sdb /dev/sdc

# 3. Create logical volume (500GB)
sudo lvcreate -L 500G -n lv_storage vg_data

# 4. Create filesystem
sudo mkfs.ext4 /dev/vg_data/lv_storage

# 5. Create mount point
sudo mkdir -p /mnt/storage

# 6. Mount
sudo mount /dev/vg_data/lv_storage /mnt/storage

# 7. Add to fstab
echo "/dev/vg_data/lv_storage  /mnt/storage  ext4  defaults  0  2" | sudo tee -a /etc/fstab
```

---

### LVM Commands

**Physical Volumes:**
```bash
# Create PV
sudo pvcreate /dev/sdb

# Show PVs
sudo pvs
sudo pvdisplay

# Remove PV
sudo pvremove /dev/sdb
```

**Volume Groups:**
```bash
# Create VG
sudo vgcreate vg_name /dev/sdb /dev/sdc

# Show VGs
sudo vgs
sudo vgdisplay

# Extend VG (add disk)
sudo vgextend vg_name /dev/sdd

# Reduce VG (remove disk)
sudo vgreduce vg_name /dev/sdd

# Remove VG
sudo vgremove vg_name
```

**Logical Volumes:**
```bash
# Create LV (specific size)
sudo lvcreate -L 100G -n lv_name vg_name

# Create LV (percentage of VG)
sudo lvcreate -l 100%FREE -n lv_name vg_name

# Show LVs
sudo lvs
sudo lvdisplay

# Remove LV
sudo lvremove /dev/vg_name/lv_name
```

---

### Resizing LVM

**Extend logical volume:**

```bash
# 1. Extend LV (+100GB)
sudo lvextend -L +100G /dev/vg_data/lv_storage

# Or extend to specific size
sudo lvextend -L 600G /dev/vg_data/lv_storage

# Or use all free space
sudo lvextend -l +100%FREE /dev/vg_data/lv_storage

# 2. Resize filesystem (ext4)
sudo resize2fs /dev/vg_data/lv_storage

# For XFS
sudo xfs_growfs /mnt/storage

# One command (extend LV and filesystem)
sudo lvextend -L +100G -r /dev/vg_data/lv_storage
```

**Reduce logical volume (ext4 only, XFS cannot shrink):**

```bash
# 1. Unmount filesystem
sudo umount /mnt/storage

# 2. Check filesystem
sudo e2fsck -f /dev/vg_data/lv_storage

# 3. Resize filesystem first
sudo resize2fs /dev/vg_data/lv_storage 400G

# 4. Reduce LV
sudo lvreduce -L 400G /dev/vg_data/lv_storage

# 5. Remount
sudo mount /mnt/storage
```

---

### LVM Snapshots

**Create snapshot:**
```bash
# Create 10GB snapshot
sudo lvcreate -L 10G -s -n lv_snapshot /dev/vg_data/lv_storage

# Snapshot grows as data changes (10GB is space for changes)
```

**Mount snapshot:**
```bash
sudo mkdir -p /mnt/snapshot
sudo mount /dev/vg_data/lv_snapshot /mnt/snapshot
```

**Restore from snapshot:**
```bash
# Unmount original
sudo umount /mnt/storage

# Merge snapshot (restore)
sudo lvconvert --merge /dev/vg_data/lv_snapshot

# Remount (snapshot is gone after merge)
sudo mount /mnt/storage
```

**Remove snapshot:**
```bash
sudo lvremove /dev/vg_data/lv_snapshot
```

---

## Advanced Topics

### RAID (Redundant Array of Independent Disks)

**RAID Levels:**

| Level | Description | Min Disks | Capacity | Performance | Fault Tolerance |
|-------|-------------|-----------|----------|-------------|-----------------|
| **RAID 0** | Striping | 2 | 100% | Fast | None |
| **RAID 1** | Mirroring | 2 | 50% | Read: fast | 1 disk failure |
| **RAID 5** | Parity | 3 | (n-1)/n | Good | 1 disk failure |
| **RAID 6** | Double parity | 4 | (n-2)/n | Good | 2 disk failures |
| **RAID 10** | Stripe + Mirror | 4 | 50% | Fast | 1 disk per mirror |

**Software RAID with mdadm:**
```bash
# Install mdadm
sudo apt install mdadm  # Debian/Ubuntu
sudo yum install mdadm  # RHEL/CentOS

# Create RAID1
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc

# Create RAID5
sudo mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd

# Check RAID status
cat /proc/mdstat
sudo mdadm --detail /dev/md0

# Save config
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf

# Format and mount
sudo mkfs.ext4 /dev/md0
sudo mount /dev/md0 /mnt/raid
```

---

### Disk Quotas

**Enable quotas:**
```bash
# 1. Edit /etc/fstab, add: usrquota,grpquota
/dev/sdb1  /home  ext4  defaults,usrquota,grpquota  0  2

# 2. Remount
sudo mount -o remount /home

# 3. Create quota files
sudo quotacheck -cug /home

# 4. Enable quotas
sudo quotaon /home
```

**Set quotas:**
```bash
# Set quota for user
sudo edquota -u username

# Set quota for group
sudo edquota -g groupname

# Copy quota from one user to another
sudo edquota -p user1 user2
```

**Check quotas:**
```bash
# User quota
quota -u username

# All users
sudo repquota /home

# Grace period
sudo edquota -t
```

---

### Filesystem Maintenance

**Check filesystem health:**
```bash
# SMART status (disk hardware health)
sudo apt install smartmontools
sudo smartctl -a /dev/sda

# Filesystem check
sudo fsck -n /dev/sdb1  # Check only, no repair

# Bad blocks check
sudo badblocks -v /dev/sdb1
```

**Tune filesystem:**
```bash
# ext4 parameters
sudo tune2fs -l /dev/sdb1     # Show parameters
sudo tune2fs -m 1 /dev/sdb1   # Reserve 1% for root
sudo tune2fs -c 0 /dev/sdb1   # Disable fsck count check
sudo tune2fs -i 0 /dev/sdb1   # Disable fsck time check
```

---

## DevOps Applications

### Docker Storage

**Docker volume types:**
```bash
# Named volume
docker volume create mydata
docker run -v mydata:/data nginx

# Bind mount (host directory)
docker run -v /host/path:/container/path nginx

# tmpfs (RAM)
docker run --tmpfs /tmp nginx
```

**List volumes:**
```bash
docker volume ls
docker volume inspect mydata
```

**Backup volume:**
```bash
# Backup to tar
docker run --rm -v mydata:/data -v $(pwd):/backup ubuntu tar czf /backup/mydata.tar.gz /data

# Restore from tar
docker run --rm -v mydata:/data -v $(pwd):/backup ubuntu tar xzf /backup/mydata.tar.gz -C /
```

---

### Kubernetes Storage

**PersistentVolume (PV):**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/data
```

**PersistentVolumeClaim (PVC):**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: manual
```

**Use in Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - mountPath: /data
      name: storage
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: pvc-data
```

**Storage Classes:**
```bash
# List storage classes
kubectl get storageclass
kubectl get sc

# Describe storage class
kubectl describe sc standard
```

---

### NFS for Container Storage

**NFS for Docker:**
```bash
# Mount NFS first
sudo mount -t nfs nfs-server:/export /mnt/nfs

# Use as bind mount
docker run -v /mnt/nfs:/data nginx
```

**NFS for Kubernetes:**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-pv
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: nfs-server
    path: /export
  persistentVolumeReclaimPolicy: Retain
```

---

### CI/CD Storage Considerations

**Build artifacts:**
```bash
# Store on shared NFS
- name: Upload artifacts
  run: |
    cp build/* /mnt/nfs/artifacts/

# Or use object storage (S3)
- name: Upload to S3
  run: |
    aws s3 cp build/ s3://bucket/artifacts/ --recursive
```

**Cache directories:**
```bash
# Use tmpfs for fast builds
mount -t tmpfs -o size=10G tmpfs /tmp/build-cache

# Or persistent cache
mount /dev/vg_cache/lv_build /var/cache/build
```

---

### Backup Strategies

**LVM snapshot backup:**
```bash
#!/bin/bash
# Create snapshot
lvcreate -L 10G -s -n backup_snap /dev/vg_data/lv_prod

# Mount snapshot
mkdir -p /mnt/backup
mount /dev/vg_data/backup_snap /mnt/backup

# Backup
tar czf /backup/prod-$(date +%Y%m%d).tar.gz /mnt/backup

# Cleanup
umount /mnt/backup
lvremove -f /dev/vg_data/backup_snap
```

**rsync backup:**
```bash
# Backup to remote server
rsync -avz /data/ backup-server:/backups/data/

# With NFS
rsync -avz /data/ /mnt/nfs/backups/data/
```

---

### Performance Monitoring

**I/O statistics:**
```bash
# Install iostat
sudo apt install sysstat

# Monitor I/O
iostat -x 1

# Per-device stats
iostat -x 1 /dev/sda
```

**Disk I/O monitoring:**
```bash
# iotop (like top for I/O)
sudo apt install iotop
sudo iotop

# dstat (versatile)
sudo apt install dstat
dstat -cdlmn 1
```

---

## Quick Reference

### Essential Commands

**View filesystems:**
```bash
df -h                    # Disk usage
lsblk -f                 # Block devices with filesystem
findmnt                  # Mount tree
mount                    # Show mounts
```

**Mount/Unmount:**
```bash
sudo mount /dev/sdb1 /mnt/data
sudo umount /mnt/data
sudo mount -a            # Mount all fstab entries
```

**Create filesystem:**
```bash
sudo mkfs.ext4 /dev/sdb1
sudo mkfs.xfs /dev/sdb1
```

**NFS:**
```bash
# Server
sudo exportfs -ra        # Reload exports

# Client
showmount -e server      # List shares
sudo mount -t nfs server:/export /mnt/nfs
```

**LVM:**
```bash
sudo pvs                 # Physical volumes
sudo vgs                 # Volume groups
sudo lvs                 # Logical volumes
sudo lvextend -L +10G -r /dev/vg/lv
```

---

## Summary

**Key Concepts:**

1. **Filesystems** - Different types for different needs (ext4, XFS, Btrfs)
2. **Mounting** - Attach filesystems to directory tree
3. **/etc/fstab** - Automatic mounting at boot
4. **Disk Management** - Partitioning, formatting, labeling
5. **Network Filesystems** - Share storage across network (NFS, CIFS, SSHFS)
6. **LVM** - Flexible volume management, resizing, snapshots
7. **RAID** - Redundancy and performance

**DevOps Best Practices:**

1. **Use UUIDs** in /etc/fstab (not device names)
2. **Add _netdev,nofail** for network filesystems
3. **Use LVM** for flexibility
4. **Regular backups** with LVM snapshots or rsync
5. **Monitor I/O** performance
6. **Use appropriate filesystem** for workload
7. **NFS for shared storage** in Kubernetes/Docker
8. **Test fstab** before rebooting!

**Essential Skills:**
- Mount/unmount filesystems
- Configure /etc/fstab correctly
- Set up NFS shares
- Create and manage LVM volumes
- Resize filesystems safely
- Troubleshoot mount issues
- Integrate with container storage

---

**Master these filesystem concepts to manage storage effectively in DevOps environments!**