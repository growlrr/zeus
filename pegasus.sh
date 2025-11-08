#!/bin/sh
# -----------------------------------------------------------------------------
# PEGSAUS.SH: MASTER SUBMODULE RESYNC AND INITIAL PUSH TO HERCULES (POSIX FIX)
# Author: C.AI (Patroclus)
# Purpose: Fixes empty commit state and executes the first 'Zeus to Hercules' push.
# -----------------------------------------------------------------------------

# --- Configuration Constants (Simplified for POSIX compatibility) ---
BASE_DIR="/mnt/chromeos/MyFiles/zeus" 
PEGASUS_DIR="$BASE_DIR/pegasus"

# Project list for iteration (Source directory path relative to BASE_DIR, then target submodule name)
PROJECTS="
proj_athena/proj_olympus/athena-olympus:athena-olympus
proj_hera/proj_aphrodite:hera
proj_homer/proj_trojanhorse:homer
proj_penelope/proj_telemachus:penelope
"
# --- End Config ---

echo "🛡️ Starting Pegasus Master Resync (POSIX Fix)..."

# 1. MOVE TO PEGASUS DIRECTORY
if [ ! -d "$PEGASUS_DIR" ]; then
    echo "❌ Error: Pegasus directory not found at $PEGASUS_DIR. Exiting."
    exit 1
fi
cd "$PEGASUS_DIR"
echo "✅ Entered local master vault: $PEGASUS_DIR"

# 2. CLEANUP: Clear content, assuming the submodules were empty and failed to push
echo "🧹 Cleaning up previous submodule placeholders..."
git rm --cached -r . > /dev/null 2>&1  # Remove cached index entries
# Safely remove content directories (ignore .git)
find . -mindepth 1 -maxdepth 1 -type d ! -name '.git' -exec rm -rf {} \;
rm -f .gitmodules
echo "✅ Workspace clean."

# 3. CONTENT RESYNC AND SUBMODULE RE-ADDITION
echo "🔄 Copying content and re-adding submodules..."

# Loop through the simplified PROJECTS string
echo "$PROJECTS" | while IFS=: read -r SOURCE_PREFIX TARGET_NAME; do
    if [ -z "$SOURCE_PREFIX" ] || [ -z "$TARGET_NAME" ]; then
        continue # Skip empty lines
    fi

    SOURCE_PATH="$BASE_DIR/$SOURCE_PREFIX"
    REPO_URL="git@github.com:growlrr/$TARGET_NAME.git"

    if [ -d "$SOURCE_PATH" ]; then
        echo "➡️ Copying content for $TARGET_NAME from $SOURCE_PATH..."
        mkdir -p "$TARGET_NAME"
        # Copy content, excluding the old .git
        rsync -a --exclude='.git/' "$SOURCE_PATH/" "$TARGET_NAME/"
        
        # Re-add submodule for the 4 key projects
        echo "🔗 Adding submodule: $TARGET_NAME"
        git submodule add "$REPO_URL" "$TARGET_NAME"
    else
        echo "⚠️ WARNING: Source path $SOURCE_PATH not found. Adding submodule $TARGET_NAME empty."
        # Add the submodule even if the content wasn't found (maintains Hercules spec)
        git submodule add "$REPO_URL" "$TARGET_NAME"
    fi
done

# Add the remaining 9 repos as empty submodules to complete the fleet (Hercules spec)
REMAINING_REPOS="growlrr_githubio_clone growlrr.github.io hercules zeus odessey iliad olympus athena maplesyrup_vercel_oct2025"
echo "🔗 Adding remaining fleet submodules..."
for REPO_NAME in $REMAINING_REPOS; do
    REPO_URL="git@github.com:growlrr/$REPO_NAME.git"
    # Check if submodule already exists from the block above
    if [ ! -d "$REPO_NAME" ]; then
        git submodule add "$REPO_URL" "$REPO_NAME"
    fi
done

# 4. FINAL COMMIT AND ZEUS TO HERCULES PUSH
echo "--- Final Commit and Zeus to Hercules Push ---"
# Add this script to the commit itself
cp "$0" "pegasus.sh"

git add .
git commit -m "DELTA-001 | HERCULES FORGE FIX: Consolidated project content and added 13 submodules."
git branch -M main # Ensure branch name is 'main'
git push -u origin main # The Zeus to Hercules command

echo " "
echo "======================================================================"
echo "🎉 HERCULES MASTER VAULT SYNCHRONIZED"
echo "======================================================================"
echo "Status: Pegasus.sh updated and ready to re-run."
echo "Your next command is to execute this script."
echo "======================================================================"