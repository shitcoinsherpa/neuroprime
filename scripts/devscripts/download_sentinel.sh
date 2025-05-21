#!/bin/bash
echo "======================================"
echo "Sentinel Downloader for NeuroPrime"
echo "======================================"

# Create a directory for Sentinel if it doesn't exist
if [ ! -d "Sentinel" ]; then
    mkdir -p "Sentinel"
fi

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "[!] curl not found. Please install curl."
    exit 1
fi

# GitHub release URL for Sentinel
SENTINEL_RELEASE_URL="https://github.com/alienator88/Sentinel/releases/latest"

# Get the latest release download URL
echo "[+] Finding latest Sentinel release..."
DOWNLOAD_URL=$(curl -s -L -I -o /dev/null -w '%{url_effective}' "$SENTINEL_RELEASE_URL")
LATEST_VERSION=$(echo "$DOWNLOAD_URL" | grep -o '[^/]*$')

echo "[+] Latest version: $LATEST_VERSION"

# Download URL for the DMG file
DMG_URL="https://github.com/alienator88/Sentinel/releases/download/$LATEST_VERSION/Sentinel.dmg"

# Download the DMG file
echo "[+] Downloading Sentinel.dmg..."
curl -L -o "Sentinel/Sentinel.dmg" "$DMG_URL"

# Check if the download was successful
if [ ! -f "Sentinel/Sentinel.dmg" ]; then
    echo "[!] Failed to download Sentinel.dmg"
    exit 1
fi

# Mount the DMG
echo "[+] Mounting Sentinel.dmg..."
MOUNT_POINT=$(hdiutil attach "Sentinel/Sentinel.dmg" -nobrowse | grep /Volumes | awk '{print $3}')

if [ -z "$MOUNT_POINT" ]; then
    echo "[!] Failed to mount Sentinel.dmg"
    exit 1
fi

# Copy Sentinel.app to our Sentinel directory
echo "[+] Copying Sentinel.app..."
if [ -d "$MOUNT_POINT/Sentinel.app" ]; then
    cp -R "$MOUNT_POINT/Sentinel.app" "Sentinel/"
    echo "[+] Sentinel.app copied successfully"
else
    echo "[!] Sentinel.app not found in the mounted DMG"
fi

# Unmount the DMG
echo "[+] Unmounting Sentinel.dmg..."
hdiutil detach "$MOUNT_POINT" -quiet

# Check if Sentinel.app was copied successfully
if [ -d "Sentinel/Sentinel.app" ]; then
    echo "[+] Sentinel.app is now available at Sentinel/Sentinel.app"
else
    echo "[!] Failed to extract Sentinel.app"
    exit 1
fi

echo "[+] Sentinel download and extraction completed"
echo "======================================"
