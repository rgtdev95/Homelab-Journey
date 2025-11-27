# 🐧 Linux Hands-On Challenge: "The New Sysadmin"

**Scenario:**
You have just been hired as a Junior System Administrator for "TechCorp". Your manager has given you access to a fresh Linux server and a list of tasks to set up your environment and perform some basic maintenance.

**Prerequisite:**
Before starting, run the setup script to generate your lab environment.
1.  Open your terminal.
2.  Navigate to this folder: `cd "Learning Linux/Practice"` (adjust path if needed).
3.  Run the script: `bash setup_challenge_env.sh`
4.  Go to the lab folder: `cd ~/Linux_Challenge_Lab`

**Objective:** Complete the following tasks using the terminal. Try to do them without looking up the answers first!

---

## 🟢 Level 1: Setup & Organization

1.  **Home Base**: Verify you are inside `~/Linux_Challenge_Lab`. List all files, including hidden ones.
2.  **Clean Up The Mess**: Look inside the `Messy_Folder`. Create three new directories inside it: `Music`, `Images`, and `Docs`.
3.  **Sort It Out**: Move all `.mp3` files to `Music`, all `.jpg` and `.png` files to `Images`, and everything else (`.txt`, `.pdf`, `.md`) to `Docs`.
4.  **The Note**: Create a file named `welcome.txt` inside `Linux_Challenge_Lab` using a text editor (nano or vim). Write "Property of TechCorp" inside it and save.

## 🟡 Level 2: Permissions & Secrets

5.  **The Locked File**: Try to read the content of `secret_file.txt`. It should fail.
6.  **Unlock It**: Change the permissions of `secret_file.txt` so that *only you* can read and write to it.
7.  **Reveal the Secret**: Read the file now. What is the code?
8.  **Hidden Clue**: Find the hidden file in the main lab directory and read its content.

## 🟠 Level 3: Power User Moves

9.  **Log Analysis**: Look at `server_logs.txt`. Use `grep` to find only the lines that contain "ERROR".
10. **Critical Alert**: Count how many "INFO" messages are in the log file using a pipe and `wc`.
11. **Redirection**: Save all "ERROR" lines to a new file named `error_report.txt`.
12. **Process Check**: Run a command to see all currently running processes. Find the process ID (PID) of your current shell.

## 🔴 Level 4: Environment & Automation

13. **Alias**: You are tired of typing `ls -la`. Create a temporary alias named `ll` that runs `ls -la`. Verify it works.
14. **System Info**: Find out the kernel version of your system.
15. **Disk Usage**: Check how much free space is available on your hard drive in a "human-readable" format.

---

## ✅ Self-Correction / Answer Key

<details>
<summary>Click to reveal the commands</summary>

**Level 1**
1. `ls -la`
2. `cd Messy_Folder; mkdir Music Images Docs`
3. `mv *.mp3 Music/; mv *.jpg *.png Images/; mv *.txt *.pdf *.md Docs/`
4. `nano welcome.txt` -> Type text -> Ctrl+O -> Enter -> Ctrl+X

**Level 2**
5. `cat secret_file.txt` (Permission denied)
6. `chmod 600 secret_file.txt` (or `chmod u+rw secret_file.txt`)
7. `cat secret_file.txt`
8. `cat .hidden_clue`

**Level 3**
9. `grep "ERROR" server_logs.txt`
10. `grep "INFO" server_logs.txt | wc -l`
11. `grep "ERROR" server_logs.txt > error_report.txt`
12. `ps` or `ps aux | grep bash`

**Level 4**
13. `alias ll='ls -la'`
14. `uname -r`
15. `df -h`

</details>
