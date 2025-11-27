# File and Directory Permissions Explained

## Introduction

Linux permissions control who can **read**, **write**, and **execute** files and directories. Understanding permissions is crucial for:
- Securing your files
- Collaborating with team members
- Troubleshooting access issues
- Managing system resources

---

## Understanding the Permissions String

When you run `ls -l`, you see a permissions string at the beginning of each line:

```bash
$ ls -l sales.data
-rw-r--r-- 1 bob users 10400 Sep 27 08:52 sales.data
```

The permissions string: `-rw-r--r--` tells you everything about access control for this file.

---

## File Type Indicators

The **first character** indicates the file type:

| Symbol | Type | Description |
|--------|------|-------------|
| `-` | Regular file | Normal files (text, programs, etc.) |
| `d` | Directory | Folder/directory |
| `l` | Symbolic link | Shortcut to another file/directory |

**Examples:**
```bash
-rw-r--r--  # Regular file
drwxr-xr-x  # Directory
lrwxrwxrwx  # Symbolic link
```

---

## Permission Types

There are three types of permissions:

| Symbol | Permission | Meaning |
|--------|-----------|---------|
| `r` | **Read** | View file contents or list directory contents |
| `w` | **Write** | Modify file or add/remove files in directory |
| `x` | **Execute** | Run file as program or access directory |

### Permissions on Files vs Directories

| Permission | File Meaning | Directory Meaning |
|------------|--------------|-------------------|
| **Read (r)** | View file contents | List files in directory |
| **Write (w)** | Modify file contents | Create/delete files in directory |
| **Execute (x)** | Run as a program | Access directory (cd into it) |

---

## User Categories

Permissions are applied to three categories of users:

| Symbol | Category | Description |
|--------|----------|-------------|
| `u` | **User** | Owner of the file |
| `g` | **Group** | Users in the file's group |
| `o` | **Other** | Everyone else |
| `a` | **All** | User + Group + Other |

### Groups in Linux

- Every user belongs to at least one **primary group**
- Users can be members of multiple groups
- Groups organize users into logical teams (sales, developers, etc.)

**Check your groups:**
```bash
groups                  # Your groups
groups username         # Another user's groups
id -Gn                  # Alternative command
```

**Example:**
```bash
$ groups
users sales

$ groups pat
users projectx apache
```

---

## Decoding the Permissions String

Let's break down: `-rw-r--r--`

```
-rw-r--r--
│└┬┘└┬┘└┬┘
│ │  │  └── Other permissions (r--) = read only
│ │  └───── Group permissions (r--) = read only
│ └──────── User permissions (rw-) = read + write
└────────── File type (-) = regular file
```

### Complete Breakdown

```
-rw-   r--  r--   1  bob  users  10400  Sep 27 08:52  sales.data
│└─┬─┘└─┬─┘└─┬─┘  │   │      │       │         │            │
│  │    │    │    │   │      │       │         │            └─ Filename
│  │    │    │    │   │      │       │         └─ Last modified
│  │    │    │    │   │      │       └─ File size (bytes)
│  │    │    │    │   │      └─ Group owner
│  │    │    │    │   └─ File owner
│  │    │    │    └─ Number of links
│  │    │    └─ Other: read only
│  │    └─ Group: read only
│  └─ User/Owner: read + write
└─ File type: regular file
```

### Special Indicators

You may see extra characters at the end:

| Character | Meaning |
|-----------|---------|
| `.` | SELinux security context applied |
| `+` | ACLs (Access Control Lists) in use |

```bash
-rw-r--r--.  # SELinux context
-rw-r--r--+  # ACLs enabled
```

---

## Changing Permissions with chmod

The `chmod` (change mode) command modifies file permissions.

### Method 1: Symbolic Mode

**Format:** `chmod [who][operator][permissions] file`

**Components:**
- **Who:** `u` (user), `g` (group), `o` (other), `a` (all)
- **Operator:** `+` (add), `-` (remove), `=` (set exactly)
- **Permissions:** `r` (read), `w` (write), `x` (execute)

#### Examples

**Add write permission for group:**
```bash
$ ls -l sales.data
-rw-r--r-- 1 bob users 10400 Sep 27 08:52 sales.data

$ chmod g+w sales.data

$ ls -l sales.data
-rw-rw-r-- 1 bob users 10400 Sep 27 08:52 sales.data
```

**Remove write permission from group:**
```bash
$ chmod g-w sales.data
-rw-r--r-- 1 bob users 10400 Sep 27 08:52 sales.data
```

**Add multiple permissions:**
```bash
$ chmod g+wx sales.data
-rw-rwxr-- 1 bob users 10400 Sep 27 08:52 sales.data
```

**Change multiple categories:**
```bash
$ chmod ug+wx sales.data
-rwxrwxr-- 1 bob users 10400 Sep 27 08:52 sales.data
```

**Set exact permissions:**
```bash
$ chmod u=rwx,g=rx,o= sales.data
-rwxr-x--- 1 bob users 10400 Sep 27 08:52 sales.data
```

**Make readable by everyone:**
```bash
$ chmod a=r sales.data
-r--r--r-- 1 bob users 10400 Sep 27 08:52 sales.data
```

---

## Method 2: Numeric (Octal) Mode

Numeric mode is faster once you memorize the numbers!

### Understanding the Numbers

Permissions are based on binary but expressed in decimal:

| Binary | Decimal | Permissions | String |
|--------|---------|-------------|--------|
| `000` | **0** | None | `---` |
| `001` | **1** | Execute only | `--x` |
| `010` | **2** | Write only | `-w-` |
| `011` | **3** | Write + Execute | `-wx` |
| `100` | **4** | Read only | `r--` |
| `101` | **5** | Read + Execute | `r-x` |
| `110` | **6** | Read + Write | `rw-` |
| `111` | **7** | Read + Write + Execute | `rwx` |

### The Magic Formula

- **Read (r) = 4**
- **Write (w) = 2**
- **Execute (x) = 1**

Add them up to get the permission number:
- `rwx = 4 + 2 + 1 = 7`
- `rw- = 4 + 2 + 0 = 6`
- `r-x = 4 + 0 + 1 = 5`
- `r-- = 4 + 0 + 0 = 4`

### Using Numeric Permissions

**Format:** `chmod ### file` (three digits for User, Group, Other)

**Example:** `chmod 754 file`

```
7        5        4
│        │        │
│        │        └─ Other: read only (4)
│        └─ Group: read + execute (5)
└─ User: read + write + execute (7)
```

```bash
$ chmod 754 sales.data
$ ls -l sales.data
-rwxr-xr-- 1 bob users 10400 Sep 27 08:52 sales.data
```

### Visual Guide

```
U   G   O
rwx r-x r--    Symbolic
111 101 100    Binary
7   5   4      Decimal
```

---

## Common Permission Patterns

Here are the most frequently used permissions:

| Numeric | Symbolic | Use Case |
|---------|----------|----------|
| **700** | `rwx------` | Private file/script - owner only |
| **755** | `rwxr-xr-x` | Public executable - everyone can run, only owner edits |
| **644** | `rw-r--r--` | Public readable file - everyone reads, only owner edits |
| **664** | `rw-rw-r--` | Group-editable file - team can edit, others read |
| **660** | `rw-rw----` | Group-only file - team can edit, others excluded |
| **750** | `rwxr-x---` | Group-executable - team can run, others excluded |
| **600** | `rw-------` | Private file - owner read/write only |

### Avoid These Permissions

⚠️ **777** (`rwxrwxrwx`) - Everyone has full access (security risk!)
⚠️ **666** (`rw-rw-rw-`) - Everyone can modify (security risk!)

**Better practice:** Use groups to control access instead of giving everyone permissions.

---

## Working with Groups

### Changing File Group with chgrp

**Format:** `chgrp GROUP FILE`

**Example:**
```bash
$ nano sales.report
$ ls -l sales.report
-rw-r--r-- 1 bob users 6 Dec 4 20:41 sales.report

$ chgrp sales sales.report
$ ls -l sales.report
-rw-r--r-- 1 bob sales 6 Dec 4 20:41 sales.report

$ chmod 664 sales.report
$ ls -l sales.report
-rw-rw-r-- 1 bob sales 6 Dec 4 20:41 sales.report
```

Now members of the `sales` group can edit the file!

### Team Directory Setup

For team collaboration, create a shared directory:

```bash
$ ls -ld /usr/local/sales
drwxrwxr-x 2 root sales 4096 Dec 4 20:53 /usr/local/sales

$ mv sales.report /usr/local/sales/
$ ls -l /usr/local/sales
-rw-rw-r-- 1 bob sales 6 Dec 4 20:41 sales.report
```

**Directory permissions:**
- **775** (`rwxrwxr-x`) - Team can access, others can view
- **770** (`rwxrwx---`) - Team only, no outside access

---

## Directory Permissions in Detail

Directory permissions work differently than file permissions:

| Permission | What It Allows |
|------------|---------------|
| **Read (r)** | List directory contents with `ls` |
| **Write (w)** | Create/delete files in directory |
| **Execute (x)** | Access directory (cd into it) and access files inside |

### Critical: Execute Permission on Directories

Without **execute (x)** on a directory, you **cannot**:
- `cd` into it
- Access files inside (even if file permissions allow)
- See file metadata

**Example Problem:**
```bash
$ ls -dl directory/
drwxr-xr-x 2 bob users 4096 Sep 29 22:02 directory/

$ chmod 400 directory       # Remove execute permission
$ ls -dl directory/
dr-------- 2 bob users 4096 Sep 29 22:02 directory/

$ ls -l directory/
ls: cannot access directory/testprog: Permission denied

$ directory/testprog
-su: directory/testprog: Permission denied
```

**Solution: Add execute permission:**
```bash
$ chmod 500 directory/
$ ls -dl directory/
dr-x------ 2 bob users 4096 Sep 29 22:02 directory/

$ directory/testprog
This program ran successfully.
```

**Remember:** Always ensure parent directories have execute permission!

---

## Default Permissions and umask

### What is umask?

The **umask** (user file-creation mask) determines default permissions for new files and directories.

- **Without umask:** Directories = 777, Files = 666
- **With umask:** Permissions are restricted (masked)

**View current umask:**
```bash
$ umask
0022

$ umask -S
u=rwx,g=rx,o=rx
```

### How umask Works

umask **subtracts** permissions from the base:

**Quick calculation:**
- Directories: `777 - umask`
- Files: `666 - umask`

### Common umask Values

#### umask 022 (Default on most systems)
```
Directories: 777 - 022 = 755 (rwxr-xr-x)
Files:       666 - 022 = 644 (rw-r--r--)
```
**Use case:** Standard security - owner has full control, others read-only

#### umask 002 (Good for team collaboration)
```
Directories: 777 - 002 = 775 (rwxrwxr-x)
Files:       666 - 002 = 664 (rw-rw-r--)
```
**Use case:** Team members can edit, others read-only

#### umask 007 (Team-only access)
```
Directories: 777 - 007 = 770 (rwxrwx---)
Files:       666 - 007 = 660 (rw-rw----)
```
**Use case:** Only team members have access, no outside access

#### umask 077 (Maximum privacy)
```
Directories: 777 - 077 = 700 (rwx------)
Files:       666 - 077 = 600 (rw-------)
```
**Use case:** Owner-only access, complete privacy

### Setting umask

**Temporary (current session):**
```bash
umask 002
```

**Permanent (add to ~/.bashrc):**
```bash
echo "umask 002" >> ~/.bashrc
```

### umask Examples

**With umask 022:**
```bash
$ umask
0022
$ mkdir a-dir
$ touch a-file
$ ls -l
drwxr-xr-x 2 bob users 4096 Dec 5 00:03 a-dir
-rw-r--r-- 1 bob users    0 Dec 5 00:03 a-file
```

**With umask 007:**
```bash
$ umask 007
$ mkdir a-dir
$ touch a-file
$ ls -l
drwxrwx--- 2 bob users 4096 Dec 5 00:04 a-dir
-rw-rw---- 1 bob users    0 Dec 5 00:04 a-file
```

---

## Complete umask Reference Table

| umask | Dir Result | File Result | Description |
|-------|------------|-------------|-------------|
| **0** | `rwx` | `rw-` | No restrictions |
| **1** | `rw-` | `rw-` | Remove execute |
| **2** | `r-x` | `r--` | Remove write |
| **3** | `r--` | `r--` | Remove write + execute |
| **4** | `-wx` | `-w-` | Remove read |
| **5** | `-w-` | `-w-` | Remove read + execute |
| **6** | `--x` | `---` | Remove read + write |
| **7** | `---` | `---` | Remove all permissions |

---

## Special Permissions (Advanced)

The leading zero in `umask 0022` represents special modes:

| Mode | Symbol | Description |
|------|--------|-------------|
| **setuid** | `s` in user execute | Run as file owner (not executor) |
| **setgid** | `s` in group execute | Run as file group (not executor's group) |
| **sticky bit** | `t` in other execute | Only owner can delete (useful for /tmp) |

**Example:**
```bash
chmod 4755 file     # setuid + 755
chmod 2755 dir      # setgid + 755
chmod 1777 /tmp     # sticky bit + 777
```

**Note:** Special permissions are beyond basic usage but good to know about.

---

## Practical Examples and Scenarios

### Scenario 1: Private Script
```bash
# Create a personal script
vim my_script.sh
chmod 700 my_script.sh
ls -l my_script.sh
-rwx------ 1 bob users 150 Dec 5 10:30 my_script.sh
```

### Scenario 2: Team Project
```bash
# Setup team directory
sudo mkdir /projects/teamA
sudo chgrp developers /projects/teamA
sudo chmod 770 /projects/teamA

# Create shared file
cd /projects/teamA
touch project.txt
chgrp developers project.txt
chmod 660 project.txt
```

### Scenario 3: Public Web Files
```bash
# Web server files (readable by all, editable by owner)
chmod 644 index.html
chmod 755 cgi-bin/script.cgi
```

### Scenario 4: Finding Permission Issues
```bash
# Check directory chain
ls -ld .
cd ..
ls -ld .
# Repeat until you find the problem
```

---

## Quick Reference Commands

### View Permissions
```bash
ls -l file                # File permissions
ls -ld directory          # Directory permissions
stat file                 # Detailed file info
```

### Change Permissions
```bash
chmod 755 file            # Numeric mode
chmod u+x file            # Add execute for user
chmod g-w file            # Remove write from group
chmod a=r file            # Everyone read-only
chmod -R 755 directory    # Recursive
```

### Change Ownership
```bash
chgrp group file          # Change group
chown user file           # Change owner
chown user:group file     # Change both
sudo chown -R user:group dir/  # Recursive
```

### Check Groups
```bash
groups                    # Your groups
groups username           # User's groups
id                        # Detailed user info
```

### umask
```bash
umask                     # Show current umask
umask 002                 # Set umask
umask -S                  # Symbolic display
```

---

## Troubleshooting Tips

1. **"Permission denied" when running script**
   - Check execute permission: `chmod +x script.sh`
   - Check directory permissions leading to script

2. **Can't modify file in shared directory**
   - Check file permissions: `ls -l file`
   - Check group membership: `groups`
   - Check directory write permission: `ls -ld directory`

3. **File has correct permissions but still can't access**
   - Check parent directory execute permission
   - Look for SELinux/ACL indicators (`.` or `+`)
   - Work up the directory tree: `ls -ld .` then `cd ..`

4. **New files don't have expected permissions**
   - Check umask: `umask`
   - Adjust umask: `umask 002`
   - Make permanent in `~/.bashrc`

---

## Best Practices

✅ **DO:**
- Use groups for team collaboration
- Set umask appropriately for your workflow
- Check directory permissions when troubleshooting
- Use `chmod 755` for executables
- Use `chmod 644` for regular files
- Document special permission requirements

❌ **DON'T:**
- Use 777 unless absolutely necessary
- Give write permissions to "other" without reason
- Forget about parent directory permissions
- Change permissions on system files without understanding impact
- Use 666 permissions (security risk)

---

## Summary

### Permission Basics
- Three types: **read (r)**, **write (w)**, **execute (x)**
- Three categories: **user (u)**, **group (g)**, **other (o)**
- Permissions shown in order: **user-group-other**

### chmod Methods
- **Symbolic:** `chmod g+w file` (intuitive)
- **Numeric:** `chmod 664 file` (faster, memorize common patterns)

### Common Patterns
- **700** - Private
- **755** - Public executable
- **644** - Public readable
- **664** - Group editable
- **660** - Group only

### umask
- Controls default permissions
- Common values: 022, 002, 007, 077
- Set in `~/.bashrc` for persistence

### Remember
- Directories need **execute** permission to access
- Check parent directories when troubleshooting
- Use groups instead of giving everyone access
- Test permissions after changes

---

**Practice makes perfect!** Try creating files with different permissions and accessing them as different users to understand how it all works.