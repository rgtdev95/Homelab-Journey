#!/bin/bash

# Linux Challenge Environment Setup Script
# This script creates a playground for practicing Linux commands.

BASE_DIR="$HOME/Linux_Challenge_Lab"

echo "Setting up your Linux Challenge Lab in $BASE_DIR..."

# 1. Create Base Directory
if [ -d "$BASE_DIR" ]; then
    echo "Directory $BASE_DIR already exists. Cleaning up..."
    rm -rf "$BASE_DIR"
fi
mkdir -p "$BASE_DIR"

# 2. Create the "Messy Folder" for organization tasks
MESSY_DIR="$BASE_DIR/Messy_Folder"
mkdir -p "$MESSY_DIR"
echo "Creating messy files..."
touch "$MESSY_DIR/song1.mp3"
touch "$MESSY_DIR/song2.mp3"
touch "$MESSY_DIR/image1.jpg"
touch "$MESSY_DIR/image2.png"
touch "$MESSY_DIR/notes.txt"
touch "$MESSY_DIR/report.pdf"
touch "$MESSY_DIR/script.sh"
touch "$MESSY_DIR/README.md"
touch "$MESSY_DIR/backup.tar.gz"

# 3. Create a Log file for grep practice
LOG_FILE="$BASE_DIR/server_logs.txt"
echo "Generating log file..."
cat <<EOF > "$LOG_FILE"
2023-10-27 08:00:01 [INFO] Server started
2023-10-27 08:05:23 [INFO] User admin logged in
2023-10-27 08:15:00 [WARNING] High memory usage
2023-10-27 08:20:12 [ERROR] Database connection failed
2023-10-27 08:20:15 [INFO] Retrying database connection...
2023-10-27 08:20:20 [SUCCESS] Database connected
2023-10-27 09:00:00 [INFO] Scheduled backup started
2023-10-27 09:05:00 [ERROR] Backup failed: Disk full
2023-10-27 09:10:00 [CRITICAL] System overheating
2023-10-27 10:00:00 [INFO] User guest logged in
EOF

# 4. Create a "Locked" file for permissions practice
LOCKED_FILE="$BASE_DIR/secret_file.txt"
echo "This is a top secret message: The code is 42." > "$LOCKED_FILE"
chmod 000 "$LOCKED_FILE" # Remove all permissions

# 5. Create a Hidden file
echo "You found the hidden clue!" > "$BASE_DIR/.hidden_clue"

# 6. Create a deep directory structure
mkdir -p "$BASE_DIR/Project_Alpha/Source/Assets/Images"

echo "---------------------------------------------------"
echo "✅ Setup Complete!"
echo "Your lab is ready at: $BASE_DIR"
echo "Run 'cd $BASE_DIR' to start exploring."
echo "---------------------------------------------------"
