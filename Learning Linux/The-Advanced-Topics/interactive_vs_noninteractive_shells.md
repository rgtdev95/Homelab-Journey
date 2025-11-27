# Interactive vs Non-Interactive Shells

## Introduction

Understanding the difference between interactive and non-interactive shells is crucial for properly configuring your Linux environment. Different types of shells load different configuration files, which affects environment variables, aliases, and functions.

**Why does this matter?**
- ✅ Understand where to put your customizations
- ✅ Troubleshoot configuration issues
- ✅ Write better scripts
- ✅ Configure SSH and automated tasks correctly
- ✅ Optimize shell startup performance

---

## Shell Types Overview

### Four Main Shell Types

| Type | Description | When It Occurs | Config Files Loaded |
|------|-------------|----------------|---------------------|
| **Interactive Login** | Shell after login | SSH sessions, virtual consoles | `/etc/profile`, `~/.bash_profile`, `~/.bash_login`, `~/.profile` |
| **Interactive Non-Login** | Shell in a shell | Terminal in GUI, running `bash` | `/etc/bash.bashrc`, `~/.bashrc` |
| **Non-Interactive Login** | Rare edge case | Some automated tasks | `/etc/profile`, `~/.bash_profile` |
| **Non-Interactive Non-Login** | Scripts | Running bash scripts | None (only `BASH_ENV` if set) |

**Quick Decision Tree:**
1. Is it a shell you can type into? → **Interactive**
2. Did you provide username/password? → **Login**

---

## Interactive Shells

### What is an Interactive Shell?

**Interactive Shell:**
A shell that accepts commands from user input and displays output to the terminal.

**Characteristics:**
- Prompt displayed (e.g., `user@host:~$`)
- Can type commands interactively
- Tab completion works
- Command history available
- Job control enabled (Ctrl+Z, `bg`, `fg`)

**Examples:**
```bash
# Terminal emulator in GUI (GNOME Terminal, Konsole, iTerm2)
user@host:~$ 

# SSH session
user@remotehost:~$

# Virtual console (Ctrl+Alt+F1)
login: user
Password: 
user@host:~$
```

### Check if Shell is Interactive

```bash
# Method 1: Check $- variable (contains 'i' if interactive)
echo $-
# Output: himBH  (contains 'i' = interactive)

# Method 2: Check PS1 variable (set only in interactive shells)
if [ -z "$PS1" ]; then
    echo "Non-interactive"
else
    echo "Interactive"
fi

# Method 3: Use tty command
if tty -s; then
    echo "Interactive"
else
    echo "Non-interactive"
fi
```

---

## Login Shells

### What is a Login Shell?

**Login Shell:**
The first shell started when you log into a system, requiring authentication.

**Characteristics:**
- Starts with authentication (username/password, SSH key)
- First character of $0 is `-` (e.g., `-bash`)
- Reads login-specific configuration files
- Sets up complete user environment

**Examples:**
```bash
# SSH into remote server
ssh user@server

# Virtual console login (Ctrl+Alt+F1)
# Enter username and password

# Login with su command
su - username

# Mac Terminal.app (configured as login shell)
```

### Check if Shell is Login

```bash
# Method 1: Check shopt option
shopt -q login_shell && echo 'Login' || echo 'Not login'

# Method 2: Check $0 (starts with - if login)
echo $0
# Output: -bash (login) or bash (non-login)

# Method 3: Use case statement
case $0 in
    -*) echo "Login shell" ;;
    *) echo "Not login shell" ;;
esac
```

---

## Non-Interactive Shells

### What is a Non-Interactive Shell?

**Non-Interactive Shell:**
A shell that executes commands from a script or command string without user interaction.

**Characteristics:**
- No prompt displayed
- Commands come from script or command-line argument
- Exits after completing commands
- Minimal configuration loaded
- No job control

**Examples:**
```bash
# Running a script
./myscript.sh

# Command via SSH
ssh user@server 'ls -l'

# Cron job
0 2 * * * /home/user/backup.sh

# Command with -c option
bash -c 'echo "Hello"'

# Pipe to bash
echo 'ls -l' | bash
```

---

## Configuration File Loading

### Interactive Login Shell

**Files loaded (in order):**

1. `/etc/profile` - System-wide initialization
2. First of these found:
   - `~/.bash_profile`
   - `~/.bash_login`
   - `~/.profile`

**Example `/etc/profile`:**
```bash
# System-wide environment and startup programs
PATH="/usr/local/bin:/usr/bin:/bin"
export PATH
```

**Example `~/.bash_profile`:**
```bash
# User's personal initialization

# Source .bashrc for interactive sessions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User-specific environment variables
export PATH="$HOME/bin:$PATH"
```

### Interactive Non-Login Shell

**Files loaded:**

1. `/etc/bash.bashrc` - System-wide interactive configuration (Debian/Ubuntu)
2. `~/.bashrc` - User-specific interactive configuration

**Example `~/.bashrc`:**
```bash
# User's personal aliases and functions

# Aliases
alias ll='ls -l'
alias la='ls -la'

# Environment variables
export EDITOR=vim

# Functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Prompt customization
PS1='\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ '
```

### Non-Interactive Non-Login Shell (Scripts)

**Files loaded:**
- None by default
- Only if `BASH_ENV` variable is set and points to a file

**Example:**
```bash
# Set BASH_ENV
export BASH_ENV="$HOME/.bashenv"

# Now scripts will source ~/.bashenv
./myscript.sh
```

**Note:** Generally, scripts should not rely on `BASH_ENV`. Make scripts self-contained.

---

## Best Practices for Configuration

### The Standard Setup

**Goal:** Same environment for both login and non-login shells.

**Strategy:** Source `.bashrc` from `.bash_profile`

**~/.bash_profile:**
```bash
# Executed for login shells

# Source .bashrc if it exists
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Login-specific settings
# (These only run once per login)
echo "Welcome, $USER! Today is $(date '+%A, %B %d, %Y')"
```

**~/.bashrc:**
```bash
# Executed for interactive non-login shells
# (Also sourced by .bash_profile for login shells)

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
alias ll='ls -l'
alias la='ls -la'
alias ..='cd ..'

# Environment variables
export EDITOR=vim
export PATH="$HOME/bin:$PATH"

# Functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Prompt
PS1='\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ '

# Shell options
shopt -s histappend
shopt -s checkwinsize
```

### What Goes Where?

**In `~/.bash_profile` or `~/.profile` (login-specific):**
- Welcome messages
- One-time initialization
- Starting SSH agent
- Setting up display for X11

**In `~/.bashrc` (interactive):**
- Aliases
- Shell functions
- Prompt customization
- Shell options (shopt)
- Interactive completions
- PATH modifications (if needed by interactive commands)

**In scripts (self-contained):**
- Use absolute paths
- Set variables explicitly
- Don't rely on aliases or functions
- Use `#!/bin/bash` shebang

---

## Practical Examples

### SSH Sessions

**Interactive login shell:**
```bash
# User SSH into server
ssh user@server

# Loads: /etc/profile → ~/.bash_profile → ~/.bashrc (if sourced)
```

**Non-interactive command:**
```bash
# Run single command via SSH
ssh user@server 'ls -l'

# Loads: Minimal (no interactive config)
# Solution: Use bash -l to force login
ssh user@server 'bash -l -c "ls -l"'
```

### Cron Jobs

**Cron runs non-interactive, non-login shells:**
```bash
# Crontab entry
0 2 * * * /home/user/backup.sh

# Problem: PATH and aliases from .bashrc not available

# Solution 1: Use full paths in script
#!/bin/bash
/usr/bin/rsync -av /data /backup

# Solution 2: Source .bashrc in script
#!/bin/bash
source ~/.bashrc
rsync -av /data /backup

# Solution 3: Set PATH in crontab
PATH=/usr/local/bin:/usr/bin:/bin
0 2 * * * /home/user/backup.sh
```

### Running Scripts

**Script doesn't see aliases:**
```bash
# ~/.bashrc
alias ll='ls -l'

# Script: myscript.sh
#!/bin/bash
ll  # ERROR: ll: command not found

# Why: Aliases not expanded in non-interactive shells

# Solution 1: Use full command
ls -l

# Solution 2: Enable alias expansion (not recommended)
#!/bin/bash
shopt -s expand_aliases
source ~/.bashrc
ll  # Now works
```

### su vs su -

**Different behavior:**
```bash
# su (non-login shell)
su username
# Keeps current environment, loads ~/.bashrc

# su - (login shell)
su - username
# Fresh environment, loads ~/.bash_profile

# Example
echo $PATH
# /usr/local/bin:/usr/bin:/bin

su otheruser
echo $PATH
# /usr/local/bin:/usr/bin:/bin (same PATH)

exit

su - otheruser
echo $PATH
# /home/otheruser/bin:/usr/local/bin:/usr/bin:/bin (otheruser's PATH)
```

### Terminal in GUI

**Non-login interactive shell:**
```bash
# Open GNOME Terminal, Konsole, xterm, etc.
# Loads: /etc/bash.bashrc → ~/.bashrc

# To make it a login shell:
# - Edit terminal settings
# - Or run: bash --login
```

---

## Debugging Configuration

### Check What Files Are Loaded

**Add debug statements:**
```bash
# Add to each config file
echo "Loading ~/.bashrc" >&2
echo "Loading ~/.bash_profile" >&2

# Run shell and see what gets loaded
bash --login
bash
```

### Test Configuration

```bash
# Test .bashrc without logging out
source ~/.bashrc

# Test as login shell
bash --login

# Test as non-login shell
bash

# Test .bash_profile
source ~/.bash_profile
```

### Common Issues

**Problem 1: Aliases not working in scripts**
```bash
# Scripts are non-interactive, aliases disabled

# Solution: Use functions or full commands
```

**Problem 2: PATH not set in cron jobs**
```bash
# Cron uses minimal environment

# Solution: Set PATH explicitly in crontab or script
```

**Problem 3: Different behavior in SSH vs local terminal**
```bash
# SSH typically starts login shell
# Local terminal starts non-login shell

# Solution: Source .bashrc from .bash_profile for consistency
```

---

## Shell Startup Optimization

### Slow Shell Startup?

**Diagnose:**
```bash
# Time .bashrc execution
time source ~/.bashrc

# Profile with set -x
bash -x -c 'source ~/.bashrc' 2>&1 | less
```

**Common causes:**
- Running slow commands in .bashrc
- Loading too many completion scripts
- Checking network resources

**Solutions:**
```bash
# Move slow commands to .bash_profile (login only)

# Lazy-load completions
# Instead of:
source /etc/bash_completion

# Use:
if [ -f /etc/bash_completion ] && [[ $- == *i* ]]; then
    . /etc/bash_completion
fi

# Cache command output
# Bad:
PS1="$(long_command)$ "

# Good:
if [ -z "$CACHED_VALUE" ]; then
    CACHED_VALUE=$(long_command)
fi
PS1="$CACHED_VALUE$ "
```

---

## Advanced: Shell Invocation Modes

### Command Line Options

```bash
# Login shell
bash --login
bash -l

# Interactive shell
bash -i

# Run command
bash -c 'command'

# Read from stdin
echo 'ls -l' | bash

# Non-interactive script
bash script.sh
```

### Detect Shell Mode in Script

```bash
#!/bin/bash

# Check if interactive
if [[ $- == *i* ]]; then
    echo "Interactive shell"
else
    echo "Non-interactive shell"
fi

# Check if login
if shopt -q login_shell; then
    echo "Login shell"
else
    echo "Non-login shell"
fi

# Check if standard input is a terminal
if [ -t 0 ]; then
    echo "Running from terminal"
else
    echo "Running from pipe/redirect"
fi
```

---

## Quick Reference

### Shell Type Detection

```bash
# Interactive?
[[ $- == *i* ]] && echo "Interactive" || echo "Non-interactive"

# Login?
shopt -q login_shell && echo "Login" || echo "Non-login"

# From terminal?
tty -s && echo "Terminal" || echo "No terminal"
```

### Configuration Files

```bash
# Login shell reads (first found):
/etc/profile
~/.bash_profile
~/.bash_login
~/.profile

# Non-login interactive shell reads:
/etc/bash.bashrc  # Debian/Ubuntu
~/.bashrc

# All shells read on logout:
~/.bash_logout
```

### Force Shell Type

```bash
# Force login shell
bash --login
bash -l

# Force interactive shell
bash -i

# Force non-interactive
bash -c 'commands'
```

---

## Summary

**Key Concepts:**

1. **Interactive** - You can type commands and see output
2. **Login** - Started after authentication (username/password)
3. **Non-Interactive** - Runs scripts or commands without user input
4. **Configuration files** - Different files loaded for different shell types

**Shell Types:**

| Type | Example | Config Files |
|------|---------|--------------|
| Interactive Login | SSH session | `.bash_profile` → `.bashrc` |
| Interactive Non-Login | Terminal in GUI | `.bashrc` |
| Non-Interactive | Script | None (or `$BASH_ENV`) |

**Best Practices:**

1. Put interactive settings (aliases, prompts) in `~/.bashrc`
2. Put login settings (environment, welcome) in `~/.bash_profile`
3. Source `~/.bashrc` from `~/.bash_profile` for consistency
4. Make scripts self-contained (don't rely on aliases)
5. Use full paths in cron jobs
6. Check shell type before loading interactive features
7. Test configuration changes before committing

**Common Patterns:**

```bash
# Standard ~/.bash_profile
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Standard ~/.bashrc
[[ $- != *i* ]] && return  # Exit if not interactive

# Standard script
#!/bin/bash
# Self-contained, use full paths
```

---

**Understanding shell types helps you configure your environment correctly!**