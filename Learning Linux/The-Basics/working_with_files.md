# Working with Files in Linux - Complete Guide

## Introduction

This guide teaches you essential file operations in Linux:
- **Deleting** files and directories
- **Copying** files and directories
- **Moving** files and directories
- **Renaming** files and directories
- **Compressing** files to save space
- **Creating archives** to bundle files together
- **Checking disk usage**

---

## Part 1: Deleting Files and Directories

### The rm Command

`rm` stands for "remove" - it deletes files and directories.

⚠️ **WARNING:** Deletion is permanent! There's no recycle bin or undo.

### Basic Syntax

```bash
rm file               # Delete a file
rm file1 file2        # Delete multiple files
```

### Examples

```bash
# Delete a single file
rm oldfile.txt

# Delete multiple files
rm file1.txt file2.txt file3.txt

# Delete with wildcard
rm *.tmp              # Delete all .tmp files
```

### Important rm Options

| Option | Description | When to Use |
|--------|-------------|-------------|
| `-i` | **Interactive** - ask before deleting | Safe deletions |
| `-f` | **Force** - no confirmation, ignore errors | Automated scripts |
| `-r` | **Recursive** - delete directories and contents | Remove directories |
| `-v` | **Verbose** - show what's being deleted | Track deletions |

### Deleting Directories

**Important:** Regular `rm` won't delete directories. Use `-r`:

```bash
# This fails
rm mydir
rm: cannot remove 'mydir': Is a directory

# This works - recursive delete
rm -r mydir

# Delete directory and all contents
rm -r documents/

# Delete multiple directories
rm -r dir1 dir2 dir3
```

### Safe Deletion with -i

Always use `-i` when learning or with important files:

```bash
$ rm -i important.txt
rm: remove regular file 'important.txt'? y

$ rm -i *.txt
rm: remove regular file 'file1.txt'? y
rm: remove regular file 'file2.txt'? n
rm: remove regular file 'file3.txt'? y
```

### Force Deletion with -f

Use carefully! Deletes without asking:

```bash
# Force delete (no confirmation)
rm -f file.txt

# Force delete directory
rm -rf directory/

# Force delete with wildcards
rm -f *.tmp
```

⚠️ **DANGER:** `rm -rf /` can delete your entire system! Never run commands you don't understand.

### Common rm Scenarios

**Delete all files matching pattern:**
```bash
# Test first!
ls *.log

# Then delete
rm *.log
```

**Delete hidden files:**
```bash
# List hidden files
ls -a

# Delete specific hidden file
rm .old_config

# Delete all hidden files (dangerous!)
rm .*
```

**Be careful with hidden files:**
```bash
$ rm .*
rm: cannot remove '.': Is a directory
rm: cannot remove '..': Is a directory
```

`.` is current directory, `..` is parent. Don't delete these!

### Best Practices for Deletion

✅ **DO:**
- Test with `ls` before using `rm`
- Use `-i` for important files
- Double-check wildcards
- Make backups first

❌ **DON'T:**
- Use `rm -rf *` without being sure
- Delete system directories
- Use force flag casually
- Rush deletions

---

## Part 2: Copying Files

### The cp Command

`cp` stands for "copy" - duplicates files and directories.

### Basic Syntax

```bash
cp source destination           # Copy file to new location
cp file1 file2 file3 directory/ # Copy multiple files to directory
```

### Simple Copy Examples

```bash
# Copy file to new name in same directory
cp file.txt file_backup.txt

# Copy file to another directory
cp report.txt documents/

# Copy with new name in another directory
cp data.txt backups/data_backup.txt

# Copy multiple files to directory
cp file1.txt file2.txt file3.txt backup/
```

### Important cp Options

| Option | Description | When to Use |
|--------|-------------|-------------|
| `-i` | **Interactive** - ask before overwriting | Prevent accidents |
| `-r` or `-R` | **Recursive** - copy directories | Copy folders |
| `-v` | **Verbose** - show what's being copied | Track operations |
| `-p` | **Preserve** - keep permissions, timestamps | Exact copies |
| `-u` | **Update** - only copy if source is newer | Backups |

### Copying Directories

Use `-r` (recursive) to copy directories:

```bash
# Copy directory and all contents
cp -r source_dir destination_dir

# Copy directory into another directory
cp -r project/ backups/

# Copy multiple directories
cp -r dir1 dir2 dir3 backup_location/
```

### Interactive Copy (Safe)

Ask before overwriting existing files:

```bash
$ cp -i file.txt backup/
cp: overwrite 'backup/file.txt'? y

$ cp -i *.txt documents/
cp: overwrite 'documents/file1.txt'? y
cp: overwrite 'documents/file2.txt'? n
```

### Preserve Attributes

Keep original permissions, ownership, and timestamps:

```bash
# Regular copy (timestamps change)
cp file.txt backup.txt

# Preserve all attributes
cp -p file.txt backup.txt

# Preserve when copying directory
cp -rp important_project/ backup/
```

### Practical Copy Examples

**Backup important file:**
```bash
cp -p config.conf config.conf.backup
```

**Copy entire project:**
```bash
cp -r myproject/ myproject_backup/
```

**Copy with wildcards:**
```bash
# Copy all .txt files
cp *.txt documents/

# Copy all images
cp *.jpg *.png photos/

# Copy files starting with 'report'
cp report* archive/
```

**Update existing backups:**
```bash
# Only copy if source is newer
cp -u data.txt backup/
```

**Verbose copy (see progress):**
```bash
$ cp -rv project/ backup/
'project/file1.txt' -> 'backup/project/file1.txt'
'project/file2.txt' -> 'backup/project/file2.txt'
'project/dir/file3.txt' -> 'backup/project/dir/file3.txt'
```

---

## Part 3: Moving and Renaming Files

### The mv Command

`mv` stands for "move" - it moves AND renames files.

**Key point:** Moving a file to a new name = renaming it!

### Basic Syntax

```bash
mv source destination           # Move/rename file
mv file1 file2 file3 directory/ # Move multiple files to directory
```

### Renaming Files (Same Directory)

```bash
# Rename a file
mv oldname.txt newname.txt

# Rename a directory
mv old_folder new_folder

# Rename with different extension
mv document.txt document.md
```

### Moving Files (Different Directory)

```bash
# Move file to directory (keeps name)
mv file.txt documents/

# Move file to directory with new name
mv file.txt documents/newfile.txt

# Move multiple files
mv file1.txt file2.txt file3.txt archive/

# Move with wildcards
mv *.log logs/
mv *.txt documents/
```

### Important mv Options

| Option | Description | When to Use |
|--------|-------------|-------------|
| `-i` | **Interactive** - ask before overwriting | Safe moves |
| `-f` | **Force** - overwrite without asking | Automated tasks |
| `-v` | **Verbose** - show what's being moved | Track operations |
| `-u` | **Update** - only move if source is newer | Conditional moves |
| `-n` | **No clobber** - never overwrite | Preserve existing |

### Interactive Move (Safe)

```bash
$ mv -i old.txt new.txt
mv: overwrite 'new.txt'? y

$ mv -i *.txt documents/
mv: overwrite 'documents/file1.txt'? y
mv: overwrite 'documents/file2.txt'? n
```

### Moving Directories

```bash
# Rename directory
mv old_project new_project

# Move directory to another location
mv project/ archive/

# Move directory with new name
mv mydir/ backup/mydir_old/
```

### Practical mv Examples

**Organize files by type:**
```bash
mkdir images documents music

mv *.jpg *.png images/
mv *.txt *.doc documents/
mv *.mp3 music/
```

**Rename for consistency:**
```bash
mv report_2024.txt 2024_report.txt
mv old-config.conf config.conf.old
```

**Move and rename:**
```bash
mv data.txt archive/data_2024_backup.txt
```

**Verbose move (see what happens):**
```bash
$ mv -v *.log logs/
'error.log' -> 'logs/error.log'
'access.log' -> 'logs/access.log'
'system.log' -> 'logs/system.log'
```

### mv vs cp: Key Differences

| Operation | cp | mv |
|-----------|----|----|
| **Original file** | Stays | Removed |
| **Disk space** | Uses more | Same |
| **Speed** | Slower (copies data) | Faster (moves pointer) |
| **Use for** | Backups, duplicates | Reorganizing, renaming |

---

## Part 4: Sorting Data

### The sort Command

Sort text file contents line by line.

### Basic Syntax

```bash
sort file             # Sort file contents
sort file1 file2      # Sort multiple files together
```

### Simple Sort Examples

```bash
# Sort file alphabetically
$ cat names.txt
Charlie
Alice
Bob

$ sort names.txt
Alice
Bob
Charlie

# Save sorted output
sort names.txt > sorted_names.txt
```

### Important sort Options

| Option | Description | Example |
|--------|-------------|---------|
| `-r` | **Reverse** sort | `sort -r file` |
| `-n` | **Numeric** sort | `sort -n numbers.txt` |
| `-u` | **Unique** - remove duplicates | `sort -u file` |
| `-k F` | Sort by **field** F | `sort -k 2 file` |
| `-t` | Field **separator** | `sort -t : -k 3 file` |

### Reverse Sort

```bash
$ sort -r names.txt
Charlie
Bob
Alice
```

### Numeric Sort

```bash
$ cat numbers.txt
100
20
3

# Wrong - alphabetic sort
$ sort numbers.txt
100
20
3

# Correct - numeric sort
$ sort -n numbers.txt
3
20
100
```

### Unique Sort

Remove duplicate lines:

```bash
$ cat duplicates.txt
apple
banana
apple
cherry
banana

$ sort -u duplicates.txt
apple
banana
cherry
```

### Sort by Field (Column)

Sort CSV or delimited files by specific column:

```bash
# File with fields: name,age,city
$ cat people.csv
Alice,30,NYC
Bob,25,LA
Charlie,35,NYC

# Sort by second field (age)
$ sort -t, -k2 people.csv
Bob,25,LA
Alice,30,NYC
Charlie,35,NYC

# Sort by third field (city)
$ sort -t, -k3 people.csv
Bob,25,LA
Alice,30,NYC
Charlie,35,NYC
```

### Practical Sort Examples

**Sort and save:**
```bash
sort names.txt > sorted.txt
```

**Sort in reverse:**
```bash
sort -r scores.txt
```

**Sort numbers properly:**
```bash
sort -n file_sizes.txt
```

**Remove duplicates:**
```bash
sort -u email_list.txt > unique_emails.txt
```

**Complex sorting:**
```bash
# Sort by numeric field, reverse order
sort -t: -k3 -n -r /etc/passwd

# Sort unique numbers
sort -nu numbers.txt
```

---

## Part 5: Creating Archives with tar

### What is tar?

`tar` stands for "Tape Archive" - it bundles multiple files into one archive file.

**Why use tar?**
- Combine many files into one
- Preserve directory structure
- Easier to transfer/backup
- Often used with compression

### Basic Syntax

```bash
tar [options] archive_name files/directories
```

### Essential tar Operations

| Operation | Description |
|-----------|-------------|
| `-c` | **Create** new archive |
| `-x` | **Extract** files from archive |
| `-t` | **List** contents (table of contents) |
| `-f` | **File** - specify archive name |
| `-v` | **Verbose** - show progress |
| `-z` | Use **gzip** compression |

**Remember:** `-f` must be followed by the filename!

### Creating Archives

**Basic archive (no compression):**
```bash
# Create archive of directory
tar -cf archive.tar directory/

# Create archive of multiple files
tar -cf backup.tar file1.txt file2.txt file3.txt

# Create archive with verbose output
tar -cvf archive.tar documents/
```

**With compression (recommended):**
```bash
# Create compressed archive (.tar.gz or .tgz)
tar -czf archive.tar.gz directory/

# Compressed archive of multiple items
tar -czf backup.tar.gz dir1/ dir2/ file.txt
```

### Extracting Archives

**Extract tar archive:**
```bash
# Extract in current directory
tar -xf archive.tar

# Extract with verbose output
tar -xvf archive.tar

# Extract compressed archive
tar -xzf archive.tar.gz
```

**Extract to specific directory:**
```bash
# Extract to specific location
tar -xf archive.tar -C /destination/path/

# Extract compressed to specific location
tar -xzf backup.tar.gz -C /restore/location/
```

### Listing Archive Contents

**View without extracting:**
```bash
# List contents
tar -tf archive.tar

# List with details (verbose)
tar -tvf archive.tar

# List compressed archive
tar -tzf archive.tar.gz
```

### Common tar Examples

**Backup home directory:**
```bash
tar -czf home_backup.tar.gz ~/
```

**Backup specific directories:**
```bash
tar -czf project_backup.tar.gz projects/ documents/
```

**Extract downloaded archive:**
```bash
# Download software as .tar.gz
tar -xzf software-1.2.3.tar.gz
cd software-1.2.3/
```

**Check archive before extracting:**
```bash
# List contents first
tar -tzf unknown.tar.gz

# Then extract if safe
tar -xzf unknown.tar.gz
```

**Create dated backups:**
```bash
tar -czf backup_$(date +%Y%m%d).tar.gz documents/
# Creates: backup_20241126.tar.gz
```

### tar Options Summary

```bash
# Create
tar -cf  archive.tar files       # No compression
tar -czf archive.tar.gz files    # With gzip
tar -cjf archive.tar.bz2 files   # With bzip2

# Extract
tar -xf  archive.tar             # Uncompressed
tar -xzf archive.tar.gz          # Gzip
tar -xjf archive.tar.bz2         # Bzip2

# List
tar -tf  archive.tar             # List contents
tar -tzf archive.tar.gz          # List compressed
```

### tar Patterns

Extract specific files using patterns:

```bash
# Extract only .txt files
tar -xzf archive.tar.gz --wildcards '*.txt'

# Extract specific directory
tar -xzf archive.tar.gz path/to/dir/

# Extract specific file
tar -xzf backup.tar.gz path/to/file.txt
```

---

## Part 6: File Compression

### Why Compress Files?

- Save disk space
- Faster transfers (smaller files)
- Email attachments
- Backups take less space

### gzip - Most Common Compression

`gzip` compresses files, adds `.gz` extension.

### Basic gzip Usage

```bash
# Compress file (original deleted!)
gzip file.txt
# Result: file.txt.gz

# Compress multiple files
gzip file1.txt file2.txt file3.txt

# Keep original file
gzip -k file.txt
# Result: file.txt and file.txt.gz
```

### gunzip - Decompress Files

```bash
# Decompress file (removes .gz)
gunzip file.txt.gz
# Result: file.txt

# Decompress multiple files
gunzip *.gz

# Keep compressed file
gunzip -k file.txt.gz
```

### View Compressed Files

```bash
# View compressed file contents without extracting
zcat file.txt.gz

# View compressed file with less
zcat file.txt.gz | less

# Search in compressed file
zcat file.txt.gz | grep "pattern"
```

### gzip Options

| Option | Description |
|--------|-------------|
| `-k` | Keep original file |
| `-r` | Recursively compress directory |
| `-v` | Verbose - show compression ratio |
| `-1` to `-9` | Compression level (1=fast, 9=best) |

### Compression Examples

**Compress with settings:**
```bash
# Fast compression
gzip -1 large_file.txt

# Best compression
gzip -9 file.txt

# Compress and keep original
gzip -k important.txt

# Verbose compression
gzip -v file.txt
file.txt:    67.2% -- replaced with file.txt.gz
```

**Work with compressed files:**
```bash
# View log file without extracting
zcat /var/log/syslog.1.gz | less

# Search in compressed file
zcat error.log.gz | grep "ERROR"

# Count lines in compressed file
zcat data.txt.gz | wc -l
```

---

## Part 7: Checking Disk Usage

### The du Command

`du` stands for "disk usage" - shows how much space files use.

### Basic Syntax

```bash
du file/directory     # Show disk usage
```

### Important du Options

| Option | Description | Output |
|--------|-------------|--------|
| `-h` | **Human-readable** | KB, MB, GB |
| `-s` | **Summary** only | Total only |
| `-a` | **All** files | Every file |
| `-c` | Show **grand total** | Sum at end |
| `--max-depth=N` | Limit depth | N levels |

### Simple du Examples

```bash
# Current directory size
du -sh .

# Specific directory size
du -sh documents/

# Multiple directories
du -sh dir1 dir2 dir3

# All items in directory
du -sh *
```

### Detailed Disk Usage

```bash
# Show all files with sizes
du -ah directory/

# Sort by size
du -h directory/ | sort -h

# Top 10 largest items
du -sh * | sort -hr | head -10
```

### Practical du Examples

**Find large directories:**
```bash
# Show size of all subdirectories
du -h --max-depth=1 /home/user/ | sort -hr

# Top space consumers
du -sh /var/* | sort -hr | head -5
```

**Check specific locations:**
```bash
# Home directory size
du -sh ~

# Downloads folder
du -sh ~/Downloads

# Log files
du -sh /var/log
```

**Disk usage report:**
```bash
# Summary with total
du -shc /home/user/*

# Detailed with grand total
du -ahc /home/user/ | tail -20
```

**Find files over certain size:**
```bash
# Find directories over 100MB
du -h /home | grep -E '^[0-9\.]+[MG]' | sort -hr
```

---

## Part 8: Practical Workflows

### Scenario 1: Backing Up Project

```bash
# Create backup directory
mkdir -p ~/backups

# Create compressed archive
tar -czf ~/backups/project_$(date +%Y%m%d).tar.gz ~/projects/

# Verify backup
tar -tzf ~/backups/project_20241126.tar.gz | head

# Check size
du -sh ~/backups/
```

### Scenario 2: Cleaning Up Old Files

```bash
# Find what's taking space
du -sh * | sort -hr | head -10

# Check old log files
ls -lh *.log

# Compress old logs
gzip old*.log

# Remove temp files
rm -i *.tmp
```

### Scenario 3: Organizing Downloads

```bash
# Go to downloads
cd ~/Downloads

# Create organization
mkdir images documents archives music

# Move files
mv *.jpg *.png images/
mv *.pdf *.doc *.txt documents/
mv *.zip *.tar.gz archives/
mv *.mp3 music/

# Check results
du -sh */
```

### Scenario 4: Extracting and Installing Software

```bash
# Download software
wget https://example.com/software-1.0.tar.gz

# Check archive
tar -tzf software-1.0.tar.gz | head

# Extract
tar -xzf software-1.0.tar.gz

# Enter directory
cd software-1.0/

# Follow installation instructions
cat README
```

---

## Quick Reference

### File Operations

```bash
# Delete
rm file                    # Delete file
rm -i file                 # Delete with confirmation
rm -r directory            # Delete directory
rm -rf directory           # Force delete directory

# Copy
cp file1 file2             # Copy file
cp -r dir1 dir2            # Copy directory
cp -i file dest            # Copy with confirmation
cp file1 file2 dir/        # Copy multiple files

# Move/Rename
mv old new                 # Rename file
mv file dir/               # Move file
mv -i file dest            # Move with confirmation
mv file1 file2 dir/        # Move multiple files

# Sort
sort file                  # Sort alphabetically
sort -r file               # Reverse sort
sort -n file               # Numeric sort
sort -u file               # Unique sort
```

### Archives and Compression

```bash
# Create archive
tar -cf archive.tar files          # No compression
tar -czf archive.tar.gz files      # With compression

# Extract archive
tar -xf archive.tar                # Extract
tar -xzf archive.tar.gz            # Extract compressed

# List archive
tar -tf archive.tar                # List contents
tar -tzf archive.tar.gz            # List compressed

# Compress
gzip file                          # Compress file
gzip -k file                       # Keep original
gunzip file.gz                     # Decompress
zcat file.gz                       # View compressed
```

### Disk Usage

```bash
du -sh directory          # Directory size
du -sh *                  # All items size
du -h | sort -h           # Sort by size
du -sh * | sort -hr       # Largest first
```

---

## Safety Checklist

Before executing destructive commands:

✅ **Use ls to preview:**
```bash
ls *.txt              # See what will be affected
rm *.txt              # Then delete
```

✅ **Use -i for confirmation:**
```bash
rm -i important*      # Ask before each deletion
```

✅ **Backup first:**
```bash
cp -r important_dir important_dir.backup
```

✅ **Test with echo:**
```bash
echo rm *.txt         # See what would happen
rm *.txt              # Then execute
```

✅ **Check current directory:**
```bash
pwd                   # Where am I?
ls                    # What's here?
```

---

## Common Mistakes to Avoid

❌ **Deleting without checking:**
```bash
rm *                  # Deletes everything!
```

❌ **Wrong destination:**
```bash
cp file.txt fil.txt   # Typo creates new file instead of moving to directory
```

❌ **Forgetting -r for directories:**
```bash
cp dir1 dir2          # Fails - need -r
cp -r dir1 dir2       # Correct
```

❌ **Overwriting without backup:**
```bash
mv new.txt old.txt    # Loses old.txt forever
```

❌ **Extracting archives in wrong location:**
```bash
# Check contents first
tar -tzf archive.tar.gz

# Extract in clean directory
mkdir temp && cd temp
tar -xzf ../archive.tar.gz
```

---

## Summary

### Key Commands

- **rm** - Remove files and directories
- **cp** - Copy files and directories
- **mv** - Move and rename files
- **sort** - Sort file contents
- **tar** - Create and extract archives
- **gzip/gunzip** - Compress and decompress
- **du** - Check disk usage

### Essential Flags

- `-i` - Interactive (ask before overwriting)
- `-r` - Recursive (for directories)
- `-v` - Verbose (show what's happening)
- `-f` - Force (be careful!)
- `-h` - Human-readable sizes

### Best Practices

1. Always test destructive commands first
2. Use `-i` when learning
3. Make backups before major changes
4. Verify archives before deleting originals
5. Keep compressed backups of important data
6. Regularly check disk usage
7. Organize files into logical directories

---

**Practice these commands regularly to become proficient at file management in Linux!**