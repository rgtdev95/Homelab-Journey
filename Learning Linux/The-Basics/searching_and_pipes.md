# Searching in Files and Using Pipes

## Introduction

Finding specific text in files is one of the most common tasks in Linux. Whether you're searching log files for errors, finding configuration settings, or filtering command output, mastering search and pipe techniques will make you much more efficient.

**What you'll learn:**
- Search for text patterns in files
- Filter and process text data
- Chain commands together with pipes
- Extract specific columns from data
- Search binary files for readable text

---

## The grep Command

`grep` (Global Regular Expression Print) searches for patterns in text files and prints matching lines.

### Basic Syntax

```bash
grep pattern filename
```

**Examples:**

```bash
# Search for "error" in a log file
grep error application.log

# Search for "root" in passwd file
grep root /etc/passwd

# Search for "TODO" in a Python script
grep TODO script.py
```

### How grep Works

1. Reads file line by line
2. Checks if pattern appears in line
3. Prints entire line if pattern matches
4. Case-sensitive by default

**Simple example:**

```bash
$ cat names.txt
Alice Smith
Bob Jones
Charlie Brown
Alice Johnson

$ grep Alice names.txt
Alice Smith
Alice Johnson
```

---

## Common grep Options

### Case-Insensitive Search (-i)

Ignore uppercase/lowercase differences:

```bash
# Find "error", "Error", "ERROR", etc.
grep -i error logfile.txt

# Search for "linux" regardless of case
grep -i linux document.txt
```

**Example:**
```bash
$ cat messages.txt
Error occurred
warning message
ERROR: Failed

$ grep -i error messages.txt
Error occurred
ERROR: Failed
```

### Show Line Numbers (-n)

Display line numbers where matches occur:

```bash
grep -n pattern file.txt
```

**Example:**
```bash
$ grep -n error app.log
15:Connection error
42:Timeout error
108:Database error
```

### Count Matches (-c)

Count how many lines contain the pattern:

```bash
grep -c pattern file.txt
```

**Example:**
```bash
$ grep -c error app.log
3

$ grep -c "^#" script.sh    # Count comment lines
12
```

### Invert Match (-v)

Show lines that DON'T contain the pattern:

```bash
grep -v pattern file.txt
```

**Examples:**
```bash
# Show all non-comment lines
grep -v "^#" config.conf

# Exclude blank lines
grep -v "^$" file.txt

# Remove lines containing "debug"
grep -v debug log.txt
```

### Recursive Search (-r)

Search through all files in a directory:

```bash
grep -r pattern directory/
```

**Examples:**
```bash
# Find all TODO comments in project
grep -r "TODO" /home/user/project/

# Search all configuration files
grep -r "port 8080" /etc/

# Find where function is used
grep -r "function_name" ./src/
```

### Search Multiple Files

```bash
# Search in specific files
grep pattern file1.txt file2.txt file3.txt

# Use wildcards
grep pattern *.log

# All text files in directory
grep pattern *.txt
```

### Whole Word Match (-w)

Match complete words only:

```bash
# Find "cat" but not "category" or "concatenate"
grep -w cat file.txt

# Find "test" as a whole word
grep -w test script.sh
```

**Example:**
```bash
$ cat words.txt
cat
category
scatter
wildcat

$ grep cat words.txt
cat
category
scatter
wildcat

$ grep -w cat words.txt
cat
```

### Show Context

**Lines after match (-A):**
```bash
# Show 3 lines after each match
grep -A 3 error log.txt
```

**Lines before match (-B):**
```bash
# Show 2 lines before each match
grep -B 2 error log.txt
```

**Lines before and after (-C):**
```bash
# Show 2 lines before and after
grep -C 2 error log.txt
```

**Example:**
```bash
$ cat log.txt
line 1
line 2
Error occurred
line 4
line 5

$ grep -A 1 Error log.txt
Error occurred
line 4

$ grep -B 1 Error log.txt
line 2
Error occurred

$ grep -C 1 Error log.txt
line 2
Error occurred
line 4
```

---

## grep Options Summary

| Option | Description | Example |
|--------|-------------|---------|
| `-i` | Case-insensitive | `grep -i error file.txt` |
| `-n` | Show line numbers | `grep -n pattern file.txt` |
| `-c` | Count matches | `grep -c error log.txt` |
| `-v` | Invert match (exclude) | `grep -v comment file.txt` |
| `-r` | Recursive search | `grep -r pattern dir/` |
| `-w` | Whole word match | `grep -w cat file.txt` |
| `-l` | List filenames only | `grep -l error *.log` |
| `-A N` | Show N lines after | `grep -A 3 error log.txt` |
| `-B N` | Show N lines before | `grep -B 2 error log.txt` |
| `-C N` | Show N lines around | `grep -C 2 error log.txt` |

### Combining Options

```bash
# Case-insensitive with line numbers
grep -in error file.txt

# Recursive, case-insensitive, whole word
grep -riw pattern directory/

# Count matches, case-insensitive
grep -ic error log.txt

# List files containing pattern (recursive)
grep -rl "function_name" ./src/
```

---

## Pipes (|)

Pipes connect commands, sending output from one command as input to another.

### Basic Pipe Syntax

```bash
command1 | command2
```

The output of command1 becomes the input of command2.

### Simple Pipe Examples

**List files and search:**
```bash
ls -l | grep ".txt"
```

**Count processes:**
```bash
ps aux | grep firefox | wc -l
```

**Sort and display:**
```bash
cat names.txt | sort
```

### How Pipes Work

```bash
# Without pipe (two steps)
ls -l > temp.txt
grep ".txt" temp.txt
rm temp.txt

# With pipe (one step, no temp file)
ls -l | grep ".txt"
```

**Pipes are efficient:**
- No temporary files needed
- Data flows directly between commands
- Can chain multiple commands

---

## Common Pipe Patterns

### Search Command Output

```bash
# Find specific process
ps aux | grep nginx

# Find listening ports
netstat -tulpn | grep LISTEN

# Search history
history | grep git

# Find large files
ls -lh | grep "^-" | sort -k 5 -h | tail
```

### Count Results

```bash
# Count number of processes
ps aux | wc -l

# Count error lines
grep error log.txt | wc -l

# Count users
cat /etc/passwd | wc -l

# Count .txt files
ls | grep ".txt" | wc -l
```

### Sort Output

```bash
# Sort directory listing by name
ls | sort

# Sort by reverse order
ls | sort -r

# Sort numbers
cat numbers.txt | sort -n

# Unique sorted list
cat list.txt | sort | uniq
```

### Filter and Format

```bash
# Show only filenames (no details)
ls -l | grep "^-" | awk '{print $9}'

# List only directories
ls -l | grep "^d"

# Format process list
ps aux | grep nginx | awk '{print $2, $11}'
```

### Chain Multiple Pipes

```bash
# Complex filtering
cat log.txt | grep error | grep -v debug | sort | uniq

# Process listing pipeline
ps aux | grep python | awk '{print $11}' | sort | uniq

# File analysis
ls -l | grep "^-" | awk '{sum+=$5} END {print sum}'
```

---

## The cut Command

`cut` extracts specific columns or fields from text.

### Cut by Character Position

```bash
# Extract characters 1-5
cut -c 1-5 file.txt

# Extract character 3 to end
cut -c 3- file.txt

# Extract single character
cut -c 1 file.txt
```

**Example:**
```bash
$ cat data.txt
abcdefghij
1234567890

$ cut -c 1-3 data.txt
abc
123

$ cut -c 5 data.txt
e
5
```

### Cut by Delimiter (Field)

```bash
# Extract field 1 (default delimiter: TAB)
cut -f 1 file.txt

# Extract field 1, delimiter is comma
cut -d ',' -f 1 file.csv

# Extract multiple fields
cut -d ':' -f 1,3 /etc/passwd

# Extract field range
cut -d ':' -f 1-3 /etc/passwd
```

**Examples:**

```bash
# Get usernames from /etc/passwd
cut -d ':' -f 1 /etc/passwd

# Get username and home directory
cut -d ':' -f 1,6 /etc/passwd

# Parse CSV file
cat data.csv
Alice,30,Engineer
Bob,25,Designer

$ cut -d ',' -f 1,3 data.csv
Alice,Engineer
Bob,Designer
```

### cut Options

| Option | Description | Example |
|--------|-------------|---------|
| `-c N` | Cut by character position | `cut -c 1-5 file.txt` |
| `-f N` | Cut by field number | `cut -f 1 file.txt` |
| `-d 'X'` | Set field delimiter | `cut -d ',' -f 1 file.csv` |

### Practical cut Examples

```bash
# Get IP addresses from log
cut -d ' ' -f 1 access.log

# Extract email addresses (assuming user@host format)
cut -d '@' -f 1 emails.txt    # Get username
cut -d '@' -f 2 emails.txt    # Get domain

# Get first and last names
cut -d ',' -f 1,2 names.csv

# Show first 10 characters of each line
cut -c 1-10 file.txt
```

---

## The strings Command

`strings` extracts readable text from binary files.

### Basic Syntax

```bash
strings binary_file
```

### When to Use strings

**Use cases:**
- Examine binary executables
- Find text in compiled programs
- Search for configuration in binary files
- Recover text from corrupted files
- Investigate unknown binaries

### strings Examples

```bash
# Find text in binary
strings /usr/bin/ls

# Find version information
strings program | grep -i version

# Search for URLs in binary
strings suspicious_file | grep http

# Find configuration strings
strings database.db | grep password

# Extract readable text from image
strings photo.jpg
```

### Practical strings Usage

```bash
# Check what libraries a program uses
strings /usr/bin/program | grep ".so"

# Find embedded strings in executable
strings program | grep "Error"

# Search binary for specific text
strings binary | grep -i "license"

# Minimum string length (default is 4)
strings -n 8 binary    # Only strings 8+ chars
```

### Combine strings with Other Commands

```bash
# Count text strings in binary
strings binary | wc -l

# Find unique strings
strings binary | sort | uniq

# Search for patterns
strings binary | grep -i "error" | sort | uniq

# Extract and save
strings binary > text_content.txt
```

---

## Practical Examples

### Log File Analysis

```bash
# Find all errors
grep -i error /var/log/syslog

# Count errors by type
grep error app.log | cut -d ':' -f 1 | sort | uniq -c

# Find recent errors (with line numbers)
grep -n error /var/log/app.log | tail

# Errors excluding specific ones
grep error log.txt | grep -v "connection timeout"

# Show error context
grep -C 3 "critical error" app.log
```

### System Information

```bash
# Find logged-in users
who | cut -d ' ' -f 1 | sort | uniq

# Count processes per user
ps aux | tail -n +2 | cut -d ' ' -f 1 | sort | uniq -c

# Find large files
ls -lh | grep "^-" | sort -k 5 -hr | head

# Check listening ports
netstat -tulpn | grep LISTEN | awk '{print $4}' | cut -d ':' -f 2 | sort -n
```

### Configuration Files

```bash
# Show non-comment lines
grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"

# Find specific setting
grep -i "port" /etc/ssh/sshd_config | grep -v "^#"

# List all configured options
grep -v "^#" config.conf | grep -v "^$" | cut -d '=' -f 1
```

### Text Processing

```bash
# Get unique values
cat data.txt | sort | uniq

# Count occurrences
cat data.txt | sort | uniq -c

# Remove duplicates
cat list.txt | sort | uniq > clean_list.txt

# Find common lines in two files
cat file1.txt file2.txt | sort | uniq -d
```

### Searching Code

```bash
# Find function definitions
grep -rn "def function_name" ./

# Find all imports
grep -r "^import" . --include="*.py"

# Count TODO comments
grep -rc "TODO" ./src/

# Find where class is used
grep -rw "ClassName" ./
```

---

## Advanced Pipe Combinations

### Multi-Stage Processing

```bash
# Process log file
cat app.log \
  | grep error \
  | grep -v debug \
  | cut -d ' ' -f 1-3 \
  | sort \
  | uniq -c \
  | sort -rn

# Analyze access logs
cat access.log \
  | cut -d ' ' -f 1 \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -10
```

### System Monitoring

```bash
# Top memory users
ps aux | tail -n +2 | sort -k 4 -rn | head -5

# Disk usage by directory
du -sh * | sort -h | tail

# Find largest files
find . -type f -exec ls -lh {} \; | sort -k 5 -hr | head -10
```

### Data Extraction

```bash
# Extract email addresses
grep -Eo "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" file.txt

# Extract IP addresses
grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" log.txt

# Extract URLs
strings file | grep -Eo "https?://[^ ]+"
```

---

## Tips and Best Practices

### Efficient Searching

```bash
# Use specific patterns
grep "error:" log.txt           # More specific
grep "error" log.txt            # Too broad

# Combine filters
grep error log.txt | grep -v debug    # More efficient
grep error log.txt | grep critical    # than multiple greps
```

### Debugging Pipes

```bash
# Test each stage
command1
command1 | command2
command1 | command2 | command3

# Use head to limit output while testing
large_command | head
```

### Performance

```bash
# Exit early when possible
grep -m 1 pattern file.txt      # Stop after first match

# Use specific file types
grep pattern *.txt              # Better than *

# Avoid unnecessary pipes
grep pattern file               # Better than
cat file | grep pattern         # unnecessary cat
```

### Common Mistakes

```bash
# WRONG: Useless cat
cat file.txt | grep pattern

# CORRECT: Direct grep
grep pattern file.txt

# WRONG: Multiple separate greps
grep word1 file | grep word2 | grep word3

# BETTER: Single grep with regex
grep "word1.*word2.*word3" file
```

---

## Quick Reference

### grep Essentials

```bash
# Basic search
grep pattern file

# Case-insensitive
grep -i pattern file

# With line numbers
grep -n pattern file

# Count matches
grep -c pattern file

# Recursive
grep -r pattern dir/

# Exclude pattern
grep -v pattern file

# Multiple files
grep pattern *.txt
```

### Pipe Patterns

```bash
# Filter output
command | grep pattern

# Count results
command | wc -l

# Sort results
command | sort

# Unique values
command | sort | uniq

# Top items
command | sort | uniq -c | sort -rn | head
```

### cut Essentials

```bash
# By character
cut -c 1-5 file

# By field (comma-delimited)
cut -d ',' -f 1 file

# Multiple fields
cut -d ':' -f 1,3 file
```

### strings Essentials

```bash
# Extract text from binary
strings binary_file

# Minimum length
strings -n 8 binary_file

# Search in binary
strings binary | grep pattern
```

---

## Summary

### Key Commands

**grep:**
- Search for text patterns in files
- Many options for flexible searching (-i, -n, -r, -v)
- Essential for log analysis and text searching

**Pipes (|):**
- Connect commands together
- Output of one becomes input of next
- Enable powerful command combinations

**cut:**
- Extract specific columns or fields
- Works with delimiters (CSV, colon-separated, etc.)
- Great for parsing structured text

**strings:**
- Extract readable text from binary files
- Useful for investigating executables
- Combine with grep for targeted searches

### Common Patterns

**Search and count:**
```bash
grep pattern file | wc -l
```

**Search and sort:**
```bash
grep pattern file | sort | uniq
```

**Process and extract:**
```bash
command | grep filter | cut -d ',' -f 1 | sort
```

**Recursive search:**
```bash
grep -r pattern directory/
```

### Best Practices

1. **Be specific** with search patterns
2. **Use pipes** to chain commands efficiently
3. **Test each stage** of complex pipes
4. **Combine options** for powerful searches
5. **Use -v** to exclude unwanted results
6. **Remember -i** for case-insensitive searches
7. **Add -n** when you need line numbers

---

**Practice these commands with real files to master text searching and processing!**