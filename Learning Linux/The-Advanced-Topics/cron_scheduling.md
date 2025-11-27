# Scheduling Tasks with Cron

## Introduction

**Cron** is a time-based job scheduler in Linux that automatically runs commands or scripts at specified times and dates. It's essential for automation, maintenance tasks, backups, and any repetitive system administration work.

**Why use cron?**
- ✅ Automate repetitive tasks
- ✅ Schedule backups and maintenance
- ✅ Run tasks when you're not available
- ✅ Monitor system health regularly
- ✅ Essential for DevOps automation

---

## What is Cron?

### Cron Components

**Three main parts:**

1. **Cron daemon (`crond`)** - Background service that executes scheduled tasks
2. **Crontab files** - Configuration files containing scheduled tasks
3. **Cron jobs** - The actual commands or scripts to be executed

**System files:**
- `/etc/crontab` - System-wide crontab
- `/etc/cron.d/` - System cron job directory
- `/var/spool/cron/crontabs/` - User crontab files (don't edit directly!)
- `/etc/cron.{hourly,daily,weekly,monthly}/` - Drop-in script directories

---

## Crontab Basics

### Viewing Crontabs

```bash
# View your crontab
crontab -l

# View another user's crontab (requires root)
sudo crontab -u username -l

# View root's crontab
sudo crontab -l
```

### Editing Crontabs

```bash
# Edit your crontab
crontab -e

# Edit another user's crontab (requires root)
sudo crontab -u username -e

# Edit root's crontab
sudo crontab -e
```

**First time:**
```bash
$ crontab -e
no crontab for john - using an empty one

Select an editor.  To change later, run 'select-editor'.
  1. /bin/nano        <---- easiest
  2. /usr/bin/vim.basic
  3. /usr/bin/vim.tiny

Choose 1-3 [1]: 1
```

### Removing Crontabs

```bash
# Remove your crontab
crontab -r

# Remove another user's crontab (requires root)
sudo crontab -u username -r

# Prompt before removing (interactive)
crontab -ri
```

---

## Crontab Syntax

### The Five Time Fields

**Basic format:**
```
* * * * * command_to_execute
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, Sunday=0 or 7)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

**Special characters:**

| Character | Meaning | Example |
|-----------|---------|---------|
| `*` | Any value | `* * * * *` = every minute |
| `,` | Multiple values | `1,15,30 * * * *` = 1st, 15th, 30th minute |
| `-` | Range of values | `1-5 * * * *` = minutes 1 through 5 |
| `/` | Step values | `*/5 * * * *` = every 5 minutes |

### Crontab Examples

**Time-based examples:**

```bash
# Every minute
* * * * * command

# Every 5 minutes
*/5 * * * * command

# Every hour at minute 0
0 * * * * command

# Every day at 2:30 AM
30 2 * * * command

# Every Sunday at 3:00 AM
0 3 * * 0 command

# Every Monday at 9:00 AM
0 9 * * 1 command

# First day of every month at midnight
0 0 1 * * command

# Every weekday (Mon-Fri) at 6:00 PM
0 18 * * 1-5 command

# Every 15 minutes
*/15 * * * * command

# Every 6 hours
0 */6 * * * command

# Twice a day: 9 AM and 9 PM
0 9,21 * * * command

# Every quarter hour
0,15,30,45 * * * * command
```

**Advanced examples:**

```bash
# Every minute during business hours (9 AM - 5 PM) on weekdays
* 9-17 * * 1-5 command

# Every 10 minutes during business hours
*/10 9-17 * * 1-5 command

# At midnight on the 1st and 15th of every month
0 0 1,15 * * command

# Every January 1st at midnight (New Year)
0 0 1 1 * command

# Every 5 minutes except on hour marks
1-59/5 * * * * command

# Every day at 2:30 AM in January and July
30 2 * 1,7 * command
```

---

## Special Strings (Keywords)

### Cron Special Strings

Instead of five time fields, you can use these keywords:

| String | Meaning | Equivalent |
|--------|---------|------------|
| `@reboot` | Run once at startup | N/A |
| `@yearly` or `@annually` | Run once a year | `0 0 1 1 *` |
| `@monthly` | Run once a month | `0 0 1 * *` |
| `@weekly` | Run once a week | `0 0 * * 0` |
| `@daily` or `@midnight` | Run once a day | `0 0 * * *` |
| `@hourly` | Run once an hour | `0 * * * *` |

**Examples:**

```bash
# Run backup script daily at midnight
@daily /home/user/backup.sh

# Check for updates hourly
@hourly /usr/bin/apt update

# Send weekly report every Sunday at midnight
@weekly /home/user/send-report.sh

# Run on system boot
@reboot /home/user/startup-tasks.sh

# Monthly cleanup
@monthly /home/user/cleanup.sh
```

---

## Writing Cron Jobs

### Complete Crontab Entry Format

**With optional components:**
```bash
# Environment variables (optional)
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO=admin@example.com

# Comments (optional)
# This is a comment

# Cron job
* * * * * command_to_execute
```

### Best Practices for Cron Jobs

**1. Use absolute paths:**
```bash
# Bad (might not find command)
0 2 * * * backup.sh

# Good (absolute path)
0 2 * * * /home/user/scripts/backup.sh
```

**2. Set PATH variable:**
```bash
# At top of crontab
PATH=/usr/local/bin:/usr/bin:/bin:/home/user/bin

# Now can use relative commands
0 2 * * * backup.sh
```

**3. Handle output properly:**
```bash
# Redirect output to log file
0 2 * * * /home/user/backup.sh >> /var/log/backup.log 2>&1

# Discard all output
0 2 * * * /home/user/backup.sh >/dev/null 2>&1

# Send errors to email, discard normal output
0 2 * * * /home/user/backup.sh >/dev/null
```

**4. Set environment variables:**
```bash
# Set SHELL (default is /bin/sh)
SHELL=/bin/bash

# Set MAILTO (default is crontab owner)
MAILTO=admin@example.com
MAILTO=""  # Disable email

# Set PATH
PATH=/usr/local/bin:/usr/bin:/bin

# Set other variables
DATABASE_URL=postgres://localhost/mydb

# Then your cron jobs
0 2 * * * /home/user/backup.sh
```

**5. Make scripts executable:**
```bash
# Make script executable
chmod +x /home/user/backup.sh

# Or call interpreter explicitly in crontab
0 2 * * * /bin/bash /home/user/backup.sh
0 3 * * * /usr/bin/python3 /home/user/script.py
```

---

## Practical Examples

### System Maintenance

**Daily backup:**
```bash
# Backup database every day at 2 AM
0 2 * * * /usr/bin/mysqldump -u root -pPASSWORD mydb > /backup/mydb_$(date +\%Y\%m\%d).sql

# Better: Use script file
0 2 * * * /home/user/scripts/backup-database.sh
```

**Weekly cleanup:**
```bash
# Delete old log files every Sunday at 3 AM
0 3 * * 0 find /var/log -name "*.log" -mtime +30 -delete

# Clean tmp directory every week
@weekly find /tmp -type f -mtime +7 -delete
```

**Update system packages:**
```bash
# Check for updates daily
@daily apt update && apt list --upgradable

# Auto-update on Sunday at 4 AM (be careful!)
0 4 * * 0 apt update && apt upgrade -y
```

### Monitoring and Alerts

**Disk space monitoring:**
```bash
# Check disk space every hour
0 * * * * df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{if($5>80) print $0}' | mail -s "Disk Alert" admin@example.com
```

**Service health check:**
```bash
# Check if nginx is running every 5 minutes
*/5 * * * * pgrep nginx || systemctl start nginx
```

**Website uptime check:**
```bash
# Ping website every 15 minutes
*/15 * * * * curl -f https://example.com >/dev/null 2>&1 || echo "Website down!" | mail -s "Alert" admin@example.com
```

### Log Management

**Rotate logs:**
```bash
# Archive logs daily at 1 AM
0 1 * * * tar -czf /backup/logs_$(date +\%Y\%m\%d).tar.gz /var/log/*.log && rm -f /var/log/*.log
```

**Parse and analyze logs:**
```bash
# Daily log analysis at 11 PM
0 23 * * * /home/user/scripts/analyze-logs.sh
```

### Database Tasks

**Backup database:**
```bash
# PostgreSQL backup daily at 3 AM
0 3 * * * pg_dump -U postgres mydb | gzip > /backup/mydb_$(date +\%Y\%m\%d).sql.gz
```

**Optimize database:**
```bash
# MySQL optimize tables weekly
@weekly mysqlcheck -u root -pPASSWORD --optimize --all-databases
```

### DevOps Automation

**Git repository sync:**
```bash
# Pull latest code every 10 minutes
*/10 * * * * cd /var/www/app && git pull origin main
```

**Docker cleanup:**
```bash
# Clean unused Docker resources weekly
@weekly docker system prune -af
```

**SSL certificate check:**
```bash
# Check SSL expiration daily
@daily /home/user/scripts/check-ssl-expiry.sh
```

---

## Cron Environment

### Understanding Cron's Environment

**Key differences from interactive shell:**
- Minimal PATH (usually just `/usr/bin:/bin`)
- No aliases or functions
- Different HOME, SHELL, LOGNAME
- No terminal (non-interactive)

**Check cron environment:**
```bash
# Add to crontab
* * * * * env > /tmp/cron-env.txt

# Wait a minute, then check
cat /tmp/cron-env.txt
```

### Setting Cron Environment

**Set variables in crontab:**
```bash
# Environment settings
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin:/home/user/bin
HOME=/home/user
MAILTO=admin@example.com

# Optional custom variables
DATABASE_URL=postgres://localhost/mydb
API_KEY=secret123

# Jobs
0 2 * * * /home/user/backup.sh
```

**Source shell configuration:**
```bash
# Source .bashrc in script
0 2 * * * /bin/bash -l -c '/home/user/backup.sh'

# Or in the script itself:
#!/bin/bash
source ~/.bashrc
# Rest of script...
```

---

## Troubleshooting Cron Jobs

### Common Issues

**1. Cron job not running:**

```bash
# Check if cron is running
systemctl status cron     # Debian/Ubuntu
systemctl status crond    # RHEL/CentOS

# Start if not running
sudo systemctl start cron
sudo systemctl enable cron

# Check crontab syntax
crontab -l

# Check system log
grep CRON /var/log/syslog       # Debian/Ubuntu
grep CRON /var/log/cron         # RHEL/CentOS
```

**2. Command not found:**

```bash
# Use absolute paths
0 2 * * * /usr/bin/python3 /home/user/script.py

# Or set PATH
PATH=/usr/local/bin:/usr/bin:/bin
0 2 * * * python3 /home/user/script.py

# Or use which to find command
which python3
# Output: /usr/bin/python3
```

**3. Permission denied:**

```bash
# Make script executable
chmod +x /home/user/script.sh

# Or specify interpreter
0 2 * * * /bin/bash /home/user/script.sh
```

**4. Not receiving emails:**

```bash
# Check MAILTO is set
crontab -l | grep MAILTO

# Set it if missing
MAILTO=your-email@example.com

# Install mail utility if needed
sudo apt install mailutils
```

**5. Script works manually but not in cron:**

```bash
# Different environment - check PATH, HOME, etc.

# Solution: Make script self-contained
#!/bin/bash

# Set environment
export PATH=/usr/local/bin:/usr/bin:/bin
export HOME=/home/user

# Source environment if needed
source ~/.bashrc

# Use absolute paths
cd /home/user/app
/usr/bin/python3 script.py
```

### Debugging Cron Jobs

**Test with frequent execution:**
```bash
# Temporarily set to run every minute
* * * * * /home/user/test.sh >> /tmp/test.log 2>&1

# Check log after a minute
cat /tmp/test.log

# Revert to correct schedule after testing
```

**Add debugging to script:**
```bash
#!/bin/bash

# Enable debugging
set -x

# Log start time
echo "Script started at $(date)" >> /tmp/script.log

# Your commands here
command1
command2

# Log end time
echo "Script finished at $(date)" >> /tmp/script.log
```

**Check cron logs:**
```bash
# Debian/Ubuntu
grep CRON /var/log/syslog

# RHEL/CentOS
tail -f /var/log/cron

# Filter by user
grep "$(whoami)" /var/log/syslog | grep CRON
```

---

## Alternative: systemd Timers

Modern systems can use **systemd timers** instead of cron.

**Advantages:**
- More precise timing
- Better logging (journalctl)
- Dependencies between services
- Can run on boot, idle, etc.

**Example systemd timer:**

```bash
# Create service: /etc/systemd/system/backup.service
[Unit]
Description=Daily Backup

[Service]
Type=oneshot
ExecStart=/home/user/backup.sh

# Create timer: /etc/systemd/system/backup.timer
[Unit]
Description=Daily Backup Timer

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target

# Enable and start
sudo systemctl enable backup.timer
sudo systemctl start backup.timer

# Check status
systemctl list-timers
```

---

## Best Practices

### 1. Test Scripts Manually First

```bash
# Test script with same environment as cron
env -i HOME=$HOME SHELL=/bin/bash PATH=/usr/bin:/bin /home/user/script.sh
```

### 2. Log Everything

```bash
# Good logging practice
0 2 * * * /home/user/backup.sh >> /var/log/backup.log 2>&1
```

### 3. Handle Errors

```bash
#!/bin/bash

# Exit on error
set -e

# Error handling
if ! /usr/bin/some-command; then
    echo "Error: Command failed" | mail -s "Cron Error" admin@example.com
    exit 1
fi
```

### 4. Use Locking

```bash
#!/bin/bash

# Prevent multiple instances
LOCKFILE=/tmp/myscript.lock

if [ -f "$LOCKFILE" ]; then
    echo "Script already running"
    exit 1
fi

touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

# Your script here
```

### 5. Document Your Crontabs

```bash
# Add comments explaining what each job does
# Backup database to /backup directory every day at 2 AM
0 2 * * * /home/user/scripts/backup-database.sh

# Send weekly report every Monday at 9 AM
0 9 * * 1 /home/user/scripts/send-report.sh

# Clean up old logs every Sunday at 3 AM
0 3 * * 0 find /var/log -name "*.log" -mtime +30 -delete
```

---

## Quick Reference

### Crontab Commands

```bash
crontab -l              # List your crontab
crontab -e              # Edit your crontab
crontab -r              # Remove your crontab
crontab -l -u user      # List user's crontab (root only)
```

### Time Field Values

```
* * * * *
│ │ │ │ └─ Day of week (0-7, Sun=0 or 7)
│ │ │ └─── Month (1-12)
│ │ └───── Day of month (1-31)
│ └─────── Hour (0-23)
└───────── Minute (0-59)
```

### Special Strings

```bash
@reboot     # At startup
@yearly     # Once a year (0 0 1 1 *)
@monthly    # Once a month (0 0 1 * *)
@weekly     # Once a week (0 0 * * 0)
@daily      # Once a day (0 0 * * *)
@hourly     # Once an hour (0 * * * *)
```

### Common Patterns

```bash
*/5 * * * *             # Every 5 minutes
0 * * * *               # Every hour
0 0 * * *               # Every day at midnight
0 0 * * 0               # Every Sunday at midnight
0 0 1 * *               # First day of month
0 0 1 1 *               # January 1st every year
```

---

## Summary

**Key Concepts:**

1. **Cron** - Time-based job scheduler
2. **Crontab** - Configuration file for cron jobs
3. **Five fields** - Minute, Hour, Day, Month, Weekday
4. **Special strings** - @daily, @hourly, @reboot, etc.
5. **Environment** - Minimal environment, use absolute paths

**Essential Commands:**

- `crontab -e` - Edit crontab
- `crontab -l` - List crontab
- `crontab -r` - Remove crontab

**Best Practices:**

1. Use absolute paths for commands and scripts
2. Redirect output to log files
3. Test scripts manually before scheduling
4. Set proper PATH and environment variables
5. Handle errors gracefully
6. Log everything for debugging
7. Use locking to prevent overlapping runs
8. Document your cron jobs with comments

**Common Uses:**

- Automated backups
- System maintenance
- Log rotation
- Monitoring and alerts
- Database tasks
- Report generation

---

**Master cron for powerful automation and scheduling!**