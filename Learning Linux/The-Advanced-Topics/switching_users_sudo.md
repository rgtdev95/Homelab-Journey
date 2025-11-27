# Switching Users and Running Commands as Others

## Introduction

Linux is a multi-user system, and sometimes you need to switch to another user account or run commands with different privileges. The primary tools for this are **su** (switch user) and **sudo** (superuser do).

**Why learn user switching?**
- ✅ Perform administrative tasks safely
- ✅ Test permissions and user environments
- ✅ Run services as specific users
- ✅ Essential for system administration
- ✅ Required for DevOps and security

---

## Understanding Users and Privileges

### Root User

**Root** is the superuser account with unrestricted access to the entire system.

**Root characteristics:**
- UID 0 (User ID zero)
- Can do anything on the system
- No permission restrictions
- Can modify any file
- Can kill any process
- Represented by `#` prompt (vs `$` for regular users)

**Danger:** One mistake as root can destroy the entire system!

### Regular Users

**Regular users** have limited privileges:
- Can only modify their own files
- Cannot install system-wide software
- Cannot modify system configuration
- Cannot access other users' files (unless given permission)
- Represented by `$` prompt

### Check Current User

```bash
# Show current username
whoami
# Output: john

# Show user ID and groups
id
# Output: uid=1000(john) gid=1000(john) groups=1000(john),27(sudo),999(docker)

# Show detailed user information
id -a
id -u        # Just UID
id -un       # Just username
id -g        # Primary group ID
id -gn       # Primary group name
```

---

## The su Command

### What is su?

**su (switch user)** allows you to become another user, typically root.

**Basic syntax:**
```bash
su [options] [username]
```

### Switch to Root

**Become root:**
```bash
# Switch to root
su

# Enter root password
Password: 

# Prompt changes to #
root@hostname:/home/john#

# Exit back to regular user
exit
```

**Differences:**

```bash
# su (without dash)
# - Keeps current environment
# - Stays in current directory
su

# su - (with dash) - RECOMMENDED
# - Full login shell
# - Loads root's environment
# - Changes to root's home directory
su -
```

**Example:**
```bash
# Without dash
$ pwd
/home/john
$ su
Password:
# pwd
/home/john        # Still in john's directory

# With dash
$ pwd
/home/john
$ su -
Password:
# pwd
/root             # Changed to root's home
```

### Switch to Another User

```bash
# Switch to user 'alice'
su alice

# Switch with full login environment (recommended)
su - alice

# Example
$ whoami
john
$ su - alice
Password:
$ whoami
alice
```

### Running Commands as Another User

**Execute single command:**
```bash
# Run command as root
su -c 'command'

# Example
su -c 'systemctl restart nginx'

# Run command as another user
su - alice -c 'ls ~'
```

**Example workflow:**
```bash
# Regular user
$ whoami
john

# Run command as root
$ su -c 'apt update'
Password:
Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease
...

# Back to regular user
$ whoami
john
```

---

## The sudo Command

### What is sudo?

**sudo (superuser do)** allows permitted users to execute commands as root or another user without knowing the root password.

**Key advantages over su:**
- Uses your own password, not root password
- Granular control (specific commands only)
- Logs all commands for auditing
- Temporary elevation (timeout after inactivity)
- Safer - don't need to share root password

### Basic sudo Usage

**Run command as root:**
```bash
# Syntax
sudo command

# Example
sudo apt update
[sudo] password for john:    # Enter YOUR password, not root's
```

**Common patterns:**
```bash
# Install software
sudo apt install vim

# Edit system file
sudo nano /etc/hosts

# Restart service
sudo systemctl restart nginx

# View system logs
sudo tail -f /var/log/syslog

# Change file ownership
sudo chown root:root file.txt
```

### Become Root with sudo

**Open root shell:**
```bash
# Become root (like su -)
sudo -i

# Or
sudo su -

# You're now root
root@hostname:~#

# Exit to return
exit
```

**Difference between sudo -i and sudo su -:**
- `sudo -i` - Runs login shell for root
- `sudo su -` - Runs su command as root
- Both achieve same result, `sudo -i` is more direct

**Run single command as root:**
```bash
# Keep current shell, run one command
sudo -s

# Exit after command
exit
```

### Running Commands as Other Users

**Execute as specific user:**
```bash
# Run as user 'www-data'
sudo -u www-data command

# Example: Check what files www-data can access
sudo -u www-data ls /var/www

# Run shell as another user
sudo -u alice -i

# Run command as alice with her environment
sudo -u alice -i command
```

**Common use cases:**
```bash
# Run web server as www-data
sudo -u www-data /usr/sbin/nginx

# Test as different user
sudo -u testuser bash

# Check if user can access file
sudo -u bob cat /etc/shadow
cat: /etc/shadow: Permission denied  # Good!
```

---

## sudo vs su

### Comparison Table

| Feature | su | sudo |
|---------|-----|------|
| **Password** | Target user's password | Your own password |
| **Root password needed** | Yes | No |
| **Granular control** | No (all or nothing) | Yes (per-command) |
| **Audit logging** | Limited | Comprehensive |
| **Timeout** | No (stays as user until exit) | Yes (15 min default) |
| **Environment** | Depends on dash usage | Configurable |
| **Configuration** | None (password only) | /etc/sudoers |

### When to Use Each

**Use su when:**
- Need to run many commands as another user
- Working in multi-user environment
- Don't have sudo access
- Prefer traditional Unix approach

**Use sudo when:**
- Running occasional admin commands
- Following principle of least privilege
- Need audit trail
- Modern Linux distribution (most use sudo by default)
- Working in DevOps/cloud environments

---

## sudo Configuration

### The sudoers File

**Main configuration:** `/etc/sudoers`

**⚠️ WARNING:** Never edit directly! Always use `visudo`:

```bash
# Edit sudoers file safely
sudo visudo

# Uses vi by default
# Set different editor:
sudo EDITOR=nano visudo
```

**Why visudo?**
- Checks syntax before saving
- Prevents locking yourself out
- Creates temporary lock file

### Basic sudoers Syntax

**Grant user full sudo access:**
```bash
# User 'john' can run any command as any user
john ALL=(ALL:ALL) ALL

# Breakdown:
# john        - username
# ALL         - from any host
# (ALL:ALL)   - as any user:group
# ALL         - any command
```

**Common configurations:**
```bash
# User without password prompt (dangerous!)
john ALL=(ALL) NOPASSWD: ALL

# User can run specific commands
john ALL=(ALL) /bin/systemctl restart nginx, /usr/bin/apt update

# User can run commands as specific user
john ALL=(www-data) ALL

# Group sudo can do anything
%sudo ALL=(ALL:ALL) ALL

# Group wheel can do anything (RHEL/CentOS)
%wheel ALL=(ALL) ALL
```

### Examples

**Allow user to restart nginx:**
```bash
# In /etc/sudoers
john ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx

# Now john can run:
sudo systemctl restart nginx
# No password required
```

**Allow multiple commands:**
```bash
# Define command alias
Cmnd_Alias SERVICES = /bin/systemctl restart nginx, /bin/systemctl restart apache2, /bin/systemctl status *

# Grant access
john ALL=(ALL) NOPASSWD: SERVICES
```

**Allow user to edit specific files:**
```bash
john ALL=(ALL) /usr/bin/nano /etc/nginx/nginx.conf, /usr/bin/vim /etc/nginx/nginx.conf

# John can now edit nginx.conf with sudo
sudo nano /etc/nginx/nginx.conf
```

---

## Practical Examples

### Quick Admin Tasks

**Update system:**
```bash
# Debian/Ubuntu
sudo apt update && sudo apt upgrade

# RHEL/CentOS
sudo yum update
```

**Manage services:**
```bash
# Start service
sudo systemctl start nginx

# Stop service
sudo systemctl stop nginx

# Restart service
sudo systemctl restart nginx

# Check status
sudo systemctl status nginx

# Enable at boot
sudo systemctl enable nginx
```

**Edit system files:**
```bash
# Edit hosts file
sudo nano /etc/hosts

# Edit nginx config
sudo vim /etc/nginx/nginx.conf

# Edit crontab for another user
sudo crontab -u www-data -e
```

### File Operations with sudo

**Create/modify system files:**
```bash
# Create file in protected directory
sudo touch /etc/myconfig.conf

# Copy to system directory
sudo cp config.conf /etc/app/

# Change ownership
sudo chown root:root /etc/myconfig.conf

# Change permissions
sudo chmod 644 /etc/myconfig.conf
```

**Using tee for redirection:**
```bash
# This WON'T work (redirection happens before sudo)
sudo echo "127.0.0.1 test.local" >> /etc/hosts
bash: /etc/hosts: Permission denied

# Use tee instead
echo "127.0.0.1 test.local" | sudo tee -a /etc/hosts

# Or
sudo bash -c 'echo "127.0.0.1 test.local" >> /etc/hosts'
```

### Running Services as Different Users

**Web server:**
```bash
# Run as www-data user
sudo -u www-data /usr/sbin/nginx

# Start service (automatically uses www-data)
sudo systemctl start nginx
```

**Database:**
```bash
# Run command as postgres user
sudo -u postgres psql

# Create backup as postgres user
sudo -u postgres pg_dump mydb > backup.sql
```

**Application server:**
```bash
# Run app as app user
sudo -u appuser node /opt/app/server.js

# Or with environment
sudo -u appuser -i bash -c 'cd /opt/app && npm start'
```

---

## Security Best Practices

### 1. Use sudo, Not Root Login

**Bad:**
```bash
# Logging in as root directly
ssh root@server

# Or enabling root login with password
PermitRootLogin yes  # in /etc/ssh/sshd_config
```

**Good:**
```bash
# Login as regular user
ssh john@server

# Use sudo for admin tasks
sudo command

# Disable root SSH login
PermitRootLogin no  # in /etc/ssh/sshd_config
```

### 2. Grant Minimal Permissions

**Bad:**
```bash
# Full sudo access
john ALL=(ALL) NOPASSWD: ALL
```

**Good:**
```bash
# Only needed commands
john ALL=(ALL) NOPASSWD: /bin/systemctl restart nginx, /usr/sbin/nginx -t
```

### 3. Always Review Commands

**Be careful with:**
```bash
# Destructive commands
sudo rm -rf /
sudo dd if=/dev/zero of=/dev/sda
sudo chmod -R 777 /

# Always double-check before running!
```

### 4. Check What You're About To Run

```bash
# Review command before running
sudo echo "This is safe"

# For complex commands, test without sudo first
command --help
man command

# Then run with sudo
sudo command
```

### 5. Use sudo Timeout

```bash
# sudo remembers password for 15 minutes by default
# Adjust in /etc/sudoers:
Defaults timestamp_timeout=5  # 5 minutes
Defaults timestamp_timeout=0  # Always ask
Defaults timestamp_timeout=-1 # Never expire (dangerous!)
```

### 6. Monitor sudo Usage

**Check sudo logs:**
```bash
# Debian/Ubuntu
sudo grep sudo /var/log/auth.log

# RHEL/CentOS
sudo grep sudo /var/log/secure

# Example output:
Jan 15 14:30:45 webserver sudo:     john : TTY=pts/0 ; PWD=/home/john ; USER=root ; COMMAND=/usr/bin/apt update
```

**Set up alerts:**
```bash
# Email on sudo usage (in /etc/sudoers)
Defaults mail_always
Defaults mailto="admin@example.com"

# Email on sudo errors
Defaults mail_badpass
```

---

## Troubleshooting

### "User is not in the sudoers file"

**Error:**
```bash
$ sudo apt update
john is not in the sudoers file.  This incident will be reported.
```

**Fix (as root or another sudo user):**
```bash
# Add user to sudo group (Debian/Ubuntu)
sudo usermod -aG sudo john

# Add user to wheel group (RHEL/CentOS)
sudo usermod -aG wheel john

# Or edit sudoers directly
sudo visudo
# Add:
john ALL=(ALL:ALL) ALL

# User must logout and login again
```

### "sudo: command not found"

**Check if sudo is installed:**
```bash
# Install sudo (as root)
su -
apt install sudo     # Debian/Ubuntu
yum install sudo     # RHEL/CentOS
```

### "Sorry, try again" (Wrong Password)

```bash
# Make sure you're entering YOUR password, not root's
sudo command
[sudo] password for john:    # Enter john's password

# Check if password is correct
su john
Password:
```

### sudo Asks for Password Every Time

```bash
# Check timestamp timeout
sudo -v  # Refresh timeout

# Check sudoers config
sudo visudo
# Look for: Defaults timestamp_timeout

# Cached credentials expire after 15 min by default
```

### Forgot Root Password

**Using sudo:**
```bash
# If you have sudo access
sudo passwd root
# Set new root password
```

**Using GRUB (recovery mode):**
```
1. Reboot and hold Shift to see GRUB menu
2. Select "Advanced options"
3. Select "Recovery mode"
4. Select "root - Drop to root shell prompt"
5. Remount filesystem: mount -o remount,rw /
6. Change password: passwd root
7. Reboot: reboot
```

---

## DevOps Applications

### Container User Management

**Docker:**
```bash
# Run container as specific user
docker run --user 1000:1000 nginx

# Execute command as root in container
docker exec -u root container_name command

# Run command as container's default user
docker exec -it container_name bash
```

**Kubernetes:**
```yaml
# Run pod as specific user
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
  containers:
  - name: nginx
    image: nginx
```

### Automation Scripts

**Running scripts with sudo:**
```bash
#!/bin/bash
# Script that requires sudo

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run with sudo"
    exit 1
fi

# Check if actually has sudo (not root directly)
if [ -z "$SUDO_USER" ]; then
    echo "Please use sudo, not root login"
    exit 1
fi

# Rest of script...
systemctl restart nginx
```

**Passwordless sudo for automation:**
```bash
# In /etc/sudoers.d/automation
jenkins ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart myapp

# Jenkins can now restart app without password
sudo systemctl restart myapp
```

### CI/CD Pipelines

**GitLab CI:**
```yaml
deploy:
  script:
    - sudo systemctl restart app
    - sudo nginx -t && sudo systemctl reload nginx
  only:
    - main
```

**GitHub Actions:**
```yaml
- name: Restart service
  run: sudo systemctl restart myapp
```

---

## Quick Reference

### Basic Commands

```bash
whoami                  # Show current user
id                      # Show user ID and groups
su                      # Switch to root (minimal)
su -                    # Switch to root (full login)
su - username           # Switch to another user
sudo command            # Run command as root
sudo -i                 # Become root (interactive)
sudo -u user command    # Run command as user
sudo -s                 # Run shell as root
exit                    # Return to previous user
```

### sudo Options

```bash
sudo -l                 # List sudo privileges
sudo -v                 # Refresh sudo timeout
sudo -k                 # Invalidate sudo credentials
sudo -i                 # Login shell as root
sudo -s                 # Shell as root
sudo -u user            # Run as different user
sudo -E                 # Preserve environment
sudo -H                 # Set HOME to target user's
```

### Configuration

```bash
sudo visudo             # Edit sudoers safely
sudo visudo -f /etc/sudoers.d/custom  # Edit file in sudoers.d

# Add user to sudo group
sudo usermod -aG sudo username        # Debian/Ubuntu
sudo usermod -aG wheel username       # RHEL/CentOS
```

---

## Summary

**Key Concepts:**

1. **su** - Switch user (needs target user's password)
2. **sudo** - Execute as root (uses your password)
3. **Root** - Superuser with unrestricted access
4. **sudoers** - Configuration file for sudo permissions
5. **Principle of least privilege** - Only use elevated privileges when needed

**Essential Commands:**

- `whoami` - Check current user
- `sudo command` - Run command as root
- `sudo -i` - Become root
- `sudo -u user command` - Run as different user
- `su - user` - Switch to user

**Best Practices:**

1. Prefer sudo over su for admin tasks
2. Use `su -` (with dash) when using su
3. Never share root password
4. Grant minimal necessary permissions
5. Always review commands before running with sudo
6. Monitor sudo logs for security
7. Use sudo groups, not direct user grants
8. Disable root SSH login
9. Use NOPASSWD sparingly and carefully
10. Test commands without sudo first when possible

**Security:**

- ✅ Use sudo for occasional admin tasks
- ✅ Use su for extended work as another user
- ✅ Review commands before running
- ✅ Monitor sudo logs
- ❌ Don't run everything as root
- ❌ Don't share root password
- ❌ Don't use `sudo su -` habitually

---

**Master user switching for safe and effective system administration!**