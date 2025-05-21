#!/bin/bash
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"   # one level up from /scripts
cd "${REPO_ROOT}"                              # become repo root
echo "======================================"
echo "NeuroPrime System Installation"
echo "======================================"
echo "[+] Initializing system..."

# Run uninstall script if it exists
if [ -f "uninstall.sh" ]; then
    echo "[+] Running uninstall script first..."
    chmod +x uninstall.sh
    ./uninstall.sh
fi

# Check if venv already exists and is valid
if [ -d "venv" ] && [ -f "venv/bin/activate" ] && [ -f "venv/bin/python3" ]; then
    echo "[+] Found existing virtual environment..."
    source venv/bin/activate
    
    # Check if dependencies are already installed
    echo "[+] Checking installed dependencies..."
    MISSING_DEPS=0
    
    # Read requirements from file and check each one
    while read requirement; do
        if [[ -n "$requirement" && ! "$requirement" =~ ^# ]]; then
            package=$(echo "$requirement" | cut -d '=' -f 1)
            if ! pip show "$package" &> /dev/null; then
                MISSING_DEPS=1
                echo "    Missing dependency: $package"
            fi
        fi
    done < requirements.txt
    
    if [ $MISSING_DEPS -eq 0 ]; then
        echo "[+] All dependencies already installed."
    else
        echo "[+] Installing missing dependencies..."
        pip install -r requirements.txt
    fi
else
    echo "[+] Creating new virtual environment..."
    python3 -m venv venv
    
    echo "[+] Activating virtual environment..."
    source venv/bin/activate
    
    echo "[+] Installing dependencies..."
    pip install -r requirements.txt
fi

echo "[+] Installation complete!"
echo "[+] Run NeuroPrime with run.sh"
echo "======================================"
