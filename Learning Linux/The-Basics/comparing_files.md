# Comparing Files in Linux

## Introduction

When working with multiple versions of files or configurations, you need to know what's different between them. Linux provides powerful tools to compare file contents and highlight differences.

**Use cases:**
- Compare configuration files before and after changes
- Check differences between file versions
- Verify backup files match originals
- Review code changes
- Troubleshoot configuration issues

---

## The diff Command

`diff` compares two files line by line and shows the differences.

### Basic Syntax

```bash
diff file1 file2
```

### Understanding diff Output

The output format shows:
- **Line numbers** from each file
- **Action** needed to make file1 match file2
- **Content** that differs

**Actions:**
- `a` = **Add** - lines to be added
- `c` = **Change** - lines to be changed
- `d` = **Delete** - lines to be deleted

### Output Format

```
LineNumFile1 Action LineNumFile2
< Content from file1
---
> Content from file2
```

### Simple Example

```bash
$ diff file1.txt file2.txt
3c3
< this is a line in a file.
---
> This is a Line in a File!
```

**Reading this:**
- Line 3 in file1 needs to be **changed** to match line 3 in file2
- `<` shows line from file1 (original)
- `>` shows line from file2 (new)

### More Examples

**Files with additions:**
```bash
$ cat file1.txt
apple
banana

$ cat file2.txt
apple
banana
cherry

$ diff file1.txt file2.txt
2a3
> cherry
```
This means: After line 2 in file1, add line 3 from file2 (cherry)

**Files with deletions:**
```bash
$ cat old.txt
line 1
line 2
line 3

$ cat new.txt
line 1
line 3

$ diff old.txt new.txt
2d1
< line 2
```
This means: Delete line 2 from old.txt

**Files with changes:**
```bash
$ diff config.old config.new
5c5
< port=8080
---
> port=9090
```
This means: Line 5 changed from port 8080 to 9090

### Common diff Options

| Option | Description | Example |
|--------|-------------|---------|
| `-i` | Ignore case differences | `diff -i file1 file2` |
| `-w` | Ignore whitespace | `diff -w file1 file2` |
| `-B` | Ignore blank lines | `diff -B file1 file2` |
| `-u` | Unified format (easier to read) | `diff -u file1 file2` |
| `-y` | Side-by-side (like sdiff) | `diff -y file1 file2` |
| `-q` | Brief - only report if files differ | `diff -q file1 file2` |

### Unified Format (-u)

More readable format, commonly used for patches:

```bash
$ diff -u original.txt modified.txt
--- original.txt
+++ modified.txt
@@ -1,4 +1,4 @@
 line 1
 line 2
-old text
+new text
 line 4
```

Lines starting with:
- `-` were removed
- `+` were added
- (space) are unchanged context

### Brief Comparison (-q)

Just check if files are different:

```bash
$ diff -q file1.txt file2.txt
Files file1.txt and file2.txt differ

$ diff -q identical1.txt identical2.txt
# No output means files are identical
```

---

## The sdiff Command

`sdiff` shows a **side-by-side** comparison - easier to visualize differences.

### Basic Syntax

```bash
sdiff file1 file2
```

### Understanding sdiff Output

| Symbol | Meaning |
|--------|---------|
| (space) | Lines are identical |
| `|` | Lines differ |
| `<` | Line only in file1 |
| `>` | Line only in file2 |

### Examples

```bash
$ sdiff file1.txt file2.txt
line in file1                   | line in file2
identical line                    identical line
                                > more in file2
< Line from file1               | Line from file2
```

**Reading this:**
1. First line differs between files (`|`)
2. Second line is identical (space, both shown)
3. Third line only in file2 (`>`)
4. Fourth line differs (`|`)

### Practical sdiff Example

```bash
$ cat config.old
server=localhost
port=8080
debug=false

$ cat config.new
server=localhost
port=9090
debug=true

$ sdiff config.old config.new
server=localhost                  server=localhost
port=8080                       | port=9090
debug=false                     | debug=true
```

### sdiff Options

| Option | Description |
|--------|-------------|
| `-w N` | Set output width to N columns |
| `-s` | Suppress identical lines |
| `-i` | Ignore case |

**Suppress identical lines:**
```bash
$ sdiff -s config.old config.new
port=8080                       | port=9090
debug=false                     | debug=true
```

---

## The vimdiff Command

`vimdiff` opens both files in Vim with differences highlighted - great for visual comparison.

### Basic Syntax

```bash
vimdiff file1 file2
```

### What You'll See

- **Split screen** showing both files side by side
- **Highlighted differences** in color
- **Synchronized scrolling**
- **Fold markers** for unchanged sections

### Navigation in vimdiff

| Command | Action |
|---------|--------|
| `Ctrl-w w` | Switch between windows |
| `Ctrl-w h` | Move to left window |
| `Ctrl-w l` | Move to right window |
| `]c` | Jump to next difference |
| `[c` | Jump to previous difference |
| `zo` | Open folded text |
| `zc` | Close folded text |

### Quitting vimdiff

| Command | Action |
|---------|--------|
| `:q` | Quit current window |
| `:qa` | Quit all windows |
| `:qa!` | Force quit all (discard changes) |
| `:wqa` | Write all and quit |

### Using vimdiff

```bash
$ vimdiff config.old config.new
```

**Workflow:**
1. File opens with differences highlighted
2. Use `]c` to jump to next difference
3. Review changes visually
4. Press `:qa` to quit when done

### vimdiff for Editing

You can edit files while comparing:

```bash
$ vimdiff file1.txt file2.txt
# Make changes
# :w to save current file
# :wqa to save all and quit
```

---

## Comparison Methods Summary

### Which Tool to Use?

| Tool | Best For | View Style |
|------|----------|-----------|
| **diff** | Scripts, automation, patches | Line-by-line text |
| **sdiff** | Quick visual check | Side-by-side text |
| **vimdiff** | Detailed review, editing | Color-highlighted, interactive |

### Quick Comparison

**Just check if files differ:**
```bash
diff -q file1 file2
```

**Quick visual check:**
```bash
sdiff -s file1 file2    # Only show differences
```

**Detailed review:**
```bash
vimdiff file1 file2
```

---

## Practical Examples

### Compare Configuration Files

```bash
# Before editing
cp /etc/ssh/sshd_config /tmp/sshd_config.backup

# After editing
sudo diff /tmp/sshd_config.backup /etc/ssh/sshd_config
```

### Compare Backup to Original

```bash
# Check if backup matches
diff -q original.txt backup.txt

# Show differences
diff original.txt backup.txt
```

### Compare Script Versions

```bash
# Side-by-side view
sdiff script_v1.sh script_v2.sh

# Or use vimdiff for detailed review
vimdiff script_v1.sh script_v2.sh
```

### Compare Directory Contents

```bash
# Compare file lists
diff <(ls dir1) <(ls dir2)

# Recursive directory comparison
diff -r dir1/ dir2/
```

### Check Multiple Files

```bash
# Compare each backup to original
for file in *.backup; do
    original="${file%.backup}"
    echo "Comparing $original"
    diff -q "$original" "$file"
done
```

---

## Tips and Best Practices

### Before Making Changes

```bash
# Create backup with timestamp
cp config.conf config.conf.$(date +%Y%m%d)

# Make changes...

# Compare
diff config.conf.20241126 config.conf
```

### Ignore Unimportant Differences

```bash
# Ignore case differences
diff -i file1 file2

# Ignore whitespace
diff -w file1 file2

# Ignore blank lines
diff -B file1 file2

# Combine options
diff -iwB file1 file2
```

### Save Differences to File

```bash
# Save diff output
diff file1 file2 > changes.diff

# Save unified format
diff -u original modified > changes.patch
```

### Comparing Remote Files

```bash
# Compare local file to remote
diff localfile <(ssh user@server cat /path/to/remotefile)

# Compare two remote files
diff <(ssh server1 cat file) <(ssh server2 cat file)
```

---

## Common Use Cases

### 1. Configuration Changes

```bash
# Before system update
cp /etc/apache2/apache2.conf /root/apache2.conf.pre-update

# After update
diff /root/apache2.conf.pre-update /etc/apache2/apache2.conf
```

### 2. Code Review

```bash
# Compare versions
vimdiff script_old.py script_new.py

# Review changes before commit
diff original.js modified.js
```

### 3. Troubleshooting

```bash
# Compare working vs broken config
diff working.conf broken.conf

# Find what changed
sdiff -s backup/settings.ini current/settings.ini
```

### 4. Verification

```bash
# Verify backup integrity
diff -q /data/important.txt /backup/important.txt

# Check restored file
diff original recovered
```

---

## Quick Reference

### Basic Commands

```bash
# Simple comparison
diff file1 file2

# Side-by-side
sdiff file1 file2

# Visual with vim
vimdiff file1 file2
```

### Common Options

```bash
# Ignore case
diff -i file1 file2

# Ignore whitespace
diff -w file1 file2

# Brief (just tell if different)
diff -q file1 file2

# Unified format
diff -u file1 file2

# Side-by-side with diff
diff -y file1 file2

# Only show differences (sdiff)
sdiff -s file1 file2
```

### vimdiff Navigation

```bash
Ctrl-w w        # Switch windows
]c              # Next difference
[c              # Previous difference
:qa             # Quit all
:qa!            # Force quit all
```

---

## Summary

### Key Concepts

**diff:**
- Line-by-line comparison
- Shows what to add/change/delete
- Good for scripts and automation
- Can generate patches

**sdiff:**
- Side-by-side comparison
- Easier to visualize differences
- Good for quick checks
- More human-readable

**vimdiff:**
- Interactive, color-coded
- Best for detailed review
- Can edit while comparing
- Synchronized scrolling

### When to Use Each

- **Quick check:** `diff -q file1 file2`
- **Visual comparison:** `sdiff -s file1 file2`
- **Detailed review:** `vimdiff file1 file2`
- **Creating patches:** `diff -u old new > file.patch`

### Best Practices

1. Always back up files before editing
2. Use diff to verify changes
3. Ignore irrelevant differences (-i, -w, -B)
4. Use vimdiff for complex comparisons
5. Document important differences
6. Test after making changes

---

**Practice comparing different file versions to become proficient at spotting changes!**