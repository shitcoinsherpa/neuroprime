import gradio as gr
import requests
import json
import os
import base64
from cryptography.fernet import Fernet
from PIL import Image
import io
import uuid
import threading
import time
import httpx
import sys
import platform
import webbrowser
import subprocess
from pathlib import Path
import logging

# --- MacOS App Support Directory ---
def get_app_support_dir():
    # Use ~/Library/Application Support/NeuroPrime for config/data
    home = os.path.expanduser("~")
    support_dir = os.path.join(home, "Library", "Application Support", "NeuroPrime")
    os.makedirs(support_dir, exist_ok=True)
    return support_dir

APP_SUPPORT_DIR = get_app_support_dir()
CONFIG_FILE = os.path.join(APP_SUPPORT_DIR, "config.json")
KEY_FILE = os.path.join(APP_SUPPORT_DIR, "key.bin")
DEFAULT_MODELS = ["openai/gpt-3.5-turbo", "anthropic/claude-3-haiku"]

# --- Encryption Key Management ---
def get_encryption_key():
    if os.path.exists(KEY_FILE):
        with open(KEY_FILE, "rb") as f:
            return f.read()
    else:
        key = Fernet.generate_key()
        with open(KEY_FILE, "wb") as f:
            f.write(key)
        return key

def encrypt_api_key(api_key):
    key = get_encryption_key()
    cipher = Fernet(key)
    return cipher.encrypt(api_key.encode()).decode()

def decrypt_api_key(encrypted_api_key):
    key = get_encryption_key()
    cipher = Fernet(key)
    return cipher.decrypt(encrypted_api_key.encode()).decode()

# --- Config Management ---
def load_config():
    try:
        if os.path.exists(CONFIG_FILE):
            with open(CONFIG_FILE, "r") as f:
                config = json.load(f)
                if "api_key" in config and config["api_key"]:
                    try:
                        config["api_key"] = decrypt_api_key(config["api_key"])
                    except Exception:
                        config["api_key"] = ""
                if "models" not in config or not config["models"]:
                    config["models"] = DEFAULT_MODELS
                return config
    except Exception:
        pass
    return {"api_key": "", "models": DEFAULT_MODELS, "conversations": []}

def save_config(config):
    config_to_save = config.copy()
    if "api_key" in config_to_save and config_to_save["api_key"]:
        config_to_save["api_key"] = encrypt_api_key(config_to_save["api_key"])
    os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)
    with open(CONFIG_FILE, "w") as f:
        json.dump(config_to_save, f)
    return True

config = load_config()

# --- OpenRouter API Functions ---
def get_reasoning_approach(query, api_key, model):
    if not api_key:
        return "API key is required.", None
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    reasoning_prompt = f"""
    I have a question/task: "{query}"

    From ALL POSSIBLE reasoning frameworks (including but not limited to: inductive, deductive, abductive, 
    critical thinking, systems thinking, lateral thinking, dialectical reasoning, analogical reasoning, 
    counterfactual reasoning, first principles reasoning, systems 1/2/3 thinking, bayesian reasoning, 
    causal reasoning, etc.), identify TWO complementary reasoning approaches that would work well IN TANDEM 
    to address this question/task effectively.

    Explain briefly why these two specific frameworks combined would yield the best results for this particular 
    query. Be specific about how they complement each other.

    FORMAT YOUR RESPONSE AS:
    1. Framework 1: [name] - [brief justification]
    2. Framework 2: [name] - [brief justification]
    3. Why combining them works: [explanation]
    4. Hybrid prompt prefix to add: [A paragraph that instructs how to use these two frameworks together]
    """
    payload = {
        "model": model,
        "messages": [
            {"role": "user", "content": reasoning_prompt}
        ]
    }
    try:
        response = requests.post("https://openrouter.ai/api/v1/chat/completions", 
                                 headers=headers, json=payload)
        response.raise_for_status()
        response_data = response.json()
        if "choices" in response_data and len(response_data["choices"]) > 0:
            result = response_data["choices"][0]["message"]["content"]
            sections = result.split("Hybrid prompt prefix to add:")
            if len(sections) > 1:
                hybrid_prompt = sections[1].strip()
                return result, hybrid_prompt
            else:
                return result, None
        else:
            return "Failed to get reasoning approach.", None
    except Exception as e:
        return f"Error: {str(e)}", None

def send_message(messages, api_key, model, hybrid_prompt=None, image_data=None):
    if not api_key:
        return "API key is required."
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    formatted_messages = []
    for msg in messages:
        if msg["role"] == "system":
            formatted_messages.append({"role": "system", "content": msg["content"]})
        else:
            content = msg["content"]
            if hybrid_prompt and msg == messages[-1] and msg["role"] == "user":
                content = f"{hybrid_prompt}\n\nUser query: {content}"
            if image_data and msg == messages[-1] and msg["role"] == "user":
                formatted_messages.append({
                    "role": msg["role"],
                    "content": [
                        {"type": "text", "text": content},
                        {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{image_data}"}}
                    ]
                })
            else:
                formatted_messages.append({"role": msg["role"], "content": content})
    payload = {
        "model": model,
        "messages": formatted_messages
    }
    try:
        response = requests.post("https://openrouter.ai/api/v1/chat/completions", 
                                 headers=headers, json=payload)
        response.raise_for_status()
        response_data = response.json()
        if "choices" in response_data and len(response_data["choices"]) > 0:
            return response_data["choices"][0]["message"]["content"]
        else:
            return "No response from the model."
    except Exception as e:
        return f"Error: {str(e)}"

def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

# --- UI Functions ---
def save_api_key(api_key):
    global config
    config["api_key"] = api_key
    success = save_config(config)
    return "API key saved successfully!" if api_key and success else "API key cleared."

def add_model(model_name):
    global config
    if model_name and model_name not in config["models"]:
        config["models"].append(model_name)
        success = save_config(config)
        return gr.Dropdown(choices=config["models"], value=model_name), f"Model {model_name} added!"
    elif model_name in config["models"]:
        return gr.Dropdown(choices=config["models"], value=model_name), f"Model {model_name} already exists."
    else:
        return gr.Dropdown(choices=config["models"]), "Please enter a valid model name."

def remove_model(model_name):
    global config
    if model_name in config["models"] and len(config["models"]) > 1:
        config["models"].remove(model_name)
        success = save_config(config)
        return gr.Dropdown(choices=config["models"], value=config["models"][0]), f"Model {model_name} removed!"
    elif len(config["models"]) <= 1:
        return gr.Dropdown(choices=config["models"]), "Cannot remove the last model."
    else:
        return gr.Dropdown(choices=config["models"]), f"Model {model_name} not found."

def get_reasoning(query, api_key, model):
    reasoning_result, hybrid_prompt = get_reasoning_approach(query, api_key, model)
    return reasoning_result, hybrid_prompt

def upload_image(image):
    if image is None:
        return None
    img_byte_arr = io.BytesIO()
    image.save(img_byte_arr, format='JPEG')
    img_byte_arr = img_byte_arr.getvalue()
    return base64.b64encode(img_byte_arr).decode('utf-8')

def on_submit(message, chat_history, api_key, model, hybrid_prompt, image_data):
    if not message:
        return "", chat_history
    chat_history.append({"role": "user", "content": message})
    messages = [{"role": "system", "content": "You are a helpful assistant."}]
    messages.extend(chat_history)
    response = send_message(messages, api_key, model, hybrid_prompt, image_data)
    chat_history.append({"role": "assistant", "content": response})
    return "", chat_history, None, None

def format_chat_history(chat_history):
    return chat_history

# --- Custom CSS for 90s hacker aesthetic ---
custom_css = """
:root {
    --primary-color: #00ff00;
    --secondary-color: #008800;
    --background-color: #000000;
    --text-color: #00ff00;
    --font-family: 'Courier New', monospace;
}
body {
    background-color: var(--background-color);
    color: var(--text-color);
    font-family: var(--font-family);
    text-shadow: 0 0 5px var(--primary-color);
}
.gradio-container {
    background-color: rgba(0,0,0,0.8);
    border: 2px solid var(--primary-color);
    box-shadow: 0 0 15px var(--primary-color);
}
.app-header {
    text-align: center;
    text-transform: uppercase;
    letter-spacing: 2px;
    animation: pulse 1.5s infinite;
    margin-bottom: 20px;
}
@keyframes pulse {
    0% { text-shadow: 0 0 5px var(--primary-color); }
    50% { text-shadow: 0 0 20px var(--primary-color), 0 0 30px var(--primary-color); }
    100% { text-shadow: 0 0 5px var(--primary-color); }
}
.message-bubble {
    background-color: #001100;
    border: 1px solid var(--primary-color);
    border-radius: 0;
    font-family: var(--font-family);
}
.user-message {
    background-color: #001400;
}
.assistant-message {
    background-color: #000800;
}
.input-box {
    border: 1px solid var(--primary-color) !important;
    background-color: #001000 !important;
    color: var(--text-color) !important;
    font-family: var(--font-family) !important;
}
button {
    background-color: var(--background-color) !important;
    color: var(--primary-color) !important;
    border: 1px solid var(--primary-color) !important;
    text-transform: uppercase;
    letter-spacing: 1px;
    transition: all 0.3s;
}
button:hover {
    background-color: var(--primary-color) !important;
    color: var(--background-color) !important;
    box-shadow: 0 0 10px var(--primary-color);
}
.settings-panel {
    border: 1px dashed var(--primary-color);
    padding: 10px;
    margin-top: 10px;
}
.footer {
    text-align: center;
    font-size: 0.8em;
    margin-top: 20px;
    color: #006600;
}
/* Scanlines effect */
.scanlines {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: linear-gradient(
        to bottom,
        rgba(0, 255, 0, 0) 50%,
        rgba(0, 255, 0, 0.03) 50%
    );
    background-size: 100% 4px;
    z-index: 9999;
    pointer-events: none;
    opacity: 0.3;
}
/* CRT flicker */
.crt-flicker {
    animation: flicker 0.15s infinite;
}
@keyframes flicker {
    0% { opacity: 0.98; }
    25% { opacity: 1; }
    50% { opacity: 0.99; }
    75% { opacity: 0.98; }
    100% { opacity: 1; }
}
/* Glitch effect for title */
.glitch {
    position: relative;
}
.glitch::before,
.glitch::after {
    content: attr(data-text);
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
}
.glitch::before {
    animation: glitch-effect 3s infinite;
    clip-path: polygon(0 0, 100% 0, 100% 35%, 0 35%);
    text-shadow: -2px 0 #ff00ff;
}
.glitch::after {
    animation: glitch-effect 2s infinite reverse;
    clip-path: polygon(0 65%, 100% 65%, 100% 100%, 0 100%);
    text-shadow: 2px 0 #00ffff;
}
@keyframes glitch-effect {
    0% { transform: translate(0); }
    20% { transform: translate(-3px, 3px); }
    40% { transform: translate(-3px, -3px); }
    60% { transform: translate(3px, 3px); }
    80% { transform: translate(3px, -3px); }
    100% { transform: translate(0); }
}
"""

# --- Main UI ---
with gr.Blocks(css=custom_css) as demo:
    current_hybrid_prompt = gr.State(None)
    current_image_data = gr.State(None)
    chat_state = gr.State([])

    gr.HTML("""
    <div class="scanlines"></div>
    <div class="crt-flicker"></div>
    <div class="app-header">
        <h1 class="glitch" data-text="NeuroPrime">NeuroPrime</h1>
        <p>Advanced Neural Reasoning Framework</p>
    </div>
    """)

    with gr.Row():
        with gr.Column(scale=3):
            chatbot = gr.Chatbot(
                [],
                elem_id="chatbot",
                avatar_images=("🧠", "🤖"),
                height=500,
                container=True,
                type="messages"
            )
            with gr.Row():
                with gr.Column(scale=8):
                    msg = gr.Textbox(
                        show_label=False,
                        placeholder="H4CK TH3 PL4N3T...",
                        container=False,
                        elem_classes=["input-box"]
                    )
                    image_upload = gr.Image(
                        type="pil", 
                        label="Upload Image (if model supports it)",
                        visible=True
                    )
                with gr.Column(scale=2):
                    get_reasoning_btn = gr.Button("GET R34S0NING", variant="primary")
                    submit_btn = gr.Button("S3ND M3SS4G3", variant="primary")
        with gr.Column(scale=1):
            with gr.Group():
                api_key = gr.Textbox(
                    placeholder="Enter OpenRouter API Key",
                    value=config.get("api_key", ""),
                    type="password",
                    label="OpenRouter API Key"
                )
                save_key_btn = gr.Button("S4V3 K3Y")
                model_dropdown = gr.Dropdown(
                    choices=config.get("models", DEFAULT_MODELS),
                    value=config.get("models", DEFAULT_MODELS)[0] if config.get("models", DEFAULT_MODELS) else None,
                    label="Select Model"
                )
                with gr.Row():
                    new_model = gr.Textbox(placeholder="Model name (e.g., openai/gpt-4)", label="Add New Model")
                    add_model_btn = gr.Button("ADD", scale=1)
                with gr.Row():
                    remove_model_btn = gr.Button("R3M0V3 M0D3L")
            reasoning_output = gr.Textbox(
                label="Reasoning Framework",
                placeholder="Click 'GET REASONING' to see the AI's approach...",
                lines=10,
                max_lines=10
            )
    gr.HTML("""
    <div class="footer">
        <p>©2025 NeuroPrime | SYST3M STAT5: FULL P0W3R | Initializing Neural Pathways...</p>
    </div>
    """)

    def update_chat_display(chat_history):
        formatted = format_chat_history(chat_history)
        return formatted

    def process_image(image):
        if image is None:
            return None
        return upload_image(image)

    save_key_btn.click(save_api_key, inputs=[api_key], outputs=[gr.Textbox()])
    add_model_btn.click(add_model, inputs=[new_model], outputs=[model_dropdown, gr.Textbox()])
    remove_model_btn.click(remove_model, inputs=[model_dropdown], outputs=[model_dropdown, gr.Textbox()])
    get_reasoning_btn.click(
        get_reasoning, 
        inputs=[msg, api_key, model_dropdown], 
        outputs=[reasoning_output, current_hybrid_prompt]
    )
    image_upload.change(
        process_image,
        inputs=[image_upload],
        outputs=[current_image_data]
    )
    submit_event = submit_btn.click(
        on_submit,
        inputs=[msg, chat_state, api_key, model_dropdown, current_hybrid_prompt, current_image_data],
        outputs=[msg, chat_state, current_hybrid_prompt, current_image_data]
    ).then(
        update_chat_display,
        inputs=[chat_state],
        outputs=[chatbot]
    )
    msg.submit(
        on_submit,
        inputs=[msg, chat_state, api_key, model_dropdown, current_hybrid_prompt, current_image_data],
        outputs=[msg, chat_state, current_hybrid_prompt, current_image_data]
    ).then(
        update_chat_display,
        inputs=[chat_state],
        outputs=[chatbot]
    )

# --- Logging Configuration ---
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger("NeuroPrime")

# --- MacOS App Management ---
def is_running_as_bundled_app():
    """Check if the application is running as a bundled macOS app."""
    bundle_path = os.environ.get('NEUROPRIME_BUNDLE_PATH')
    if bundle_path:
        logger.info(f"Running as bundled app with path: {bundle_path}")
        return True
    
    # Check common bundle path indicators
    app_path = os.path.abspath(sys.argv[0])
    is_bundled = '.app/Contents/Resources' in app_path or '.app/Contents/MacOS' in app_path
    
    if is_bundled:
        logger.info(f"Detected bundled app from path: {app_path}")
    else:
        logger.info("Running in development mode")
    
    return is_bundled

def show_splash_screen():
    """Display a splash screen while the app is loading (macOS only)."""
    if not is_running_as_bundled_app() or platform.system() != 'Darwin':
        return

    try:
        # Use a simple AppleScript to display a splash window
        import subprocess
        
        # Get bundle path for icon
        bundle_path = os.environ.get('NEUROPRIME_BUNDLE_PATH', '')
        icon_path = os.path.join(bundle_path, 'Resources', 'neuroprime.icns')
        icon_path_osa = icon_path.replace('"', '\\"') # escape quotes
        
        # Create AppleScript for splash window
        applescript = f'''
        tell application "System Events"
            set frontmost of every process whose unix id is {os.getpid()} to true
        end tell
        
        tell application "System Events"
            set iconPath to POSIX file "{icon_path_osa}" as alias
            display dialog "NeuroPrime is starting..." ¬
                with title "NeuroPrime" with icon iconPath buttons {{"Loading..."}} ¬
                default button 1 giving up after 3
        end tell
        '''
        
        # Execute the AppleScript
        subprocess.Popen(['osascript', '-e', applescript])
        logger.info("Splash screen displayed")
    except Exception as e:
        logger.error(f"Error showing splash screen: {e}")

# --- Default Browser Launcher ---
def open_in_default_browser(url: str):
    if platform.system() == "Darwin":               # macOS
        subprocess.Popen(["open", url])            # respects user’s default browser
    elif platform.system() == "Windows":
        os.startfile(url)                          # type: ignore  # default handler
    else:                                          # Linux / BSD
        webbrowser.open(url)

if __name__ == "__main__":
    try:
        # Determine if running as a bundled app
        bundled_app = is_running_as_bundled_app()
        
        if bundled_app:
            # Show splash screen when running as bundled app
            show_splash_screen()
            
            # When running as a bundled app, use the embedded browser approach
            # Launch Gradio server without opening a browser
            logger.info("Starting Gradio server in bundled app mode")
            launch_result = demo.launch(
                prevent_thread_lock=False,
                share=False,
                show_error=True,
                quiet=False,
                inline=False,
                inbrowser=True,
                favicon_path=None,
                ssl_verify=False
            )
            
        else:
            # Standard development mode - let Gradio handle browser launch
            logger.info("Starting Gradio server in development mode")
            demo.launch(share=False)
    except Exception as e:
        logger.error(f"Application error: {e}")
        # If we're in a bundled app, display an error dialog
        if is_running_as_bundled_app() and platform.system() == 'Darwin':
            try:
                import subprocess
                error_msg = str(e).replace('"', '\\"')
                subprocess.call(['osascript', '-e', f'display dialog "Error starting NeuroPrime: {error_msg}" with title "NeuroPrime Error" buttons {{"OK"}} default button 1 with icon stop'])
            except:
                pass
        sys.exit(1)
