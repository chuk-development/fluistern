# Building Flüstern on Windows

## Prerequisites

1. **Install Flutter**
   - Download from: https://flutter.dev/docs/get-started/install/windows
   - Add Flutter to your PATH
   - Verify installation: `flutter doctor`

2. **Install Visual Studio 2022** (required for Windows desktop development)
   - Download Visual Studio 2022 Community (free): https://visualstudio.microsoft.com/downloads/
   - During installation, select "Desktop development with C++"
   - Make sure to include:
     - MSVC v143 - VS 2022 C++ x64/x86 build tools
     - Windows 10/11 SDK

3. **Enable Windows Desktop Development**
   ```bash
   flutter config --enable-windows-desktop
   ```

## Build Instructions

### Option 1: Using the Build Script (Easiest)

Simply double-click `build.bat` or run from command prompt:

```cmd
build.bat
```

This will:
- Get all dependencies
- Build the Windows executable
- Place the .exe in `build\windows\x64\runner\Release\fluistern_app.exe`

### Option 2: Manual Build

1. Get dependencies:
   ```cmd
   flutter pub get
   ```

2. Build for Windows:
   ```cmd
   flutter build windows --release
   ```

3. The executable will be at:
   ```
   build\windows\x64\runner\Release\fluistern_app.exe
   ```

## Running the App

### Option 1: Using the Run Script

Double-click `run.bat` or run from command prompt:

```cmd
run.bat
```

### Option 2: Direct Execution

Navigate to the build folder and run:

```cmd
cd build\windows\x64\runner\Release
fluistern_app.exe
```

### Option 3: Development Mode

For development with hot reload:

```cmd
flutter run -d windows
```

## Distribution

To distribute the app, you need to include these files:

```
fluistern_app.exe
flutter_windows.dll
data/
  icudtl.dat
  app.so
  (other data files)
```

The entire `build\windows\x64\runner\Release\` folder contains everything needed to run the app.

## Troubleshooting

### Flutter Doctor Issues

If `flutter doctor` shows issues:

1. **Visual Studio not found**: Make sure Visual Studio 2022 is installed with C++ tools
2. **Windows SDK missing**: Install Windows 10/11 SDK through Visual Studio Installer
3. **Flutter not in PATH**: Add Flutter bin directory to your System PATH

### Build Errors

If you get CMake errors:
- Make sure Visual Studio 2022 is installed (not 2019)
- Run `flutter doctor -v` to see detailed diagnostics
- Try running Visual Studio once to complete first-time setup

If you get package errors:
- Run `flutter clean`
- Run `flutter pub get`
- Try building again

### Runtime Errors

If the app doesn't start:
- Make sure you have the latest Windows updates
- Try running from command prompt to see error messages
- Check that all DLL files are in the same folder as the .exe

## Features (Windows-Specific)

- ✅ **Global Hotkeys**: Press Ctrl+Shift+R to record from anywhere
- ✅ **Auto-Paste**: Automatically pastes transcriptions into active window
- ✅ **Command Mode**: Voice commands like "summarize", "translate", etc.
- ✅ **Window Management**: Native Windows window controls

## Notes

- The app is currently **focused on Windows** as the primary platform
- Linux builds are supported but require additional dependencies (see README.md)
- macOS support is available but untested
- Android support is planned for future releases

## Getting a Groq API Key

1. Go to https://console.groq.com
2. Sign up for a free account
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key and paste it in the app's Settings screen

The free tier includes generous limits for personal use.
