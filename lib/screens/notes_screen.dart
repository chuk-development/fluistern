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
import '../services/auto_paste_service.dart';
import '../services/command_mode_service.dart';
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

      // Apply corrections, filler filtering, and save note
      if (!mounted) return;

      final provider = context.read<AppProvider>();
      formattedText = await provider.applyCorrections(formattedText);
      formattedText = await provider.applyFillerFilter(formattedText, language);

      // Check for command mode (if enabled)
      final commandModeEnabled = await _storageService.getCommandModeEnabled();
      if (commandModeEnabled) {
        final commandService = CommandModeService.instance;
        final parsed = commandService.parseCommand(formattedText);

        if (parsed.command != CommandType.none) {
          // Execute the command
          formattedText = await commandService.processCommand(
            text: parsed.cleanedText,
            command: parsed.command,
            apiKey: apiKey,
            targetLanguage: language == 'de' ? 'English' : 'German',
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Command executed: ${commandService.getCommandName(parsed.command)}'),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }

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

      // Auto-paste into active window (if enabled)
      final autoPasteEnabled = await _storageService.getAutoPasteEnabled();
      bool autoPasted = false;

      if (autoPasteEnabled) {
        autoPasted =
            await AutoPasteService.instance.copyAndPaste(formattedText);
      } else {
        // Just copy to clipboard
        await FlutterClipboard.copy(formattedText);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(autoPasted
                ? 'Note saved and pasted!'
                : 'Note saved and copied to clipboard!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
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
        return const Color(0xFF6366F1); // Indigo
      case RecordingState.recording:
        return const Color(0xFFEF4444); // Red
      case RecordingState.processing:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  List<Color> _getRecordButtonGradient() {
    switch (_recordingState) {
      case RecordingState.idle:
        return [
          const Color(0xFF6366F1), // Indigo
          const Color(0xFF8B5CF6), // Purple
        ];
      case RecordingState.recording:
        return [
          const Color(0xFFEF4444), // Red
          const Color(0xFFF97316), // Orange
        ];
      case RecordingState.processing:
        return [
          const Color(0xFFF59E0B), // Amber
          const Color(0xFFEAB308), // Yellow
        ];
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
        // Modern recording header
        Container(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voice Dictation',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Click to start recording or press Ctrl+Shift+R',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () {
                      context.read<AppProvider>().loadNotes();
                    },
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Modern record button
              Row(
                children: [
                  GestureDetector(
                    onTap: _recordingState != RecordingState.processing
                        ? _toggleRecording
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getRecordButtonGradient(),
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _getRecordButtonColor().withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getRecordButtonIcon(),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _quickNoteText != null
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF10B981).withValues(alpha: 0.1),
                                  const Color(0xFF059669).withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _quickNoteText!.length > 100
                                        ? '${_quickNoteText!.substring(0, 100)}...'
                                        : _quickNoteText!,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _error != null
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFEF4444).withValues(alpha: 0.1),
                                      const Color(0xFFDC2626).withValues(alpha: 0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.error_outline_rounded,
                                          color: Colors.white, size: 16),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: const Color(0xFFDC2626),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Row(
                                children: [
                                  Icon(
                                    Icons.mic_none_rounded,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Ready to capture your voice',
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
                                ],
                              ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
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
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: note.isPinned
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (note.isPinned || note.isFavorite) ...[
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: note.isPinned
                              ? colorScheme.primary.withValues(alpha: 0.1)
                              : const Color(0xFFFBBF24).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          note.isPinned ? Icons.push_pin_rounded : Icons.star_rounded,
                          size: 14,
                          color: note.isPinned ? colorScheme.primary : const Color(0xFFFBBF24),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        note.displayTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatDate(note.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  note.preview,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
