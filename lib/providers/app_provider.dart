import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../models/note.dart';
import '../models/correction.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../services/filler_filter_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final StorageService _storage = StorageService();
  final FillerFilterService _fillerFilter = FillerFilterService.instance;

  List<Note> _notes = [];
  List<Correction> _corrections = [];
  String _searchQuery = '';
  bool _isLoading = false;
  HotKey? _recordHotKey;

  List<Note> get notes => _notes;
  List<Correction> get corrections => _corrections;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  HotKey? get recordHotKey => _recordHotKey;

  Future<void> initialize() async {
    await loadNotes();
    await loadCorrections();
    await _initializeHotKey();
  }

  // Notes methods
  Future<void> loadNotes({String? query}) async {
    _isLoading = true;
    notifyListeners();

    _searchQuery = query ?? '';
    _notes = await _db.getNotes(searchQuery: _searchQuery);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await _db.insertNote(note);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await _db.updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await _db.deleteNote(id);
    await loadNotes();
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    await _db.toggleFavorite(id, isFavorite);
    await loadNotes();
  }

  Future<void> togglePin(int id, bool isPinned) async {
    await _db.togglePin(id, isPinned);
    await loadNotes();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadNotes(query: query);
  }

  // Filler filtering
  Future<String> applyFillerFilter(String text, String language) async {
    final isEnabled = await _storage.getFillerFilterEnabled();
    if (!isEnabled) return text;
    return _fillerFilter.filterFillers(text, language: language);
  }

  // Corrections methods
  Future<void> loadCorrections() async {
    _corrections = await _db.getCorrections();
    notifyListeners();
  }

  Future<void> addCorrection(Correction correction) async {
    await _db.insertCorrection(correction);
    await loadCorrections();
  }

  Future<void> deleteCorrection(int id) async {
    await _db.deleteCorrection(id);
    await loadCorrections();
  }

  Future<String> applyCorrections(String text) async {
    return await _db.applyCorrections(text);
  }

  // Hotkey methods
  Future<void> _initializeHotKey() async {
    // Check if hotkeys are enabled in settings
    final hotkeysEnabled = await _storage.getHotkeysEnabled();
    if (!hotkeysEnabled) {
      debugPrint('Hotkeys disabled in settings');
      return;
    }

    // Only initialize on desktop platforms
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return;
    }

    try {
      // Default hotkey: Ctrl+Shift+R (Cmd+Shift+R on macOS)
      _recordHotKey = HotKey(
        key: LogicalKeyboardKey.keyR,
        modifiers: [HotKeyModifier.control, HotKeyModifier.shift],
        scope: HotKeyScope.system,
      );

      await hotKeyManager.register(
        _recordHotKey!,
        keyDownHandler: (hotKey) {
          debugPrint('Hotkey pressed: ${hotKey.toJson()}');
        },
      );
    } catch (e) {
      debugPrint('Failed to register hotkey: $e');
    }
  }

  Future<void> updateHotKey(HotKey newHotKey) async {
    if (_recordHotKey != null) {
      try {
        await hotKeyManager.unregister(_recordHotKey!);
      } catch (e) {
        debugPrint('Failed to unregister old hotkey: $e');
      }
    }

    try {
      await hotKeyManager.register(newHotKey);
      _recordHotKey = newHotKey;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to register new hotkey: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    if (_recordHotKey != null) {
      try {
        hotKeyManager.unregister(_recordHotKey!);
      } catch (e) {
        debugPrint('Failed to unregister hotkey: $e');
      }
    }
    super.dispose();
  }
}
