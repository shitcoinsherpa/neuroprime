@echo off
echo ======================================
echo NeuroPrime System Installation
echo ======================================
echo [+] Initializing system...

REM Delete existing venv if it exists
if exist venv (
    echo [+] Removing previous installation...
    rmdir /s /q venv
)

echo [+] Creating virtual environment...
python -m venv venv

echo [+] Activating virtual environment...
call venv\Scripts\activate.bat

echo [+] Installing dependencies...
pip install -r requirements.txt

echo [+] Installation complete!
echo [+] Run NeuroPrime with run.bat
echo ======================================

pause
