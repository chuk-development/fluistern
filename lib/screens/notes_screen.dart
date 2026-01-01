import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:clipboard/clipboard.dart';
import 'dart:io';
import '../providers/app_provider.dart';
import '../models/note.dart';
import '../services/audio_service.dart';
import '../services/groq_api_service.dart';
import '../services/storage_service.dart';
import 'note_detail_screen.dart';

enum RecordingState { idle, recording, processing }

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _audioService = AudioService();
  final _storageService = StorageService();
  final _searchController = TextEditingController();

  RecordingState _recordingState = RecordingState.idle;
  String? _quickNoteText;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Hotkey is handled in AppProvider
  }

  Future<void> _toggleRecording() async {
    if (_recordingState == RecordingState.recording) {
      await _stopRecording();
    } else if (_recordingState == RecordingState.idle) {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _recordingState = RecordingState.recording;
      _error = null;
      _quickNoteText = null;
    });

    try {
      await _audioService.startRecording();
    } catch (e) {
      setState(() {
        _recordingState = RecordingState.idle;
        _error = 'Failed to start recording: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    setState(() {
      _recordingState = RecordingState.processing;
    });

    try {
      final audioFile = await _audioService.stopRecording();
      if (audioFile == null) {
        throw Exception('No audio recorded');
      }

      final apiKey = await _storageService.getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not set');
      }

      final language = await _storageService.getLanguage();
      final groqService = GroqApiService(apiKey);

      String formattedText = await groqService.processAudio(
        audioFile,
        language: language,
      );

      await audioFile.delete();

      // Apply corrections and save note
      if (!mounted) return;

      final provider = context.read<AppProvider>();
      formattedText = await provider.applyCorrections(formattedText);

      final now = DateTime.now();
      final note = Note(
        content: formattedText,
        createdAt: now,
        updatedAt: now,
        language: language,
      );

      await provider.addNote(note);

      setState(() {
        _quickNoteText = formattedText;
        _recordingState = RecordingState.idle;
      });

      await FlutterClipboard.copy(formattedText);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved and copied to clipboard!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _recordingState = RecordingState.idle;
        _error = 'Error: $e';
      });
    }
  }

  Color _getRecordButtonColor() {
    switch (_recordingState) {
      case RecordingState.idle:
        return Colors.blue;
      case RecordingState.recording:
        return Colors.red;
      case RecordingState.processing:
        return Colors.orange;
    }
  }

  IconData _getRecordButtonIcon() {
    switch (_recordingState) {
      case RecordingState.idle:
        return Icons.mic;
      case RecordingState.recording:
        return Icons.stop;
      case RecordingState.processing:
        return Icons.hourglass_empty;
    }
  }

  String _getRecordButtonTooltip() {
    switch (_recordingState) {
      case RecordingState.idle:
        return Platform.isWindows || Platform.isMacOS || Platform.isLinux
            ? 'Record (Ctrl+Shift+R)'
            : 'Tap to record';
      case RecordingState.recording:
        return 'Stop recording';
      case RecordingState.processing:
        return 'Processing...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quick note input area
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'What\'s on your mind today?',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<AppProvider>().loadNotes();
                    },
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Tooltip(
                    message: _getRecordButtonTooltip(),
                    child: Material(
                      color: _getRecordButtonColor(),
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _recordingState != RecordingState.processing
                            ? _toggleRecording
                            : null,
                        customBorder: const CircleBorder(),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(
                            _getRecordButtonIcon(),
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _quickNoteText != null
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _quickNoteText!.length > 100
                                        ? '${_quickNoteText!.substring(0, 100)}...'
                                        : _quickNoteText!,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _error != null
                            ? Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text(
                                'Take a quick note with your voice',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                              ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<AppProvider>().setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    context.read<AppProvider>().setSearchQuery(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.view_list),
                onPressed: () {},
                tooltip: 'View options',
              ),
            ],
          ),
        ),

        // Notes list
        Expanded(
          child: Consumer<AppProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.notes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add_outlined,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.searchQuery.isEmpty
                            ? 'No notes yet'
                            : 'No notes found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.searchQuery.isEmpty
                            ? 'Start by recording your first note'
                            : 'Try a different search term',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.notes.length,
                itemBuilder: (context, index) {
                  final note = provider.notes[index];
                  return _NoteCard(
                    note: note,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailScreen(note: note),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const _NoteCard({
    required this.note,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(date);
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.displayTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(note.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.preview,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.isFavorite) ...[
                const SizedBox(height: 8),
                const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
