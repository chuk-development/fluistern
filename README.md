# Flüstern

> Advanced voice dictation app with AI-powered formatting, command mode, and auto-paste

A modern, feature-rich voice-to-text app built with Flutter. **Optimized for Windows** with support for macOS and Linux. Uses Groq's Whisper API for transcription and LLaMA 3.3 for intelligent text formatting.

## ✨ Features

### Core Features
- **🎤 Voice Dictation** - Record and transcribe speech to text instantly
- **⌨️ Global Keyboard Shortcuts** - Start/stop recording from anywhere with Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (macOS)
- **📝 Notes History** - All transcriptions are automatically saved with full editing capabilities
- **🔍 Search & Filter** - Quickly find notes with powerful search
- **✏️ Rich Note Editor** - Edit, favorite, pin, and organize your notes
- **📖 Custom Dictionary** - Add corrections to auto-fix common transcription mistakes

### Advanced Features (NEW!)
- **🚀 Auto-Paste** - Automatically pastes transcription into active window (Windows)
- **🎯 Command Mode** - Use voice commands to manipulate text:
  - "Fasse zusammen" / "Summarize" - Summarize text
  - "Übersetze nach Englisch" / "Translate to English" - Translate
  - "Lösche den letzten Satz" / "Delete last sentence" - Delete
  - "Kürze das" / "Shorten" - Make text shorter
  - "Erweitere das" / "Expand" - Add more details
  - "Mach das formal" / "Make formal" - Rewrite formally
  - "Korrigiere" / "Fix grammar" - Fix grammar mistakes
- **🧹 Filler Word Filtering** - Automatically removes "vielen Dank", "äh", "um", etc.
- **📌 Note Pinning** - Pin important notes to the top
- **⭐ Favorites** - Mark notes as favorites for quick access

### Smart Features
- **🤖 AI Formatting** - Automatic punctuation, capitalization, and paragraph breaks
- **🗣️ Voice Commands** - "Absatz" for paragraphs, "in Anführungszeichen" for quotes, etc.
- **🌍 Multi-Language** - Supports German, English, Spanish, French, Italian, and Portuguese
- **📋 Clipboard Integration** - Automatically copies formatted text to clipboard
- **🎨 Modern UI** - WhisperFlow-inspired interface with sidebar navigation
- **🌓 Dark Mode** - Automatic dark/light theme support

## 🚀 Quick Start (Windows)

### 1. Prerequisites
- **Flutter SDK** - [Download and install](https://flutter.dev/docs/get-started/install/windows)
- **Visual Studio 2022** with "Desktop development with C++" workload
- **Groq API Key** - Free at [console.groq.com](https://console.groq.com)

### 2. Build & Run

**Easiest way** - just double-click `build.bat`!

Or manually:
```cmd
flutter pub get
flutter build windows --release
```

The executable will be at `build\windows\x64\runner\Release\fluistern_app.exe`

**📖 See [WINDOWS_BUILD.md](WINDOWS_BUILD.md) for detailed Windows build instructions**

### 3. Setup
1. Launch the app
2. Go to Settings (⚙️ icon in sidebar)
3. Enter your Groq API key
4. Select your preferred language
5. Configure features (Auto-Paste, Command Mode, etc.)
6. Click "Save Settings"

## 📖 Usage

### Basic Dictation
1. Click the blue microphone button (or press Ctrl+Shift+R)
2. Speak your text
3. Click the red stop button when done
4. The app will:
   - Transcribe your speech using Whisper
   - Format it with AI
   - Apply corrections from your dictionary
   - Filter out filler words (if enabled)
   - Save as a note
   - Copy to clipboard (or auto-paste if enabled)

### Command Mode
Say commands during or after dictation:

**German Commands:**
- "Fasse zusammen" - Summarize the text
- "Übersetze nach Englisch" - Translate to English
- "Lösche den letzten Satz" - Delete last sentence
- "Kürze das" - Make shorter
- "Erweitere das" - Add more details
- "Mach das formal" - Rewrite formally
- "Mach das informell" - Rewrite casually
- "Korrigiere" - Fix grammar

**English Commands:**
- "Summarize" - Summarize the text
- "Translate to German" - Translate to German
- "Delete last sentence" - Delete last sentence
- "Shorten" - Make shorter
- "Expand" - Add more details
- "Make formal" - Rewrite formally
- "Make informal" - Rewrite casually
- "Fix grammar" - Fix grammar

### Voice Formatting Commands
- "Absatz" / "Paragraph" - Insert paragraph break
- "in Anführungszeichen" - Quote the previous word/phrase
- "Komma" - Insert comma
- "Punkt" - Insert period
- "Fragezeichen" - Insert question mark
- "Ausrufezeichen" - Insert exclamation mark

### Auto-Paste (Windows Only)
When enabled in Settings, transcriptions are automatically pasted into your active window:
1. Have any app open (Word, Slack, Email, etc.)
2. Press Ctrl+Shift+R to record
3. Speak and stop recording
4. Text is automatically pasted into your app!

### Managing Notes
- **Search** - Type in the search bar to find notes
- **Edit** - Click any note to view and edit
- **Pin** - Click the pin icon to pin notes to the top
- **Favorite** - Click the star icon to mark as favorite
- **Delete** - Click the trash icon to delete a note
- **Copy** - Click the copy icon to copy note content

### Custom Dictionary
1. Go to Dictionary screen (📖 icon in sidebar)
2. Click the + button to add a correction
3. Enter the wrong text (e.g., "teh")
4. Enter the correct text (e.g., "the")
5. All future transcriptions will auto-correct!

## 🛠️ Installation & Building

### Windows (Primary Platform)

**See [WINDOWS_BUILD.md](WINDOWS_BUILD.md) for complete Windows instructions**

Quick build:
```cmd
flutter pub get
flutter build windows --release
```

Or use the build script:
```cmd
build.bat
```

### Linux

**System Dependencies** (required for building):
```bash
# Ubuntu/Debian/Linux Mint
sudo apt-get update
sudo apt-get install build-essential lld libkeybinder-3.0-dev

# Arch Linux
sudo pacman -S base-devel lld keybinder3

# Fedora
sudo dnf install gcc-c++ lld keybinder3-devel
```

**Note:** If you don't want to use global hotkeys on Linux (e.g., your window manager doesn't support keybinder3), you can disable them in Settings after building.

Build:
```bash
flutter pub get
flutter build linux --release
```

Binary will be in `build/linux/x64/release/bundle/`

### macOS

```bash
flutter pub get
flutter build macos --release
```

**Note:** macOS builds are supported but untested. Auto-paste is not yet implemented for macOS.

## ⚙️ Settings

### API Configuration
- **Groq API Key** - Your API key from console.groq.com
- **Language** - Select transcription language (German, English, Spanish, French, Italian, Portuguese)

### Advanced Features
- **Auto-Paste** - Automatically paste into active window (Windows only)
- **Command Mode** - Enable voice commands for text manipulation
- **Filler Word Filtering** - Remove common filler words from transcriptions

### Keyboard Shortcuts
- **Enable Global Hotkeys** - Allow Ctrl+Shift+R from anywhere
  - Disable this on Linux if keybinder3 is not available

## 🏗️ How It Works

```
Recording → Whisper API → LLM Formatting → Corrections → Filler Filtering → Command Mode → Auto-Paste
```

1. **Record**: Audio is recorded in m4a format (16kHz, mono)
2. **Transcribe**: Groq's Whisper API converts speech to text
3. **Format**: LLaMA 3.3 70B adds punctuation, capitalization, and handles voice commands
4. **Correct**: Custom dictionary applies your corrections
5. **Filter**: Remove filler words (if enabled)
6. **Command**: Execute voice commands (if enabled)
7. **Paste**: Auto-paste into active window (if enabled) or copy to clipboard

## 📁 Project Structure

```
lib/
├── main.dart                      # App entry point
├── screens/
│   ├── main_layout.dart           # Navigation sidebar
│   ├── notes_screen.dart          # Main recording & notes list
│   ├── note_detail_screen.dart    # Note editor
│   ├── dictionary_screen.dart     # Corrections management
│   └── settings_screen.dart       # Settings & configuration
├── services/
│   ├── audio_service.dart         # Audio recording
│   ├── groq_api_service.dart      # Whisper & LLM integration
│   ├── storage_service.dart       # Settings persistence
│   ├── database_service.dart      # SQLite database
│   ├── filler_filter_service.dart # Filler word removal
│   ├── auto_paste_service.dart    # Auto-paste functionality
│   └── command_mode_service.dart  # Voice command processing
├── models/
│   ├── note.dart                  # Note data model
│   └── correction.dart            # Correction data model
└── providers/
    └── app_provider.dart          # State management
```

## 🐛 Troubleshooting

### Windows
- **Build fails**: Make sure Visual Studio 2022 is installed with C++ tools
- **App doesn't start**: Run from command prompt to see error messages
- **Auto-paste doesn't work**: Make sure Auto-Paste is enabled in Settings

### Linux
- **CMake error about keybinder-3.0**: Install libkeybinder-3.0-dev (see Installation section)
- **ld.lld not found**: Install lld and build-essential packages
- **Hotkeys don't work**: Disable global hotkeys in Settings

### General
- **"API key not set" error**: Go to Settings and enter your Groq API key
- **Transcription is inaccurate**: Try speaking more clearly, or adjust microphone settings
- **Commands not working**: Make sure Command Mode is enabled in Settings

## 🗺️ Roadmap

- [ ] macOS auto-paste support
- [ ] Android version
- [ ] Custom hotkey configuration
- [ ] Export notes to various formats (PDF, Markdown, etc.)
- [ ] Voice text selection ("mark last sentence", "copy that", etc.)
- [ ] Cloud sync
- [ ] Multiple language support in single session
- [ ] Offline mode with local Whisper

## 📜 License

MIT

## 🙏 Credits

- [Groq](https://groq.com) - Fast Whisper API & LLaMA inference
- [Flutter](https://flutter.dev) - Cross-platform framework
- Inspired by [WhisperFlow](https://github.com/BerriAI/WhisperFlow)

## 🔗 Related Projects

- [fluistern](https://github.com/chukfinley/fluistern) - Original Linux-only version (Bash/Python)

---

**Made with ❤️ for productive voice dictation**
