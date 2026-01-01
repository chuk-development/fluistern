# Flüstern Project - Claude Knowledge Base

This file contains essential information about the Flüstern project for future Claude Code sessions.

## Project Overview

**Flüstern** is a cross-platform voice dictation app with AI-powered formatting and intelligent features.

- **Primary Platform**: Windows (optimized for Windows users)
- **Supported Platforms**: Windows, macOS, Linux
- **Tech Stack**: Flutter 3.27.1, Dart, Groq API (Whisper + LLaMA 3.3)
- **Repository**: https://github.com/chuk-development/fluistern

## Key Features

### Core
- Voice recording and transcription (Groq Whisper API)
- AI-powered text formatting (LLaMA 3.3 70B)
- Notes history with SQLite database
- Custom dictionary for auto-corrections
- Filler word filtering (German & English)
- Note pinning and favorites
- Search functionality

### Advanced
- **Auto-Paste** (Windows): Automatically pastes transcriptions into active window
- **Command Mode**: Voice commands for text manipulation
  - Summarize, translate, delete, shorten, expand, format, fix grammar
  - Supports German and English commands
- **Global Hotkeys**: Ctrl+Shift+R (Windows/Linux) / Cmd+Shift+R (macOS)
- **Filler Filtering**: Removes "vielen Dank", "äh", "um", etc.

## Architecture

### Directory Structure
```
lib/
├── main.dart                      # App entry + theme
├── screens/
│   ├── main_layout.dart           # Sidebar navigation
│   ├── notes_screen.dart          # Recording + notes list
│   ├── note_detail_screen.dart    # Note editor
│   ├── dictionary_screen.dart     # Corrections management
│   └── settings_screen.dart       # Settings
├── services/
│   ├── audio_service.dart         # Audio recording
│   ├── groq_api_service.dart      # API integration
│   ├── storage_service.dart       # SharedPreferences
│   ├── database_service.dart      # SQLite
│   ├── filler_filter_service.dart # Filler word removal
│   ├── auto_paste_service.dart    # Auto-paste
│   └── command_mode_service.dart  # Voice commands
├── models/
│   ├── note.dart
│   └── correction.dart
└── providers/
    └── app_provider.dart          # State management
```

### Key Dependencies
```yaml
dependencies:
  record: ^6.1.0          # Audio recording
  http: ^1.2.0            # Groq API
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0         # Database
  sqflite_common_ffi: ^2.3.0
  provider: ^6.1.1        # State management
  hotkey_manager: ^0.2.3  # Global shortcuts
  window_manager: ^0.3.7
  clipboard: ^0.1.3
  intl: ^0.19.0
  win32: ^5.5.0           # Windows APIs
```

## Design System

### Colors
- **Primary**: #6366F1 (Indigo)
- **Secondary**: #8B5CF6 (Purple)
- **Tertiary**: #06B6D4 (Cyan)
- **Success**: #10B981 (Emerald)
- **Error**: #EF4444 (Red)
- **Warning**: #F59E0B (Amber)

### Typography
- **Font weights**: Regular (400), Medium (500), Semi-Bold (600), Bold (700)
- **Border radius**: 16px for cards, 12px for buttons
- **Spacing**: 24-32px for main padding

### Components
- Gradient sidebar (280px width)
- Modern gradient buttons with shadows
- Card-based UI with subtle shadows
- Smooth animations (300ms transitions)
- Glassmorphism effects

## Development

### Building

**Windows** (Primary):
```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/fluistern_app.exe
```

**macOS**:
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/fluistern_app.app
```

**Linux** (requires dependencies):
```bash
# Install dependencies first
sudo apt-get install build-essential lld libkeybinder-3.0-dev

flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

### Testing
```bash
flutter run -d windows  # or -d macos, -d linux
```

### Platform-Specific Notes

**Linux**:
- Requires keybinder3 for hotkeys (can be disabled in Settings)
- Requires lld and build-essential
- Linux Mint users may need to disable hotkeys

**Windows**:
- Auto-paste uses win32 API (partially implemented)
- Hotkeys work out of the box
- Primary development platform

**macOS**:
- Auto-paste not yet implemented
- Hotkeys supported
- Builds work but untested

## Database Schema

### Notes Table
```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  content TEXT NOT NULL,
  raw_transcription TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  language TEXT,
  is_favorite INTEGER DEFAULT 0,
  is_pinned INTEGER DEFAULT 0
)
```

### Corrections Table
```sql
CREATE TABLE corrections (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  wrong_text TEXT NOT NULL UNIQUE,
  correct_text TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  usage_count INTEGER DEFAULT 0
)
```

## API Integration

### Groq API
- **Whisper**: `whisper-large-v3-turbo` for transcription
- **LLM**: `llama-3.3-70b-versatile` for formatting and commands
- **Endpoints**:
  - Transcription: `https://api.groq.com/openai/v1/audio/transcriptions`
  - Chat: `https://api.groq.com/openai/v1/chat/completions`

### System Prompt (Formatting)
The LLM uses a detailed system prompt that:
- Adds punctuation and capitalization
- Keeps related sentences in single paragraphs
- Handles voice formatting commands ("Absatz", "Komma", etc.)
- Preserves original meaning without summarizing
- Does NOT follow content commands (only formatting commands)

## Release Process

### Creating a Release
1. Update version in `pubspec.yaml`
2. Commit: `git commit -m "Bump version to X.Y.Z"`
3. Tag: `git tag vX.Y.Z`
4. Push: `git push origin vX.Y.Z`
5. GitHub Actions builds and releases automatically

See [BUILD_RELEASE.md](BUILD_RELEASE.md) for details.

### GitHub Actions Workflow
- **Trigger**: Tags matching `v*.*.*`
- **Jobs**: Windows, macOS, Linux builds
- **Output**: ZIP/tar.gz files uploaded to GitHub Releases
- **File**: `.github/workflows/release.yml`

## Common Issues & Solutions

### Build Errors

**Linux - keybinder missing**:
```bash
sudo apt-get install libkeybinder-3.0-dev
```

**Linux - lld not found**:
```bash
sudo apt-get install lld build-essential
```

**Windows - Visual Studio required**:
- Install Visual Studio 2022 with "Desktop development with C++"

### Runtime Errors

**API key not set**:
- User needs to enter Groq API key in Settings

**Hotkeys don't work**:
- Check if hotkeys are enabled in Settings
- Linux: may need keybinder3 installed

**Auto-paste doesn't work**:
- Currently only partially implemented for Windows
- Falls back to clipboard copy

## User Configuration

Settings stored in SharedPreferences:
- `groq_api_key`: Groq API key
- `language`: Transcription language (de, en, es, fr, it, pt)
- `hotkeys_enabled`: Global hotkeys toggle
- `filler_filter_enabled`: Filler word filtering toggle
- `auto_paste_enabled`: Auto-paste toggle
- `command_mode_enabled`: Voice commands toggle

## Future Improvements

Potential features (not yet implemented):
- Voice text selection ("mark last sentence", "copy that")
- Contextual intelligence (adapt to active app)
- macOS auto-paste implementation
- Android version
- Cloud sync
- Custom hotkey configuration
- Export to PDF/Markdown

## Important Notes

- **Windows is the primary platform** - optimize for Windows first
- **UI is modern** - Indigo/Purple gradient theme, glassmorphism
- **Auto-paste is TODO** - Currently just copies to clipboard
- **User prefers German** - But app supports English too
- **Keep it simple** - Don't over-engineer solutions

## Contact & Links

- **GitHub**: https://github.com/chuk-development/fluistern
- **Original Project**: https://github.com/chukfinley/fluistern (Bash/Python version)
- **Inspired by**: WhisperFlow

---

**Last Updated**: 2026-01-01 (after complete UI redesign)
