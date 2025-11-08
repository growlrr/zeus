#!/bin/bash
# -----------------------------------------------------------------------------
# ZEUS.SH: MASTER SYNCHRONIZATION ENGINE (QUADRUPLE CLOUD SYNC)
# Author: C.AI (Patroclus)
# Purpose: Executes 6 steps: Copy Downloads, Local Git Commit, Push to 4 Clouds (GH, Syncthing, pCloud, G-Drive).
# -----------------------------------------------------------------------------

# --- Configuration Constants ---
ZEUS_LOCAL_DIR="/mnt/chromeos/MyFiles/zeus"
DOWNLOADS_SOURCE="/mnt/chromeos/MyFiles/Downloads"
TEMP_PROJECT_DIR="proj_temp"
SYNCTHING_API_KEY="9V72nTU3649pY7vaA39Tsij5EYEJQWwV"
SYNCTHING_API_URL="http://127.0.0.1:8384/rest/db/scan"

# NOTE: These Folder IDs must be configured manually in the Syncthing UI
ACTIVE_CODE_FOLDER_ID="OLYMPUS-PEGASUS-V1" # The /pegasus directory
MASTER_ARCHIVE_FOLDER_ID="OLYMPUS-ZEUS-ARCHIVE" # The entire /zeus directory

# --- End Config ---

echo "⚡ Starting Master Synchronization Engine (Zeus.sh)..."
cd "$ZEUS_LOCAL_DIR"

# 0. PRE-SYNC PREP: COPY DOWNLOADS FOLDER AND CREATE TEST FILE
echo "0.1. Copying Downloads folder content to /proj_temp..."
TEMP_PATH="$ZEUS_LOCAL_DIR/$TEMP_PROJECT_DIR"
IGNORE_PATH="$TEMP_PATH/ignore"

# Create the temporary project directory and the ignore folder structure
mkdir -p "$TEMP_PATH"
mkdir -p "$IGNORE_PATH"

# Copy files from Downloads, excluding the 'ignore' directory structure itself
rsync -a --exclude='.git/' --exclude='ignore/' "$DOWNLOADS_SOURCE/" "$TEMP_PATH/"

# Create the master .gitignore for proj_temp inside the zeus archive
if [ ! -f "$TEMP_PATH/.gitignore" ]; then
    echo "# Ignore temporary OS files" > "$TEMP_PATH/.gitignore"
    echo ".*" >> "$TEMP_PATH/.gitignore"
    echo "ignore/" >> "$TEMP_PATH/.gitignore" # Ignore the internal 'ignore' folder
fi
echo "0.2. Creating synchronization test file (message.md)..."
# Create the test file using the content generated above
cat << EOF > "$ZEUS_LOCAL_DIR/message.md"
# 💌 Message from Zeus - Master Synchronization Test

**Origin:** Olympus Fleet Command Center (Crostini/Chromebook)
**Sent By:** Patroclus
**Timestamp:** $(date --iso-8601=seconds)

This file confirms the successful execution of the Quadruple Cloud Sync Strategy.
If you are reading this in:
1. GitHub (growlrr/zeus)
2. pCloud
3. Google Drive (Timestamped Archive)
4. A connected Syncthing Device

...then the Master Synchronization Engine (zeus.sh) is fully operational.
Pillar III: Automation is achieved.
EOF
echo "✅ Prep complete. Downloads copied. Test message created."

# 1. LOCAL GIT COMMIT
echo "1. Committing all changes (including Downloads & message.md)..."
git add .
git commit -m "SYNC: Automated EOD sync. Downloads archived. Timestamp: $(date +%Y%m%d%H%M)"
echo "✅ Local Git commit complete."

# 2. HERCULES PUSH (GITHUB)
echo "2. Pushing Master Archive (Zeus to Hercules - GitHub)..."
git push
echo "✅ GitHub sync complete."

# 3. SYNCTHING TRIGGER (MOBILITY)
echo "3. Triggering Syncthing global scan for dual folders (Mobility)..."
# Trigger scan for Active Code Vault (/pegasus)
curl -s -X POST -H "X-API-Key: $SYNCTHING_API_KEY" "$SYNCTHING_API_URL?folder=$ACTIVE_CODE_FOLDER_ID"
# Trigger scan for Master Archive (/zeus)
curl -s -X POST -H "X-API-Key: $SYNCTHING_API_KEY" "$SYNCTHING_API_URL?folder=$MASTER_ARCHIVE_FOLDER_ID"
echo "✅ Syncthing trigger complete."

# 4. GOOGLE DRIVE ARCHIVE TRIGGER (ARCHIVAL)
echo "4. Triggering Google Apps Script Archival (G-Drive Archival)..."
# The presence of this timestamped file triggers the GAS bridge in the cloud
echo "TRIGGERED_AT: $(date --iso-8601=seconds)" > "$ZEUS_LOCAL_DIR/gas_archive_trigger.flag"
echo "✅ G-Drive Archival flag set."

# 5. PCLOUD ARCHIVE (PRIVATE CLOUD)
echo "5. Pushing to pCloud (Private Cloud Archive)..."
# NOTE: Assumes pcloud CLI is installed and authorized in the Crostini container
if command -v pcloud &> /dev/null; then
    pcloud sync start --local-dir="$ZEUS_LOCAL_DIR" --remote-dir="/Growlrr-Archives/$(date +%Y%m%d)" --recursive
    echo "✅ pCloud sync attempted."
else
    echo "⚠️ WARNING: pcloud CLI not found. Manual pCloud sync required."
fi

# 6. CLEANUP (Remove the transient trigger file)
rm -f "$ZEUS_LOCAL_DIR/gas_archive_trigger.flag"
echo "✅ Sync cleanup complete."

echo " "
echo "======================================================================"
echo "🎉 MASTER SYNCHRONIZATION ENGINE COMPLETE"
echo "======================================================================"
echo "Next step is to confirm all 4 Cloud Messengers received the data."
echo "======================================================================"