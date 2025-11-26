# Linux Wildcards - Complete Beginner's Guide

## What Are Wildcards?

**Wildcards** (also called **globs** or **glob patterns**) are special characters used to match file and directory names. They help you work with multiple files at once by creating search patterns.

**Why use wildcards?**
- Work with multiple files quickly
- Avoid typing long file names
- Create powerful search patterns
- Make commands more efficient

**The process of expanding wildcards into matching files is called "globbing."**

---

## Where Can You Use Wildcards?

Wildcards work with most Linux commands that accept file or directory names:

| Command | Common Usage |
|---------|-------------|
| `ls` | List files matching pattern |
| `rm` | Delete files matching pattern |
| `cp` | Copy files matching pattern |
| `mv` | Move files matching pattern |
| `cat` | Display files matching pattern |
| `chmod` | Change permissions on matching files |
| `find` | Find files matching pattern |

**Key point:** If a command takes a file or directory as an argument, you can use wildcards!

---

## The Three Main Wildcards

### 1. The Asterisk (*) - Match Zero or More Characters

The `*` matches **anything** - zero or more characters of any type.

| Pattern | Matches | Examples |
|---------|---------|----------|
| `*.txt` | Files ending in .txt | `file.txt`, `report.txt`, `a.txt` |
| `a*` | Files starting with 'a' | `apple`, `a`, `a123`, `abc.txt` |
| `a*.txt` | Files starting with 'a' and ending in .txt | `a.txt`, `apple.txt`, `abc.txt` |
| `*` | Everything in directory | All files and directories |
| `test*` | Files starting with 'test' | `test`, `test1`, `testing.doc` |
| `*report*` | Files containing 'report' | `report.txt`, `myreport`, `2024-report.pdf` |

**Examples:**

```bash
# List all .txt files
ls *.txt

# Delete all .log files
rm *.log

# Copy all images to backup
cp *.jpg *.png backup/

# List all files starting with 'data'
ls data*
```

### 2. The Question Mark (?) - Match Exactly One Character

The `?` matches **exactly one** character, no more, no less.

| Pattern | Matches | Examples |
|---------|---------|----------|
| `?.txt` | One character + .txt | `a.txt`, `1.txt`, `b.txt` |
| `a?` | 'a' + one character | `a1`, `ab`, `az` |
| `a?.txt` | 'a' + one character + .txt | `a1.txt`, `ab.txt`, `ax.txt` |
| `??` | Exactly 2 characters | `ab`, `12`, `xy` |
| `???` | Exactly 3 characters | `abc`, `123`, `xyz` |
| `test?.log` | 'test' + one char + .log | `test1.log`, `testa.log`, `test9.log` |

**Examples:**

```bash
# List all files with exactly 1 character name
ls ?

# List all files with exactly 2 characters
ls ??

# List files like a1.txt, a2.txt, ab.txt
ls a?.txt

# List files like file1.log, file2.log, fileA.log
ls file?.log
```

**Difference between * and ?:**

```bash
ls a*.txt      # Matches: a.txt, ab.txt, abc.txt, a123.txt
ls a?.txt      # Matches: ab.txt, a1.txt, ax.txt (NOT a.txt - needs exactly 1 char)
```

---

## Character Classes [ ]

Character classes let you specify **exactly which characters** to match.

### Basic Syntax

```bash
[characters]   # Match any ONE of these characters
```

### Examples

| Pattern | Matches | Description |
|---------|---------|-------------|
| `[aeiou]` | `a`, `e`, `i`, `o`, `u` | Any single vowel |
| `[abc]` | `a`, `b`, `c` | Any of these letters |
| `[123]` | `1`, `2`, `3` | Any of these numbers |
| `ca[nt]*` | `can`, `cat`, `candy`, `catch` | 'ca' + (n or t) + anything |
| `file[12].txt` | `file1.txt`, `file2.txt` | file + (1 or 2) + .txt |

**Practical examples:**

```bash
# Match vowels at start
ls [aeiou]*

# Match file1.txt or file2.txt or file3.txt
ls file[123].txt

# Match files starting with capital letters
ls [ABC]*

# Match can, cat, candy, catch
ls ca[nt]*
```

### Negating with ! (Exclusion)

Use `!` inside brackets to match everything **except** those characters:

| Pattern | Matches | Description |
|---------|---------|-------------|
| `[!aeiou]*` | `baseball`, `cricket`, `dog` | NOT starting with vowels |
| `[!0-9]*` | `abc`, `test`, `file` | NOT starting with numbers |
| `file[!3].txt` | `file1.txt`, `file2.txt`, `file4.txt` | NOT file3.txt |

**Examples:**

```bash
# List files NOT starting with vowels
ls [!aeiou]*

# List files NOT starting with numbers
ls [!0-9]*

# List files NOT starting with a, b, or c
ls [!abc]*
```

---

## Ranges with Character Classes

Create ranges with a hyphen `-` inside brackets:

| Pattern | Matches | Description |
|---------|---------|-------------|
| `[a-z]` | `a` through `z` | Any lowercase letter |
| `[A-Z]` | `A` through `Z` | Any uppercase letter |
| `[0-9]` | `0` through `9` | Any digit |
| `[a-f]` | `a` through `f` | Letters a, b, c, d, e, f |
| `[3-6]` | `3`, `4`, `5`, `6` | Numbers 3 through 6 |
| `[A-Za-z]` | Any letter | All uppercase and lowercase |
| `[0-9a-z]` | Alphanumeric | Numbers and lowercase letters |

**Examples:**

```bash
# List files starting with a, b, c, or d
ls [a-d]*

# List files starting with numbers 1-5
ls [1-5]*

# List files starting with uppercase letters
ls [A-Z]*

# List files ending with numbers
ls *[0-9]

# Match files like: test1, test2, test3
ls test[1-3]
```

### Combining Multiple Ranges

```bash
# Match lowercase or uppercase letters
[a-zA-Z]

# Match letters and numbers
[a-zA-Z0-9]

# Match specific ranges
[a-f0-5]        # a-f or 0-5
```

---

## Named Character Classes

Predefined classes for common character sets. Use with `[[:name:]]` syntax:

| Class | Matches | Description |
|-------|---------|-------------|
| `[[:alpha:]]` | `a-z`, `A-Z` | Alphabetic letters (upper & lower) |
| `[[:alnum:]]` | `a-z`, `A-Z`, `0-9` | Alphanumeric (letters + digits) |
| `[[:digit:]]` | `0-9` | Decimal digits |
| `[[:lower:]]` | `a-z` | Lowercase letters only |
| `[[:upper:]]` | `A-Z` | Uppercase letters only |
| `[[:space:]]` | Space, tab, newline | Whitespace characters |

**Examples:**

```bash
# List files ending with a digit
ls *[[:digit:]]

# List files starting with uppercase letter
ls [[:upper:]]*

# List files starting with lowercase letter
ls [[:lower:]]*

# List files with alphanumeric names
ls [[:alnum:]]*
```

**Practical example:**

```bash
# Match report1, report2, report9
ls report[[:digit:]]

# Match FileA, FileB, FileZ
ls File[[:upper:]]
```

---

## Escaping Special Characters

What if your filename actually contains `*`, `?`, or `[`?

Use a **backslash** `\` to escape the wildcard:

| Filename | How to Match |
|----------|--------------|
| `file?.txt` | `file\?.txt` |
| `done?` | `done\?` |
| `test*.log` | `test\*.log` |
| `data[1].txt` | `data\[1\].txt` |

**Examples:**

```bash
# Match files ending with literal question mark
ls *\?

# Match file named "what?.txt"
ls what\?.txt

# Match file named "test*.log"
ls test\*.log
```

**Pro tip:** Avoid using wildcards in filenames to keep things simple!

---

## Practical Examples

### Viewing Files

```bash
# List all text files
ls *.txt

# List all Python files
ls *.py

# List all files starting with 'test'
ls test*

# List all files with 3-character names
ls ???

# List all files starting with capital letters
ls [A-Z]*
```

### Copying Files

```bash
# Copy all .txt files to backup directory
cp *.txt backup/

# Copy all images
cp *.jpg *.png images/

# Copy all files starting with 'data'
cp data* archive/

# Copy files named file1, file2, file3
cp file[1-3] backup/
```

### Moving Files

```bash
# Move all .log files to logs directory
mv *.log logs/

# Move all .mp3 files to music directory
mv *.mp3 music/

# Move all text files
mv *.txt documents/

# Move files matching pattern
mv report[0-9].pdf reports/
```

### Deleting Files

⚠️ **IMPORTANT:** Always test your pattern with `ls` first!

```bash
# TEST FIRST - see what will be deleted
ls *.tmp

# Then delete
rm *.tmp

# Delete all backup files
ls *.bak          # Test first
rm *.bak          # Then delete

# Delete files with 2-character names
ls ??             # Test first
rm ??             # Then delete

# Delete old log files
ls old*.log       # Test first
rm old*.log       # Then delete
```

### Real-World Scenario

```bash
# Organize files into directories
$ ls
a.txt  ab.txt  b.txt  cat  cricket  done?  notes/  music/  
song1.mp3  song2.mp3  songs.txt

# Move all text files to notes
$ mv *.txt notes/

# Move all mp3 files to music
$ mv *.mp3 music/

# Verify
$ ls notes/
a.txt  ab.txt  b.txt  songs.txt

$ ls music/
song1.mp3  song2.mp3
```

---

## Combining Wildcards

You can combine multiple wildcard types:

```bash
# Files starting with a-d, any middle, ending with .txt
ls [a-d]*.txt

# Files with 2 digits in name
ls *[0-9][0-9]*

# Files NOT starting with . or _
ls [!._]*

# Complex pattern
ls test[1-5]?.log
# Matches: test1a.log, test2b.log, test39.log, etc.
```

---

## Using Wildcards with Common Commands

### With ls (List)

```bash
ls *.txt              # List text files
ls -l a*              # Long listing of files starting with 'a'
ls -lh [A-Z]*         # Human-readable sizes for files starting with capitals
ls -d */              # List only directories
```

### With rm (Remove)

```bash
# Always test first!
ls temp*              # Test
rm temp*              # Remove

ls *.tmp              # Test
rm *.tmp              # Remove

ls backup[0-9]        # Test
rm backup[0-9]        # Remove
```

### With cp (Copy)

```bash
cp *.conf backup/                  # Copy all .conf files
cp file[1-5].txt archive/          # Copy file1.txt through file5.txt
cp [a-m]* first-half/              # Copy files starting a-m
```

### With mv (Move)

```bash
mv *.log logs/                     # Move log files
mv [0-9]* numbered/                # Move files starting with numbers
mv test?.txt tests/                # Move test files
```

### With cat (Display)

```bash
cat *.txt              # Display all text files
cat file[1-3]          # Display file1, file2, file3
cat report*.log        # Display all report logs
```

### With chmod (Permissions)

```bash
chmod 755 *.sh         # Make all shell scripts executable
chmod 644 *.txt        # Set permissions on text files
```

---

## Important Safety Tips

### 1. Always Test Before Deleting

```bash
# WRONG - Don't do this immediately
rm *

# RIGHT - Test first
ls *              # See what matches
rm *              # Then delete if correct
```

### 2. Be Careful with *

```bash
# Dangerous - deletes everything
rm *

# Dangerous - deletes all files starting with space
rm * .txt         # (if there's a space)

# Safe - specific pattern
rm *.txt
```

### 3. Use -i for Interactive Confirmation

```bash
# Ask before each deletion
rm -i *.log

# Ask before overwriting
cp -i *.txt backup/
```

### 4. Verify Your Pattern

```bash
# Test with echo
echo *.txt        # Shows what will be matched

# Test with ls
ls *.txt          # Shows files that match

# Then use with rm, mv, etc.
rm *.txt
```

---

## Common Patterns Cheat Sheet

| What You Want | Pattern | Example |
|---------------|---------|---------|
| All files | `*` | `ls *` |
| Files with extension | `*.ext` | `ls *.txt` |
| Files starting with... | `prefix*` | `ls test*` |
| Files ending with... | `*suffix` | `ls *report` |
| Files containing... | `*word*` | `ls *data*` |
| One character | `?` | `ls ?` |
| Two characters | `??` | `ls ??` |
| Specific chars | `[abc]` | `ls [abc]*` |
| Range of chars | `[a-z]` | `ls [a-z]*` |
| NOT these chars | `[!abc]` | `ls [!abc]*` |
| Files with digits | `*[0-9]` | `ls *[0-9]` |
| Starts with digit | `[0-9]*` | `ls [0-9]*` |

---

## Practice Exercises

### Exercise 1: Basic Wildcards

Create test files and practice:

```bash
# Create test files
touch a.txt b.txt ab.txt test1.txt test2.txt file1.log file2.log

# List all .txt files
ls *.txt

# List all files starting with 'test'
ls test*

# List all files with 1-character names
ls ?

# List all .log files
ls *.log
```

### Exercise 2: Character Classes

```bash
# List files starting with t, f, or a
ls [tfa]*

# List files starting with numbers
ls [0-9]*

# List files NOT starting with vowels
ls [!aeiou]*

# List files starting with a-m
ls [a-m]*
```

### Exercise 3: Real Work

```bash
# Create directory structure
mkdir documents images music

# Create test files
touch report.txt notes.txt photo.jpg image.png song.mp3 tune.mp3

# Move text files to documents
mv *.txt documents/

# Move images to images folder
mv *.jpg *.png images/

# Move music files
mv *.mp3 music/

# Verify
ls documents/
ls images/
ls music/
```

### Exercise 4: Safe Deletion

```bash
# Create temp files
touch temp1 temp2 temp3 backup.bak old.log

# Test pattern first
ls temp*

# Delete temp files
rm temp*

# Test again
ls *.bak

# Delete backup files
rm *.bak
```

---

## Quick Reference Card

```bash
WILDCARDS
*           Match zero or more characters
?           Match exactly one character
[abc]       Match any character in brackets
[a-z]       Match any character in range
[!abc]      Match any character NOT in brackets

EXAMPLES
*.txt       All .txt files
test*       Files starting with test
*report*    Files containing report
file?.txt   file + one char + .txt
[abc]*      Files starting with a, b, or c
[0-9]*      Files starting with digit
[!aeiou]*   Files NOT starting with vowel
*[[:digit:]] Files ending with digit

SAFETY
ls pattern  Test pattern first
rm -i       Ask before deleting
echo *      See what matches
```

---

## Common Mistakes to Avoid

❌ **Deleting everything accidentally:**
```bash
rm *              # Deletes everything in current directory!
```

❌ **Forgetting to test:**
```bash
rm *.log          # Did you mean to delete ALL log files?
```

❌ **Space in wrong place:**
```bash
rm * .txt         # Deletes everything, then tries to delete .txt
rm *.txt          # Correct - deletes only .txt files
```

❌ **Using wildcards in filenames:**
```bash
# Avoid naming files like: test*.txt, file?.doc
```

✅ **Always test first:**
```bash
ls *.log          # See what matches
rm *.log          # Then delete
```

---

## Summary

### Key Concepts

**Wildcards:**
- `*` - Matches zero or more characters (anything)
- `?` - Matches exactly one character
- `[...]` - Matches any character in brackets

**Character Classes:**
- `[abc]` - Match a, b, or c
- `[a-z]` - Match range from a to z
- `[!abc]` - Match anything except a, b, or c
- `[[:digit:]]` - Match any digit (0-9)
- `[[:alpha:]]` - Match any letter

**Best Practices:**
1. Test patterns with `ls` before using with `rm`
2. Use `-i` flag for confirmation
3. Avoid wildcards in filenames
4. Be careful with spaces in patterns
5. Start simple, then get more complex

**Common Uses:**
- Organizing files: `mv *.txt documents/`
- Cleaning up: `rm *.tmp`
- Batch operations: `chmod 755 *.sh`
- Finding files: `ls *report*`

---

**Now practice with real files! The more you use wildcards, the more natural they become.**