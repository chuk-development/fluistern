# Flüstern

> Cross-platform voice dictation app using Groq Whisper API

A modern, lightweight voice-to-text app built with Flutter that works on Windows, macOS, Linux, and Android. Uses Groq's Whisper API for transcription and LLM for intelligent text formatting.

## Features

- **🎤 Voice Dictation** - Record and transcribe speech to text with a single click or hotkey
- **⌨️ Global Keyboard Shortcuts** - Start/stop recording from anywhere with Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (macOS)
- **📝 Notes History** - All transcriptions are automatically saved with full editing capabilities
- **🔍 Search & Filter** - Quickly find notes with powerful search
- **✏️ Rich Note Editor** - Edit, favorite, and organize your notes
- **📖 Custom Dictionary** - Add corrections to auto-fix common transcription mistakes
- **🤖 Smart Formatting** - Automatic punctuation, capitalization, and paragraph breaks
- **🗣️ Voice Commands** - "Absatz" for paragraphs, "in Anführungszeichen" for quotes, etc.
- **🌍 Multi-Language** - Supports German, English, Spanish, French, Italian, and Portuguese
- **📋 Auto-Copy** - Automatically copies formatted text to clipboard
- **🎨 Modern UI** - WhisperFlow-inspired interface with sidebar navigation
- **🌓 Dark Mode** - Automatic dark/light theme support
- **📱 Cross-Platform** - Works on Windows, macOS, Linux, and Android

## Installation

### Prerequisites

- Flutter SDK 3.38.0 or higher
- Groq API key (get one free at [console.groq.com](https://console.groq.com))

#### Linux System Dependencies

On Linux, install keybinder for global keyboard shortcuts:

```bash
# Arch Linux
sudo pacman -S keybinder3

# Ubuntu/Debian
sudo apt-get install libkeybinder-3.0-dev

# Fedora
sudo dnf install keybinder3-devel
```

### Quick Start

```bash
# Clone the repository
git clone https://github.com/chuk-development/fluistern.git
cd fluistern

# Install dependencies
flutter pub get

# Run on your platform
flutter run  # Auto-detects platform
```

### Platform-Specific

```bash
# Linux
flutter run -d linux

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Android (connect device or start emulator first)
flutter run -d android
```

## Setup

1. Launch the app
2. Tap the ⚙️ Settings icon
3. Enter your Groq API key
4. Select your preferred language
5. Tap "Save Settings"

## Usage

1. Tap the large blue microphone button to start recording
2. Speak your text
3. Tap the red stop button when done
4. The app will:
   - Transcribe your speech using Whisper
   - Format it with intelligent punctuation and capitalization
   - Automatically copy it to your clipboard

### Voice Commands

While dictating, you can use these commands:

- **"Absatz"** / **"Paragraph"** - Insert paragraph break
- **"in Anführungszeichen"** - Quote the previous word/phrase
- **"Komma"** - Insert comma
- **"Punkt"** - Insert period
- **"Fragezeichen"** - Insert question mark
- **"Ausrufezeichen"** - Insert exclamation mark

## How It Works

```
Recording → Whisper API (transcription) → LLM (formatting) → Clipboard
```

1. **Record**: Audio is recorded in m4a format (16kHz, mono)
2. **Transcribe**: Groq's Whisper API converts speech to text
3. **Format**: LLM adds punctuation, capitalization, and handles voice commands
4. **Copy**: Formatted text is copied to clipboard automatically

## Building

### Linux

```bash
flutter build linux --release
```

Binary will be in `build/linux/x64/release/bundle/`

### Windows

```bash
flutter build windows --release
```

### Android APK

```bash
flutter build apk --release
```

APK will be in `build/app/outputs/flutter-apk/`

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   ├── home_screen.dart      # Main recording interface
│   └── settings_screen.dart  # API key & language settings
└── services/
    ├── audio_service.dart    # Audio recording
    ├── groq_api_service.dart # Whisper & LLM integration
    └── storage_service.dart  # Settings persistence
```

## Related Projects

- [fluistern](https://github.com/chukfinley/fluistern) - Original Linux-only version (Bash)

## License

MIT

## Credits

- [Groq](https://groq.com) - Fast Whisper API & LLM
- [Flutter](https://flutter.dev) - Cross-platform framework
