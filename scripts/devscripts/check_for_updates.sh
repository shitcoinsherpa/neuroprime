#!/bin/bash
echo "======================================"
echo "NeuroPrime Update Checker"
echo "======================================"
echo "[+] Checking for updates to NeuroPrime..."

# Define the repository URL (replace with actual repository URL)
REPO_URL="https://github.com/yourusername/neuroprime"

# Get the current version from the VERSION file
if [ -f "VERSION" ]; then
    CURRENT_VERSION=$(cat VERSION)
else
    # Fallback version if VERSION file is not found
    CURRENT_VERSION="1.0.0"
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "[!] Git is not installed. Cannot check for updates."
    echo "    Please install Git or check for updates manually at:"
    echo "    $REPO_URL"
    exit 1
fi

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR" || exit 1

# Clone the repository (shallow clone to save bandwidth)
echo "[+] Fetching latest version information..."
if ! git clone --depth 1 "$REPO_URL" repo 2>/dev/null; then
    echo "[!] Failed to fetch update information."
    echo "    Please check your internet connection or visit:"
    echo "    $REPO_URL"
    rm -rf "$TEMP_DIR"
    exit 1
fi

cd repo || exit 1

# Check if version file exists
if [ -f "VERSION" ]; then
    LATEST_VERSION=$(cat VERSION)
    echo "[+] Current version: $CURRENT_VERSION"
    echo "[+] Latest version: $LATEST_VERSION"
    
    # Compare versions (simple string comparison, could be improved)
    if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        echo "[+] You have the latest version of NeuroPrime!"
    else
        echo "[!] A new version of NeuroPrime is available!"
        echo "    Current version: $CURRENT_VERSION"
        echo "    Latest version: $LATEST_VERSION"
        echo ""
        echo "    Would you like to download the latest version? (y/n)"
        read -r download_update
        if [[ $download_update == "y" ]]; then
            echo "[+] Opening download page..."
            open "$REPO_URL/releases/latest"
        fi
    fi
else
    # If no VERSION file, check for release tags
    LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null)
    if [ -n "$LATEST_TAG" ]; then
        echo "[+] Current version: $CURRENT_VERSION"
        echo "[+] Latest version: $LATEST_TAG"
        
        # Compare versions (simple string comparison, could be improved)
        if [ "$CURRENT_VERSION" = "$LATEST_TAG" ]; then
            echo "[+] You have the latest version of NeuroPrime!"
        else
            echo "[!] A new version of NeuroPrime is available!"
            echo "    Current version: $CURRENT_VERSION"
            echo "    Latest version: $LATEST_TAG"
            echo ""
            echo "    Would you like to download the latest version? (y/n)"
            read -r download_update
            if [[ $download_update == "y" ]]; then
                echo "[+] Opening download page..."
                open "$REPO_URL/releases/latest"
            fi
        fi
    else
        echo "[!] Could not determine the latest version."
        echo "    Please check for updates manually at:"
        echo "    $REPO_URL"
    fi
fi

# Clean up
cd "$OLDPWD" || exit 1
rm -rf "$TEMP_DIR"

echo "======================================"
