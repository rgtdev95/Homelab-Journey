# Linux Text Editors - Complete Beginner's Guide

## Introduction

Text editors are essential tools in Linux. Whether you're editing configuration files, writing scripts, or viewing log files, you'll need to know how to work with text. This guide covers viewing files and the three main Linux editors, from simplest to most advanced.

---

## Part 1: Viewing Files

Before editing, you often just need to view file contents. Here are the essential viewing commands:

### Basic Viewing Commands

| Command | Purpose | Use Case |
|---------|---------|----------|
| `cat file` | Display entire file | Small files |
| `more file` | Page through file (forward only) | Medium files |
| `less file` | Page through file (forward & backward) | Any size, most flexible |
| `head file` | Show first 10 lines | Quick preview |
| `tail file` | Show last 10 lines | Recent entries (logs) |

### Examples

**View entire file:**
```bash
$ cat file.txt
This is the first line.
This is the second.
Here is some more interesting text.
Knock knock.
Who's there?
More filler text.
The quick brown fox jumps over the lazy dog.
The dog was rather impressed.
Roses are red,
Violets are blue,
All my base are belong to you.
Finally, the 12th and last line.
```

**Show first lines:**
```bash
$ head file.txt
This is the first line.
This is the second.
Here is some more interesting text.
Knock knock.
Who's there?
More filler text.
The quick brown fox jumps over the lazy dog.
The dog was rather impressed.
Roses are red,
Violets are blue,
```

**Show last lines:**
```bash
$ tail file.txt
Here is some more interesting text.
Knock knock.
Who's there?
More filler text.
The quick brown fox jumps over the lazy dog.
The dog was rather impressed.
Roses are red,
Violets are blue,
All my base are belong to you.
Finally, the 12th and last line.
```

### Controlling Output Size

Specify number of lines with `-n`:

```bash
# Show first 2 lines
$ head -2 file.txt
This is the first line.
This is the second.

# Show last 1 line
$ tail -1 file.txt
Finally, the 12th and last line.

# Show first 5 lines
head -5 file.txt

# Show last 20 lines
tail -20 file.txt
```

### Using more

```bash
$ more file.txt
```

**Navigation in more:**
- **Spacebar** - Next page
- **Enter** - Next line
- **q** - Quit

### Using less (Better than more!)

```bash
$ less file.txt
```

**Navigation in less:**
- **Spacebar** - Next page
- **b** - Previous page
- **Enter** - Next line
- **k** - Previous line
- **/** - Search forward (type pattern, press Enter)
- **?** - Search backward
- **n** - Next search result
- **N** - Previous search result
- **q** - Quit

**Why less is better:** You can scroll both directions and search!

### Real-Time File Viewing

Watch files as they're being updated (perfect for logs):

```bash
$ tail -f /var/log/syslog
Oct 10 16:41:17 app: Processing request 7680687
Oct 10 16:42:28 app: User pat denied access to admin functions
... (continues updating as new lines are added)
```

**Stop watching:** Press `Ctrl+C`

**Use cases:**
- Monitoring log files
- Watching application output
- Debugging in real-time

---

## Part 2: Choosing an Editor

Linux has three main text editors, each with different complexity:

| Editor | Difficulty | Best For | When to Use |
|--------|-----------|----------|-------------|
| **nano** | Easy ⭐ | Quick edits | Beginners, simple tasks |
| **vi/vim** | Hard ⭐⭐⭐ | Everything | Power users, always available |
| **emacs** | Hard ⭐⭐⭐ | Everything | Power users, programmers |

**Recommendation for beginners:** Start with **nano**, then learn **vim** as you get comfortable.

---

## Part 3: Nano Editor (Easiest)

### What is Nano?

- **Simplest** Linux editor
- Commands shown on screen
- Perfect for beginners
- Great for quick edits

### Starting Nano

```bash
nano filename          # Edit existing file or create new one
nano                   # Start with empty file
```

### Nano Interface

When you open nano, you see:
- File content in main area
- Commands at bottom of screen
- `^` means `Ctrl` key

```
  GNU nano 2.9.3                    filename.txt

This is the file content
You can type here


[ Read 1 line ]
^G Get Help  ^O Write Out  ^W Where Is   ^K Cut Text   ^J Justify
^X Exit      ^R Read File  ^\ Replace    ^U Uncut Text ^T To Spell
```

### Basic Nano Commands

| Command | What It Does |
|---------|--------------|
| `Ctrl+O` | **Save** file (Write Out) |
| `Ctrl+X` | **Exit** nano |
| `Ctrl+K` | **Cut** line |
| `Ctrl+U` | **Paste** (Uncut) |
| `Ctrl+W` | **Search** (Where Is) |
| `Ctrl+\` | **Replace** text |
| `Ctrl+G` | **Help** |
| `Ctrl+C` | Show cursor position |

### Navigation in Nano

| Keys | Movement |
|------|----------|
| **Arrow keys** | Move cursor around |
| `Ctrl+A` | Beginning of line |
| `Ctrl+E` | End of line |
| `Ctrl+Y` | Page up |
| `Ctrl+V` | Page down |

### Nano Workflow

**1. Open file:**
```bash
nano myfile.txt
```

**2. Edit content:**
- Type normally
- Use arrow keys to move
- Use Backspace/Delete to remove text

**3. Save:**
- Press `Ctrl+O`
- Press Enter to confirm filename

**4. Exit:**
- Press `Ctrl+X`
- If unsaved, it asks "Save modified buffer?"
  - `Y` to save
  - `N` to discard changes
  - `Ctrl+C` to cancel and continue editing

### Nano Example Session

```bash
$ nano shopping.txt
# Type: milk, eggs, bread
# Press Ctrl+O to save
# Press Enter to confirm
# Press Ctrl+X to exit
```

### When to Use Nano

✅ Quick config file edits
✅ Simple text files
✅ When you need to get the job done fast
✅ Learning Linux (no steep learning curve)

---

## Part 4: Vi/Vim Editor (Most Common)

### What is Vi/Vim?

- **Vi** = Visual editor (original)
- **Vim** = Vi Improved (enhanced version)
- Most powerful and ubiquitous editor
- Available on EVERY Linux system
- Has a learning curve but worth it

**Why learn Vi/Vim?**
1. Always available (even on minimal systems)
2. Very powerful once learned
3. Fast editing with keyboard shortcuts
4. Skills transfer to other commands (less, man, etc.)

### Starting Vi/Vim

```bash
vi filename           # Edit file
vim filename          # Edit file (enhanced)
view filename         # Read-only mode
```

### Understanding Vi Modes

Vi has **3 modes** - this is the key concept!

| Mode | Purpose | How to Enter | How to Exit |
|------|---------|--------------|-------------|
| **Command** | Navigate, delete, copy, paste | Press `Esc` | Press `i` or `:` |
| **Insert** | Type text | Press `i`, `a`, `I`, or `A` | Press `Esc` |
| **Line** | Save, quit, search/replace | Type `:` from command mode | Press `Esc` |

**Golden Rule:** Press `Esc` to get back to command mode anytime!

### Mode 1: Command Mode (Navigation)

You start in command mode. Move around without editing:

#### Basic Movement

| Key | Movement |
|-----|----------|
| `h` | Left one character |
| `j` | Down one line |
| `k` | Up one line |
| `l` | Right one character |
| `w` | Forward one word |
| `b` | Back one word |
| `0` or `^` | Beginning of line |
| `$` | End of line |
| `G` | End of file |
| `gg` | Beginning of file |

**Note:** Arrow keys also work in vim!

#### Fast Movement

| Key | Movement |
|-----|----------|
| `5j` | Down 5 lines |
| `10w` | Forward 10 words |
| `3b` | Back 3 words |
| `:5` | Go to line 5 |
| `:$` | Go to last line |

### Mode 2: Insert Mode (Editing)

Press one of these to enter insert mode:

| Key | What It Does |
|-----|--------------|
| `i` | Insert at cursor |
| `I` | Insert at beginning of line |
| `a` | Append after cursor |
| `A` | Append at end of line |
| `o` | Open new line below |
| `O` | Open new line above |

**In insert mode:**
- Type normally
- Use Backspace to delete
- Press `Esc` when done to return to command mode

### Mode 3: Line Mode (Commands)

From command mode, type `:` to enter line mode:

#### Essential Commands

| Command | What It Does |
|---------|--------------|
| `:w` | **Save** (write) |
| `:q` | **Quit** |
| `:wq` | **Save and quit** |
| `:q!` | **Quit without saving** (force) |
| `:w!` | Force save (if you own file) |
| `:x` | Save and quit (same as :wq) |

#### Helpful Commands

| Command | What It Does |
|---------|--------------|
| `:5` | Go to line 5 |
| `:$` | Go to last line |
| `:set nu` | Show line numbers |
| `:set nonu` | Hide line numbers |
| `:help` | Get help |

### Editing in Vi/Vim

#### Deleting Text (Command Mode)

| Key | What It Deletes |
|-----|----------------|
| `x` | Character under cursor |
| `dw` | Word |
| `dd` | Entire line |
| `D` | From cursor to end of line |
| `5dd` | Delete 5 lines |
| `d5w` | Delete 5 words |

#### Changing Text (Command Mode)

| Key | What It Does |
|-----|--------------|
| `r` | Replace one character |
| `cw` | Change word |
| `cc` | Change entire line |
| `C` | Change from cursor to end of line |
| `~` | Toggle uppercase/lowercase |

#### Copying and Pasting (Command Mode)

| Key | What It Does |
|-----|--------------|
| `yy` | **Yank** (copy) line |
| `yw` | Yank word |
| `y3w` | Yank 3 words |
| `p` | **Paste** after cursor |
| `P` | Paste before cursor |

**Workflow:**
1. Navigate to line
2. Press `yy` to copy
3. Navigate to destination
4. Press `p` to paste

#### Undo and Redo (Command Mode)

| Key | What It Does |
|-----|--------------|
| `u` | Undo last change |
| `Ctrl+r` | Redo |

Press `u` multiple times to undo multiple changes!

#### Searching (Command Mode)

| Key | What It Does |
|-----|--------------|
| `/pattern` | Search forward for pattern |
| `?pattern` | Search backward |
| `n` | Next match |
| `N` | Previous match |

**Example:**
```
/error    # Search for "error"
n         # Next occurrence
N         # Previous occurrence
```

### Vi/Vim Quick Reference

**Starting:**
```bash
vim myfile.txt
```

**Basic workflow:**
1. Start in command mode
2. Press `i` to insert text
3. Type your content
4. Press `Esc` to return to command mode
5. Type `:wq` to save and quit

### Vi/Vim Practice Example

```bash
# Create a file
vim practice.txt

# Now in vim:
i                          # Enter insert mode
Hello, World!              # Type text
[Press Esc]                # Back to command mode
:w                         # Save
o                          # Open new line below (insert mode)
This is line 2             # Type more text
[Press Esc]                # Back to command mode
yy                         # Copy this line
p                          # Paste it
:wq                        # Save and quit
```

### Common Vi/Vim Mistakes

❌ Trying to type while in command mode
✅ Press `i` first to enter insert mode

❌ Can't figure out how to quit
✅ Press `Esc` then type `:q!`

❌ Made changes but can't save
✅ Type `:wq` to write and quit

### Vi/Vim Cheat Sheet

```
COMMAND MODE (default)
Movement: h j k l  (left down up right)
Delete:   x dd dw
Copy:     yy yw
Paste:    p
Undo:     u
Redo:     Ctrl+r

INSERT MODE (edit text)
Enter:    i I a A o O
Exit:     Esc

LINE MODE (commands)
Enter:    :
Save:     :w
Quit:     :q
Both:     :wq
Force:    :q!  :wq!
```

---

## Part 5: Emacs Editor (Alternative Power Editor)

### What is Emacs?

- Another powerful editor (rival to vi)
- Different philosophy and key bindings
- Highly customizable
- Large feature set
- Good for programming

**Vi vs Emacs:** Personal preference! Both are excellent. Try both and pick your favorite.

### Starting Emacs

```bash
emacs filename        # Edit file
emacs                 # Start with empty file
```

### Understanding Emacs Notation

**C-x** means `Ctrl+x`:
- Hold `Ctrl` and press `x`

**M-x** means `Meta+x`:
- Hold `Alt` and press `x`
- OR press `Esc`, release, then press `x`

**C-x C-s** means:
- Hold `Ctrl`, press `x`, keep holding `Ctrl`, press `s`

**Tip:** Use `Esc` instead of `Alt` if Alt doesn't work in your terminal.

### Essential Emacs Commands

#### File Operations

| Command | What It Does |
|---------|--------------|
| `C-x C-s` | **Save** file |
| `C-x C-c` | **Exit** Emacs |
| `C-x C-f` | Open file |

#### Getting Help

| Command | What It Does |
|---------|--------------|
| `C-h` | Help |
| `C-h t` | Tutorial (highly recommended!) |
| `C-h k [key]` | Help on specific key |

### Navigation in Emacs

| Command | Movement |
|---------|----------|
| `C-p` | Previous line (up) |
| `C-n` | Next line (down) |
| `C-b` | Backward one character |
| `C-f` | Forward one character |
| `M-f` | Forward one word |
| `M-b` | Backward one word |
| `C-a` | Beginning of line |
| `C-e` | End of line |
| `M-<` | Beginning of file |
| `M->` | End of file |

**Tip:** Arrow keys also work!

### Editing in Emacs

#### Deleting

| Command | What It Deletes |
|---------|----------------|
| `C-d` | Character under cursor |
| `M-d` | Word |
| `C-k` | From cursor to end of line |

#### Copying and Pasting

| Command | What It Does |
|---------|--------------|
| `C-k` | Kill (cut) rest of line |
| `C-y` | Yank (paste) |
| `C-x u` | Undo |

**To copy a line:**
1. Move to beginning: `C-a`
2. Kill line: `C-k`
3. Yank it back: `C-y`
4. Move to paste location
5. Yank again: `C-y`

#### Searching

| Command | What It Does |
|---------|--------------|
| `C-s` | Search forward |
| `C-r` | Search backward |

**After C-s:**
- Type search text
- Press `C-s` again for next match
- Press `Enter` when done

### Repeating Commands

```bash
C-u N [command]       # Repeat command N times
```

**Examples:**
```bash
C-u 3 C-k            # Kill 3 lines
C-u 10 C-f           # Move forward 10 characters
C-u 5 C-n            # Move down 5 lines
```

### Emacs Quick Reference

```
FILE OPERATIONS
Save:      C-x C-s
Exit:      C-x C-c
Open:      C-x C-f

NAVIGATION
Up:        C-p
Down:      C-n
Left:      C-b
Right:     C-f
Line start: C-a
Line end:   C-e

EDITING
Delete char: C-d
Delete word: M-d
Cut line:    C-k
Paste:       C-y
Undo:        C-x u

HELP
Tutorial:    C-h t
Help:        C-h
```

### Emacs Example Session

```bash
$ emacs myfile.txt
# Type some content
# C-x C-s to save
# C-x C-c to exit
```

---

## Part 6: Graphical Editors

If you're using Linux with a desktop (not server), you have GUI options:

### Linux GUI Editors

| Editor | Description |
|--------|-------------|
| **gedit** | Simple, like Notepad (GNOME) |
| **kate** | Feature-rich editor (KDE) |
| **geany** | For programming |
| **gvim** | Graphical vim |
| **emacs (GUI)** | Graphical emacs |
| **Sublime Text** | Modern, commercial |
| **VS Code** | Microsoft's editor, very popular |

### Word Processors

| Software | Description |
|----------|-------------|
| **LibreOffice Writer** | Like Microsoft Word |
| **AbiWord** | Lightweight word processor |

---

## Part 7: Setting Default Editor

Some Linux commands open an editor automatically. Set your preference:

### Check Current Default

```bash
$ echo $EDITOR
vi
```

### Set Default Editor

**Temporary (current session):**
```bash
export EDITOR=nano
```

**Permanent (add to ~/.bashrc):**
```bash
echo 'export EDITOR=nano' >> ~/.bashrc
source ~/.bashrc
```

**Options:**
- `nano` - For simplicity
- `vim` or `vi` - For power
- `emacs` - If you prefer emacs

---

## Quick Decision Guide

### Which Editor Should I Use?

**Just need to view a file:**
- Small file → `cat`
- Large file → `less`
- Monitor changes → `tail -f`

**Need to edit a file quickly:**
- Use **nano** (easiest)

**On a minimal system / server:**
- Learn **vim** (always available)

**Want maximum power:**
- Learn **vim** or **emacs**

**On desktop Linux:**
- Use **gedit**, **kate**, or **VS Code**

---

## Learning Path for Beginners

### Week 1: Viewing Files
- Practice `cat`, `head`, `tail`, `less`
- Watch log files with `tail -f`

### Week 2: Nano
- Edit files with nano
- Get comfortable with Ctrl commands
- Use nano for all simple edits

### Week 3-4: Vim Basics
- Learn the three modes
- Practice navigation (hjkl)
- Master insert mode and basic commands
- Learn :wq to save and quit

### Week 5+: Advanced Vim
- Copying and pasting (yy, p)
- Searching (/, ?)
- Deleting (dd, dw)
- Advanced navigation

### Optional: Emacs
- Try emacs if vim doesn't feel right
- Work through the built-in tutorial (C-h t)

---

## Essential Commands Summary

### Viewing
```bash
cat file              # Show entire file
less file             # Page through file
head -n file          # First n lines
tail -n file          # Last n lines
tail -f file          # Watch file in real-time
```

### Nano
```bash
nano file             # Edit file
Ctrl+O                # Save
Ctrl+X                # Exit
Ctrl+K                # Cut line
Ctrl+U                # Paste
Ctrl+W                # Search
```

### Vim
```bash
vim file              # Edit file
i                     # Insert mode
Esc                   # Command mode
:w                    # Save
:q                    # Quit
:wq                   # Save and quit
:q!                   # Quit without saving
yy                    # Copy line
dd                    # Delete line
p                     # Paste
u                     # Undo
/pattern              # Search
```

### Emacs
```bash
emacs file            # Edit file
C-x C-s               # Save
C-x C-c               # Exit
C-h t                 # Tutorial
C-k                   # Cut line
C-y                   # Paste
C-s                   # Search
C-x u                 # Undo
```

---

## Tips for Success

1. **Start simple** - Begin with nano, graduate to vim
2. **Practice daily** - Edit any file for practice
3. **Learn incrementally** - Master basics before advanced features
4. **Use cheat sheets** - Keep reference handy
5. **Don't give up on vim** - First few days are hard, then it clicks
6. **Customize** - As you get comfortable, customize your editor
7. **One editor at a time** - Master one before learning another

---

## Common Problems and Solutions

### In Vim: Can't Type Anything
**Problem:** In command mode
**Solution:** Press `i` to enter insert mode

### In Vim: Can't Quit
**Problem:** In insert or command mode
**Solution:** Press `Esc` then type `:q!`

### In Nano: Commands Don't Work
**Problem:** Wrong keys
**Solution:** ^ means Ctrl (e.g., ^X = Ctrl+X)

### File Won't Save
**Problem:** No write permission
**Solution:** 
- Check permissions with `ls -l`
- Use `sudo` if needed: `sudo nano file`

### Accidentally Closed Without Saving
**Problem:** Lost changes
**Solution:**
- Vim: Check swap file (.filename.swp)
- Otherwise: No auto-recovery, lost

---

## Practice Exercises

### Exercise 1: Viewing Files
```bash
# Create a test file
echo -e "Line 1\nLine 2\nLine 3\nLine 4\nLine 5" > test.txt

# Try different viewing commands
cat test.txt
head -2 test.txt
tail -2 test.txt
less test.txt
```

### Exercise 2: Nano Practice
```bash
# Edit with nano
nano shopping.txt
# Type: milk, eggs, bread
# Ctrl+O to save
# Ctrl+X to exit
```

### Exercise 3: Vim Practice
```bash
# Edit with vim
vim practice.txt
# Press i
# Type: Hello from vim
# Press Esc
# Type :wq
```

### Exercise 4: More Vim Practice
```bash
vim practice.txt
# Press o (new line)
# Type: Line 2
# Esc
# yy (copy line)
# p (paste line)
# dd (delete line)
# u (undo)
# :wq
```

---

## Final Thoughts

**For beginners:**
- Master file viewing commands first
- Get comfortable with nano
- Don't rush into vim

**When ready for vim:**
- Commit to using it for 1-2 weeks
- Use the built-in tutorial: `vimtutor`
- Keep a cheat sheet nearby
- It gets easier!

**Remember:**
- Every Linux admin knows at least nano and vim
- Vim is worth learning for its ubiquity
- Choose the tool that makes you productive
- You can always learn more editors later

---

**Now go practice! The best way to learn is by doing.**