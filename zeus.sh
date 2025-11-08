#!/bin/bash
# -----------------------------------------------------------------------------
# ZEUS.SH: MASTER LOCAL BACKUP TO GITHUB (Final POSIX Compliant Version)
# -----------------------------------------------------------------------------

# --- Configuration Constants ---
ZEUS_LOCAL_DIR="/mnt/chromeos/MyFiles/zeus"
ZEUS_REPO_NAME="zeus"
BACKUP_GIT_URL="git@github.com:growlrr/$ZEUS_REPO_NAME.git"
# --- End Config ---

echo "⚡ Starting Zeus Master Backup and Archive Protocol..."
cd "$ZEUS_LOCAL_DIR"

# 1. INITIALIZE GIT AND REMOTE
echo "1. Initializing Git repository in $ZEUS_LOCAL_DIR..."
git init 
git remote rm origin > /dev/null 2>&1 # Remove if already exists
git remote add origin "$BACKUP_GIT_URL" 

# 2. CREATE MASTER .gitignore
echo "2. Creating master .gitignore file..."
cat << EOF > .gitignore
# --- Olympian Master Backup Ignore List ---
# Ignore the master submodule vault (it manages its own Git history)
pegasus/
# Ignore temporary synchronization/config directories
dir_syncthing/
dir_autosync/
# Ignore known large/binary folders
app_docker/
app_llama/
# Ignore compressed/backup files
*.zip
*.tar
*.gz
*.iso
# Ignore OS/Editor files
.DS_Store
.vscode/
EOF
echo "✅ .gitignore created to exclude submodules and binaries."

# 3. ADD ALL REMAINING FILES AND COMMIT
echo "3. Staging and committing remaining files..."
git add .
git add -f .gitignore

# Check if there are changes to commit, if not, commit empty
if git status --porcelain | grep -q '^\(M\|A\|D\|R\|C\|U\)\s'; then
    git commit -m "INIT: Master Zeus Archive. Contains local backups, utility folders, and base configurations."
else
    echo "⚠️ No changes detected. Creating initial empty commit to establish branch."
    git commit --allow-empty -m "INIT: Master Zeus Archive - Establishing branch."
fi

# 4. FINAL PUSH TO GITHUB
echo "4. Pushing Master Archive to growlrr/zeus..."
git branch -M main
git push -u origin main

echo " "
echo "======================================================================"
echo "🎉 ZEUS MASTER ARCHIVE COMPLETE"
echo "======================================================================"
echo "Status: Archive pushed successfully to growlrr/zeus."
echo "Your next command is to confirm success."
echo "======================================================================"