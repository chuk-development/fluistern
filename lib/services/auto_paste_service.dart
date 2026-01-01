import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:clipboard/clipboard.dart';

// Windows-specific imports
import 'package:win32/win32.dart' if (dart.library.html) '';

class AutoPasteService {
  static final AutoPasteService instance = AutoPasteService._internal();
  AutoPasteService._internal();

  /// Copies text to clipboard and automatically pastes it into the active window
  Future<bool> copyAndPaste(String text) async {
    try {
      // First, copy to clipboard
      await FlutterClipboard.copy(text);

      // Then simulate paste on supported platforms
      if (Platform.isWindows) {
        return await _pasteWindows();
      } else if (Platform.isMacOS) {
        return await _pasteMacOS();
      } else if (Platform.isLinux) {
        return await _pasteLinux();
      }

      // Fallback: just copied to clipboard
      return true;
    } catch (e) {
      debugPrint('Failed to auto-paste: $e');
      return false;
    }
  }

  /// Simulate Ctrl+V on Windows using win32 API
  Future<bool> _pasteWindows() async {
    try {
      // Simulate Ctrl+V keystroke
      // VK_CONTROL = 0x11, VK_V = 0x56

      // Press Ctrl
      keybd_event(VK_CONTROL, 0, KEYEVENTF_EXTENDEDKEY, 0);

      // Press V
      keybd_event(0x56, 0, KEYEVENTF_EXTENDEDKEY, 0);

      // Release V
      keybd_event(0x56, 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0);

      // Release Ctrl
      keybd_event(VK_CONTROL, 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0);

      debugPrint('Auto-paste: Simulated Ctrl+V on Windows');
      return true;
    } catch (e) {
      debugPrint('Failed to simulate paste on Windows: $e');
      return false;
    }
  }

  /// Simulate Cmd+V on macOS
  Future<bool> _pasteMacOS() async {
    try {
      // On macOS, we could use AppleScript or similar
      // For now, just return true (user can paste manually)
      debugPrint('Auto-paste: macOS paste not yet implemented');
      return true;
    } catch (e) {
      debugPrint('Failed to paste on macOS: $e');
      return false;
    }
  }

  /// Simulate Ctrl+V on Linux
  Future<bool> _pasteLinux() async {
    try {
      // On Linux, we could use xdotool or similar
      // For now, just return true (user can paste manually)
      debugPrint('Auto-paste: Linux paste not yet implemented');
      return true;
    } catch (e) {
      debugPrint('Failed to paste on Linux: $e');
      return false;
    }
  }
}
