# Shell History and Command Efficiency

## Introduction

The shell maintains a **command history** - a record of previously executed commands. Mastering shell history features can dramatically improve your productivity by allowing you to quickly recall, edit, and re-execute commands without retyping them.

**Why master shell history?**
- ✅ Work faster by recalling previous commands
- ✅ Avoid retyping long, complex commands
- ✅ Find and fix previous mistakes easily
- ✅ Learn from command history
- ✅ Essential for efficient command-line work

---

## The history Command

### Viewing Command History

**Basic usage:**
```bash
# Show all history
history

# Example output:
  501  cd /var/log
  502  tail -f syslog
  503  grep error syslog
  504  history
```

**Show specific number of commands:**
```bash
# Last 10 commands
history 10

# Last 20 commands
history 20
```

**Search history:**
```bash
# Search for commands containing "git"
history | grep git

# Example output:
  450  git status
  451  git add .
  452  git commit -m "Update"
  480  git push origin main
```

### History File

**Where history is stored:**
```bash
# View history file location
echo $HISTFILE
# Output: /home/user/.bash_history

# View history file directly
cat ~/.bash_history

# Count commands in history
wc -l ~/.bash_history
```

**History file behavior:**
- Written when shell exits
- Read when shell starts
- Stores commands from previous sessions
- Current session in memory until exit

---

## Executing Commands from History

### Using History Numbers

**Execute by history number:**
```bash
# Run command 502
!502

# Example
$ history | grep tail
  502  tail -f /var/log/syslog
$ !502
tail -f /var/log/syslog
```

### Using History Event Designators

**Quick command recall:**

| Syntax | Action | Example |
|--------|--------|---------|
| `!!` | Repeat last command | `sudo !!` |
| `!n` | Execute command number n | `!502` |
| `!-n` | Execute nth previous command | `!-2` |
| `!string` | Execute most recent command starting with string | `!git` |
| `!?string` | Execute most recent command containing string | `!?commit` |
| `^old^new` | Replace first occurrence in last command | `^http^https` |

**Examples:**

```bash
# Forgot sudo
$ apt update
E: Could not open lock file...
$ sudo !!
sudo apt update
[sudo] password: 

# Repeat command from 3 commands ago
$ ls
$ cd /tmp
$ pwd
$ !-3
ls

# Last git command
$ !git
git status

# Last command containing "install"
$ !?install
sudo apt install vim

# Quick substitution
$ ping gogle.com
$ ^gogle^google
ping google.com
```

---

## Interactive History Search

### Reverse Search (Ctrl+R)

**Most powerful history feature:**

```bash
# Press Ctrl+R to enter reverse search
(reverse-i-search)`':

# Start typing to search
(reverse-i-search)`git': git commit -m "Update documentation"

# Press Ctrl+R again to find previous matches
# Press Enter to execute
# Press Ctrl+G or Ctrl+C to cancel
# Press ← or → to edit before executing
```

**Workflow example:**
```bash
# You typed a long docker command hours ago
# Press Ctrl+R
(reverse-i-search)`':

# Type "docker"
(reverse-i-search)`docker': docker run -d --name web -p 80:80 nginx

# That's the one! Press Enter
docker run -d --name web -p 80:80 nginx

# Or press → to edit first
```

### Forward Search (Ctrl+S)

**Search forward in history:**
```bash
# Press Ctrl+R to start reverse search
# Press Ctrl+S to search forward
# (Might need to disable flow control: stty -ixon)
```

**Disable XON/XOFF flow control:**
```bash
# Add to ~/.bashrc
stty -ixon

# Now Ctrl+S works for forward search
```

---

## Word Designators and Modifiers

### Accessing Previous Command Arguments

**Word designators:**

| Syntax | Meaning | Example |
|--------|---------|---------|
| `!^` | First argument of last command | `!^` |
| `!$` | Last argument of last command | `!$` |
| `!*` | All arguments of last command | `!*` |
| `!:n` | nth argument of last command | `!:2` |
| `!:n-m` | Arguments n through m | `!:1-3` |

**Examples:**

```bash
# Repeat first argument
$ cat /var/log/syslog
$ less !^
less /var/log/syslog

# Repeat last argument
$ ls -l /etc/nginx/nginx.conf
$ vim !$
vim /etc/nginx/nginx.conf

# Use all previous arguments
$ echo one two three
$ printf "%s\n" !*
printf "%s\n" one two three

# Specific argument
$ cp file1.txt file2.txt /backup
$ ls !:3
ls /backup

# Range of arguments
$ tar -czf backup.tar.gz file1 file2 file3
$ tar -xzf backup.tar.gz !:2-4
tar -xzf backup.tar.gz file1 file2 file3
```

### Special Shortcuts

**ALT key shortcuts (Meta key):**

| Shortcut | Action |
|----------|--------|
| `Alt+.` or `Esc+.` | Insert last argument of previous command |
| `Alt+*` | Insert all arguments of previous command |
| `Alt+<` | Move to beginning of history |
| `Alt+>` | Move to end of history |

**Example with Alt+. (most useful):**
```bash
$ mkdir /very/long/path/to/directory
# Want to cd there?
# Press Alt+.
$ cd /very/long/path/to/directory

# Press Alt+. again to cycle through previous arguments
```

---

## Command Line Editing

### Keyboard Shortcuts

**Movement:**

| Shortcut | Action |
|----------|--------|
| `Ctrl+A` | Move to beginning of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+B` or `←` | Move back one character |
| `Ctrl+F` or `→` | Move forward one character |
| `Alt+B` | Move back one word |
| `Alt+F` | Move forward one word |

**Editing:**

| Shortcut | Action |
|----------|--------|
| `Ctrl+K` | Cut from cursor to end of line |
| `Ctrl+U` | Cut from cursor to beginning of line |
| `Ctrl+W` | Cut word before cursor |
| `Alt+D` | Cut word after cursor |
| `Ctrl+Y` | Paste (yank) last cut text |
| `Ctrl+_` or `Ctrl+X Ctrl+U` | Undo |

**Deletion:**

| Shortcut | Action |
|----------|--------|
| `Ctrl+D` | Delete character under cursor |
| `Ctrl+H` or `Backspace` | Delete character before cursor |
| `Alt+Backspace` | Delete word before cursor |

**Command execution:**

| Shortcut | Action |
|----------|--------|
| `Ctrl+C` | Cancel current command |
| `Ctrl+L` | Clear screen (keep current line) |
| `Ctrl+Z` | Suspend current command (background) |
| `Enter` | Execute command |

**Example workflow:**
```bash
# Type long command with typo
$ sudo apt install ngins

# Oops, typo at end
# Ctrl+W to delete last word
$ sudo apt install 

# Type correct word
$ sudo apt install nginx

# Or use Alt+B to go back one word
# Backspace to delete 's'
# Add 'x'
```

---

## Tab Completion

### Basic Tab Completion

**How it works:**
```bash
# Type beginning of command/file
$ git st<Tab>

# Completes to:
$ git status

# If multiple matches, press Tab twice
$ git s<Tab><Tab>
show       stash      status     submodule  

# Type more characters to narrow down
$ git st<Tab>
$ git status
```

### Command Completion

```bash
# Command completion
$ fire<Tab>
firefox

# Path completion
$ cd /etc/sys<Tab>
$ cd /etc/systemd/

# Username completion (after ~)
$ cd ~jo<Tab>
$ cd ~john/

# Variable completion (after $)
$ echo $HO<Tab>
$ echo $HOME

# Hostname completion (after @)
$ ssh user@web<Tab>
$ ssh user@webserver
```

### Advanced Completion

**Install bash-completion package:**
```bash
# Debian/Ubuntu
sudo apt install bash-completion

# RHEL/CentOS
sudo yum install bash-completion

# Add to ~/.bashrc if not already there
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
```

**Examples with advanced completion:**
```bash
# Git branch completion
$ git checkout <Tab><Tab>
main    develop    feature/new-ui

# Docker container completion
$ docker exec <Tab><Tab>
web    database    redis

# Package name completion
$ sudo apt install fire<Tab><Tab>
firefox    firejail    firewalld

# SSH hostname completion (from ~/.ssh/config and /etc/hosts)
$ ssh <Tab><Tab>
webserver    database    staging

# Process name completion (for kill)
$ killall fire<Tab>
$ killall firefox
```

---

## History Configuration

### Environment Variables

**Configure history behavior:**

```bash
# Add to ~/.bashrc

# Number of commands in memory during session
export HISTSIZE=10000

# Number of commands stored in history file
export HISTFILESIZE=20000

# Don't save duplicate commands
export HISTCONTROL=ignoredups

# Don't save commands starting with space
export HISTCONTROL=ignorespace

# Combine: ignore duplicates and spaces
export HISTCONTROL=ignoreboth

# Don't save specific commands
export HISTIGNORE="ls:ll:history:exit:clear"

# Add timestamp to history
export HISTTIMEFORMAT="%F %T "

# Append to history file (don't overwrite)
shopt -s histappend
```

**View with timestamps:**
```bash
# After setting HISTTIMEFORMAT
$ history | tail -5
  501  2024-01-15 14:30:22  cd /var/log
  502  2024-01-15 14:31:45  tail -f syslog
  503  2024-01-15 14:32:10  grep error syslog
  504  2024-01-15 14:35:00  history
```

### Recommended Configuration

**Add to ~/.bashrc:**
```bash
# Increase history size
export HISTSIZE=10000
export HISTFILESIZE=20000

# Ignore duplicates and commands starting with space
export HISTCONTROL=ignoreboth

# Don't record some commands
export HISTIGNORE="ls:ll:ls -la:pwd:clear:history"

# Add timestamps
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "

# Append to history file, don't overwrite
shopt -s histappend

# Save multi-line commands as one entry
shopt -s cmdhist

# Update LINES and COLUMNS after each command
shopt -s checkwinsize

# Save and reload history after each command (for multiple terminals)
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
```

---

## Advanced History Techniques

### History Substitution Modifiers

**Modify previous commands:**

| Modifier | Action | Example |
|----------|--------|---------|
| `:h` | Remove filename, keep path | `!$:h` |
| `:t` | Remove path, keep filename | `!$:t` |
| `:r` | Remove extension | `!$:r` |
| `:e` | Keep extension only | `!$:e` |
| `:s/old/new/` | Substitute first occurrence | `!!:s/http/https/` |
| `:gs/old/new/` | Substitute all occurrences | `!!:gs/http/https/` |

**Examples:**

```bash
# Extract directory from path
$ ls /var/log/nginx/access.log
$ cd !$:h
cd /var/log/nginx

# Extract filename
$ cat /var/log/nginx/access.log
$ less !$:t
less access.log

# Remove file extension
$ gcc program.c
$ ./!$:r
./program

# Substitution
$ echo "http://example.com"
http://example.com
$ !!:s/http/https/
echo "https://example.com"
https://example.com
```

### Multiple Terminal Windows

**Sync history across terminals:**

```bash
# Add to ~/.bashrc
# Save and reload history after each command
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# Or simpler version
PROMPT_COMMAND="history -a; history -n"
```

**What it does:**
- `history -a` - Append current session to history file
- `history -c` - Clear current session history
- `history -r` - Read history file into current session
- `history -n` - Read new entries from history file

---

## Practical Workflows

### Finding and Fixing Mistakes

```bash
# You ran a command with a typo
$ systemctl status ngins
Unit ngins.service could not be found.

# Quick fix with substitution
$ ^ngins^nginx
systemctl status nginx

# Or use Ctrl+R to find correct command
# Press Ctrl+R, type "nginx"
```

### Repeating Complex Commands

```bash
# You ran a complex docker command
$ docker run -d --name web --restart unless-stopped -p 80:80 -v /data:/usr/share/nginx/html nginx:latest

# Later, want to run similar command for different service
$ !docker
# Brings it back, edit as needed
$ docker run -d --name api --restart unless-stopped -p 8080:8080 -v /data/api:/app myapi:latest
```

### Building Commands Incrementally

```bash
# Start with basic command
$ ssh webserver

# Add options one by one (using Alt+. to recall arguments)
$ ssh -v webserver     # Add verbose
$ ssh -v -p 2222 webserver     # Add port
$ ssh -v -p 2222 -i ~/.ssh/id_rsa webserver     # Add key
```

---

## Security Considerations

### Sensitive Data in History

**Problem:** Passwords and secrets in command history

**Solutions:**

**1. Start command with space (if HISTCONTROL=ignorespace):**
```bash
# Note the leading space
$  mysql -u root -pSECRETPASSWORD mydb
# Won't be saved to history
```

**2. Read password from file or prompt:**
```bash
# Read from file
$ mysql -u root -p$(cat /secure/db-password) mydb

# Prompt for password
$ mysql -u root -p mydb
Enter password: 
```

**3. Temporarily disable history:**
```bash
# Disable for current session
$ set +o history

# Run sensitive commands
$ mysql -u root -pSECRET mydb

# Re-enable history
$ set -o history
```

**4. Remove specific command from history:**
```bash
# View history with numbers
$ history | grep -n "password"
  502  mysql -u root -pSECRET mydb

# Delete that line
$ history -d 502

# Or delete and write immediately
$ history -d 502 && history -w
```

**5. Clear all history:**
```bash
# Clear current session
$ history -c

# Clear history file
$ cat /dev/null > ~/.bash_history

# Or
$ > ~/.bash_history
```

---

## Troubleshooting

### History Not Saving

**Problem:** Commands don't appear in history after logout

**Check:**
```bash
# Check if HISTFILE is set
echo $HISTFILE

# Check if history file exists and is writable
ls -la ~/.bash_history

# Check HISTFILESIZE
echo $HISTFILESIZE
```

**Fix:**
```bash
# Ensure HISTFILESIZE is set
export HISTFILESIZE=20000

# Ensure histappend is enabled
shopt -s histappend

# Manually save history
history -w
```

### History Not Shared Between Terminals

**Problem:** Commands from one terminal don't appear in others

**Solution:** Add to ~/.bashrc
```bash
PROMPT_COMMAND="history -a; history -n"
```

### History File Corrupted

**Fix:**
```bash
# Backup current history
cp ~/.bash_history ~/.bash_history.backup

# Clear corrupted file
> ~/.bash_history

# Start new shell
bash
```

---

## Quick Reference

### History Commands

```bash
history                  # Show all history
history 10               # Last 10 commands
history | grep git       # Search history
!!                       # Repeat last command
!n                       # Execute command number n
!-n                      # Execute nth previous command
!string                  # Execute last command starting with string
!?string                 # Execute last command containing string
!$                       # Last argument of last command
!^                       # First argument of last command
!*                       # All arguments of last command
^old^new                 # Quick substitution
```

### Keyboard Shortcuts

```bash
Ctrl+R                   # Reverse search
Ctrl+S                   # Forward search (after stty -ixon)
Alt+.                    # Insert last argument
Tab                      # Auto-complete
Ctrl+A / Ctrl+E          # Beginning / End of line
Ctrl+K / Ctrl+U          # Cut to end / beginning
Ctrl+W                   # Delete word
Ctrl+Y                   # Paste
Ctrl+L                   # Clear screen
```

### Configuration

```bash
HISTSIZE=10000           # Commands in memory
HISTFILESIZE=20000       # Commands in file
HISTCONTROL=ignoreboth   # Ignore duplicates and spaces
HISTIGNORE="ls:pwd"      # Commands to ignore
HISTTIMEFORMAT="%F %T "  # Add timestamps
shopt -s histappend      # Append, don't overwrite
```

---

## Summary

**Key Concepts:**

1. **History** - Record of previously executed commands
2. **History file** - ~/.bash_history stores commands
3. **Event designators** - `!!`, `!n`, `!string` to recall commands
4. **Word designators** - `!$`, `!^`, `!*` to reuse arguments
5. **Reverse search** - Ctrl+R for interactive search

**Essential Shortcuts:**

- `Ctrl+R` - Reverse search (most important!)
- `!!` - Repeat last command
- `!$` - Last argument of last command
- `Alt+.` - Insert last argument (repeatable)
- `Tab` - Auto-complete

**Best Practices:**

1. Increase HISTSIZE and HISTFILESIZE
2. Use HISTCONTROL=ignoreboth
3. Enable histappend
4. Add timestamps with HISTTIMEFORMAT
5. Use Ctrl+R frequently
6. Master Tab completion
7. Don't store sensitive data in history
8. Use space prefix for sensitive commands

**Productivity Boosters:**

- Use `Ctrl+R` instead of retyping commands
- Use `Alt+.` to reuse arguments
- Use `Tab` completion everywhere
- Use `!!` with `sudo` frequently
- Learn keyboard shortcuts

---

**Master shell history for maximum command-line efficiency!**