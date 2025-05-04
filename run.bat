@echo off
echo ======================================
echo NeuroPrime System Launch Sequence
echo ======================================
echo [+] Initializing neural network...

REM Activate virtual environment
call venv\Scripts\activate.bat

echo [+] System online. Starting interface...
echo [+] Opening browser in 5 seconds...

REM Start the server
start /B python app.py

REM Using ping to create a delay (pinging localhost with a timeout of 1 second, 5 times)
ping 127.0.0.1 -n 6 > nul

REM Open browser (Gradio typically runs on port 7860)
start http://localhost:7860

echo [+] Access port opened. H4ppy h4cking!
echo ======================================
