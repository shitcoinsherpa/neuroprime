#!/bin/bash
set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"   # one level up from /scripts
cd "${REPO_ROOT}"                              # become repo root

echo "======================================"
echo "NeuroPrime DMG Creation - Simplified"
echo "======================================"

# Define variables
APP_NAME="NeuroPrime.app"
DMG_NAME="NeuroPrime-Installer.dmg"
BACKGROUND_IMG="resources/dmg_background.png"

# Check if the application bundle exists
if [ ! -d "dist/${APP_NAME}" ]; then
    echo "[!] Application bundle not found at dist/${APP_NAME}"
    echo "[!] Please run package.sh first to create the application bundle"
    exit 1
fi

# Check if Sentinel.app is available (optional component)
if [ -d "Sentinel/Sentinel.app" ]; then
    SENTINEL_AVAILABLE=true
    echo "[+] Using pre-built Sentinel.app"
else
    SENTINEL_AVAILABLE=false
    echo "[!] Sentinel.app not found, continuing without it."
fi

# Clean up any existing files
echo "[+] Cleaning up any existing files..."
rm -f "${DMG_NAME}"

# Ensure the background image exists
if [ ! -f "${BACKGROUND_IMG}" ]; then
    echo "[+] Generating background image with Python-based renderer..."
    python3 resources/generate_background.py
    
    if [ ! -f "${BACKGROUND_IMG}" ]; then
        echo "[!] Failed to create background image."
        exit 1
    fi
fi

# Get image dimensions for logging purposes
if command -v sips &> /dev/null; then
    DIMENSIONS=$(sips -g pixelWidth -g pixelHeight "${BACKGROUND_IMG}" | tail -n2 | awk '{print $2}')
    ACTUAL_WIDTH=$(echo "$DIMENSIONS" | head -n1)
    ACTUAL_HEIGHT=$(echo "$DIMENSIONS" | tail -n1)
    echo "[+] Background image dimensions: ${ACTUAL_WIDTH}x${ACTUAL_HEIGHT} (high resolution)"
    
    # Create a resized version of the background image that exactly matches window size
    echo "[+] Resizing background image to ensure proper display in DMG..."
    TEMP_BG="/tmp/dmg_background_resized.png"
    sips --resampleWidth 800 "${BACKGROUND_IMG}" --out "${TEMP_BG}" >/dev/null 2>&1
    
    # Replace with the resized version
    mv "${TEMP_BG}" "${BACKGROUND_IMG}"
    echo "[+] Background image resized to 800px width"
else
    echo "[!] Cannot get image dimensions or resize image."
fi

# Use dimensions that ensure the full background is visible
# The HTML file specifies width=800px but we need to ensure the full height is visible
WIDTH=800
HEIGHT=500  # Increased height to show the footer
echo "[+] Using DMG window size: ${WIDTH}x${HEIGHT} (ensuring full background visibility)"

# Create a temporary directory for DMG assets
STAGING=$(mktemp -d)
trap 'rm -rf "$STAGING"' EXIT

# Copy the app to the staging dir
echo "[+] Preparing content for DMG creation..."
cp -R "dist/${APP_NAME}" "${STAGING}/"

# Copy Sentinel app if available
if [ "$SENTINEL_AVAILABLE" = true ]; then
    cp -R "Sentinel/Sentinel.app" "${STAGING}/"
fi

# Use create-dmg to create a DMG with nice layout
echo "[+] Creating DMG using create-dmg..."

# Define icon sizes - make main app icon significantly larger
MAIN_ICON_SIZE=128  # Much larger size for main app
OTHER_ICON_SIZE=64   # Standard size for other icons

# Build the create-dmg command in parts to use different icon sizes for different elements
# Start with the base configuration
CMD="create-dmg \
  --volname \"NeuroPrime Installer\" \
  --volicon \"resources/neuroprime.icns\" \
  --background \"${BACKGROUND_IMG}\" \
  --window-pos 200 120 \
  --window-size ${WIDTH} ${HEIGHT} \
  --text-size 12 \
  --hdiutil-quiet"

# Add a note about the approach
echo "[+] Using strategic icon positioning to work with background labels"

# Add a note about the background scaling
echo "[+] Setting window size to ${WIDTH}x${HEIGHT} to match background image aspect ratio"

# Add main app with larger icon size and hide extension
# Position it higher up to avoid text overlap
CMD="${CMD} \
  --icon-size ${MAIN_ICON_SIZE} \
  --icon \"${APP_NAME}\" 40 120 \
  --hide-extension \"${APP_NAME}\""

# Switch to smaller icon size for other elements
# Position Applications link higher up to avoid text overlap
CMD="${CMD} \
  --icon-size ${OTHER_ICON_SIZE} \
  --app-drop-link 640 120"

# Add Sentinel to the command if available - using original position from HTML
if [ "$SENTINEL_AVAILABLE" = true ]; then
    CMD="${CMD} \
  --icon \"Sentinel.app\" 350 320 \
  --hide-extension \"Sentinel.app\""
fi

# Log the icon sizes being used
echo "[+] Using icon sizes: ${MAIN_ICON_SIZE}px for ${APP_NAME}, ${OTHER_ICON_SIZE}px for other icons"

# Finalize the command
CMD="${CMD} \
  --no-internet-enable \
  \"${DMG_NAME}\" \
  \"${STAGING}/\""

# Execute the command
echo "[+] Executing: $CMD"
eval ${CMD}

# Verify DMG was created
if [ -f "${DMG_NAME}" ]; then
    echo "[+] ✅ ${DMG_NAME} created successfully!"
else
    echo "[!] Failed to create ${DMG_NAME}."
    exit 1
fi

echo "======================================"
