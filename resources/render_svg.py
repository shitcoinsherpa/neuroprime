#!/usr/bin/env python3
"""
SVG to PNG renderer using pyppeteer (Python port of puppeteer)
"""

import asyncio
import os
import sys
from pathlib import Path

# Try to import pyppeteer, install if not available
try:
    from pyppeteer import launch  # type: ignore # noqa
except ImportError:
    print("[+] Installing pyppeteer...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pyppeteer"])
    from pyppeteer import launch # type: ignore # noqa

async def render_svg_to_png():
    """Render SVG to PNG using pyppeteer"""
    print("[+] Starting browser-based SVG rendering...")
    
    # Get the absolute path to the HTML file
    script_dir = Path(os.path.dirname(os.path.abspath(__file__)))
    html_path = script_dir / 'render_svg.html'
    file_url = f"file://{html_path}"
    
    # Launch a headless browser
    browser = await launch(headless=True)
    page = await browser.newPage()
    
    # Set viewport to ensure proper rendering
    await page.setViewport({
        'width': 1024,
        'height': 1024,
        'deviceScaleFactor': 3  # Higher resolution
    })
    
    # Navigate to the HTML file
    print(f"[+] Loading {file_url}")
    await page.goto(file_url, {'waitUntil': 'networkidle0'})
    
    # Wait for the SVG to load (it's already in the HTML)
    await page.waitForSelector('svg', {'timeout': 10000})
    
    # Give it a moment to fully render
    await asyncio.sleep(1)
    
    # Take a screenshot
    print("[+] Capturing screenshot...")
    png_path = script_dir / 'neuroprime.png'
    await page.screenshot({
        'path': str(png_path),
        'omitBackground': True,
        'clip': {
            'x': 0,
            'y': 0,
            'width': 1024,
            'height': 1024
        }
    })
    
    print(f"[+] Screenshot saved to {png_path}")
    
    await browser.close()
    return True

if __name__ == "__main__":
    try:
        asyncio.get_event_loop().run_until_complete(render_svg_to_png())
    except Exception as e:
        print(f"[!] Error: {e}")
        sys.exit(1)
