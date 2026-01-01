@echo off
REM Run script for Flüstern on Windows

echo ========================================
echo Running Flüstern on Windows
echo ========================================
echo.

REM Check if build exists
if not exist "build\windows\x64\runner\Release\fluistern_app.exe" (
    echo Build not found. Building first...
    echo.
    call build.bat
    if %errorlevel% neq 0 (
        echo ERROR: Build failed
        pause
        exit /b 1
    )
)

echo Starting Flüstern...
echo.
start "" "build\windows\x64\runner\Release\fluistern_app.exe"

echo App started!
