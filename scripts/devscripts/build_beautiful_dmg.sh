#!/bin/bash
echo "======================================"
echo "NeuroPrime Beautiful DMG Builder"
echo "======================================"

# Make all scripts executable
chmod +x build_macos_app.sh
chmod +x package.sh
chmod +x resources/generate_background.sh
chmod +x download_sentinel.sh
chmod +x create_dmg.sh

# Step 1: Build the macOS app
echo "[+] Step 1: Building the macOS app..."
./build_macos_app.sh

# Step 2: Generate the background image
echo "[+] Step 2: Generating the DMG background image..."
./resources/generate_background.sh

# Step 3: Download Sentinel
echo "[+] Step 3: Downloading Sentinel..."
./download_sentinel.sh

# Step 4: Create the DMG
echo "[+] Step 4: Creating the DMG installer..."
./create_dmg.sh

echo "[+] All steps completed!"
echo "[+] Your beautiful DMG installer is ready: NeuroPrime-Installer.dmg"
echo "======================================"
