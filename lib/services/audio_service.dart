import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;

  /// Check if microphone permission is granted
  /// On Linux, we assume permission is granted and handle errors during recording
  Future<bool> hasPermission() async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      // Desktop platforms don't use runtime permissions
      return true;
    }

    // For mobile platforms, check if we can access the recorder
    try {
      return await _recorder.hasPermission();
    } catch (e) {
      return false;
    }
  }

  /// Start recording
  Future<void> startRecording() async {
    // On mobile, check permissions first
    if (Platform.isAndroid || Platform.isIOS) {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }
    }

    final directory = await getTemporaryDirectory();
    _currentRecordingPath =
        '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _currentRecordingPath!,
    );
  }

  /// Stop recording and return the audio file
  Future<File?> stopRecording() async {
    final path = await _recorder.stop();
    if (path == null) return null;

    return File(path);
  }

  /// Check if currently recording
  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  /// Cancel recording without saving
  Future<void> cancelRecording() async {
    await _recorder.stop();
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  /// Clean up temporary files
  Future<void> cleanupTempFiles() async {
    final directory = await getTemporaryDirectory();
    final files = directory.listSync();

    for (final file in files) {
      if (file.path.contains('recording_') && file.path.endsWith('.m4a')) {
        try {
          await file.delete();
        } catch (e) {
          // Ignore errors during cleanup
        }
      }
    }
  }

  void dispose() {
    _recorder.dispose();
  }
}
