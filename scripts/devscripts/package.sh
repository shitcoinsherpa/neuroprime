#!/bin/bash
set -e
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"   # one level up from /scripts
cd "${REPO_ROOT}"                              # become repo root

echo "======================================"
echo "NeuroPrime Icon Packaging"
echo "======================================"

# Create resources directory if it doesn't exist
mkdir -p resources

# Check if icon file exists, if not create it from the SVG
if [ ! -f "resources/neuroprime.icns" ]; then
    echo "[+] Creating icon file from SVG..."

    # Check if the SVG file exists
    if [ ! -f "resources/neuroprime.svg" ] && [ ! -f "neuroprime.svg" ]; then
        echo "[!] Error: SVG file not found at resources/neuroprime.svg or neuroprime.svg"
        exit 1
    else
        # Copy SVG to resources directory if not already there
        if [ ! -f "resources/neuroprime.svg" ] && [ -f "neuroprime.svg" ]; then
            cp neuroprime.svg resources/
        fi

        # Convert SVG to PNG using Python-based renderer if available
        if command -v python3 &> /dev/null; then
            echo "[+] Converting SVG to PNG using Python-based browser rendering..."
            python3 resources/render_svg.py
        fi

        # Fallback: Use ImageMagick if available
        if [ ! -f "resources/neuroprime.png" ] && (command -v convert &> /dev/null || command -v magick &> /dev/null); then
            echo "[+] Converting SVG to PNG using ImageMagick..."
            CONVERT_CMD="convert"
            if command -v magick &> /dev/null; then
                CONVERT_CMD="magick convert"
            fi
            $CONVERT_CMD -background none -density 1200 -colorspace sRGB -channel RGBA \
                resources/neuroprime.svg -resize 1024x1024 -gravity center -extent 1024x1024 resources/neuroprime.png
        fi

        # Fallback: Use librsvg if available
        if [ ! -f "resources/neuroprime.png" ] && command -v rsvg-convert &> /dev/null; then
            echo "[+] Converting SVG to PNG using librsvg..."
            rsvg-convert -w 1024 -h 1024 --keep-aspect-ratio --format=png \
                --output=resources/neuroprime.png resources/neuroprime.svg
        fi

        # Create .icns from PNG if possible
        if [ -f "resources/neuroprime.png" ] && command -v sips &> /dev/null && command -v iconutil &> /dev/null; then
            echo "[+] Creating iconset using sips and iconutil..."
            mkdir -p resources/neuroprime.iconset
            sips -z 16 16 resources/neuroprime.png --out resources/neuroprime.iconset/icon_16x16.png
            sips -z 32 32 resources/neuroprime.png --out resources/neuroprime.iconset/icon_16x16@2x.png
            sips -z 32 32 resources/neuroprime.png --out resources/neuroprime.iconset/icon_32x32.png
            sips -z 64 64 resources/neuroprime.png --out resources/neuroprime.iconset/icon_32x32@2x.png
            sips -z 128 128 resources/neuroprime.png --out resources/neuroprime.iconset/icon_128x128.png
            sips -z 256 256 resources/neuroprime.png --out resources/neuroprime.iconset/icon_128x128@2x.png
            sips -z 256 256 resources/neuroprime.png --out resources/neuroprime.iconset/icon_256x256.png
            sips -z 512 512 resources/neuroprime.png --out resources/neuroprime.iconset/icon_256x256@2x.png
            sips -z 512 512 resources/neuroprime.png --out resources/neuroprime.iconset/icon_512x512.png
            sips -z 1024 1024 resources/neuroprime.png --out resources/neuroprime.iconset/icon_512x512@2x.png
            iconutil -c icns resources/neuroprime.iconset
            rm -rf resources/neuroprime.iconset
            echo "[+] Icon file created at resources/neuroprime.icns"
        else
            echo "[!] Warning: Could not create .icns file. PNG is available at resources/neuroprime.png"
        fi
    fi
else
    echo "[+] Icon file already exists at resources/neuroprime.icns"
fi

echo "======================================"
echo "Run ./build_macos_app.sh to build the app bundle."
echo "======================================"
