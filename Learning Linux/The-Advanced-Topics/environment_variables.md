# Environment Variables in Linux

## Introduction

Environment variables are named values stored by the shell and operating system that affect how programs and processes behave. They provide a way to configure system behavior without modifying code or configuration files directly.

**Why are environment variables important?**
- ✅ Configure applications and system behavior
- ✅ Store user preferences and settings
- ✅ Define system paths and locations
- ✅ Pass configuration to programs
- ✅ Essential for DevOps and automation

---

## What Are Environment Variables?

### Definition

**Environment Variable:**
A named value that exists in the shell's environment and can be accessed by programs running in that shell and its child processes.

**Think of them as:**
- Global configuration settings
- System-wide or user-specific variables
- Key-value pairs stored in memory

### Variable Types

**Two types of variables in Linux:**

1. **Shell Variables** - Local to current shell session
2. **Environment Variables** - Available to shell and child processes

```bash
# Shell variable (local only)
MY_VAR="value"

# Environment variable (exported to child processes)
export MY_VAR="value"
```

---

## Viewing Environment Variables

### View All Environment Variables

**Multiple commands to view variables:**

```bash
# Method 1: printenv
printenv

# Method 2: env
env

# Method 3: export (bash)
export

# Method 4: set (shows all variables, including shell variables)
set
```

**Output example:**
```
HOME=/home/john
PATH=/usr/local/bin:/usr/bin:/bin
USER=john
SHELL=/bin/bash
PWD=/home/john
LANG=en_US.UTF-8
```

### View Specific Variable

```bash
# Method 1: printenv
printenv HOME
# Output: /home/john

# Method 2: echo
echo $HOME
# Output: /home/john

# Method 3: printf
printf "%s\n" "$HOME"
# Output: /home/john
```

**Important:** Use `$` prefix when accessing variable value with `echo`.

---

## Common Environment Variables

### System Variables

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `HOME` | User's home directory | `/home/john` |
| `USER` | Current username | `john` |
| `SHELL` | Current shell | `/bin/bash` |
| `TERM` | Terminal type | `xterm-256color` |
| `PWD` | Present working directory | `/home/john/projects` |
| `OLDPWD` | Previous working directory | `/home/john` |
| `PATH` | Directories to search for commands | `/usr/local/bin:/usr/bin:/bin` |
| `LANG` | System language/locale | `en_US.UTF-8` |
| `HOSTNAME` | System hostname | `webserver` |
| `LOGNAME` | Login name | `john` |

### Application Variables

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `EDITOR` | Default text editor | `vim`, `nano`, `emacs` |
| `VISUAL` | Visual editor (GUI) | `code`, `gedit` |
| `PAGER` | Default pager | `less`, `more` |
| `BROWSER` | Default web browser | `firefox`, `chrome` |
| `MAIL` | Mail spool location | `/var/mail/john` |
| `JAVA_HOME` | Java installation directory | `/usr/lib/jvm/java-11` |
| `PYTHONPATH` | Python module search path | `/usr/lib/python3/dist-packages` |
| `NODE_ENV` | Node.js environment | `development`, `production` |

### Display Variables

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `DISPLAY` | X11 display server | `:0`, `:1.0` |
| `XAUTHORITY` | X11 authorization file | `/home/john/.Xauthority` |
| `WAYLAND_DISPLAY` | Wayland display | `wayland-0` |

---

## The PATH Variable

### Understanding PATH

**PATH** is the most important environment variable. It defines directories where the shell looks for executable files.

**View PATH:**
```bash
echo $PATH
# Output: /usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
```

**How it works:**
1. You type a command (e.g., `ls`)
2. Shell searches for `ls` executable in directories listed in PATH
3. Searches left to right (first match wins)
4. If found, executes; if not found, shows "command not found"

### Modifying PATH

**Temporarily add directory:**
```bash
# Add to beginning (highest priority)
export PATH="/new/directory:$PATH"

# Add to end (lowest priority)
export PATH="$PATH:/new/directory"

# Check it worked
echo $PATH
```

**Example:**
```bash
# Add custom scripts directory
export PATH="$HOME/bin:$PATH"

# Now scripts in ~/bin can be run without full path
my-script.sh  # Instead of ~/bin/my-script.sh
```

### Making PATH Changes Permanent

**Add to ~/.bashrc or ~/.bash_profile:**
```bash
# Edit bashrc
nano ~/.bashrc

# Add line
export PATH="$HOME/bin:$PATH"

# Save and reload
source ~/.bashrc
```

**Common directories added to PATH:**
```bash
# User's personal bin
export PATH="$HOME/bin:$PATH"

# User's local bin
export PATH="$HOME/.local/bin:$PATH"

# Custom applications
export PATH="/opt/myapp/bin:$PATH"

# Snap applications
export PATH="/snap/bin:$PATH"
```

---

## Setting Environment Variables

### Temporary Variables (Current Session Only)

**Set shell variable:**
```bash
# Creates variable in current shell only
MY_VAR="value"

# Access it
echo $MY_VAR
# Output: value
```

**Set environment variable:**
```bash
# Export makes it available to child processes
export MY_VAR="value"

# Or in one line
export MY_VAR="value"
```

**Difference example:**
```bash
# Without export
MY_VAR="hello"
bash -c 'echo $MY_VAR'
# Output: (empty - child process can't see it)

# With export
export MY_VAR="hello"
bash -c 'echo $MY_VAR'
# Output: hello
```

### Permanent Variables

**User-specific (add to ~/.bashrc):**
```bash
# Edit bashrc
nano ~/.bashrc

# Add exports
export EDITOR=vim
export PATH="$HOME/bin:$PATH"
export PYTHONPATH="$HOME/python-libs"

# Save and reload
source ~/.bashrc
```

**Login shells (add to ~/.bash_profile or ~/.profile):**
```bash
nano ~/.bash_profile

# Add exports
export JAVA_HOME=/usr/lib/jvm/java-11
export PATH="$JAVA_HOME/bin:$PATH"

# Save and reload
source ~/.bash_profile
```

**System-wide (requires root):**
```bash
# Option 1: Edit /etc/environment
sudo nano /etc/environment

# Add variables (no 'export' needed, no '$' for expansion)
JAVA_HOME=/usr/lib/jvm/java-11

# Option 2: Create file in /etc/profile.d/
sudo nano /etc/profile.d/custom-vars.sh

# Add exports
export JAVA_HOME=/usr/lib/jvm/java-11
export PATH="$JAVA_HOME/bin:$PATH"

# Make executable
sudo chmod +x /etc/profile.d/custom-vars.sh
```

---

## Unsetting Variables

### Remove Variable

```bash
# Create variable
export MY_VAR="value"

# Remove it
unset MY_VAR

# Check it's gone
echo $MY_VAR
# Output: (empty)
```

**Remove from PATH:**
```bash
# Current PATH
echo $PATH
# /usr/local/bin:/home/john/bin:/usr/bin:/bin

# Remove /home/john/bin
export PATH=$(echo $PATH | sed 's|:/home/john/bin||g')

# Or use parameter expansion (bash)
export PATH=${PATH//\/home\/john\/bin:/}
```

---

## Shell Startup Files

### Understanding Startup Files

**Different files for different scenarios:**

| File | Type | When Executed |
|------|------|---------------|
| `/etc/profile` | Login | System-wide, login shells |
| `/etc/bash.bashrc` | Non-login | System-wide, interactive non-login |
| `/etc/environment` | All | System-wide, all shells |
| `~/.bash_profile` | Login | User-specific, login shells |
| `~/.bash_login` | Login | If `~/.bash_profile` doesn't exist |
| `~/.profile` | Login | If neither above exist |
| `~/.bashrc` | Non-login | User-specific, interactive non-login |
| `~/.bash_logout` | Logout | Executed when login shell exits |

### Login vs Non-Login Shells

**Login shell:**
- When you SSH into a server
- When you log in to virtual console (Ctrl+Alt+F1)
- Executes: `/etc/profile`, `~/.bash_profile`, `~/.bash_login`, or `~/.profile`

**Non-login shell:**
- Opening terminal in GUI
- Running `bash` from another shell
- Executes: `/etc/bash.bashrc`, `~/.bashrc`

**Check shell type:**
```bash
# Check if login shell
echo $0
# Output: -bash (login) or bash (non-login)

# Or
shopt -q login_shell && echo 'Login' || echo 'Not login'
```

### Best Practice

**Standard setup:**
```bash
# ~/.bash_profile (login shell)
# Source .bashrc for consistent environment
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# ~/.bashrc (non-login shell)
# Put all your customizations here
export EDITOR=vim
export PATH="$HOME/bin:$PATH"

# Aliases
alias ll='ls -l'
alias la='ls -la'
```

This ensures both login and non-login shells get the same configuration.

---

## Variable Substitution

### Basic Substitution

```bash
# Variable substitution
name="John"
echo "Hello, $name"
# Output: Hello, John

# Braces for clarity
echo "Hello, ${name}!"
# Output: Hello, John!

# Concatenation
greeting="Hello, ${name}! Welcome to $(hostname)."
echo $greeting
# Output: Hello, John! Welcome to webserver.
```

### Default Values

```bash
# Use default if variable is unset or empty
${var:-default}

# Example
echo ${UNDEFINED_VAR:-"default value"}
# Output: default value

# Assign default if unset
${var:=default}

# Example
echo ${MY_VAR:="assigned"}
# Output: assigned
echo $MY_VAR
# Output: assigned (now it's set)
```

### Command Substitution

```bash
# Store command output in variable
current_user=$(whoami)
echo "Current user: $current_user"

current_dir=$(pwd)
echo "Current directory: $current_dir"

file_count=$(ls | wc -l)
echo "Files in directory: $file_count"
```

---

## Practical Examples

### Setting Default Editor

```bash
# Add to ~/.bashrc
export EDITOR=vim
export VISUAL=code

# Now 'crontab -e' uses vim
# And 'git commit' uses vim for commit messages
```

### Java Development

```bash
# Add to ~/.bashrc
export JAVA_HOME=/usr/lib/jvm/java-11
export PATH="$JAVA_HOME/bin:$PATH"

# Verify
java -version
```

### Python Development

```bash
# Add to ~/.bashrc
export PYTHONPATH="$HOME/python-libs:$PYTHONPATH"
export VIRTUAL_ENV_DISABLE_PROMPT=1  # Don't modify PS1

# Set default Python version
alias python=python3
alias pip=pip3
```

### Node.js Development

```bash
# Add to ~/.bashrc
export NODE_ENV=development
export PATH="$HOME/.npm-global/bin:$PATH"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

### Docker and Containers

```bash
# Add to ~/.bashrc
export DOCKER_HOST=unix:///var/run/docker.sock
export COMPOSE_PROJECT_NAME=myproject
```

### Go Development

```bash
# Add to ~/.bashrc
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH="$GOBIN:$PATH"
```

### Cloud Provider CLIs

```bash
# AWS
export AWS_PROFILE=production
export AWS_DEFAULT_REGION=us-east-1

# Google Cloud
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/gcloud-key.json"
export CLOUDSDK_PYTHON=/usr/bin/python3

# Azure
export AZURE_SUBSCRIPTION_ID=your-subscription-id
```

---

## DevOps and Automation

### CI/CD Pipelines

**Common variables in CI/CD:**
```bash
# GitLab CI
CI_COMMIT_SHA        # Commit SHA
CI_COMMIT_BRANCH     # Branch name
CI_PROJECT_DIR       # Project directory

# GitHub Actions
GITHUB_SHA           # Commit SHA
GITHUB_REF           # Branch reference
GITHUB_WORKSPACE     # Workspace directory

# Jenkins
BUILD_NUMBER         # Build number
WORKSPACE            # Workspace directory
GIT_COMMIT           # Commit SHA
```

### Docker Containers

**Pass environment variables to containers:**
```bash
# Single variable
docker run -e MY_VAR=value myimage

# Multiple variables
docker run -e VAR1=value1 -e VAR2=value2 myimage

# From file
docker run --env-file ./env.list myimage

# Example env.list
# DATABASE_URL=postgres://localhost/mydb
# API_KEY=secret123
```

### Kubernetes Secrets

**Set environment from secrets:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  containers:
  - name: myapp
    image: myapp:latest
    env:
    - name: DATABASE_URL
      valueFrom:
        secretKeyRef:
          name: db-secret
          key: url
```

### Ansible

**Use environment variables in playbooks:**
```yaml
- name: Deploy application
  hosts: webservers
  environment:
    PATH: "/usr/local/bin:{{ ansible_env.PATH }}"
    APP_ENV: production
  tasks:
    - name: Run deployment script
      command: /opt/app/deploy.sh
```

---

## Security Considerations

### Sensitive Data

**❌ Don't:**
```bash
# DON'T put secrets in ~/.bashrc
export DB_PASSWORD=secret123  # Bad!
export API_KEY=abc123xyz      # Bad!
```

**✅ Do:**
```bash
# Use secret management tools
# - HashiCorp Vault
# - AWS Secrets Manager
# - Azure Key Vault
# - Environment-specific .env files (gitignored)

# Load from secure file
if [ -f ~/.secrets ]; then
    source ~/.secrets
fi

# Set permissions
chmod 600 ~/.secrets
```

### Environment in Scripts

**Check for required variables:**
```bash
#!/bin/bash

# Ensure required variables are set
: ${DATABASE_URL:?Need to set DATABASE_URL}
: ${API_KEY:?Need to set API_KEY}

# Or with better error messages
if [ -z "$DATABASE_URL" ]; then
    echo "Error: DATABASE_URL is not set"
    exit 1
fi

# Continue script...
```

---

## Troubleshooting

### Variable Not Found

**Problem:** `echo $MY_VAR` shows nothing

**Check:**
```bash
# Was it exported?
export | grep MY_VAR

# Is it a shell variable only?
set | grep MY_VAR

# Did you reload the shell?
source ~/.bashrc
```

### PATH Not Working

**Problem:** Command not found even though it's in PATH

**Debug:**
```bash
# Check PATH
echo $PATH

# Check if executable exists
ls -l /path/to/command

# Check if executable
file /path/to/command

# Check permissions
ls -l /path/to/command  # Should have 'x' permission

# Find where command is located
which command_name
type command_name
```

### Changes Not Persisting

**Problem:** Variables reset after logout

**Solution:**
```bash
# Make sure you're editing the right file
# For bash login shells: ~/.bash_profile or ~/.profile
# For bash interactive shells: ~/.bashrc

# Check which file is loaded
echo "Loaded .bashrc" >> ~/.bashrc
# Start new shell and see if message appears

# Verify syntax
bash -n ~/.bashrc  # Check for errors
```

---

## Quick Reference

### View Variables

```bash
printenv              # All environment variables
env                   # All environment variables
echo $VAR             # Specific variable
printenv VAR          # Specific variable
```

### Set Variables

```bash
VAR=value             # Shell variable (current shell only)
export VAR=value      # Environment variable (child processes too)
```

### Unset Variables

```bash
unset VAR             # Remove variable
```

### PATH Management

```bash
# Add to beginning
export PATH="/new/dir:$PATH"

# Add to end
export PATH="$PATH:/new/dir"

# View PATH (one per line)
echo $PATH | tr ':' '\n'
```

### Persistence

```bash
# User-specific (most common)
nano ~/.bashrc

# Login shells
nano ~/.bash_profile

# System-wide (root required)
sudo nano /etc/environment
sudo nano /etc/profile.d/custom.sh
```

---

## Summary

**Key Concepts:**

1. **Environment variables** - Named values that configure system and applications
2. **PATH** - Directories where shell searches for commands
3. **export** - Makes variables available to child processes
4. **Startup files** - Different files for login vs non-login shells
5. **Persistence** - Add to ~/.bashrc or ~/.bash_profile

**Best Practices:**

1. Use `export` for variables needed by child processes
2. Add custom paths to beginning of PATH for priority
3. Put user customizations in ~/.bashrc
4. Source ~/.bashrc from ~/.bash_profile for consistency
5. Never store secrets in plain text in startup files
6. Document your environment variables
7. Check required variables in scripts

**Common Variables:**

- `HOME` - User's home directory
- `PATH` - Command search path
- `USER` - Current username
- `SHELL` - Current shell
- `EDITOR` - Default text editor
- `LANG` - System locale

---

**Master environment variables to configure your system efficiently!**