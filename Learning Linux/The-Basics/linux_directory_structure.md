# Linux Directory Structure

## Why Learn This?
Understanding the Linux directory structure helps you:
- Find programs and executables
- Locate configuration files
- Find application log files
- Navigate the system efficiently

## Essential Directories (Must Know)

| Directory | Purpose |
|-----------|---------|
| **/** | Root directory - the starting point of the file system (not the root user's home) |
| **/bin** | Essential binaries and executable programs |
| **/etc** | System configuration files |
| **/home** | User home directories (e.g., /home/username) |
| **/opt** | Optional or third-party software |
| **/tmp** | Temporary files, usually cleared on reboot |
| **/usr** | User-related programs and data |
| **/var** | Variable data, especially log files |
## Complete Directory Reference

**Note:** You won't interact with all these directories regularly. Some are on every Linux system, others are distribution-specific. Refer back to this when needed.

| Directory | Purpose |
|-----------|---------|
| **/** | Root - starting point of the file system |
| **/bin** | Essential command binaries (ls, cp, cat) |
| **/boot** | Boot loader files (kernel, initrd) |
| **/cdrom** | CD-ROM mount point |
| **/cgroup** | Control Groups hierarchy |
| **/dev** | Device files (hardware interfaces) |
| **/etc** | System configuration files |
| **/export** | Shared file systems (mainly Solaris) |
| **/home** | User home directories |
| **/lib** | System libraries |
| **/lib64** | 64-bit system libraries |
| **/lost+found** | Recovered files after file system check |
| **/media** | Removable media mount points (USB, CD-ROM) |
| **/mnt** | Temporary mount points |
| **/opt** | Optional/third-party software |
| **/proc** | Virtual filesystem with process information |
| **/root** | Root user's home directory |
| **/sbin** | System administration binaries |
| **/selinux** | SELinux security information |
| **/srv** | Service data (web, FTP) |
| **/sys** | Kernel device/bus information |
| **/tmp** | Temporary files (cleared on reboot) |
| **/usr** | User programs and data |
| **/var** | Variable data (logs, caches) |

### Important Subdirectories

| Directory | Purpose |
|-----------|---------|
| **/usr/bin** | User command binaries |
| **/usr/lib** | User libraries |
| **/usr/local** | Locally installed software (not from package manager) |
| **/usr/sbin** | Non-essential system administration binaries |
| **/var/log** | System and application log files |
| **/srv/www** | Web server files |
| **/srv/ftp** | FTP server files |
## Unix-Specific Directories

If you work with Unix systems (Solaris, HP-UX), you may see these:

| Directory | Purpose | System |
|-----------|---------|--------|
| **/devices** | Device files | Solaris |
| **/kernel** | Kernel and modules | Solaris |
| **/platform** | Platform-specific files | Solaris |
| **/rpool** | ZFS root pool | Solaris |
| **/net** | External file system mounts | HP-UX |
| **/nfs4** | Federated File System | Solaris |
| **/stand** | Boot files | HP-UX |

**Note:** You may see other directories created by system administrators.## Application Directory Structures

Applications often mirror the OS directory structure.

### Example 1: Apache in /usr/local
```
/usr/local/apache/
├── bin/        # Binaries and executables
├── etc/        # Configuration files
├── lib/        # Libraries
└── logs/       # Log files
```

### Example 2: Apache in /opt
```
/opt/apache/
├── bin/        # Binaries and executables
├── etc/        # Configuration files
├── lib/        # Libraries
└── logs/       # Log files
```

### Example 3: Split Configuration (Alternative)
```
/etc/opt/apache/           # Configuration files
/opt/apache/bin/           # Binaries
/opt/apache/lib/           # Libraries
/var/opt/apache/           # Log files
```

### Shared Installation
Applications can share space in `/usr/local`:
```
/usr/local/bin/apache      # Binary
/usr/local/etc/apache.conf # Configuration
/usr/local/lib/libapache.so # Library
```

### Company/Team-Based Structure

**Company-level:**
```
/opt/acme/                 # Company directory
└── bin/                   # Company binaries
```

**Or with nested applications:**
```
/opt/acme/
└── apache/
    └── bin/               # Apache binaries
```

**Team-level variations:**
```
/opt/web-team/
/opt/acme/web-team/
/usr/local/acme/web-team/
```
## Real-World Examples

### Red Hat Enterprise Linux 6
```bash
$ ls -1 /
bin
boot
cgroup
dev
etc
home
lib
lib64
lost+found
media
mnt
opt
proc
root
sbin
selinux
srv
sys
tmp
usr
var
```

### SUSE Linux Enterprise Server 11
```bash
$ ls -1 /
bin
boot
dev
etc
home
lib
lib64
lost+found
media
mnt
opt
proc
root
sbin
selinux
srv
sys
tmp
usr
```

### Ubuntu 12.04 LTS
```bash
$ ls -1 /
bin
boot
dev
etc
home
lib
lib64
lost+found
media
mnt
opt
proc
root
run
sbin
selinux
srv
sys
tmp
usr
var
```

---

## Additional Resources
- [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)
- Distribution documentation for RHEL, SLES, and Ubuntu