import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import '../services/audio_service.dart';
import '../services/groq_api_service.dart';
import '../services/storage_service.dart';
import 'settings_screen.dart';

enum RecordingState { idle, recording, processing }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storageService = StorageService();
  final _audioService = AudioService();

  RecordingState _state = RecordingState.idle;
  String? _formattedText;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    final hasKey = await _storageService.hasApiKey();
    if (!hasKey && mounted) {
      _showSettingsPrompt();
    }
  }

  void _showSettingsPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Key Required'),
        content: const Text(
          'Please set your Groq API key in settings to use Flüstern.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _openSettings();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );

    if (result == true) {
      // Settings were saved, ready to use
    }
  }

  Future<void> _toggleRecording() async {
    if (_state == RecordingState.recording) {
      await _stopRecording();
    } else if (_state == RecordingState.idle) {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _state = RecordingState.recording;
      _error = null;
      _formattedText = null;
    });

    try {
      await _audioService.startRecording();
    } catch (e) {
      setState(() {
        _state = RecordingState.idle;
        _error = 'Failed to start recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _state = RecordingState.processing;
    });

    try {
      final audioFile = await _audioService.stopRecording();
      if (audioFile == null) {
        throw Exception('No audio recorded');
      }

      // Get API key and language
      final apiKey = await _storageService.getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not set');
      }

      final language = await _storageService.getLanguage();

      // Process audio
      final groqService = GroqApiService(apiKey);
      final formattedText = await groqService.processAudio(
        audioFile,
        language: language,
      );

      // Clean up audio file
      await audioFile.delete();

      setState(() {
        _formattedText = formattedText;
        _state = RecordingState.idle;
      });

      // Auto-copy to clipboard
      await FlutterClipboard.copy(formattedText);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text copied to clipboard!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _state = RecordingState.idle;
        _error = 'Error: $e';
      });
    }
  }

  void _copyToClipboard() {
    if (_formattedText != null) {
      FlutterClipboard.copy(_formattedText!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Color _getRecordButtonColor() {
    switch (_state) {
      case RecordingState.idle:
        return Colors.blue;
      case RecordingState.recording:
        return Colors.red;
      case RecordingState.processing:
        return Colors.orange;
    }
  }

  IconData _getRecordButtonIcon() {
    switch (_state) {
      case RecordingState.idle:
        return Icons.mic;
      case RecordingState.recording:
        return Icons.stop;
      case RecordingState.processing:
        return Icons.hourglass_empty;
    }
  }

  String _getStatusText() {
    switch (_state) {
      case RecordingState.idle:
        return 'Tap to record';
      case RecordingState.recording:
        return 'Recording... Tap to stop';
      case RecordingState.processing:
        return 'Processing...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flüstern'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Record Button
              GestureDetector(
                onTap: _state != RecordingState.processing
                    ? _toggleRecording
                    : null,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getRecordButtonColor(),
                    boxShadow: [
                      BoxShadow(
                        color: _getRecordButtonColor().withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getRecordButtonIcon(),
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Status Text
              Text(
                _getStatusText(),
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 48),

              // Error Display
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Formatted Text Display
              if (_formattedText != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Result',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: _copyToClipboard,
                            tooltip: 'Copy',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        _formattedText!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
