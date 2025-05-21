#!/usr/bin/env bash
set -eu

# This script generates a template .DS_Store file for use with DMG creation
# It sets up proper Finder view options for a professional installer look

echo "======================================"
echo "NeuroPrime DS_Store Template Generator"
echo "======================================"

# Function to clean up all mounted disks and temporary files
cleanup_all() {
    echo "[+] Performing thorough cleanup..."
    
    # Kill any processes that might be using our disk images
    for PID in $(hdiutil info | grep "template.dmg" | grep "process ID" | awk '{print $4}'); do
        if [ -n "$PID" ]; then
            echo "[+] Killing process $PID that might be using our disk image..."
            kill -9 $PID 2>/dev/null || true
        fi
    done
    
    # Wait a moment for processes to terminate
    sleep 1
    
    # Unmount all disks related to template.dmg
    for DISK in $(hdiutil info | grep "/dev/disk" | grep -B 5 "template.dmg" | grep "/dev/disk" | awk '{print $1}'); do
        echo "[+] Detaching $DISK..."
        hdiutil detach "$DISK" -force 2>/dev/null || true
    done
    
    # Unmount all disks with Template volume name
    for VOL in "/Volumes/Template" "/Volumes/Template-"*; do
        if [ -d "$VOL" ]; then
            echo "[+] Unmounting $VOL..."
            hdiutil detach "$VOL" -force 2>/dev/null || true
            diskutil unmount force "$VOL" 2>/dev/null || true
        fi
    done
    
    # Clean up temporary files
    rm -f "./template.dmg" 2>/dev/null || true
    rm -rf "./tmp_ds_store" 2>/dev/null || true
    rm -rf "/tmp/neuroprime_dmg_template" 2>/dev/null || true
}

# Set up trap to ensure cleanup on exit or error
trap cleanup_all EXIT INT TERM

# Clean up any existing disk images or mount points from previous runs
echo "[+] Cleaning up any leftovers from previous runs..."
cleanup_all

# Ensure resources directory exists
mkdir -p resources

# Create a temporary directory for setting up the view
TEMP_DIR="/tmp/neuroprime_dmg_template"
mkdir -p "$TEMP_DIR"
rm -rf "$TEMP_DIR"/*

# Copy the background image into the temporary directory
mkdir -p "$TEMP_DIR/.background"
if [ -f "resources/dmg_background.png" ]; then
    cp "resources/dmg_background.png" "$TEMP_DIR/.background/background.png"
    echo "[+] Using existing background image"
else 
    echo "[!] Background image not found. Creating a placeholder."
    # Create a simple gradient background image as placeholder
    if command -v convert &> /dev/null; then
        convert -size 800x400 gradient:gray10-gray30 "$TEMP_DIR/.background/background.png"
        echo "[+] Created placeholder background with ImageMagick"
    else
        # Create an empty file as backup
        touch "$TEMP_DIR/.background/background.png"
        echo "[!] ImageMagick not found, created empty background file"
    fi
fi

# Mount the directory
echo "[+] Creating test disk image..."
hdiutil create -volname "Template" -srcfolder "$TEMP_DIR" -ov -format UDRW "./template.dmg" > /dev/null

# Make sure no previous mount exists
if [ -d "/Volumes/Template" ]; then
    echo "[!] Found existing mount at /Volumes/Template, attempting to unmount..."
    hdiutil detach "/Volumes/Template" -force 2>/dev/null || true
    if [ -d "/Volumes/Template" ]; then
        echo "[!] Could not unmount /Volumes/Template. Please unmount it manually and try again."
        exit 1
    fi
fi

echo "[+] Mounting test disk image..."
# Mount directly to /Volumes/Template
MOUNT_OUTPUT=$(hdiutil attach "./template.dmg" -nobrowse 2>&1)
echo "[+] Mount output: $MOUNT_OUTPUT"

# Find the mounted volume
VOLUME_PATH=$(echo "$MOUNT_OUTPUT" | grep "/Volumes/" | awk '{print $NF}')
if [ -z "$VOLUME_PATH" ]; then
    echo "[!] Could not determine mount point. Aborting."
    exit 1
fi

echo "[+] Disk mounted at: $VOLUME_PATH"
VOLUME_NAME=$(basename "$VOLUME_PATH")
echo "[+] Volume name is: $VOLUME_NAME"

# Make sure the background directory exists in the mounted volume
if [ ! -d "$VOLUME_PATH/.background" ]; then
    echo "[+] Creating .background directory in mounted volume"
    mkdir -p "$VOLUME_PATH/.background"
    cp "$TEMP_DIR/.background/background.png" "$VOLUME_PATH/.background/"
fi

# Give Finder more time to recognize the mounted disk
echo "[+] Waiting for Finder to recognize the disk..."
sleep 3

# Make the volume visible to Finder
echo "[+] Making volume visible to Finder..."
open "$VOLUME_PATH"
sleep 2

# Create a verification script to check if the volume is accessible to Finder
echo "[+] Verifying volume is accessible to Finder..."
FINDER_CHECK=$(osascript << EOF
tell application "Finder"
    try
        get name of disk "$VOLUME_NAME"
        return "Volume is accessible"
    on error errMsg
        return "Error: " & errMsg
    end try
end tell
EOF
)

echo "[+] Finder check result: $FINDER_CHECK"
if [[ "$FINDER_CHECK" == Error* ]]; then
    echo "[!] Finder cannot access the volume. Trying alternative approach..."
    # Try to make the volume more visible
    diskutil unmount "$VOLUME_PATH" 2>/dev/null || true
    sleep 1
    diskutil mount "$VOLUME_PATH" 2>/dev/null || true
    sleep 3
    open "$VOLUME_PATH"
    sleep 2
fi

# Use a simpler AppleScript to configure the window
echo "[+] Configuring Finder view options..."
osascript <<EOF
tell application "Finder"
    try
        -- Make sure Finder is active
        activate
        delay 1
        
        -- Try to access the disk by name first
        try
            tell disk "$VOLUME_NAME"
                open
                delay 1
                set current view of container window to icon view
                set toolbar visible of container window to false
                set statusbar visible of container window to false
                set the bounds of container window to {100, 100, 900, 600}
                
                set opts to the icon view options of container window
                set icon size of opts to 128
                set text size of opts to 12
                set arrangement of opts to not arranged
                
                -- Try to set background
                try
                    set bgFile to POSIX file "$VOLUME_PATH/.background/background.png"
                    set background picture of opts to bgFile
                on error errMsg
                    log "Could not set background: " & errMsg
                end try
                
                -- Force save
                close
                open
                delay 1
                close
            end tell
        on error
            -- If we couldn't find it by name, try with the exact path
            tell folder "$VOLUME_PATH" of application "Finder"
                open
                delay 1
                set current view of container window to icon view
                set toolbar visible of container window to false
                set statusbar visible of container window to false
                set the bounds of container window to {100, 100, 900, 600}
                
                set opts to the icon view options of container window
                set icon size of opts to 128
                set text size of opts to 12
                set arrangement of opts to not arranged
                
                -- Try to set background
                try
                    set bgFile to POSIX file "$VOLUME_PATH/.background/background.png"
                    set background picture of opts to bgFile
                on error errMsg
                    log "Could not set background: " & errMsg
                end try
                
                -- Force save
                close
                open
                delay 1
                close
            end tell
        end try
        
        delay 1
    on error errMsg
        log "An error occurred: " & errMsg
    end try
end tell

tell application "Finder" to quit
EOF

# Give Finder time to save changes
echo "[+] Waiting for Finder to save changes..."
sleep 5

# Copy the .DS_Store file
echo "[+] Extracting template .DS_Store file..."
if [ -f "$VOLUME_PATH/.DS_Store" ]; then
    cp "$VOLUME_PATH/.DS_Store" "resources/template.DS_Store"
    echo "[+] Template .DS_Store saved to resources/template.DS_Store"
else
    echo "[!] No .DS_Store file found in the mounted volume"
    if [ -f "/Volumes/Template/.DS_Store" ]; then
        cp "/Volumes/Template/.DS_Store" "resources/template.DS_Store"
        echo "[+] Found and copied .DS_Store from /Volumes/Template"
    else
        echo "[!] No .DS_Store file found in /Volumes/Template either"
    fi
fi

# Clean up - this will be handled by the trap, but we'll do it explicitly too
echo "[+] Cleaning up..."

# Unmount the primary volume
if [ -n "$VOLUME_PATH" ]; then
    echo "[+] Detaching primary volume: $VOLUME_PATH"
    hdiutil detach "$VOLUME_PATH" -force > /dev/null 2>&1 || true
fi

# Run the full cleanup to ensure everything is unmounted
cleanup_all

echo "[+] Template creation completed"
echo "======================================"
