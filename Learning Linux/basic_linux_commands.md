# Basic Linux Commands for Beginners

## Navigation Commands

### pwd - Print Working Directory
Shows your current location in the file system.
```bash
pwd
# Output: /home/username
```

### ls - List Files and Directories
Display contents of a directory.
```bash
ls                    # List files
ls -l                 # Long format (detailed)
ls -a                 # Show hidden files
ls -la                # Long format + hidden files
ls -lh                # Long format with human-readable sizes
ls /path/to/dir       # List specific directory
```

**Common Options:**
- `-l` - Long listing format
- `-a` - Show all files (including hidden)
- `-h` - Human-readable file sizes
- `-t` - Sort by modification time
- `-r` - Reverse order

### cd - Change Directory
Move between directories.
```bash
cd /path/to/directory    # Go to specific path
cd ~                     # Go to home directory
cd                       # Also goes to home
cd ..                    # Go up one level
cd -                     # Go to previous directory
cd ../..                 # Go up two levels
```

---

## File Operations

### cat - Concatenate and Display Files
Display file contents.
```bash
cat file.txt              # Display file
cat file1.txt file2.txt   # Display multiple files
cat file.txt | less       # View with paging
```

### less - View File Contents (Paginated)
Better for large files.
```bash
less file.txt
# Navigation: Space (next page), b (previous), q (quit), / (search)
```

### head - Show First Lines
Display the beginning of a file.
```bash
head file.txt         # First 10 lines (default)
head -n 5 file.txt    # First 5 lines
head -20 file.txt     # First 20 lines
```

### tail - Show Last Lines
Display the end of a file.
```bash
tail file.txt         # Last 10 lines (default)
tail -n 20 file.txt   # Last 20 lines
tail -f file.txt      # Follow file (watch for updates)
```

### touch - Create Empty File
Create a new empty file or update timestamp.
```bash
touch newfile.txt
touch file1.txt file2.txt file3.txt
```

### mkdir - Make Directory
Create new directories.
```bash
mkdir myfolder                # Create single directory
mkdir -p path/to/nested/dir   # Create nested directories
mkdir dir1 dir2 dir3          # Create multiple directories
```

### cp - Copy Files and Directories
Copy files or directories.
```bash
cp source.txt destination.txt    # Copy file
cp file.txt /path/to/directory/  # Copy to directory
cp -r folder1 folder2            # Copy directory recursively
cp -i file.txt dest.txt          # Interactive (ask before overwrite)
cp *.txt backup/                 # Copy all .txt files
```

**Common Options:**
- `-r` or `-R` - Recursive (for directories)
- `-i` - Interactive (prompt before overwrite)
- `-v` - Verbose (show what's being copied)

### mv - Move or Rename
Move files/directories or rename them.
```bash
mv oldname.txt newname.txt       # Rename file
mv file.txt /path/to/directory/  # Move file
mv -i file.txt destination/      # Interactive mode
mv *.txt documents/              # Move all .txt files
```

### rm - Remove Files and Directories
Delete files or directories.
```bash
rm file.txt                  # Delete file
rm file1.txt file2.txt       # Delete multiple files
rm -i file.txt               # Interactive (ask confirmation)
rm -r directory/             # Delete directory recursively
rm -rf directory/            # Force delete (BE CAREFUL!)
rm *.tmp                     # Delete all .tmp files
```

**⚠️ Warning:** `rm` is permanent! There's no trash/recycle bin. Use `-i` for safety.

---

## File Viewing and Searching

### grep - Search Text
Search for patterns in files.
```bash
grep "search term" file.txt              # Search in file
grep -i "search" file.txt                # Case-insensitive
grep -r "search" /path/to/directory/     # Recursive search
grep -n "search" file.txt                # Show line numbers
grep -v "exclude" file.txt               # Invert match (exclude)
ls | grep ".txt"                         # Filter ls output
```

**Common Options:**
- `-i` - Ignore case
- `-r` - Recursive
- `-n` - Show line numbers
- `-v` - Invert match
- `-c` - Count matches

### find - Find Files
Search for files and directories.
```bash
find /path -name "filename"           # Find by name
find . -name "*.txt"                  # Find all .txt files
find /home -type f -name "*.log"      # Find files
find /home -type d -name "folder*"    # Find directories
find . -mtime -7                      # Files modified in last 7 days
find . -size +100M                    # Files larger than 100MB
```

### wc - Word Count
Count lines, words, and characters.
```bash
wc file.txt           # Lines, words, characters
wc -l file.txt        # Count lines only
wc -w file.txt        # Count words only
wc -c file.txt        # Count characters only
ls | wc -l            # Count files in directory
```

---

## File Permissions

### chmod - Change Permissions
Modify file/directory permissions.
```bash
chmod 755 script.sh          # rwxr-xr-x
chmod +x script.sh           # Add execute permission
chmod -w file.txt            # Remove write permission
chmod u+x,g+r file.txt       # User execute, group read
```

**Permission Numbers:**
- `7` = rwx (read, write, execute)
- `6` = rw-
- `5` = r-x
- `4` = r--

### chown - Change Ownership
Change file owner and group.
```bash
sudo chown user file.txt              # Change owner
sudo chown user:group file.txt        # Change owner and group
sudo chown -R user:group directory/   # Recursive
```

---

## System Information

### whoami - Current User
Display your username.
```bash
whoami
# Output: username
```

### hostname - Computer Name
Show the computer's hostname.
```bash
hostname
# Output: computer-name
```

### uname - System Information
Display system information.
```bash
uname -a              # All information
uname -s              # Kernel name
uname -r              # Kernel release
uname -m              # Machine hardware
```

### df - Disk Space
Show disk space usage.
```bash
df                    # Disk space
df -h                 # Human-readable format
df -h /               # Check root partition
```

### du - Directory Size
Check directory/file sizes.
```bash
du -sh directory/     # Summary, human-readable
du -sh *              # Size of all items in current dir
du -ah directory/     # All files with sizes
```

### free - Memory Usage
Display RAM usage.
```bash
free                  # Memory in KB
free -h               # Human-readable
free -m               # In MB
```

### top - Process Viewer
Show running processes (interactive).
```bash
top
# Press q to quit
```

### ps - Process Status
List running processes.
```bash
ps                    # Current user processes
ps aux                # All processes (detailed)
ps aux | grep process_name    # Find specific process
```

---

## Network Commands

### ping - Test Connectivity
Test network connection to a host.
```bash
ping google.com           # Ping continuously
ping -c 4 google.com      # Ping 4 times
# Press Ctrl+C to stop
```

### ifconfig or ip - Network Interfaces
Display network interface information.
```bash
ip addr                   # Show IP addresses
ip a                      # Short form
ifconfig                  # Older command (may need net-tools)
```

### curl - Transfer Data
Download or interact with URLs.
```bash
curl https://example.com              # Display page
curl -O https://example.com/file.zip  # Download file
curl -I https://example.com           # Show headers only
```

### wget - Download Files
Download files from the internet.
```bash
wget https://example.com/file.zip     # Download file
wget -O renamed.zip https://url       # Save with different name
```

---

## Text Manipulation

### echo - Print Text
Display text or variables.
```bash
echo "Hello World"
echo $HOME                # Print variable
echo "text" > file.txt    # Write to file (overwrite)
echo "text" >> file.txt   # Append to file
```

### nano - Text Editor
Simple terminal text editor.
```bash
nano file.txt
# Ctrl+O to save, Ctrl+X to exit
```

### vi or vim - Advanced Text Editor
Powerful text editor.
```bash
vi file.txt
# Press i to insert, Esc to exit insert mode
# :w to save, :q to quit, :wq to save and quit, :q! to quit without saving
```

---

## Archive and Compression

### tar - Archive Files
Create and extract tar archives.
```bash
tar -cvf archive.tar files/       # Create archive
tar -xvf archive.tar              # Extract archive
tar -czvf archive.tar.gz files/   # Create compressed archive
tar -xzvf archive.tar.gz          # Extract compressed archive
tar -tvf archive.tar              # List contents
```

**Options:**
- `-c` - Create archive
- `-x` - Extract archive
- `-v` - Verbose
- `-f` - File name
- `-z` - Compress with gzip
- `-j` - Compress with bzip2

### zip/unzip - Zip Archives
Create and extract zip files.
```bash
zip archive.zip file1 file2       # Create zip
zip -r archive.zip directory/     # Zip directory
unzip archive.zip                 # Extract zip
unzip -l archive.zip              # List contents
```

---

## User Management

### sudo - Execute as Superuser
Run commands with administrator privileges.
```bash
sudo command              # Run single command as root
sudo -i                   # Switch to root shell
sudo su                   # Alternative root shell
```

### passwd - Change Password
Change your password.
```bash
passwd                    # Change your password
sudo passwd username      # Change another user's password
```

---

## Help and Documentation

### man - Manual Pages
Display command documentation.
```bash
man ls                    # Manual for ls command
man man                   # Manual for man itself
# Press q to quit
```

### --help - Quick Help
Get quick command help.
```bash
ls --help
grep --help
```

### whatis - Brief Description
One-line description of a command.
```bash
whatis ls
whatis grep
```

### apropos - Search Manual Pages
Search for commands by keyword.
```bash
apropos search
apropos "list files"
```

---

## Useful Shortcuts

| Shortcut | Action |
|----------|--------|
| `Tab` | Auto-complete commands/paths |
| `Ctrl+C` | Cancel current command |
| `Ctrl+D` | Exit shell/logout |
| `Ctrl+L` | Clear screen (same as `clear`) |
| `Ctrl+A` | Move to beginning of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+U` | Delete from cursor to beginning |
| `Ctrl+K` | Delete from cursor to end |
| `Ctrl+R` | Search command history |
| `↑` / `↓` | Browse command history |
| `!!` | Repeat last command |

---

## Redirection and Pipes

### Redirection
```bash
command > file.txt        # Redirect output to file (overwrite)
command >> file.txt       # Append output to file
command 2> error.log      # Redirect errors
command &> output.log     # Redirect all output
```

### Pipes
```bash
command1 | command2       # Pipe output to another command
ls | grep ".txt"          # Find .txt files
cat file.txt | less       # View file with paging
ps aux | grep firefox     # Find firefox process
```

---

## Tips for Beginners

1. **Use Tab completion** - Saves time and prevents typos
2. **Start with `--help`** - Most commands have built-in help
3. **Use `man` pages** - Comprehensive documentation
4. **Be careful with `rm`** - Deletions are permanent
5. **Use `sudo` carefully** - Great power, great responsibility
6. **Practice in a safe environment** - Test commands in a VM or container
7. **Use `-i` flag** - Interactive mode asks for confirmation
8. **Check before running** - Especially for destructive commands

---

## Practice Exercises

Try these to build muscle memory:

1. Navigate to your home directory: `cd ~`
2. Create a test directory: `mkdir practice`
3. Enter it: `cd practice`
4. Create some files: `touch file1.txt file2.txt`
5. List them: `ls -l`
6. Copy a file: `cp file1.txt file1_backup.txt`
7. Rename a file: `mv file2.txt renamed.txt`
8. View file: `cat renamed.txt`
9. Go up one level: `cd ..`
10. Remove test directory: `rm -r practice`

**Remember:** Practice makes perfect! The more you use these commands, the more natural they'll become.