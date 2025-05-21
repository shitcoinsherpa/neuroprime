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
