# Processes and Job Control in Linux

## Introduction

A **process** is a running instance of a program. Understanding how to view, manage, and control processes is essential for system administration, troubleshooting, and resource management in Linux.

**Why learn about processes?**
- ✅ Monitor system resource usage
- ✅ Troubleshoot performance issues
- ✅ Manage background tasks
- ✅ Kill frozen or unresponsive programs
- ✅ Essential for DevOps and system administration

---

## What is a Process?

### Process Basics

**Process:**
An instance of a program running in memory with its own process ID (PID), resources, and execution state.

**Every process has:**
- **PID** - Process ID (unique identifier)
- **PPID** - Parent Process ID (who started it)
- **UID/GID** - User and group ownership
- **State** - Running, sleeping, stopped, zombie
- **Priority** - CPU scheduling priority
- **Resources** - Memory, CPU time, open files

**Process lifecycle:**
```
Created → Running → Sleeping → Stopped → Terminated
```

### Process Types

| Type | Description | Example |
|------|-------------|---------|
| **Foreground** | Runs in terminal, blocks input | `vim file.txt` |
| **Background** | Runs without blocking terminal | `command &` |
| **Daemon** | Background system service | `sshd`, `httpd`, `cron` |
| **Zombie** | Finished but not cleaned up | (defunct process) |
| **Orphan** | Parent process died | Adopted by init/systemd |

---

## The ps Command

### Basic ps Usage

**View your processes:**
```bash
# Show processes in current shell
ps

# Example output:
  PID TTY          TIME CMD
12345 pts/0    00:00:00 bash
12789 pts/0    00:00:00 ps
```

**Column meanings:**
- **PID** - Process ID
- **TTY** - Terminal controlling the process
- **TIME** - CPU time consumed
- **CMD** - Command name

### Common ps Options

**Show all processes for current user:**
```bash
ps -u
# or
ps u

# Example output:
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
john     12345  0.0  0.1  21768  5012 pts/0    Ss   14:30   0:00 -bash
john     12789  0.0  0.0  39120  3456 pts/0    R+   14:35   0:00 ps u
```

**Show all processes system-wide:**
```bash
# BSD style (no dash)
ps aux

# UNIX style (with dash)
ps -ef

# Example ps aux output:
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.2 169604 11344 ?        Ss   Jan15   0:15 /sbin/init
root         2  0.0  0.0      0     0 ?        S    Jan15   0:00 [kthreadd]
www-data  1234  0.1  1.5 245688 62340 ?        S    14:20   0:05 nginx: worker
john      5678  2.5  3.2 678912 131072 ?       Sl   14:30   1:23 /usr/bin/code
```

### Understanding ps Output

**Key columns explained:**

| Column | Meaning | Example |
|--------|---------|---------|
| `USER` | Process owner | `root`, `john` |
| `PID` | Process ID | `1234` |
| `%CPU` | CPU usage percentage | `2.5` = 2.5% |
| `%MEM` | Memory usage percentage | `3.2` = 3.2% |
| `VSZ` | Virtual memory size (KB) | `169604` |
| `RSS` | Resident memory size (KB) | `11344` |
| `TTY` | Controlling terminal | `pts/0`, `?` (no terminal) |
| `STAT` | Process state | `S`, `R`, `Z`, `D` |
| `START` | Start time | `14:30` or `Jan15` |
| `TIME` | CPU time consumed | `0:05` = 5 seconds |
| `COMMAND` | Full command with arguments | `/usr/bin/nginx -g ...` |

**Process states (STAT column):**

| Code | State | Meaning |
|------|-------|---------|
| `R` | Running | Currently executing or runnable |
| `S` | Sleeping | Waiting for event (interruptible) |
| `D` | Sleeping | Waiting for I/O (uninterruptible) |
| `T` | Stopped | Suspended (Ctrl+Z) |
| `Z` | Zombie | Terminated but not reaped |
| `I` | Idle | Kernel idle thread |

**Additional codes:**
- `<` - High priority
- `N` - Low priority
- `L` - Has pages locked in memory
- `s` - Session leader
- `l` - Multi-threaded
- `+` - In foreground process group

### Useful ps Command Combinations

**Show specific user's processes:**
```bash
ps -u username
ps aux | grep username
```

**Show process tree (hierarchy):**
```bash
ps auxf     # Forest mode (ASCII tree)
ps -ejH     # Hierarchy with indentation
pstree      # Dedicated tree view
```

**Show processes by name:**
```bash
ps aux | grep nginx
ps -C nginx     # More efficient
pgrep nginx     # Just show PIDs
```

**Show top CPU consumers:**
```bash
ps aux --sort=-%cpu | head -10
```

**Show top memory consumers:**
```bash
ps aux --sort=-%mem | head -10
```

**Show processes with specific PID:**
```bash
ps -p 1234
ps -fp 1234     # Full format
```

**Custom output format:**
```bash
# Show PID, user, memory, CPU, command
ps -eo pid,user,%mem,%cpu,comm

# Show threads
ps -eLf
```

---

## Job Control

### What is Job Control?

**Job control** allows you to manage multiple processes from a single terminal session - running commands in foreground, background, suspending, and resuming them.

### Running Commands in Background

**Start process in background:**
```bash
# Add & at the end
command &

# Example
sleep 60 &
# Output: [1] 12345
# [1] = job number, 12345 = PID
```

**Start multiple background jobs:**
```bash
sleep 60 &
sleep 120 &
sleep 180 &
```

### Viewing Jobs

**List current jobs:**
```bash
jobs

# Example output:
[1]   Running                 sleep 60 &
[2]-  Running                 sleep 120 &
[3]+  Running                 sleep 180 &
```

**Symbols:**
- `+` - Current job (default for `fg` and `bg`)
- `-` - Previous job
- No symbol - Older jobs

**Show job PIDs:**
```bash
jobs -l

# Output:
[1]  12345 Running                 sleep 60 &
[2]  12346 Running                 sleep 120 &
[3]  12347 Running                 sleep 180 &
```

### Foreground and Background

**Bring job to foreground:**
```bash
# Bring current job to foreground
fg

# Bring specific job to foreground
fg %1      # Job 1
fg %sleep  # Job matching "sleep"
```

**Send job to background:**
```bash
# First suspend with Ctrl+Z
# Then send to background
bg

# Or send specific job
bg %1
```

**Example workflow:**
```bash
# Start long-running command
find / -name "*.log" 2>/dev/null

# Oops, this will take forever!
# Press Ctrl+Z to suspend
^Z
[1]+  Stopped                 find / -name "*.log"

# Send to background
bg
[1]+ find / -name "*.log" &

# Continue working while it runs
ls
vim file.txt

# Check job status
jobs
[1]+  Running                 find / -name "*.log" &

# Bring back to foreground when ready
fg
```

### Keyboard Shortcuts for Job Control

| Shortcut | Action |
|----------|--------|
| `Ctrl+Z` | Suspend (stop) current foreground process |
| `Ctrl+C` | Terminate (kill) current foreground process |
| `Ctrl+D` | Send EOF (end-of-file), often exits shell |
| `Ctrl+\` | Send QUIT signal (core dump) |

---

## Process Signals

### What are Signals?

**Signals** are software interrupts sent to processes to notify them of events or request actions.

**Common signals:**

| Signal | Number | Name | Default Action | Use Case |
|--------|--------|------|----------------|----------|
| `SIGTERM` | 15 | Terminate | Terminate gracefully | Normal shutdown |
| `SIGKILL` | 9 | Kill | Force terminate | Kill unresponsive process |
| `SIGINT` | 2 | Interrupt | Terminate | Ctrl+C in terminal |
| `SIGHUP` | 1 | Hangup | Terminate or reload | Reload configuration |
| `SIGSTOP` | 19 | Stop | Suspend | Cannot be caught |
| `SIGCONT` | 18 | Continue | Resume | Resume suspended process |
| `SIGQUIT` | 3 | Quit | Terminate with core dump | Ctrl+\ in terminal |

### Sending Signals with kill

**Basic syntax:**
```bash
kill [signal] PID
```

**Terminate process gracefully:**
```bash
kill 12345          # Send SIGTERM (default)
kill -15 12345      # Explicit SIGTERM
kill -TERM 12345    # Named signal
```

**Force kill unresponsive process:**
```bash
kill -9 12345       # Send SIGKILL
kill -KILL 12345    # Named signal
```

**Reload configuration (common for daemons):**
```bash
kill -HUP 12345     # Send SIGHUP
kill -1 12345
```

**Suspend process:**
```bash
kill -STOP 12345    # Suspend
kill -CONT 12345    # Resume
```

**Kill by name:**
```bash
killall process_name
killall nginx
killall -9 firefox

# More selective
pkill pattern
pkill -u john sleep     # Kill john's sleep processes
pkill -f "python script.py"  # Match full command line
```

---

## Process Management Tools

### top - Real-Time Process Monitor

**Interactive process viewer:**
```bash
top

# Example output:
top - 14:35:22 up 5 days,  3:15,  2 users,  load average: 0.15, 0.10, 0.05
Tasks: 284 total,   1 running, 283 sleeping,   0 stopped,   0 zombie
%Cpu(s):  2.3 us,  0.7 sy,  0.0 ni, 96.8 id,  0.2 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :  15912.5 total,   2134.8 free,   8456.2 used,   5321.5 buff/cache
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   6789.2 avail Mem 

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
 1234 john      20   0 2345678 654321  12345 S   5.3   4.0   1:23.45 firefox
 5678 root      20   0  678901 234567  89012 S   2.0   1.4   0:45.67 Xorg
```

**Useful top commands (while running):**
- `h` - Help
- `k` - Kill process (prompts for PID)
- `r` - Renice (change priority)
- `u` - Show specific user
- `M` - Sort by memory
- `P` - Sort by CPU (default)
- `c` - Show full command
- `1` - Show individual CPUs
- `q` - Quit

**Better alternative - htop:**
```bash
# Install htop
sudo apt install htop

# Run
htop

# Features:
# - Colorful interface
# - Mouse support
# - Tree view
# - Easy process management
```

### pgrep and pkill

**Find processes by name:**
```bash
# Show PIDs matching pattern
pgrep nginx
# Output: 1234 5678

# Show full details
pgrep -a nginx
# Output: 1234 nginx: master process
#         5678 nginx: worker process

# Count matching processes
pgrep -c nginx
# Output: 2
```

**Kill processes by pattern:**
```bash
# Kill all matching processes
pkill nginx

# Force kill
pkill -9 firefox

# Kill for specific user
pkill -u john

# Kill with specific signal
pkill -HUP nginx
```

### pidof

**Find PID of running program:**
```bash
pidof nginx
# Output: 5678 1234

# Use in scripts
NGINX_PID=$(pidof nginx)
echo "Nginx PID: $NGINX_PID"
```

---

## Process Priority and Nice Values

### Understanding Priority

**Priority** determines how much CPU time a process gets relative to others.

**Nice value:**
- Range: -20 (highest priority) to 19 (lowest priority)
- Default: 0
- Only root can set negative values
- Lower nice value = higher priority = more CPU time

### Viewing Priority

```bash
# Show priority in ps
ps -eo pid,ni,comm

# Show in top
top
# Look at 'NI' column
```

### Setting Priority

**Start process with specific nice value:**
```bash
# Start with low priority
nice -n 10 command
nice -10 command

# Start with high priority (requires root)
sudo nice -n -10 command
```

**Change priority of running process:**
```bash
# Increase nice value (lower priority)
renice 10 -p 12345

# Decrease nice value (higher priority, root only)
sudo renice -10 -p 12345

# Change for all processes of user
sudo renice 5 -u john
```

**Practical examples:**
```bash
# Run backup with low priority (won't impact system)
nice -n 19 tar -czf backup.tar.gz /data

# Run important task with high priority
sudo nice -n -15 ./critical_job.sh

# Lower priority of CPU-intensive process
renice 15 -p $(pidof ffmpeg)
```

---

## Monitoring System Resources

### Load Average

**Understanding load average:**
```bash
uptime
# Output: 14:35:22 up 5 days, 3:15, 2 users, load average: 0.15, 0.10, 0.05

# Three numbers:
# 0.15 - 1-minute average
# 0.10 - 5-minute average
# 0.05 - 15-minute average
```

**Interpreting load:**
- **< 1.0** - System idle, no waiting processes
- **= 1.0** - System fully utilized
- **> 1.0** - Processes waiting for CPU time

**Note:** Compare to number of CPU cores. On a 4-core system:
- Load 4.0 = 100% utilized
- Load 8.0 = Overloaded (2x capacity)

### Free Memory

```bash
# Show memory usage
free -h

# Example output:
              total        used        free      shared  buff/cache   available
Mem:           15Gi       8.3Gi       2.1Gi       345Mi       5.3Gi       6.6Gi
Swap:         2.0Gi          0B       2.0Gi
```

### Disk I/O

```bash
# Show I/O statistics
iostat

# Real-time I/O monitoring
iotop  # Requires root

# Show processes using disk
sudo iotop -o  # Only processes doing I/O
```

---

## DevOps Applications

### Container Process Management

**Docker:**
```bash
# List container processes
docker ps

# Show processes inside container
docker top container_name

# Inspect resource usage
docker stats

# Kill container
docker kill container_name
docker stop container_name  # Graceful stop
```

**Kubernetes:**
```bash
# Show pod processes
kubectl top pods

# Get pod resource usage
kubectl top pod pod_name

# View pod logs
kubectl logs -f pod_name
```

### Monitoring in Production

**Process monitoring:**
```bash
# Check if service is running
pgrep -x nginx >/dev/null && echo "Running" || echo "Stopped"

# Monitor specific process
watch -n 1 'ps -p 12345 -o pid,pcpu,pmem,cmd'

# Alert if process dies
while sleep 10; do
    if ! pgrep -x nginx >/dev/null; then
        echo "Nginx is down!" | mail -s "Alert" admin@example.com
        systemctl start nginx
    fi
done
```

### Automation Scripts

**Wait for process to complete:**
```bash
# Start background process
./long_job.sh &
JOB_PID=$!

# Wait for completion
wait $JOB_PID
echo "Job completed with exit code: $?"
```

**Kill process tree:**
```bash
# Kill process and all its children
pkill -TERM -P 12345  # Kill children
kill -TERM 12345      # Kill parent
```

---

## Troubleshooting

### High CPU Usage

```bash
# Find CPU hogs
top
# Press 'P' to sort by CPU

# Or
ps aux --sort=-%cpu | head -10

# Check specific process
top -p 12345
```

### High Memory Usage

```bash
# Find memory hogs
top
# Press 'M' to sort by memory

# Or
ps aux --sort=-%mem | head -10

# Check memory details
cat /proc/12345/status | grep Vm
```

### Zombie Processes

```bash
# Find zombies
ps aux | grep Z
ps aux | grep defunct

# Zombies can't be killed directly
# Kill parent process to clean them up
kill $(ps -o ppid= -p zombie_pid)
```

### Unresponsive Process

```bash
# Try graceful termination first
kill 12345

# Wait 10 seconds
sleep 10

# Force kill if still running
kill -9 12345

# Or in one line
kill 12345 || sleep 10 && kill -9 12345
```

---

## Quick Reference

### Process Viewing

```bash
ps                  # Your processes
ps aux              # All processes (BSD style)
ps -ef              # All processes (UNIX style)
ps -u username      # User's processes
pgrep pattern       # Find PIDs by name
pidof program       # PID of program
top                 # Real-time monitor
htop                # Better top
```

### Job Control

```bash
command &           # Run in background
jobs                # List jobs
fg %1               # Bring job 1 to foreground
bg %1               # Send job 1 to background
Ctrl+Z              # Suspend current job
Ctrl+C              # Kill current job
```

### Process Management

```bash
kill PID            # Terminate gracefully (SIGTERM)
kill -9 PID         # Force kill (SIGKILL)
kill -HUP PID       # Reload config (SIGHUP)
killall name        # Kill by name
pkill pattern       # Kill by pattern
nice -n 10 command  # Start with low priority
renice 10 -p PID    # Change priority
```

---

## Summary

**Key Concepts:**

1. **Process** - Running instance of a program
2. **PID** - Unique process identifier
3. **Job control** - Managing foreground/background processes
4. **Signals** - Messages sent to processes
5. **Priority** - CPU scheduling preference

**Essential Commands:**

- `ps aux` - View all processes
- `top` / `htop` - Monitor processes in real-time
- `kill PID` - Terminate process
- `jobs` - List background jobs
- `fg` / `bg` - Switch foreground/background

**Best Practices:**

1. Use `kill` (SIGTERM) before `kill -9` (SIGKILL)
2. Monitor system resources regularly
3. Use `nice` for CPU-intensive tasks
4. Clean up zombie processes by killing parent
5. Use `pgrep`/`pkill` for pattern matching
6. Check process state before killing
7. Use job control for interactive tasks

**Common Troubleshooting:**

- High CPU → `top`, sort by CPU, investigate
- High memory → `top`, sort by memory, investigate
- Unresponsive → `kill`, wait, then `kill -9`
- Zombies → Kill parent process

---

**Master process management for effective system administration!**