#!/bin/bash
echo "======================================"
echo "NeuroPrime DMG Background Generator"
echo "======================================"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "[!] Python 3 not found. Please install Python 3."
    exit 1
fi

# Create a temporary Python script that uses pyppeteer
cat > ./resources/generate_background.py << 'EOL'
import asyncio
from pyppeteer import launch
import os
import sys

async def generate_background():
    try:
        # Get the absolute path of the HTML file
        current_dir = os.path.dirname(os.path.abspath(__file__))
        html_path = os.path.join(current_dir, "dmg_background.html")
        output_path = os.path.join(current_dir, "dmg_background.png")
        
        if not os.path.exists(html_path):
            print(f"[!] HTML file not found at {html_path}")
            return False
        
        # Launch the browser
        browser = await launch(args=['--no-sandbox', '--disable-setuid-sandbox'])
        page = await browser.newPage()
        
        await page.setViewport({
        'width': 800,
        'height': 400,
        'deviceScaleFactor': 3   # use 3 for @3x density if desired
        })
        
        # Navigate to the HTML file
        await page.goto(f'file://{html_path}')
        
        # Wait for any animations or styling to complete
        await asyncio.sleep(1)
        
        # Take a screenshot
        await page.screenshot({'path': output_path, 'fullPage': False})
        
        # Ensure the screenshot was actually saved before closing
        if not os.path.exists(output_path):
            print(f"[!] Screenshot wasn't created at {output_path}")
            return False
        
        # Close the browser and ensure it's properly terminated
        try:
            await browser.close()
            print("[+] Browser closed successfully")
        except Exception as e:
            print(f"[!] Error closing browser: {str(e)}")
            # Continue anyway as the image might still have been created
        
        print(f"[+] Background image created successfully at {output_path}")
        return True
    except Exception as e:
        print(f"[!] Error generating background: {str(e)}")
        return False

if __name__ == "__main__":
    success = asyncio.get_event_loop().run_until_complete(generate_background())
    sys.exit(0 if success else 1)
EOL

# Ensure the Python script is executable
chmod +x ./resources/generate_background.py

# Make sure the HTML file exists
if [ ! -f "resources/dmg_background.html" ]; then
    echo "[!] HTML background file not found at resources/dmg_background.html"
    exit 1
fi

# Install required Python packages if needed
echo "[+] Checking for required Python packages..."
if ! python3 -c "import pyppeteer" 2>/dev/null; then
    echo "[+] Installing pyppeteer..."
    if pip3 install --no-cache-dir pyppeteer; then
        echo "[+] pyppeteer installed successfully"
    else
        echo "[!] Failed to install pyppeteer. Please install it manually: pip3 install pyppeteer"
        exit 1
    fi
fi

# Make sure pyppeteer is properly installed and browser downloaded
echo "[+] Running browser download to ensure Chromium is available..."

# Try multiple methods to download the browser in case one fails
if command -v pyppeteer-install &> /dev/null; then
    echo "[+] Using pyppeteer-install command..."
    pyppeteer-install || {
        echo "[!] pyppeteer-install command failed, trying alternative method..."
    }
else
    echo "[+] pyppeteer-install command not found, using Python download method..."
fi

# Fallback to Python script method if command not available or failed
python3 -c "
from pyppeteer.chromium_downloader import download_chromium
import os
# Check if the browser is already downloaded
from pyppeteer.chromium_downloader import chromium_executable
if not os.path.exists(chromium_executable()):
    print('[+] Downloading Chromium browser...')
    download_chromium()
else:
    print('[+] Chromium browser already downloaded')
" || {
    echo "[!] Warning: Failed to download browser. The script will attempt to continue,"
    echo "    but may fail if the browser is not already installed."
}

# Generate the background image
echo "[+] Generating background image using pyppeteer..."
python3 ./resources/generate_background.py

# Check if the image was created successfully
if [ -f "resources/dmg_background.png" ]; then
    echo "[+] Background image created successfully at resources/dmg_background.png"
else
    echo "[!] Failed to create background image"
    exit 1
fi

echo "======================================"
