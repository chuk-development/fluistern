import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clipboard/clipboard.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/app_provider.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title ?? '');
    _contentController = TextEditingController(text: widget.note.content);

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveNote() async {
    final updatedNote = widget.note.copyWith(
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      content: _contentController.text,
      updatedAt: DateTime.now(),
    );

    await context.read<AppProvider>().updateNote(updatedNote);

    setState(() {
      _hasChanges = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated')),
      );
    }
  }

  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AppProvider>().deleteNote(widget.note.id!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    await context
        .read<AppProvider>()
        .toggleFavorite(widget.note.id!, !widget.note.isFavorite);
    setState(() {});
  }

  void _copyToClipboard() {
    FlutterClipboard.copy(_contentController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'Note'),
        actions: [
          IconButton(
            icon: Icon(
              widget.note.isFavorite ? Icons.star : Icons.star_border,
              color: widget.note.isFavorite ? Colors.amber : null,
            ),
            onPressed: _toggleFavorite,
            tooltip: 'Toggle favorite',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            tooltip: 'Copy',
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _hasChanges ? _saveNote : null,
              tooltip: 'Save',
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit',
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteNote,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing)
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title (optional)',
                  border: OutlineInputBorder(),
                ),
                style: Theme.of(context).textTheme.titleLarge,
              )
            else if (widget.note.title != null)
              Text(
                widget.note.title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            const SizedBox(height: 16),
            Text(
              'Created: ${DateFormat.yMMMd().add_jm().format(widget.note.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            if (widget.note.updatedAt != widget.note.createdAt) ...[
              const SizedBox(height: 4),
              Text(
                'Updated: ${DateFormat.yMMMd().add_jm().format(widget.note.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ],
            const SizedBox(height: 24),
            if (_isEditing)
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                minLines: 10,
                style: Theme.of(context).textTheme.bodyLarge,
              )
            else
              SelectableText(
                widget.note.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
