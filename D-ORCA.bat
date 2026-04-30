@echo off
REM D-ORCA Video Captioning - Windows 10
REM Drag and drop a video file onto this batch file to process it
REM Output will be saved in the same folder as the input video

setlocal enabledelayedexpansion

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

REM Check if a file was dragged onto the script
if "%~1"=="" (
    echo.
    echo D-ORCA Video Captioning
    echo ======================
    echo Usage: Drag and drop a video file onto D-ORCA.bat
    echo Or run: D-ORCA.bat ^<video_file^>
    echo.
    echo The caption output will be saved in the same folder as the input video.
    echo.
    pause
    exit /b 1
)

REM Set the input video file
set "VIDEO_FILE=%~1"

REM Verify the file exists
if not exist "%VIDEO_FILE%" (
    echo Error: File not found: %VIDEO_FILE%
    pause
    exit /b 1
)

echo.
echo ========================================
echo D-ORCA Video Captioning
echo ========================================
echo Processing: %VIDEO_FILE%
echo.

REM Change to script directory to ensure proper Python path
cd /d "%SCRIPT_DIR%"

REM Run the captioning script with CUDA to CPU fallback
python d_orca_caption.py "%VIDEO_FILE%"

echo.
echo ========================================
echo Processing complete!
echo ========================================
echo.
pause
