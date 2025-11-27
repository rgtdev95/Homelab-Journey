# Customizing the Shell Prompt

## Introduction

The shell prompt is the text displayed before your cursor in the terminal, typically showing information like your username, hostname, and current directory. Customizing your prompt can make your terminal experience more informative, visually appealing, and productive.

**Why customize your prompt?**
- ✅ Show useful context at a glance (directory, git branch, time)
- ✅ Distinguish between different servers or environments
- ✅ Add visual clarity with colors
- ✅ Display command status and return codes
- ✅ Express your personal style

---

## Understanding the Shell Prompt

### Default Prompts

**Common default prompts:**

```bash
# Bash default (Debian/Ubuntu)
user@hostname:~$

# Bash default (RHEL/CentOS)
[user@hostname ~]$

# Root user
root@hostname:~#

# Zsh default
hostname%
```

### Prompt Variables

**Main prompt variables:**

| Variable | Description | Default Use |
|----------|-------------|-------------|
| `PS1` | Primary prompt | Main command prompt |
| `PS2` | Secondary prompt | Multi-line commands (usually `>`) |
| `PS3` | Select prompt | Used by `select` command |
| `PS4` | Debug prompt | Used when debugging scripts (usually `+`) |

**We'll focus on `PS1` - the prompt you see most.**

---

## Viewing Your Current Prompt

### Check Current Prompt

```bash
# View PS1 variable
echo $PS1

# Example output
\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$
```

**Note:** The output looks cryptic because it contains escape sequences that the shell interprets when displaying the prompt.

### Test Prompts

```bash
# Temporarily change prompt
PS1="new prompt> "

# Your prompt changes immediately
new prompt> 

# Reset to default (reload shell)
source ~/.bashrc
```

---

## Bash Prompt Escape Sequences

### Basic Escape Sequences

| Sequence | Description | Example |
|----------|-------------|---------|
| `\u` | Username | `john` |
| `\h` | Hostname (short) | `webserver` |
| `\H` | Hostname (FQDN) | `webserver.example.com` |
| `\w` | Full working directory | `/home/john/projects` |
| `\W` | Basename of working directory | `projects` |
| `\$` | `#` if root, `$` otherwise | `$` or `#` |
| `\n` | Newline | Line break |
| `\t` | Current time (24-hour HH:MM:SS) | `14:30:45` |
| `\T` | Current time (12-hour HH:MM:SS) | `02:30:45` |
| `\@` | Current time (12-hour am/pm) | `02:30 PM` |
| `\A` | Current time (24-hour HH:MM) | `14:30` |
| `\d` | Date (Weekday Month Date) | `Mon Jan 15` |
| `\s` | Shell name | `bash` |
| `\v` | Bash version | `5.1` |
| `\V` | Bash version + patch level | `5.1.16` |
| `\\` | Backslash | `\` |
| `\!` | History number | `42` |
| `\#` | Command number | `15` |

### Examples with Escape Sequences

```bash
# Simple username@hostname
PS1="\u@\h$ "
# Output: john@webserver$

# With current directory
PS1="\u@\h:\w$ "
# Output: john@webserver:/home/john/projects$

# With time
PS1="[\t] \u@\h:\w$ "
# Output: [14:30:45] john@webserver:/home/john/projects$

# Two-line prompt
PS1="\u@\h:\w\n$ "
# Output:
# john@webserver:/home/john/projects
# $

# Show only directory basename
PS1="\W$ "
# Output: projects$

# Root indicator
PS1="\u@\h:\w\$ "
# Regular user: john@webserver:/home/john$
# Root: root@webserver:/root#
```

---

## Adding Colors

### ANSI Color Codes

**Basic structure:**
```bash
\[\e[COLORm\]text\[\e[0m\]
```

**Color codes:**

| Code | Color | Code | Color (Bold) |
|------|-------|------|--------------|
| `30m` | Black | `1;30m` | Dark Gray |
| `31m` | Red | `1;31m` | Light Red |
| `32m` | Green | `1;32m` | Light Green |
| `33m` | Brown/Orange | `1;33m` | Yellow |
| `34m` | Blue | `1;34m` | Light Blue |
| `35m` | Purple | `1;35m` | Light Purple |
| `36m` | Cyan | `1;36m` | Light Cyan |
| `37m` | Light Gray | `1;37m` | White |

**Background colors:** Use `40-47` instead of `30-37`

**Format codes:**

| Code | Effect |
|------|--------|
| `0m` | Reset all attributes |
| `1m` | Bold |
| `2m` | Dim |
| `4m` | Underline |
| `5m` | Blink |
| `7m` | Reverse (swap foreground/background) |

### Color Variables (Recommended)

**Define colors once:**
```bash
# Add to ~/.bashrc

# Regular colors
BLACK='\[\e[0;30m\]'
RED='\[\e[0;31m\]'
GREEN='\[\e[0;32m\]'
YELLOW='\[\e[0;33m\]'
BLUE='\[\e[0;34m\]'
PURPLE='\[\e[0;35m\]'
CYAN='\[\e[0;36m\]'
WHITE='\[\e[0;37m\]'

# Bold colors
BBLACK='\[\e[1;30m\]'
BRED='\[\e[1;31m\]'
BGREEN='\[\e[1;32m\]'
BYELLOW='\[\e[1;33m\]'
BBLUE='\[\e[1;34m\]'
BPURPLE='\[\e[1;35m\]'
BCYAN='\[\e[1;36m\]'
BWHITE='\[\e[1;37m\]'

# Reset
RESET='\[\e[0m\]'

# Example usage
PS1="${GREEN}\u@\h${RESET}:${BLUE}\w${RESET}\$ "
```

### Colored Prompt Examples

**Green user, blue directory:**
```bash
PS1="\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ "
```

**Bold cyan user, yellow directory:**
```bash
PS1="\[\e[1;36m\]\u@\h\[\e[0m\]:\[\e[1;33m\]\w\[\e[0m\]\$ "
```

**Two-line with colors:**
```bash
PS1="\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\n\$ "
```

**Root warning (red):**
```bash
if [ "$EUID" -eq 0 ]; then
    PS1="\[\e[1;31m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\# "
else
    PS1="\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ "
fi
```

---

## Advanced Prompt Customization

### Show Exit Status

**Change color based on last command:**
```bash
# Add to ~/.bashrc

# Function to get exit status color
exit_status() {
    if [ $? -eq 0 ]; then
        echo -e "\[\e[0;32m\]✓\[\e[0m\]"  # Green checkmark
    else
        echo -e "\[\e[0;31m\]✗\[\e[0m\]"  # Red X
    fi
}

# Use in prompt
PS1='$(exit_status) \u@\h:\w\$ '
```

**Show actual exit code:**
```bash
PS1="\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\] [\$?]\$ "
# Output: john@webserver:/home/john [0]$
```

### Show Git Branch

**Display current Git branch:**
```bash
# Add to ~/.bashrc

# Function to get git branch
parse_git_branch() {
    git branch 2>/dev/null | grep '*' | sed 's/* //'
}

# Use in prompt
PS1="\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\] \[\e[0;33m\]\$(parse_git_branch)\[\e[0m\]\$ "
# Output: john@webserver:/home/john/repo main$
```

**Fancy Git status:**
```bash
parse_git_dirty() {
    [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]] && echo "*"
}

parse_git_branch() {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\1$(parse_git_dirty))/"
}

PS1="\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\] \[\e[0;33m\]\$(parse_git_branch)\[\e[0m\]\$ "
# Output: john@webserver:/home/john/repo (main*)$
# The * indicates uncommitted changes
```

### Show Python Virtual Environment

**Display active virtualenv:**
```bash
# Add to ~/.bashrc

show_virtual_env() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "($(basename $VIRTUAL_ENV))"
    fi
}

PS1="\[\e[1;35m\]\$(show_virtual_env)\[\e[0m\]\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ "
# Output: (venv)john@webserver:/home/john/project$
```

### Show Time and Load

**Include timestamp and system load:**
```bash
PS1="[\t] [\$(uptime | awk -F'load average:' '{print \$2}')] \u@\h:\w\$ "
# Output: [14:30:45] [ 0.15, 0.10, 0.05] john@webserver:/home/john$
```

### Show Number of Background Jobs

```bash
show_jobs() {
    jobs_count=$(jobs | wc -l)
    if [ $jobs_count -gt 0 ]; then
        echo " [$jobs_count jobs]"
    fi
}

PS1="\u@\h:\w\$(show_jobs)\$ "
# Output: john@webserver:/home/john [2 jobs]$
```

---

## Professional Prompt Examples

### DevOps Engineer

```bash
# Multi-line with Git, virtualenv, exit status
parse_git_branch() {
    git branch 2>/dev/null | grep '*' | sed 's/* //'
}

exit_status() {
    if [ $? -eq 0 ]; then
        echo "✓"
    else
        echo "✗"
    fi
}

show_virtual_env() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "($(basename $VIRTUAL_ENV)) "
    fi
}

# Colors
GREEN='\[\e[0;32m\]'
BLUE='\[\e[0;34m\]'
YELLOW='\[\e[0;33m\]'
PURPLE='\[\e[0;35m\]'
RED='\[\e[0;31m\]'
RESET='\[\e[0m\]'

# Two-line prompt
PS1="${PURPLE}\$(show_virtual_env)${GREEN}\u@\h${RESET}:${BLUE}\w${RESET} ${YELLOW}\$(parse_git_branch)${RESET}\n\$(exit_status) \$ "

# Output:
# (venv) john@webserver:/home/john/project main
# ✓ $
```

### System Administrator

```bash
# Show hostname prominently for safety
RED='\[\e[1;31m\]'
GREEN='\[\e[1;32m\]'
BLUE='\[\e[1;34m\]'
RESET='\[\e[0m\]'

if [ "$EUID" -eq 0 ]; then
    # Root = red hostname
    PS1="${RED}\h${RESET}:${BLUE}\w${RESET}\# "
else
    # Regular user = green hostname
    PS1="${GREEN}\h${RESET}:${BLUE}\w${RESET}\$ "
fi

# Output (as root): webserver:/etc#
# Output (as user): webserver:/home/john$
```

### Developer

```bash
# Clean two-line with Git integration
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

GREEN='\[\e[0;32m\]'
BLUE='\[\e[1;34m\]'
YELLOW='\[\e[1;33m\]'
RESET='\[\e[0m\]'

PS1="${GREEN}\u@\h${RESET}:${BLUE}\w${YELLOW}\$(parse_git_branch)${RESET}\n\$ "

# Output:
# john@laptop:/home/john/myapp (main)
# $
```

### Multi-Environment

**Color-code different environments:**
```bash
# Add to ~/.bashrc

# Detect environment
if [[ "$HOSTNAME" == *"prod"* ]]; then
    HOST_COLOR='\[\e[1;31m\]'  # Red for production
elif [[ "$HOSTNAME" == *"staging"* ]]; then
    HOST_COLOR='\[\e[1;33m\]'  # Yellow for staging
else
    HOST_COLOR='\[\e[1;32m\]'  # Green for dev
fi

BLUE='\[\e[0;34m\]'
RESET='\[\e[0m\]'

PS1="${HOST_COLOR}\u@\h${RESET}:${BLUE}\w${RESET}\$ "

# Production servers show red hostname (visual warning!)
```

---

## Powerline and Fancy Prompts

### Powerline

**Powerline** is a statusline plugin that provides a beautiful, informative prompt.

**Installation:**
```bash
# Install powerline
sudo apt install powerline  # Debian/Ubuntu
sudo yum install powerline  # RHEL/CentOS

# Add to ~/.bashrc
if [ -f /usr/share/powerline/bindings/bash/powerline.sh ]; then
    source /usr/share/powerline/bindings/bash/powerline.sh
fi
```

**Requirements:**
- Powerline fonts (for special symbols)
- Terminal with 256 color support

### Oh My Bash

**Framework for managing Bash configuration:**
```bash
# Install Oh My Bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# Themes in ~/.bashrc
OSH_THEME="agnoster"
```

**Popular themes:**
- `agnoster` - Powerline-style
- `powerline` - Clean powerline
- `font` - Colorful and informative

### Starship

**Modern, minimal, fast prompt:**
```bash
# Install Starship
curl -sS https://starship.rs/install.sh | sh

# Add to ~/.bashrc
eval "$(starship init bash)"

# Configure ~/.config/starship.toml
```

---

## Making Prompt Changes Permanent

### For Bash

**Edit ~/.bashrc:**
```bash
# Open bashrc
nano ~/.bashrc

# Add your PS1 configuration
PS1="\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ "

# Save and reload
source ~/.bashrc
```

### For Zsh

**Edit ~/.zshrc:**
```bash
# Zsh uses PROMPT instead of PS1
nano ~/.zshrc

# Add prompt configuration
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%# '

# Save and reload
source ~/.zshrc
```

### System-Wide

**Edit /etc/bash.bashrc (affects all users):**
```bash
# Requires root
sudo nano /etc/bash.bashrc

# Add default PS1 for all users
PS1="\[\e[0;32m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ "
```

---

## Troubleshooting

### Prompt Too Long

**Problem:** Prompt takes up too much screen space

**Solutions:**
```bash
# Use \W instead of \w (basename only)
PS1="\u@\h:\W\$ "

# Use two-line prompt
PS1="\u@\h:\w\n\$ "

# Shorten hostname
PS1="\u:\w\$ "
```

### Colors Not Working

**Check terminal support:**
```bash
# Check if terminal supports colors
echo $TERM

# Test colors
for i in {0..7}; do echo -e "\e[3${i}mColor $i\e[0m"; done
```

**Fix:**
- Ensure proper escape sequences: `\[\e[COLORm\]`
- Check terminal emulator settings
- Use `tput` for better compatibility:
```bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

PS1="${GREEN}\u@\h${RESET}:\w\$ "
```

### Cursor Position Issues

**Problem:** Cursor appears in wrong place

**Cause:** Missing `\[` and `\]` around color codes

**Fix:**
```bash
# Wrong
PS1="\e[0;32m\u@\h\e[0m\$ "

# Correct
PS1="\[\e[0;32m\]\u@\h\[\e[0m\]\$ "
```

### Git Branch Slow

**Problem:** Prompt lags in large Git repositories

**Solution:**
```bash
# Cache git status
GIT_PS1_SHOWDIRTYSTATE=false
GIT_PS1_SHOWUNTRACKEDFILES=false
```

---

## Quick Reference

### Essential Escape Sequences

```bash
\u  # Username
\h  # Hostname
\w  # Full working directory
\W  # Basename of working directory
\$  # $ or # (user/root)
\t  # Time (24h)
\n  # Newline
```

### Color Template

```bash
# Define colors
GREEN='\[\e[0;32m\]'
BLUE='\[\e[0;34m\]'
RESET='\[\e[0m\]'

# Use in prompt
PS1="${GREEN}\u@\h${RESET}:${BLUE}\w${RESET}\$ "

# Reload
source ~/.bashrc
```

### Test Before Committing

```bash
# Test temporarily
PS1="test prompt> "

# If you like it, add to ~/.bashrc
echo 'PS1="test prompt> "' >> ~/.bashrc

# Reload
source ~/.bashrc
```

---

## Summary

**Key Concepts:**

1. **PS1** - Primary prompt variable
2. **Escape sequences** - Special codes like `\u`, `\h`, `\w`
3. **Colors** - ANSI escape codes for colored text
4. **Functions** - Dynamic content (git branch, exit status)
5. **Persistence** - Add to `~/.bashrc` for permanence

**Best Practices:**

1. Keep prompt readable and not too long
2. Use colors to highlight important information
3. Use two-line prompts if needed
4. Show context (directory, git branch, environment)
5. Distinguish production environments with colors
6. Test prompts before making permanent
7. Document your customizations

**Practical Applications:**

- ✅ Show current directory at a glance
- ✅ Display Git branch for developers
- ✅ Indicate production environments (red!)
- ✅ Show Python virtualenv status
- ✅ Display command exit status
- ✅ Add timestamps for logging
- ✅ Distinguish between user and root

---

**Customize your prompt to work smarter and avoid mistakes!**