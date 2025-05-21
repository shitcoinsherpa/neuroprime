# Neuroprime MacOS fork
  
![NeuroPrime Logo](https://img.shields.io/badge/Neuro-Prime-00ff00?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjMDBmZjAwIiBzdHJva2Utd2lkdGg9IjIiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIgc3Ryb2tlLWxpbmVqb2luPSJyb3VuZCIgY2xhc3M9ImZlYXRoZXIgZmVhdGhlci1icmFpbiI+PHBhdGggZD0iTTkgMy42djQuMkg2LjVhMi41IDIuNSAwIDAgMCAwIDVoNS41Ij48L3BhdGg+PHBhdGggZD0iTTE1IDMuNnY0LjJoMi41YTIuNSAyLjUgMCAwIDEgMCA1SDE1Ij48L3BhdGg+PHBhdGggZD0iTTEyIDMuNnYxNi44Ij48L3BhdGg+PHBhdGggZD0iTTcgMTUuMmg0LjQiPjwvcGF0aD48cGF0aCBkPSJNMTcgMTUuMmgtMi44Ij48L3BhdGg+PHBhdGggZD0iTTggMTkuOGg4Ij48L3BhdGg+PC9zdmc+)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Python](https://img.shields.io/badge/Python-3.10+-00ff00.svg)
![Framework](https://img.shields.io/badge/Framework-Gradio-00ff00.svg)

Neuroprime MacOS fork

### Quick Start

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/aporeticaxis/neuroprime_test_fork.git
   cd neuroprime_test_fork
   ```

2. Set up the Python environment and install dependencies:
   ```bash
   ./scripts/build.sh
   ```

3. Build the macOS application bundle:
   ```bash
   ./scripts/build_macos_app.sh
   ```

4. Run the application:
   ```bash
   open ./dist/NeuroPrime.app
   ```

### Build Process Details

The build scripts perform the following actions:

- **build.sh**: Sets up a Python virtual environment and installs required dependencies
- **build_macos_app.sh**: Creates the macOS application bundle (.app) with proper structure

-- 

For faster development iterations, you can use the development mode which bypasses the need to rebuild the app bundle for each change:

```bash
# Run the app directly from source
python app.py
```

After making changes, if you want to test the packaged app:

```bash
# Rebuild the app bundle
./scripts/build_macos_app.sh

# Test the app bundle
open ./dist/NeuroPrime.app
```
