# Transferring and Copying Files Over the Network

## Introduction

Moving files between computers over the network is a fundamental Linux skill. Whether you're backing up files to a remote server, deploying code, or transferring data between systems, you need secure and reliable methods.

**What you'll learn:**
- Secure file copying with SCP
- Interactive file transfer with SFTP
- Understanding FTP (when to use, when to avoid)
- Best practices for network file transfers

---

## SCP (Secure Copy)

SCP uses SSH to securely copy files between hosts. It encrypts both authentication and data transfer.

### Why Use SCP?

✅ **Secure** - Encrypted transfer via SSH  
✅ **Simple** - Easy command-line syntax  
✅ **Fast** - Efficient for single or batch file transfers  
✅ **Reliable** - Built on SSH protocol  
✅ **Universal** - Available on all Linux/Unix systems

### Basic SCP Syntax

```bash
# Copy TO remote host
scp source_file user@remote_host:/path/to/destination

# Copy FROM remote host
scp user@remote_host:/path/to/file local_destination
```

---

## SCP Examples - Copy TO Remote Host

### Copy Single File

```bash
# Basic file copy
scp myfile.txt user@192.168.1.100:/home/user/

# Copy to specific location
scp document.pdf admin@server.example.com:/tmp/

# Copy with different name
scp local.txt user@remote:/home/user/remote.txt
```

### Copy Multiple Files

```bash
# Multiple files to remote directory
scp file1.txt file2.txt file3.txt user@remote:/destination/

# Using wildcards
scp *.txt user@remote:/documents/

# All log files
scp *.log admin@server:/var/log/backup/
```

### Copy Entire Directory

```bash
# Copy directory recursively
scp -r my_directory/ user@remote:/home/user/

# Copy project folder
scp -r /home/user/project/ admin@server:/var/www/

# Backup directory
scp -r ~/important_data/ backup@backup-server:/backups/
```

**Note:** The `-r` flag means **recursive** (include all subdirectories and files).

---

## SCP Examples - Copy FROM Remote Host

### Download Single File

```bash
# Copy file from remote to current directory
scp user@remote:/home/user/file.txt .

# Copy to specific local directory
scp user@remote:/etc/config.conf /tmp/

# Copy with new name
scp user@remote:/var/log/app.log ~/logs/app-$(date +%Y%m%d).log
```

### Download Multiple Files

```bash
# Multiple files from remote
scp user@remote:"/home/user/*.txt" ./

# Specific files
scp user@remote:"/home/user/{file1,file2,file3}.txt" ./
```

### Download Directory

```bash
# Download entire directory
scp -r user@remote:/home/user/project/ ./

# Download backup
scp -r admin@server:/backups/2024/ ~/backups/
```

---

## SCP Options and Features

### Useful SCP Options

| Option | Description | Example |
|--------|-------------|---------|
| `-r` | Recursive (copy directories) | `scp -r dir/ user@remote:/path/` |
| `-P` | Specify SSH port | `scp -P 2222 file user@remote:/path/` |
| `-p` | Preserve file attributes | `scp -p file user@remote:/path/` |
| `-q` | Quiet mode (no progress) | `scp -q file user@remote:/path/` |
| `-C` | Enable compression | `scp -C largefile user@remote:/path/` |
| `-v` | Verbose (debugging) | `scp -v file user@remote:/path/` |
| `-i` | Use specific SSH key | `scp -i ~/.ssh/key file user@remote:/path/` |

### Specify SSH Port

If SSH runs on non-standard port:

```bash
# Use -P (capital P) for port
scp -P 2222 file.txt user@remote:/home/user/

# Copy directory with custom port
scp -P 2222 -r directory/ user@remote:/backup/
```

**Important:** It's `-P` (capital) for scp, but `-p` (lowercase) for ssh!

### Preserve File Attributes

Keep original timestamps, permissions:

```bash
# Preserve attributes with -p
scp -p important.txt user@remote:/backup/

# Preserve when copying directories
scp -rp ~/project/ user@remote:/home/user/
```

### Enable Compression

For large files over slow connections:

```bash
# Compress during transfer
scp -C largefile.tar user@remote:/destination/

# Combine with recursive
scp -rC big_directory/ user@remote:/backup/
```

### Use Specific SSH Key

```bash
# Use specific private key
scp -i ~/.ssh/my_key.pem file.txt user@remote:/home/user/

# Common for AWS/cloud instances
scp -i ~/.ssh/aws_key.pem app.zip ubuntu@ec2-instance:/home/ubuntu/
```

### Verbose Mode (Debugging)

```bash
# See detailed transfer information
scp -v file.txt user@remote:/home/user/

# Debug connection issues
scp -vvv file.txt user@remote:/home/user/
```

---

## Practical SCP Examples

### Backup Files

```bash
# Daily backup
scp -r ~/documents/ backup@server:/backups/$(date +%Y%m%d)/

# Backup configuration
scp -p /etc/nginx/nginx.conf admin@backup:/configs/nginx-$(date +%Y%m%d).conf

# Backup database dump
scp database_backup.sql user@remote:/backups/db/
```

### Deploy Code

```bash
# Deploy website
scp -r website/* user@webserver:/var/www/html/

# Deploy application
scp app.jar admin@server:/opt/myapp/

# Upload configuration
scp config.yml admin@server:/etc/myapp/
```

### Download Logs

```bash
# Get latest log
scp admin@server:/var/log/application.log ~/logs/

# Download all logs
scp -r admin@server:/var/log/myapp/ ~/logs/

# Download with date in name
scp admin@server:/var/log/system.log ~/logs/system-$(date +%Y%m%d).log
```

### Between Two Remote Hosts

```bash
# Copy from one remote to another (through your computer)
scp user1@host1:/path/file user2@host2:/path/

# Example
scp admin@server1:/backup/data.tar admin@server2:/restore/
```

---

## SFTP (SSH File Transfer Protocol)

SFTP provides an **interactive** file transfer session over SSH. Unlike SCP (which is command-based), SFTP gives you a prompt where you can navigate and transfer files.

### When to Use SFTP

**Use SFTP when:**
- You need to browse remote directories before transferring
- Transferring multiple files in a session
- You're unsure of exact remote paths
- You want interactive file management

**Use SCP when:**
- You know exact file paths
- Quick one-off transfers
- Scripting file transfers

### Starting SFTP Session

```bash
# Connect to remote host
sftp user@remote_host

# Connect with specific port
sftp -P 2222 user@remote_host

# Connect with SSH key
sftp -i ~/.ssh/key user@remote_host
```

### SFTP Session Example

```bash
$ sftp admin@192.168.1.100
Connected to 192.168.1.100.
sftp> 
```

You now have an interactive SFTP prompt where you can run commands.

---

## SFTP Commands

### Navigation Commands

| Command | Description | Example |
|---------|-------------|---------|
| `pwd` | Print remote working directory | `sftp> pwd` |
| `lpwd` | Print local working directory | `sftp> lpwd` |
| `ls` | List remote directory | `sftp> ls` |
| `lls` | List local directory | `sftp> lls` |
| `cd` | Change remote directory | `sftp> cd /var/log` |
| `lcd` | Change local directory | `sftp> lcd ~/downloads` |

**Note:** Commands with **l** prefix operate on your **local** machine.

### File Transfer Commands

| Command | Description | Example |
|---------|-------------|---------|
| `get` | Download file from remote | `sftp> get file.txt` |
| `get -r` | Download directory | `sftp> get -r directory/` |
| `put` | Upload file to remote | `sftp> put file.txt` |
| `put -r` | Upload directory | `sftp> put -r directory/` |
| `mget` | Download multiple files | `sftp> mget *.txt` |
| `mput` | Upload multiple files | `sftp> mput *.log` |

### File Management Commands

| Command | Description | Example |
|---------|-------------|---------|
| `mkdir` | Create remote directory | `sftp> mkdir backup` |
| `lmkdir` | Create local directory | `sftp> lmkdir downloads` |
| `rm` | Delete remote file | `sftp> rm oldfile.txt` |
| `rmdir` | Delete remote directory | `sftp> rmdir olddir` |
| `rename` | Rename remote file | `sftp> rename old.txt new.txt` |
| `chmod` | Change remote permissions | `sftp> chmod 755 script.sh` |

### Other Commands

| Command | Description |
|---------|-------------|
| `help` or `?` | Show available commands |
| `!` | Execute local shell command |
| `bye` or `exit` or `quit` | Close SFTP session |

---

## SFTP Interactive Session Example

### Complete SFTP Workflow

```bash
# Connect
$ sftp user@remote_host
Connected to remote_host.

# Check where you are (remote)
sftp> pwd
Remote working directory: /home/user

# Check local location
sftp> lpwd
Local working directory: /home/localuser

# List remote files
sftp> ls
file1.txt
file2.txt
directory/

# Change remote directory
sftp> cd directory
sftp> pwd
Remote working directory: /home/user/directory

# Download a file
sftp> get file1.txt
Fetching /home/user/directory/file1.txt to file1.txt

# Download multiple files
sftp> mget *.txt
Fetching /home/user/directory/file2.txt to file2.txt
Fetching /home/user/directory/file3.txt to file3.txt

# Change local directory
sftp> lcd ~/downloads
sftp> lpwd
Local working directory: /home/localuser/downloads

# Upload a file
sftp> put local_file.txt
Uploading local_file.txt to /home/user/directory/local_file.txt

# Create remote directory
sftp> mkdir backup

# Upload directory
sftp> put -r my_folder/
Uploading my_folder/ to /home/user/directory/my_folder

# List to verify
sftp> ls
backup/
file1.txt
file2.txt
local_file.txt
my_folder/

# Exit
sftp> bye
```

### SFTP with Wildcards

```bash
# Download all text files
sftp> mget *.txt

# Download all log files
sftp> mget *.log

# Upload all PDF files
sftp> mput *.pdf
```

### Execute Local Commands

```bash
# Run local shell command from SFTP
sftp> !ls -l
# Shows local directory listing

sftp> !pwd
# Shows local working directory

sftp> !df -h
# Shows local disk usage
```

---

## Graphical SFTP Clients

For users who prefer GUI over command line:

### Popular SFTP Clients

**Cross-Platform:**
- **FileZilla** - Free, open-source, feature-rich
- **Cyberduck** - macOS and Windows
- **WinSCP** - Windows only, very popular

**Linux:**
- **Nautilus** (GNOME file manager) - built-in SFTP support
- **Dolphin** (KDE file manager) - built-in SFTP support
- **gFTP** - Dedicated FTP/SFTP client

### Connecting with GUI Client

**FileZilla Example:**
1. Open FileZilla
2. Enter connection details:
   - Host: `sftp://remote_host`
   - Username: `your_username`
   - Password: `your_password`
   - Port: `22` (default SSH port)
3. Click "Quickconnect"
4. Drag and drop files between local and remote panels

**Nautilus (GNOME) Example:**
1. Open Nautilus file manager
2. Press `Ctrl+L` to show location bar
3. Enter: `sftp://user@remote_host`
4. Enter password when prompted
5. Browse and copy files like local folders

---

## FTP (File Transfer Protocol)

FTP is an **older** protocol for file transfer. Unlike SCP/SFTP, standard FTP is **not encrypted**.

### FTP Security Warning

⚠️ **FTP sends passwords and data in plain text!**

**Security issues:**
- Passwords visible on network
- File contents can be intercepted
- Vulnerable to man-in-the-middle attacks

**When NOT to use FTP:**
- Transferring sensitive data
- Over untrusted networks (Internet)
- When security is important

**When FTP might be acceptable:**
- Local private network only
- Public file downloads (anonymous FTP)
- Legacy systems that don't support SFTP
- When explicitly required by service provider

### Modern Alternatives

**Instead of FTP, use:**
1. **SFTP** - Secure, SSH-based (preferred)
2. **SCP** - Simple, secure copying
3. **FTPS** - FTP with SSL/TLS encryption
4. **HTTPS** - Web-based file transfers

---

## FTP Clients (If You Must Use FTP)

### Command-Line FTP Client

```bash
# Connect to FTP server
ftp ftp.example.com

# Login (prompts for username/password)
Name: username
Password: ******

# FTP commands (similar to SFTP)
ftp> ls               # List files
ftp> cd directory     # Change directory
ftp> get file.txt     # Download file
ftp> put file.txt     # Upload file
ftp> bye              # Exit
```

### Anonymous FTP

Some servers allow anonymous access:

```bash
$ ftp ftp.example.com
Name: anonymous
Password: [your email or just press Enter]
```

### Better FTP Clients

**Command-line:**
- `lftp` - More features than standard ftp
- `ncftp` - User-friendly alternative

**Graphical:**
- **FileZilla** - Supports FTP, FTPS, SFTP
- **gFTP** - Linux FTP client

---

## Comparison: SCP vs SFTP vs FTP

| Feature | SCP | SFTP | FTP |
|---------|-----|------|-----|
| **Security** | Encrypted (SSH) | Encrypted (SSH) | ⚠️ Plain text |
| **Authentication** | SSH keys/password | SSH keys/password | Username/password |
| **Interface** | Command-based | Interactive | Interactive |
| **Use Case** | Quick transfers | Browse & transfer | Legacy systems |
| **Resume Failed Transfers** | No | Yes | Yes |
| **Scripting** | Easy | Moderate | Moderate |
| **Recommendation** | ✅ Use for scripts | ✅ Use for interactive | ⚠️ Avoid if possible |

---

## Best Practices

### Security

```bash
# Always prefer SFTP/SCP over FTP
# Use SSH keys instead of passwords
# Use specific SSH key for automated transfers
scp -i ~/.ssh/backup_key data.tar user@backup:/backups/

# Verify host fingerprints on first connection
# Keep SSH keys secure (chmod 600)
chmod 600 ~/.ssh/id_rsa
```

### Efficiency

```bash
# Use compression for large files
scp -C large_file.tar.gz user@remote:/destination/

# Transfer multiple files in one command
scp file1 file2 file3 user@remote:/destination/

# Use rsync for synchronized backups (more efficient than scp)
rsync -avz --progress source/ user@remote:/destination/
```

### Automation

```bash
# Setup SSH keys for passwordless transfers
ssh-keygen -t rsa
ssh-copy-id user@remote

# Now scp works without password prompts
scp file.txt user@remote:/destination/

# Use in scripts
#!/bin/bash
scp /backup/data.tar.gz backup@server:/backups/$(date +%Y%m%d)/
```

### Error Handling

```bash
# Check if scp succeeded
if scp file.txt user@remote:/destination/; then
    echo "Transfer successful"
else
    echo "Transfer failed"
fi

# Verbose mode for troubleshooting
scp -v file.txt user@remote:/destination/
```

---

## Practical Transfer Scenarios

### Regular Backups

```bash
# Automated daily backup
#!/bin/bash
DATE=$(date +%Y%m%d)
tar -czf backup-$DATE.tar.gz /important/data
scp -i ~/.ssh/backup_key backup-$DATE.tar.gz backup@server:/backups/
rm backup-$DATE.tar.gz
```

### Website Deployment

```bash
# Upload website files
scp -r /local/website/* user@webserver:/var/www/html/

# Or use SFTP for selective uploads
sftp user@webserver
sftp> cd /var/www/html
sftp> put -r assets/
sftp> put index.html
sftp> bye
```

### Log Collection

```bash
# Collect logs from multiple servers
for server in server1 server2 server3; do
    scp admin@$server:/var/log/app.log logs/$server-app.log
done
```

### Development Workflow

```bash
# Quick file edit on remote server
sftp dev@devserver
sftp> get config.php
sftp> bye

# Edit locally
nano config.php

# Upload back
sftp dev@devserver
sftp> put config.php
sftp> bye
```

---

## Quick Reference

### SCP Commands

```bash
# Upload file
scp file.txt user@remote:/path/

# Upload directory
scp -r directory/ user@remote:/path/

# Download file
scp user@remote:/path/file.txt ./

# Download directory
scp -r user@remote:/path/directory/ ./

# With compression
scp -C file user@remote:/path/

# Custom SSH port
scp -P 2222 file user@remote:/path/

# With SSH key
scp -i key.pem file user@remote:/path/
```

### SFTP Commands

```bash
# Connect
sftp user@remote

# Navigate
pwd, lpwd, ls, lls, cd, lcd

# Transfer
get file              # Download
put file              # Upload
get -r directory/     # Download directory
put -r directory/     # Upload directory

# Manage
mkdir, rmdir, rm, rename, chmod

# Exit
bye
```

### Connection Patterns

```bash
# Standard SSH port (22)
user@hostname
user@192.168.1.100

# Custom port
-P 2222 user@hostname

# With SSH key
-i ~/.ssh/key user@hostname
```

---

## Summary

### Key Concepts

**SCP (Secure Copy):**
- Simple, secure file copying
- Command-based (not interactive)
- Great for scripts and automation
- Uses SSH encryption

**SFTP (SSH File Transfer Protocol):**
- Interactive file transfer session
- Browse remote directories
- Multiple commands in one session
- Uses SSH encryption

**FTP (File Transfer Protocol):**
- ⚠️ Insecure - avoid when possible
- Legacy protocol
- Only use on trusted local networks
- Consider SFTP or FTPS instead

### When to Use What

**Use SCP when:**
- Quick one-time file copy
- Scripting/automation
- Know exact file paths
- Simple transfers

**Use SFTP when:**
- Need to browse remote filesystem
- Multiple file operations
- Unsure of exact paths
- Interactive session needed

**Avoid FTP:**
- Use SFTP or SCP instead
- Only use FTP if absolutely required
- Never for sensitive data

### Security Best Practices

1. **Always use SCP/SFTP** instead of FTP
2. **Use SSH keys** for authentication
3. **Verify host fingerprints** on first connection
4. **Keep private keys secure** (chmod 600)
5. **Use specific keys** for automated tasks
6. **Never send passwords** over unencrypted FTP

---

**Master secure file transfers to safely move data between systems!**