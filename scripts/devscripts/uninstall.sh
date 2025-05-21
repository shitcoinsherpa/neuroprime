#!/bin/bash
echo "======================================"
echo "NeuroPrime Uninstaller"
echo "======================================"
echo "[+] This script will uninstall NeuroPrime from your system"

# Define common locations to search
CURRENT_DIR="$(pwd)/NeuroPrime.app"
DOWNLOADS_DIR="$HOME/Downloads/NeuroPrime.app"
APPLICATIONS_DIR="/Applications/NeuroPrime.app"

# Check if NeuroPrime.app exists in Applications
if [ -d "$APPLICATIONS_DIR" ]; then
    APP_PATH="$APPLICATIONS_DIR"
    echo "[+] Found NeuroPrime.app in Applications folder."
elif [ -d "$CURRENT_DIR" ]; then
    APP_PATH="$CURRENT_DIR"
    echo "[+] Found NeuroPrime.app in current directory."
elif [ -d "$DOWNLOADS_DIR" ]; then
    APP_PATH="$DOWNLOADS_DIR"
    echo "[+] Found NeuroPrime.app in Downloads folder."
else
    echo "[!] NeuroPrime.app not found in common locations."
    echo "    It may already be uninstalled or installed in a different location."
    
    # Ask if user wants to search for the application in specific locations
    echo "[?] Would you like to search for NeuroPrime.app in Applications and Downloads? (y/n)"
    read -r search_app
    if [[ $search_app == "y" ]]; then
        echo "[+] Searching for NeuroPrime.app in common locations..."
        FOUND_APP=$(find "$HOME/Downloads" "/Applications" -name "NeuroPrime.app" -type d 2>/dev/null | head -n 1)
        
        if [ -z "$FOUND_APP" ]; then
            echo "[!] NeuroPrime.app not found in common locations."
            exit 1
        else
            echo "[+] Found NeuroPrime.app at: $FOUND_APP"
            echo "[?] Would you like to uninstall this instance? (y/n)"
            read -r uninstall_found
            if [[ $uninstall_found != "y" ]]; then
                echo "[+] Uninstallation cancelled."
                exit 0
            fi
            APP_PATH="$FOUND_APP"
        fi
    else
        echo "[+] Uninstallation cancelled."
        exit 0
    fi
fi

# Confirm uninstallation
echo "[!] This will remove NeuroPrime from your system."
echo "[?] Are you sure you want to continue? (y/n)"
read -r confirm
if [[ $confirm != "y" ]]; then
    echo "[+] Uninstallation cancelled."
    exit 0
fi

# Remove the application
echo "[+] Removing NeuroPrime.app..."
if rm -rf "$APP_PATH"; then
    echo "[+] NeuroPrime.app successfully removed."
else
    echo "[!] Failed to remove NeuroPrime.app."
    echo "    You may need to run this script with sudo or check permissions."
    exit 1
fi

# Check for and remove configuration files
CONFIG_DIR="$HOME/Library/Application Support/NeuroPrime"
if [ -d "$CONFIG_DIR" ]; then
    echo "[+] Found configuration directory at: $CONFIG_DIR"
    echo "[?] Would you like to remove configuration files as well? (y/n)"
    read -r remove_config
    if [[ $remove_config == "y" ]]; then
        if rm -rf "$CONFIG_DIR"; then
            echo "[+] Configuration files successfully removed."
        else
            echo "[!] Failed to remove configuration files."
        fi
    else
        echo "[+] Configuration files preserved."
    fi
fi

# Check for and remove cache files
CACHE_DIR="$HOME/Library/Caches/NeuroPrime"
if [ -d "$CACHE_DIR" ]; then
    echo "[+] Found cache directory at: $CACHE_DIR"
    echo "[?] Would you like to remove cache files as well? (y/n)"
    read -r remove_cache
    if [[ $remove_cache == "y" ]]; then
        if rm -rf "$CACHE_DIR"; then
            echo "[+] Cache files successfully removed."
        else
            echo "[!] Failed to remove cache files."
        fi
    else
        echo "[+] Cache files preserved."
    fi
fi

# Check for and remove local config directory
LOCAL_CONFIG_DIR="$HOME/.neuroprime"
if [ -d "$LOCAL_CONFIG_DIR" ]; then
    echo "[+] Found local configuration directory at: $LOCAL_CONFIG_DIR"
    echo "[?] Would you like to remove local configuration files as well? (y/n)"
    read -r remove_local_config
    if [[ $remove_local_config == "y" ]]; then
        if rm -rf "$LOCAL_CONFIG_DIR"; then
            echo "[+] Local configuration files successfully removed."
        else
            echo "[!] Failed to remove local configuration files."
        fi
    else
        echo "[+] Local configuration files preserved."
    fi
fi

echo "[+] Uninstallation complete!"
echo "======================================"
