# NeuroPrime

<div align="center">
  
![NeuroPrime Logo](https://img.shields.io/badge/Neuro-Prime-00ff00?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDBmZjAwIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgY2xhc3M9ImZlYXRoZXIgZmVhdGhlci1icmFpbiI+PHBhdGggZD0iTTkgMy42djQuMkg2LjVhMi41IDIuNSAwIDAgMCAwIDVoNS41Ij48L3BhdGg+PHBhdGggZD0iTTE1IDMuNnY0LjJoMi41YTIuNSAyLjUgMCAwIDEgMCA1SDE1Ij48L3BhdGg+PHBhdGggZD0iTTEyIDMuNnYxNi44Ij48L3BhdGg+PHBhdGggZD0iTTcgMTUuMmg0LjQiPjwvcGF0aD48cGF0aCBkPSJNMTcgMTUuMmgtMi44Ij48L3BhdGg+PHBhdGggZD0iTTggMTkuOGg4Ij48L3BhdGg+PC9zdmc+)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Python](https://img.shields.io/badge/Python-3.9+-00ff00.svg)
![Framework](https://img.shields.io/badge/Framework-Gradio-00ff00.svg)

🧠 A 90s "hackerz" themed ChatGPT-like interface that unlocks advanced reasoning frameworks for deeper AI interactions

</div>

NeuroPrime combines nostalgia with cutting-edge AI capabilities, allowing you to dynamically select optimal reasoning strategies before sending queries to large language models. The app features a retro cyberpunk aesthetic with modern functionality, letting you combine two complementary reasoning frameworks to get more insightful responses from any OpenRouter-supported model.

## ✨ Features

- 🕹️ **Retro 90s "hackerz" UI** with scanlines, glitch effects, and terminal-inspired design
- 🧠 **Dynamic reasoning framework selector** that mixes two complementary approaches for enhanced results
- 🔐 **Encrypted API key storage** and model management system
- 📸 **Image upload support** for multimodal models
- 🌐 **Works with any OpenRouter-supported model**

## 🚀 Installation

### Prerequisites

- Python 3.9+
- Internet connection for accessing OpenRouter API

### Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/neuroprime.git
   cd neuroprime
   ```

2. Run the build script to set up the environment:
   ```bash
   # On Windows
   build.bat
   
   # On Linux/Mac
   ./build.sh
   ```

3. Launch the application:
   ```bash
   # On Windows
   run.bat
   
   # On Linux/Mac
   ./run.sh
   ```

4. The interface will automatically open in your default browser (typically at http://localhost:7860).

## 👾 Usage

### API Key Setup
1. Register for an [OpenRouter](https://openrouter.ai) account
2. Generate an API key from your dashboard
3. Enter the API key in the NeuroPrime settings panel and click "S4V3 K3Y"

### Basic Operation

1. Type your query in the input field
2. Click "GET R34S0NING" to see what reasoning frameworks the AI suggests for your query
3. Click "S3ND M3SS4G3" to send your message enhanced with the hybrid reasoning approach

### Adding Models

1. Type the model name (e.g., "anthropic/claude-3-opus") in the "Add New Model" field
2. Click "ADD" to save it to your model list
3. Select the model from the dropdown to use it

### Using Images

If you're using a multimodal model that supports images:
1. Click the "Upload Image" button
2. Select the image from your device
3. Your image will be sent along with your text query

## 🧠 How It Works

NeuroPrime represents a new paradigm in AI interfaces. Here's what makes it special:

### Hybrid Reasoning Framework

Traditional AI interfaces simply send your query to the model. NeuroPrime takes a different approach:

1. It first analyzes your question and determines the optimal combination of reasoning frameworks
2. It selects TWO complementary approaches from all possible reasoning frameworks:
   - Inductive reasoning
   - Deductive reasoning
   - Abductive reasoning
   - Systems thinking
   - First principles reasoning
   - Lateral thinking
   - Critical reasoning
   - Bayesian reasoning
   - And many more...
3. It creates a hybrid prompt that instructs the AI to use both frameworks in tandem
4. It sends your query enhanced with this specialized reasoning approach

The result is responses that are more nuanced, accurate, and insightful than standard interactions.

## 🛠️ Technical Details

NeuroPrime is built with:

- **Gradio 5.23.3** for the web interface
- **Cryptography 41.0.7** for API key encryption
- **OpenRouter API** for model access
- **Python** for core functionality

Configuration is stored locally in the `config` directory:
- `config.json` - Stores your models and encrypted API key
- `key.bin` - Encryption key for securing your API key

## 📜 License

MIT License

## 🤝 Contributions

Contributions are welcome! Please feel free to submit a Pull Request.

## 🔮 Future Features

- Dark/Light mode toggle
- Chat history persistence
- Custom reasoning framework definitions
- Multiple conversation threads
- Export/import of conversations
- Mobile-responsive design

## ⚠️ Disclaimer

This is a personal tool built for enthusiasts. It's not affiliated with OpenRouter, OpenAI, or any other AI provider.

## 💻 Development

To set up a development environment:

```bash
# Clone the repository
git clone https://github.com/shitcoinsherpa/neuroprime.git
cd neuroprime

# Create a virtual environment
python -m venv venv

# Activate the virtual environment
# On Windows
venv\Scripts\activate
# On Linux/Mac
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the app in development mode
python app.py
```

## 🔧 Troubleshooting

**Q: My API key isn't saving.**  
A: Make sure the application has write permissions to the `config` directory.

**Q: The app crashes when I try to use a specific model.**  
A: Verify that the model name is correct and that it's available on OpenRouter.

**Q: The reasoning framework feature doesn't seem to be working.**  
A: Make sure to click "GET R34S0NING" before sending your message and that your API key is valid.

**Q: Images aren't being sent with my messages.**  
A: Confirm you're using a multimodal model that supports image inputs (like GPT-4 Vision).

## 📚 Acknowledgments

- OpenRouter for providing an unified API for multiple language models
- The Gradio team for their amazing web interface library

---

<div align="center">
  <sub>Built with 💚 by hackers, for hackers</sub>
</div>
