# Linux Shell

## What is a Shell?

The **shell** is a command-line interface that lets you interact with the Linux operating system. It's a program that:
- Takes commands you type
- Interprets them
- Tells the OS what to do
- Shows you the results

Think of it as a translator between you and the Linux kernel.

## Why Use the Shell?

- **Power**: More control than graphical interfaces
- **Speed**: Faster for many tasks once you learn it
- **Automation**: Can script repetitive tasks
- **Remote Access**: Works over SSH connections
- **Required**: Many server tasks can only be done via shell

## Common Linux Shells

| Shell | Name | Description |
|-------|------|-------------|
| **bash** | Bourne Again Shell | Most common, default on most Linux distros |
| **sh** | Bourne Shell | Original Unix shell, simpler than bash |
| **zsh** | Z Shell | Enhanced features, popular with developers |
| **fish** | Friendly Interactive Shell | User-friendly, great autocomplete |
| **dash** | Debian Almquist Shell | Lightweight, used for scripts |

**For beginners:** Start with **bash** - it's everywhere and has tons of documentation.

## The Prompt

When you open a terminal, you see the **prompt**. It typically looks like:

```bash
username@hostname:~$
```

Breaking it down:
- `username` - Your login name
- `hostname` - Computer/server name
- `~` - Current directory (~ means home directory)
- `$` - Regular user (root user shows `#`)

### Example Prompts:
```bash
bob@ubuntu:~$              # Bob in home directory
bob@ubuntu:/var/log$       # Bob in /var/log directory
root@ubuntu:~#             # Root user (superuser)
```

## Basic Shell Commands

### Navigation
```bash
pwd                # Print working directory (where am I?)
ls                 # List files and directories
ls -l              # List with details
ls -a              # List including hidden files
cd /path           # Change directory
cd ~               # Go to home directory
cd ..              # Go up one directory
cd -               # Go to previous directory
```

### File Operations
```bash
cat file.txt       # Display file contents
less file.txt      # View file (scrollable)
head file.txt      # Show first 10 lines
tail file.txt      # Show last 10 lines
touch newfile.txt  # Create empty file
cp source dest     # Copy file
mv source dest     # Move/rename file
rm file.txt        # Delete file
mkdir dirname      # Create directory
rmdir dirname      # Remove empty directory
rm -r dirname      # Remove directory and contents
```

### Getting Help
```bash
man command        # Manual page for command
command --help     # Quick help
whatis command     # Brief description
```

### System Information
```bash
whoami             # Show current username
hostname           # Show computer name
uname -a           # System information
date               # Current date and time
uptime             # How long system has been running
```

## Command Structure

```bash
command [options] [arguments]
```

**Example:**
```bash
ls -l /home
│  │   │
│  │   └─ Argument (what to act on)
│  └───── Option/flag (how to act)
└──────── Command (what to do)
```

### Options/Flags
- Short form: `-l` (single dash, single letter)
- Long form: `--all` (double dash, full word)
- Combined: `-la` (multiple short options together)

## Tips for Beginners

1. **Tab Completion**: Press Tab to autocomplete commands and file names
2. **Command History**: Use ↑ and ↓ arrows to browse previous commands
3. **Clear Screen**: Type `clear` or press `Ctrl+L`
4. **Stop Command**: Press `Ctrl+C` to cancel a running command
5. **Case Sensitive**: Linux is case-sensitive (`file.txt` ≠ `File.txt`)
6. **Hidden Files**: Files starting with `.` are hidden (use `ls -a`)

## Special Characters

| Character | Meaning |
|-----------|---------|
| `~` | Home directory |
| `.` | Current directory |
| `..` | Parent directory |
| `/` | Root directory / path separator |
| `*` | Wildcard (matches anything) |
| `?` | Wildcard (matches single character) |
| `|` | Pipe (send output to another command) |
| `>` | Redirect output to file (overwrite) |
| `>>` | Redirect output to file (append) |

## Shell Features

### Command History
```bash
history            # Show command history
!123               # Run command #123 from history
!!                 # Run last command
!ls                # Run last command starting with 'ls'
```

### Wildcards
```bash
ls *.txt           # All files ending in .txt
ls file?.txt       # file1.txt, fileA.txt, etc.
ls [abc]*          # Files starting with a, b, or c
```

### Redirection
```bash
ls > files.txt     # Save output to file
cat file1 file2 > combined.txt
echo "text" >> file.txt    # Append to file
```

### Pipes
```bash
ls | less          # Pipe ls output to less
cat file | grep "search"   # Search in file
history | tail -20         # Last 20 commands
```

## Environment Variables

Variables that affect how the shell works:

```bash
echo $HOME         # Your home directory
echo $PATH         # Where the shell looks for commands
echo $USER         # Your username
echo $SHELL        # Your current shell

env                # Show all environment variables
```

## Finding Your Shell

```bash
echo $SHELL        # Shows your default shell
echo $0            # Shows current shell
cat /etc/shells    # List all available shells
```

## Changing Your Shell

```bash
chsh -s /bin/zsh   # Change to zsh (example)
chsh -s /bin/bash  # Change back to bash
```

**Note:** Log out and back in for changes to take effect.

## Practice Exercises

Try these commands to get comfortable:

1. Find your current directory: `pwd`
2. List all files including hidden: `ls -la`
3. Go to root directory: `cd /`
4. List the contents: `ls`
5. Return to home: `cd ~`
6. Create a test directory: `mkdir test`
7. Create a file: `touch test/hello.txt`
8. View it: `ls test/`
9. Clean up: `rm -r test`

---

**Remember:** The shell is powerful - with great power comes great responsibility. Always double-check commands, especially those using `rm` or `sudo`!