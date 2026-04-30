@echo off
REM D-ORCA Installation Script for Windows 10
REM This script installs dependencies and downloads the D-ORCA model

setlocal enabledelayedexpansion

echo.
echo ========================================
echo D-ORCA Installation
echo ========================================
echo.
echo This script will:
echo   1. Install uv (Python package manager)
echo   2. Create a virtual environment
echo   3. Install required dependencies
echo   4. Download the D-ORCA-8B-0210 model
echo.
pause

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH.
    echo Please install Python 3.10+ from https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [1/5] Python found...
python --version
echo.

REM Check if uv is installed, if not install it
where uv >nul 2>&1
if errorlevel 1 (
    echo [2/5] Installing uv...
    pip install uv
    if errorlevel 1 (
        echo Error: Failed to install uv. Try running: pip install uv
        pause
        exit /b 1
    )
) else (
    echo [2/5] uv already installed
)
uv --version
echo.

REM Create virtual environment if it doesn't exist
if not exist ".venv" (
    echo [3/5] Creating virtual environment...
    uv venv
) else (
    echo [3/5] Virtual environment already exists
)
echo.

REM Install dependencies using uv
echo [4/5] Installing dependencies...
call .venv\Scripts\activate.bat
uv pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
uv pip install transformers accelerate sentencepiece protobuf
uv pip install pillow opencv-python imageio[ffmpeg]
uv pip install pyyaml pathlib
echo.

REM Download the model
echo [5/5] Downloading D-ORCA-8B-0210 model...
echo This may take a while depending on your internet connection...
echo.

REM Create models directory if it doesn't exist
if not exist "models" mkdir models

REM Use huggingface-cli to download the model
python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='tsinghua-ee/D-ORCA-8B-0210', local_dir='models/tsinghua-ee/D-ORCA-8B-0210')"

if errorlevel 1 (
    echo.
    echo Note: If huggingface_hub is not installed, installing now...
    uv pip install huggingface_hub
    python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='tsinghua-ee/D-ORCA-8B-0210', local_dir='models/tsinghua-ee/D-ORCA-8B-0210')"
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo You can now use D-ORCA.bat to process videos.
echo Simply drag and drop a video file onto D-ORCA.bat
echo.
echo The model has been downloaded to: models/tsinghua-ee/D-ORCA-8B-0210
echo.
pause
