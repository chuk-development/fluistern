@echo off
REM Build script for Flüstern on Windows

echo ========================================
echo Building Flüstern for Windows
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev
    pause
    exit /b 1
)

echo [1/3] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo [2/3] Building for Windows...
call flutter build windows --release
if %errorlevel% neq 0 (
    echo ERROR: Build failed
    pause
    exit /b 1
)

echo.
echo [3/3] Build complete!
echo.
echo ========================================
echo Executable location:
echo build\windows\x64\runner\Release\fluistern_app.exe
echo ========================================
echo.

pause
