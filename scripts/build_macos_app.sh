#!/bin/bash
set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"   # one level up from /scripts
cd "${REPO_ROOT}"                              # become repo root

APP_NAME="NeuroPrime"
APP_BUNDLE="dist/${APP_NAME}.app"
PYTHON_VERSION="3.10"
ICON_PATH="resources/neuroprime.icns"
APP_SOURCE_DIR="$(pwd)"
VENV_DIR="${APP_BUNDLE}/Contents/Resources/python"
APP_DIR="${APP_BUNDLE}/Contents/Resources/app"
LAUNCHER="${APP_BUNDLE}/Contents/MacOS/neuroprime"
PLIST="${APP_BUNDLE}/Contents/Info.plist"

echo "=== Building ${APP_NAME} macOS App Bundle ==="
echo "Cleaning previous build..."
rm -rf dist
mkdir -p "${APP_BUNDLE}/Contents/MacOS" "${APP_DIR}" "${VENV_DIR}"

echo "Copying app source files..."
rsync -av --exclude='venv/' --exclude='dist/' --exclude='*.pyc' \
        --exclude='__pycache__/' --exclude='.DS_Store' \
        --exclude='*.bat' --exclude='*.sh' --exclude='build*/' \
        --exclude='*.spec' --exclude='Sentinel/' --exclude='legacy/' \
        --exclude='*.dmg' \
        "${APP_SOURCE_DIR}/" "${APP_DIR}/"

if [ -d "Sentinel/Sentinel.app" ]; then
    echo "[+] Adding Sentinel helper ..."
    cp -R "Sentinel/Sentinel.app" "${APP_DIR}/"
fi

echo "Copying resources..."
# Only copy the icon file to avoid duplication
if [ -f "${ICON_PATH}" ]; then
    cp "${ICON_PATH}" "${APP_BUNDLE}/Contents/Resources/"
    echo "Copied app icon to bundle"
fi

echo "Creating Python venv in app bundle using official Python.org binary..."
# Use the official Python.org binary instead of pyenv to ensure portability
if [ -f "/Library/Frameworks/Python.framework/Versions/3.10/bin/python3" ]; then
    /Library/Frameworks/Python.framework/Versions/3.10/bin/python3 -m venv "${VENV_DIR}"
else
    echo "Warning: Official Python 3.10 not found. Using system Python which may cause portability issues."
    echo "Consider installing the official Python from python.org first:"
    echo "curl -O https://www.python.org/ftp/python/3.10.13/python-3.10.13-macos11.pkg"
    echo "sudo installer -pkg python-3.10.13-macos11.pkg -target /"
    python3 -m venv "${VENV_DIR}"
fi

echo "Installing requirements in app bundle venv..."
"${VENV_DIR}/bin/pip" install --upgrade pip
"${VENV_DIR}/bin/pip" install -r requirements.txt

echo "Creating launcher script..."
cat > "${LAUNCHER}" <<EOF
#!/bin/bash
# Get absolute paths to avoid issues with relative paths
SCRIPT_PATH="\$(cd "\$(dirname "\$0")" && pwd)"
BUNDLE_PATH="\$(dirname "\$SCRIPT_PATH")"
APP_DIR="\${BUNDLE_PATH}/Resources/app"
PYTHON_BIN="\${BUNDLE_PATH}/Resources/python/bin/python3"

# Ensure we're using the correct paths
echo "Script path: \$SCRIPT_PATH"
echo "Bundle path: \$BUNDLE_PATH"
echo "App directory: \$APP_DIR"
echo "Python binary: \$PYTHON_BIN"

# Verify app.py exists
if [ ! -f "\${APP_DIR}/app.py" ]; then
    echo "ERROR: app.py not found at \${APP_DIR}/app.py"
    osascript -e 'display dialog "Error: app.py not found in the application bundle." with title "NeuroPrime Error" buttons {"OK"} default button 1 with icon stop'
    exit 1
fi

# Set up Python environment with absolute paths
# DO NOT use PYTHONHOME as it breaks the venv mechanics
export PATH="\${BUNDLE_PATH}/Resources/python/bin:\${PATH}"
export NEUROPRIME_BUNDLE_PATH="\${BUNDLE_PATH}"

# Change to app directory using absolute path
cd "\$APP_DIR"

# Launch the app with the modified environment using absolute paths
echo "Launching app with Python: \$PYTHON_BIN"
exec "\$PYTHON_BIN" "\${APP_DIR}/app.py" "\$@"
EOF
chmod +x "${LAUNCHER}"

echo "Creating Info.plist..."
cat > "${PLIST}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.shitcoinsherpa.neuroprime</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleExecutable</key>
    <string>neuroprime</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>neuroprime.icns</string>
</dict>
</plist>
EOF

echo "Setting permissions..."
chmod -R go-w "${APP_BUNDLE}"

echo "Applying ad-hoc code signing to prevent Gatekeeper issues..."
codesign --deep --force --sign - "${APP_BUNDLE}"

echo "Build complete!"
echo "You can run the app with: open \"${APP_BUNDLE}\""
echo "Or create a DMG installer with: ./create_dmg.sh"
echo ""
echo "To test from Terminal first (recommended):"
echo "./dist/NeuroPrime.app/Contents/MacOS/neuroprime"
