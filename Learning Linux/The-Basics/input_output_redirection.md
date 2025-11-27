# Input, Output, and Redirection in Linux

## Introduction

Linux treats everything as a file, including input and output. Understanding how to control where data comes from and goes to is essential for effective shell usage.

**Why this matters:**
- Save command output to files
- Process data from multiple sources
- Separate errors from regular output
- Chain commands together
- Automate tasks efficiently

---

## The Three Data Streams

Every Linux process has three default data streams:

| Stream | Name | File Descriptor | Default | Description |
|--------|------|-----------------|---------|-------------|
| **stdin** | Standard Input | 0 | Keyboard | Where process reads input |
| **stdout** | Standard Output | 1 | Terminal | Where process writes normal output |
| **stderr** | Standard Error | 2 | Terminal | Where process writes error messages |

### Understanding the Streams

**stdin (Standard Input):**
- Default: What you type on keyboard
- File descriptor: 0
- Commands read data from here
- Can be redirected from files

**stdout (Standard Output):**
- Default: Terminal screen
- File descriptor: 1
- Normal command output goes here
- Success messages appear here

**stderr (Standard Error):**
- Default: Terminal screen (same as stdout)
- File descriptor: 2
- Error messages go here
- Kept separate so you can handle errors differently

---

## Output Redirection

### Redirect stdout to a File (>)

The `>` operator sends standard output to a file, **overwriting** existing content.

**Syntax:**
```bash
command > file
```

**Examples:**

```bash
# Save directory listing to file
ls -l > files.txt

# Save date to file
date > today.txt

# Overwrite existing file
echo "new content" > file.txt
```

**Important:** Using `>` will **erase** existing file content!

```bash
$ echo "first line" > output.txt
$ cat output.txt
first line

$ echo "second line" > output.txt    # Overwrites!
$ cat output.txt
second line                           # First line is gone
```

### Append to a File (>>)

The `>>` operator **adds** to the end of a file without erasing existing content.

**Syntax:**
```bash
command >> file
```

**Examples:**

```bash
# Add to existing file
echo "line 1" > log.txt
echo "line 2" >> log.txt
echo "line 3" >> log.txt

$ cat log.txt
line 1
line 2
line 3
```

**Building a log file:**
```bash
date >> system.log
echo "System check starting..." >> system.log
df -h >> system.log
echo "System check complete" >> system.log
```

### Redirect vs Append Summary

| Operator | Action | Use Case |
|----------|--------|----------|
| `>` | **Overwrite** file | Starting fresh, replacing content |
| `>>` | **Append** to file | Adding to logs, accumulating data |

**Memory tip:** 
- One `>` = one chance (overwrites)
- Two `>>` = adds more (appends)

---

## Input Redirection

### Read from a File (<)

The `<` operator tells a command to read input from a file instead of keyboard.

**Syntax:**
```bash
command < inputfile
```

**Examples:**

```bash
# Sort contents of a file
sort < names.txt

# Count words in a file
wc < document.txt

# Read email message from file
mail -s "Subject" user@example.com < message.txt
```

**Practical example:**
```bash
$ cat names.txt
Charlie
Alice
Bob

$ sort < names.txt
Alice
Bob
Charlie
```

### Combining Input and Output Redirection

You can redirect both input and output:

```bash
# Read from input.txt, write to output.txt
sort < unsorted.txt > sorted.txt

# Process data.txt and save results
wc -l < data.txt > linecount.txt
```

---

## Error Redirection

### Understanding File Descriptors

Each stream has a number (file descriptor):
- `0` = stdin
- `1` = stdout
- `2` = stderr

### Redirect stderr (2>)

Send error messages to a file:

**Syntax:**
```bash
command 2> error.txt
```

**Examples:**

```bash
# Save errors to file
ls /nonexistent 2> errors.txt

# Try to read non-existent file
cat badfile.txt 2> error.log
```

**What happens:**
```bash
$ ls /nonexistent 2> errors.txt
# No output to screen

$ cat errors.txt
ls: cannot access '/nonexistent': No such file or directory
```

### Redirect Both stdout and stderr

**Method 1: Separate files**
```bash
command > output.txt 2> errors.txt
```

**Method 2: Same file (new way)**
```bash
command > alloutput.txt 2>&1
```

**Method 3: Same file (newer, shorter way)**
```bash
command &> alloutput.txt
```

### Understanding 2>&1

`2>&1` means: "Send stderr (2) to wherever stdout (1) is going"

**Example:**
```bash
# Both output and errors to same file
ls /home /nonexistent > all.txt 2>&1

$ cat all.txt
ls: cannot access '/nonexistent': No such file or directory
/home:
user1
user2
```

**Order matters:**
```bash
# Correct: redirect stdout first, then stderr follows
command > file.txt 2>&1

# Wrong: stderr goes to screen, stdout to file
command 2>&1 > file.txt
```

### Append stderr

```bash
# Append errors to log file
command 2>> error.log

# Append both output and errors
command >> all.log 2>&1
```

---

## The Null Device (/dev/null)

`/dev/null` is a special file that **discards** everything written to it. It's like a black hole for data.

**Use cases:**
- Discard unwanted output
- Suppress error messages
- Keep things quiet

### Discard stdout

```bash
# Run command silently
ls /home > /dev/null

# Time a command without seeing output
time find / -name "*.log" > /dev/null
```

### Discard stderr

```bash
# Hide error messages
find / -name "config" 2> /dev/null

# Search without permission errors
grep -r "pattern" / 2> /dev/null
```

### Discard Everything

```bash
# Complete silence
command > /dev/null 2>&1

# Or shorter version
command &> /dev/null
```

**Practical examples:**

```bash
# Check if command succeeds, don't show output
if grep -q "error" logfile > /dev/null 2>&1; then
    echo "Errors found"
fi

# Cron job that only reports errors
0 2 * * * backup-script.sh > /dev/null

# Silent command, only see result
wget -q http://example.com/file -O /dev/null && echo "Site is up"
```

---

## Practical Examples

### Logging

**Simple log file:**
```bash
echo "=== System Check ===" > system.log
date >> system.log
uptime >> system.log
df -h >> system.log
```

**Log with errors separated:**
```bash
script.sh > script.log 2> script.err
```

**Everything in one log:**
```bash
script.sh > script.log 2>&1
# Or
script.sh &> script.log
```

### Backup Command Output

```bash
# Backup user list
cat /etc/passwd > passwd.backup.$(date +%Y%m%d)

# Save package list
dpkg -l > installed-packages.txt

# Backup cron jobs
crontab -l > mycron.backup
```

### Silent Commands

```bash
# Update system, only show errors
apt-get update > /dev/null

# Find files, suppress permission errors
find /etc -name "*.conf" 2> /dev/null

# Completely silent
command &> /dev/null
```

### Processing Data

```bash
# Sort file and save
sort < unsorted.txt > sorted.txt

# Count unique lines
sort < data.txt | uniq | wc -l > count.txt

# Filter and save
grep "ERROR" < app.log > errors-only.log
```

### Error Handling

```bash
# Save errors for review
make 2> build-errors.txt

# Ignore errors, save output
command 2> /dev/null > output.txt

# Test if command works
if command 2> /dev/null; then
    echo "Success"
else
    echo "Failed"
fi
```

---

## Common Patterns

### Create or Overwrite

```bash
# New file
echo "Header" > report.txt
date >> report.txt
command >> report.txt
```

### Separate Output and Errors

```bash
# When you need to examine each separately
long-running-task > output.log 2> errors.log
```

### Combined Output

```bash
# When you want everything together
script.sh &> complete.log

# Append combined
script.sh &>> complete.log
```

### Silent Unless Error

```bash
# Normal output hidden, errors shown
command > /dev/null

# Everything hidden
command &> /dev/null
```

### Test Files

```bash
# Check if file is readable
if [ -r file.txt ]; then
    cat < file.txt
fi
```

---

## Tips and Best Practices

### Preventing Accidental Overwrites

**Use noclobber option:**
```bash
# Prevent > from overwriting
set -o noclobber

# Now this fails if file exists
echo "data" > existing.txt

# Force overwrite with >|
echo "data" >| existing.txt

# Turn off noclobber
set +o noclobber
```

### Checking Errors

```bash
# Always check command success
if command > output.txt 2> errors.txt; then
    echo "Success"
else
    echo "Failed, check errors.txt"
fi
```

### Log Rotation

```bash
# Timestamp log files
command > "log-$(date +%Y%m%d-%H%M%S).txt"

# Keep recent logs
command > latest.log
cp latest.log "backup-$(date +%Y%m%d).log"
```

### Debugging

```bash
# See output AND save it (use tee, covered in pipes)
command | tee output.txt

# Verbose mode with logging
script.sh -v > script.log 2>&1
```

### Temporary Files

```bash
# Quick temporary file
command > /tmp/tempfile.$$    # $$ = process ID
process < /tmp/tempfile.$$
rm /tmp/tempfile.$$
```

---

## Redirection Reference

### Output Redirection

| Syntax | Description | Example |
|--------|-------------|---------|
| `> file` | Overwrite file with stdout | `ls > files.txt` |
| `>> file` | Append stdout to file | `date >> log.txt` |
| `2> file` | Redirect stderr to file | `ls bad 2> err.txt` |
| `2>> file` | Append stderr to file | `cmd 2>> err.log` |
| `&> file` | Redirect both to file | `cmd &> all.txt` |
| `&>> file` | Append both to file | `cmd &>> all.log` |

### Input Redirection

| Syntax | Description | Example |
|--------|-------------|---------|
| `< file` | Read stdin from file | `sort < input.txt` |

### Advanced Redirection

| Syntax | Description | Example |
|--------|-------------|---------|
| `2>&1` | Redirect stderr to stdout | `cmd > file 2>&1` |
| `1>&2` | Redirect stdout to stderr | `echo "error" 1>&2` |
| `> /dev/null` | Discard stdout | `cmd > /dev/null` |
| `2> /dev/null` | Discard stderr | `cmd 2> /dev/null` |
| `&> /dev/null` | Discard everything | `cmd &> /dev/null` |

### Order of Operations

```bash
# Correct order
command > file.txt 2>&1

# Explained step-by-step:
# 1. > file.txt    (stdout goes to file)
# 2. 2>&1          (stderr follows stdout to file)
```

---

## Common Mistakes

### Mistake 1: Wrong Order

```bash
# WRONG - stderr goes to screen, stdout to file
command 2>&1 > file.txt

# CORRECT
command > file.txt 2>&1
```

### Mistake 2: Accidental Overwrite

```bash
# Oops! Loses data
important-data > data.txt

# Better: append
important-data >> data.txt

# Or: use noclobber
set -o noclobber
```

### Mistake 3: Forgetting to Redirect stderr

```bash
# Errors still show on screen
command > output.txt

# Fix: redirect errors too
command > output.txt 2>&1
```

### Mistake 4: Redirecting to Same File You're Reading

```bash
# DANGEROUS - can corrupt file
sort file.txt > file.txt

# CORRECT - use temporary file
sort file.txt > file.txt.tmp && mv file.txt.tmp file.txt

# OR use sponge (if available)
sort file.txt | sponge file.txt
```

---

## Quick Reference Card

### Most Common Operations

```bash
# Save output
command > file.txt

# Add to file
command >> file.txt

# Hide output
command > /dev/null

# Hide errors
command 2> /dev/null

# Hide everything
command &> /dev/null

# Save everything
command &> all.log

# Read from file
command < input.txt

# Both input and output
command < input.txt > output.txt
```

### Troubleshooting Commands

```bash
# See where errors go
ls /bad 2> errors.txt && cat errors.txt

# Test redirection
echo "test" > test.txt && cat test.txt

# Check file descriptors
ls -l /proc/$$/fd
```

---

## Summary

### Key Concepts

**Three Streams:**
- stdin (0): Input from keyboard or file
- stdout (1): Normal output
- stderr (2): Error messages

**Redirection Operators:**
- `>` : Overwrite file with stdout
- `>>` : Append stdout to file
- `<` : Read stdin from file
- `2>` : Redirect stderr
- `&>` : Redirect both stdout and stderr
- `2>&1` : Send stderr where stdout is going

**Special File:**
- `/dev/null` : Discard unwanted output

### When to Use What

**Overwrite (>):**
- Creating new report
- Replacing old data
- Starting fresh

**Append (>>):**
- Adding to log files
- Accumulating results
- Keeping history

**Error Redirection (2>):**
- Saving error messages
- Debugging scripts
- Separating errors from output

**Null Device (/dev/null):**
- Suppressing unwanted output
- Silent operations
- Testing commands

### Best Practices

1. **Use append (>>) for logs** to avoid losing data
2. **Redirect errors separately** when debugging
3. **Use /dev/null** to silence commands
4. **Remember order matters** in `> file 2>&1`
5. **Test redirection** with simple commands first
6. **Enable noclobber** to prevent accidental overwrites
7. **Use meaningful filenames** for output files

---

**Master these redirection techniques to become more efficient at the command line!**