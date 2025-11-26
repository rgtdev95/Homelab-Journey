# Finding Files and Directories in Linux

## Introduction

Being able to quickly find files and directories is an essential Linux skill. Whether you're searching for configuration files, log files, or documents, Linux provides powerful tools to locate exactly what you need.

This guide covers two main commands:
- **`find`** - Powerful, real-time search with extensive filtering options
- **`locate`** - Fast database search for quick lookups

---

## The find Command

The `find` command recursively searches for files and directories that match your criteria. It searches in real-time, evaluating every file it encounters.

### Basic Syntax

```bash
find [path...] [expression]
```

- **path** - Where to start searching (defaults to current directory)
- **expression** - Criteria to match (name, size, date, etc.)

### Simple Example

Search everything in the current directory:

```bash
$ find
.
./.profile
./.bash_history
./PerformanceReviews
./PerformanceReviews/Fred
./PerformanceReviews/current
./sales.data
```

---

## Finding by Name

### Case-Sensitive Name Search

```bash
find . -name pattern
```

**Examples:**

```bash
# Find exact filename
find . -name sales.data

# Find all .txt files
find . -name "*.txt"

# Find files starting with "test"
find . -name "test*"

# Find files in /var/log
find /var/log -name "*.log"
```

### Case-Insensitive Name Search

```bash
find . -iname pattern
```

**Example:**

```bash
$ find /opt -iname apache
/opt/web/Apache
/opt/apache
/opt/config/apache.conf
```

This finds "apache", "Apache", "APACHE", etc.

**Practical use:**

```bash
# Find README files regardless of case
find . -iname "readme*"

# Results: README.md, readme.txt, ReadMe, etc.
```

---

## Finding by File Type

Use `-type` to filter by file type:

| Flag | Type |
|------|------|
| `f` | Regular file |
| `d` | Directory |
| `l` | Symbolic link |
| `b` | Block device |
| `c` | Character device |

**Examples:**

```bash
# Find only directories
find . -type d

# Find only files
find . -type f

# Find only symbolic links
find . -type l

# Find directories named "config"
find /etc -type d -name "config"

# Find all Python files (not directories)
find . -type f -name "*.py"
```

---

## Finding by Size

Use `-size` to find files based on size:

### Size Units

| Unit | Meaning |
|------|---------|
| `c` | Bytes |
| `k` | Kilobytes (1024 bytes) |
| `M` | Megabytes (1024 KB) |
| `G` | Gigabytes (1024 MB) |

### Size Operators

| Operator | Meaning |
|----------|---------|
| `+n` | Greater than n |
| `-n` | Less than n |
| `n` | Exactly n |

**Examples:**

```bash
# Files larger than 300MB
find . -size +300M

# Files smaller than 1KB
find . -size -1k

# Files exactly 512 bytes
find . -size 512c

# Files between 1MB and 10MB
find . -size +1M -size -10M

# Find large log files
find /var/log -type f -size +100M
```

**Find disk space hogs:**

```bash
# Find files larger than 1GB in /home
find /home -type f -size +1G -exec ls -lh {} \;
```

---

## Finding by Modification Time

Use `-mtime` to find files by age (in days):

| Operator | Meaning |
|----------|---------|
| `+n` | Modified more than n days ago |
| `-n` | Modified less than n days ago |
| `n` | Modified exactly n days ago |

**Examples:**

```bash
# Files modified in the last 7 days
find . -mtime -7

# Files modified more than 30 days ago
find . -mtime +30

# Files modified 10-13 days ago
find . -mtime +10 -mtime -13

# Files NOT modified in the last 90 days (candidates for cleanup)
find /var/log -type f -mtime +90
```

### Other Time-Based Options

```bash
# Changed (metadata) in last 24 hours
find . -ctime -1

# Accessed in last 24 hours
find . -atime -1

# Modified in last 60 minutes
find . -mmin -60

# Modified more than 2 hours ago
find . -mmin +120
```

**Practical examples:**

```bash
# Find recently modified config files
find /etc -name "*.conf" -mtime -7

# Find old backup files
find /backup -name "*.bak" -mtime +365

# Find files modified today
find . -mtime 0
```

---

## Finding Newer/Older Than a File

Use `-newer` to find files modified after another file:

```bash
find . -newer reference_file
```

**Examples:**

```bash
# Find files newer than b.txt
find . -newer b.txt

# Find directories newer than b.txt
find . -type d -newer b.txt

# Find files modified after last backup
find . -type f -newer /backup/last_backup.txt
```

**Use case - Incremental backups:**

```bash
# Create timestamp file
touch /tmp/last_backup_time

# Do backup...

# Next time, find only files changed since last backup
find /data -type f -newer /tmp/last_backup_time
```

---

## Finding by Permissions

Find files with specific permissions:

```bash
# Find files with 777 permissions (security risk!)
find . -perm 777

# Find files with SUID bit set
find / -perm -4000

# Find world-writable files
find . -perm -002

# Find executable files
find . -type f -perm -111
```

**Security audit examples:**

```bash
# Find potential security issues
find /var/www -type f -perm 777

# Find SUID/SGID files (could be security risk)
find / -perm /6000 -type f 2>/dev/null
```

---

## Finding by Owner/Group

```bash
# Find files owned by specific user
find . -user bob

# Find files owned by specific group
find . -group sales

# Find files owned by bob in sales group
find . -user bob -group sales

# Find files with no valid owner (orphaned)
find / -nouser

# Find files with no valid group
find / -nogroup
```

**Practical use:**

```bash
# Find all files owned by departed employee
find /home -user oldemployee

# Find files in shared directory not owned by correct group
find /shared -not -group team
```

---

## Using -ls Option

Display detailed information for found files:

```bash
find . -name "s*" -ls
```

**Output:**

```bash
52 11 -rw-r--r-- 1 bob users 10400 Sep 27 08:52 ./sales.data
48  1 -rw-r--r-- 1 bob users    35 Sep 27 08:47 ./tpsreports/sr.txt
53 112 -rw-r--r-- 1 bob sales  2566 Sep 27 08:54 ./sales-lecture.mp3
```

Shows inode, blocks, permissions, owner, group, size, date, and path.

---

## Executing Commands with -exec

Run a command on each file found:

### Syntax

```bash
find . -exec command {} \;
```

- `{}` - Placeholder for current file
- `\;` - Terminates the command (must be escaped)

**Alternative syntax (faster):**

```bash
find . -exec command {} +
```

The `+` passes multiple files at once instead of running the command for each file.

### Examples

**Identify file types:**

```bash
$ find . -exec file {} \;
.: directory
./.profile: ASCII text
./.bash_history: ASCII text
./sales.data: data
```

**Delete old log files:**

```bash
# Delete files older than 30 days
find /var/log -name "*.log" -mtime +30 -exec rm {} \;

# Safer: use -ok for confirmation
find /var/log -name "*.log" -mtime +30 -ok rm {} \;
```

**Change permissions:**

```bash
# Make all .sh files executable
find . -name "*.sh" -exec chmod +x {} \;

# Fix permissions on directories
find . -type d -exec chmod 755 {} \;

# Fix permissions on files
find . -type f -exec chmod 644 {} \;
```

**Copy files:**

```bash
# Copy all .conf files to backup directory
find /etc -name "*.conf" -exec cp {} /backup/ \;
```

**Search inside files:**

```bash
# Find files containing specific text
find . -type f -exec grep -H "error" {} \;

# Better: use grep with find
find . -type f -name "*.log" -exec grep -l "ERROR" {} \;
```

**Calculate total size:**

```bash
# Size of all .log files
find . -name "*.log" -exec du -ch {} + | tail -1
```

**Move files:**

```bash
# Move all .tmp files to /tmp
find . -name "*.tmp" -exec mv {} /tmp/ \;
```

---

## Combining Multiple Criteria

### AND Logic (both conditions must match)

```bash
# Files named "test*" larger than 1MB
find . -name "test*" -size +1M

# Files modified in last 7 days AND owned by bob
find . -mtime -7 -user bob

# .log files larger than 100MB
find /var/log -name "*.log" -size +100M
```

### OR Logic (either condition matches)

Use `-o` for OR:

```bash
# Files ending in .txt OR .doc
find . -name "*.txt" -o -name "*.doc"

# Files owned by bob OR alice
find . -user bob -o -user alice

# Files larger than 1GB OR older than 365 days
find . -size +1G -o -mtime +365
```

### NOT Logic (negate condition)

Use `-not` or `!`:

```bash
# All files EXCEPT .txt files
find . -not -name "*.txt"
find . ! -name "*.txt"

# Files NOT owned by root
find . -not -user root

# All files except in .git directory
find . -not -path "*/.git/*"
```

### Complex Combinations

```bash
# .log files modified in last week, larger than 10MB, NOT in /tmp
find . -name "*.log" -mtime -7 -size +10M -not -path "/tmp/*"

# Executable files owned by root with SUID bit
find / -type f -user root -perm -4000 2>/dev/null
```

---

## Practical find Examples

### Clean Up Old Files

```bash
# Find and delete files older than 90 days
find /tmp -type f -mtime +90 -delete

# Delete empty files
find . -type f -empty -delete

# Delete empty directories
find . -type d -empty -delete
```

### Find and Archive

```bash
# Create archive of files modified in last 7 days
find . -type f -mtime -7 -print | tar -czf backup.tar.gz -T -
```

### Security Audits

```bash
# Find world-writable files
find / -type f -perm -002 2>/dev/null

# Find files with no owner
find / -nouser -o -nogroup 2>/dev/null

# Find SUID/SGID executables
find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -l {} \; 2>/dev/null
```

### Find Large Files

```bash
# Top 10 largest files
find / -type f -exec du -h {} + 2>/dev/null | sort -rh | head -10

# Files larger than 500MB
find / -type f -size +500M -exec ls -lh {} \; 2>/dev/null
```

### Find Duplicate Files

```bash
# Find files with same name in different locations
find . -type f -printf "%f\n" | sort | uniq -d
```

### Search Source Code

```bash
# Find all Python files containing "TODO"
find . -name "*.py" -exec grep -l "TODO" {} \;

# Count lines of code in all .js files
find . -name "*.js" -exec wc -l {} + | tail -1
```

---

## The locate Command

`locate` is a much faster alternative to `find` for simple name-based searches. It queries a pre-built database instead of scanning the filesystem in real-time.

### Basic Syntax

```bash
locate pattern
```

### How locate Works

1. A daily cron job runs `updatedb` to index all files
2. `locate` queries this database (very fast!)
3. Returns any file path containing the pattern

### Advantages

- **Extremely fast** - searches database, not filesystem
- **Simple syntax** - just provide the pattern
- **Finds files anywhere** on the system instantly

### Disadvantages

- **Not real-time** - database updated once daily
- **Won't find new files** created since last update
- **May show deleted files** until next update
- **Not always installed** or enabled on servers

### Examples

```bash
# Find files containing "tpsrep"
$ locate tpsrep
/home/bob/tpsreports
/home/bob/tpsreports/coversheet.doc
/home/bob/tpsreports/sales-report.txt

# Find nginx config files
locate nginx.conf

# Find all .bashrc files
locate .bashrc

# Case-insensitive search
locate -i readme
```

### When locate is Not Available

```bash
$ locate bob
locate: /var/locatedb: No such file or directory
```

If you see this, either:
1. `locate` is not installed
2. The database hasn't been created yet

**Install locate:**

```bash
# Ubuntu/Debian
sudo apt install mlocate

# RHEL/CentOS
sudo yum install mlocate

# Update the database
sudo updatedb
```

### Updating the Database Manually

```bash
# Update database now (don't wait for daily cron)
sudo updatedb
```

This is useful after:
- Installing new software
- Creating important files you need to find
- Restoring backups

### locate Options

```bash
# Case-insensitive search
locate -i pattern

# Count matches only
locate -c pattern

# Limit results to 10
locate -l 10 pattern

# Show only existing files (check if file still exists)
locate -e pattern

# Use regex pattern
locate --regex pattern
```

**Examples:**

```bash
# Count how many .conf files exist
locate -c ".conf"

# Find existing Python files
locate -e "*.py"

# Show first 5 matches
locate -l 5 python
```

---

## find vs locate: When to Use Which?

### Use `find` when:

✅ You need real-time results
✅ Searching by size, date, permissions, owner
✅ Need to perform actions on found files
✅ Searching specific directory tree
✅ Need complex filtering criteria
✅ Working with recently created files

### Use `locate` when:

✅ Simple name-based search
✅ Need speed (searching entire filesystem)
✅ Know part of the filename
✅ File has been on system for at least a day
✅ Just need to know file location

### Comparison

| Feature | find | locate |
|---------|------|--------|
| **Speed** | Slower (real-time) | Very fast (database) |
| **Real-time** | Yes | No (daily updates) |
| **Complex filters** | Yes | Limited |
| **New files** | Finds immediately | After updatedb |
| **Execute commands** | Yes (`-exec`) | No |
| **Deleted files** | Won't find | May show until update |
| **Always available** | Yes | Sometimes not installed |

---

## Practical Workflows

### Finding Recently Modified Configs

```bash
# Option 1: Using find (real-time)
find /etc -name "*.conf" -mtime -7

# Option 2: Using locate (if file is older)
locate .conf | grep /etc
```

### Finding Files by Partial Name

```bash
# If you know part of the name
locate partial_name

# If file might be new
find / -name "*partial_name*" 2>/dev/null
```

### Cleaning Up Disk Space

```bash
# Find largest files
find /home -type f -size +100M -exec ls -lh {} \;

# Find old log files
find /var/log -name "*.log" -mtime +30

# Find old temporary files
find /tmp -type f -mtime +7 -delete
```

### Searching for Configuration Files

```bash
# Quick search (if it exists for a while)
locate nginx.conf

# Precise search (real-time)
find /etc -name "nginx.conf"

# All config files modified recently
find /etc -name "*.conf" -mtime -1
```

---

## Suppressing Errors

Both `find` and `locate` may produce permission errors. Suppress them:

```bash
# Redirect errors to /dev/null
find / -name "file" 2>/dev/null

# locate with errors suppressed
locate pattern 2>/dev/null

# Show only real results, hide permission denied
find / -name "*.conf" 2>&1 | grep -v "Permission denied"
```

---

## Quick Reference

### find Command Options

| Option | Description |
|--------|-------------|
| `-name pattern` | Find by name (case-sensitive) |
| `-iname pattern` | Find by name (case-insensitive) |
| `-type f/d/l` | Find by type (file/directory/link) |
| `-size +/-n` | Find by size |
| `-mtime +/-n` | Find by modification time (days) |
| `-mmin +/-n` | Find by modification time (minutes) |
| `-user name` | Find by owner |
| `-group name` | Find by group |
| `-perm mode` | Find by permissions |
| `-newer file` | Find newer than file |
| `-exec cmd {} \;` | Execute command on results |
| `-delete` | Delete found files |
| `-ls` | List with details |

### locate Command Options

| Option | Description |
|--------|-------------|
| `locate pattern` | Search database for pattern |
| `-i` | Case-insensitive |
| `-c` | Count matches |
| `-l n` | Limit to n results |
| `-e` | Only show existing files |
| `--regex` | Use regex pattern |

### Common Patterns

```bash
# Find all Python files
find . -name "*.py"

# Find large files (>100MB)
find . -size +100M

# Find files modified today
find . -mtime 0

# Find and delete old logs
find /var/log -name "*.log" -mtime +30 -delete

# Quick name search
locate filename

# Update locate database
sudo updatedb
```

---

## Best Practices

✅ **DO:**
- Use `locate` for quick name searches
- Use `find` for complex criteria
- Suppress errors with `2>/dev/null` when searching system-wide
- Test `-exec` commands with `-ok` first (asks for confirmation)
- Use `+` instead of `\;` with `-exec` for better performance
- Combine multiple criteria to narrow results

❌ **DON'T:**
- Run `find /` without filters (takes forever)
- Forget to escape special characters in patterns
- Use `-delete` without testing the find expression first
- Rely on `locate` for new files
- Run `updatedb` too frequently (resource intensive)

---

## Troubleshooting Tips

**Problem: Too many results**
- Add more specific filters
- Narrow the search path
- Use multiple conditions

**Problem: Permission denied errors**
- Use `2>/dev/null` to suppress
- Run with `sudo` if needed (be careful!)
- Search in directories you have access to

**Problem: locate doesn't find new file**
- Run `sudo updatedb` to refresh database
- Use `find` instead for real-time search

**Problem: find is too slow**
- Narrow the search path
- Use `locate` if possible
- Add more specific criteria early in the command

---

## Summary

### Key Takeaways

**find:**
- Real-time filesystem search
- Powerful filtering (name, size, date, permissions, owner)
- Can execute commands on results
- Slower but comprehensive

**locate:**
- Fast database search
- Simple name-based searches
- Limited to pattern matching
- Not real-time (daily updates)

### When Starting Out

1. **Use `locate`** for simple "Where is this file?" questions
2. **Use `find`** when you need more control or recent files
3. **Start simple** and add options as needed
4. **Test carefully** before using `-delete` or `-exec`

### Most Useful Commands

```bash
# Quick search
locate filename

# Find by name
find . -name "*.txt"

# Find recent files
find . -mtime -7

# Find large files
find . -size +100M

# Find and do something
find . -name "*.log" -exec rm {} \;
```

---

**Practice these commands regularly to become proficient at finding files quickly and efficiently!**