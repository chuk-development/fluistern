import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import '../models/correction.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._internal();

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize FFI for desktop platforms
    if (Platform.isLinux || Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'fluistern.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Notes table
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT NOT NULL,
        raw_transcription TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        language TEXT,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // Corrections/dictionary table
    await db.execute('''
      CREATE TABLE corrections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wrong_text TEXT NOT NULL UNIQUE,
        correct_text TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        usage_count INTEGER DEFAULT 0
      )
    ''');

    // Index for search
    await db.execute(
      'CREATE INDEX idx_notes_content ON notes(content)',
    );
    await db.execute(
      'CREATE INDEX idx_notes_created ON notes(created_at DESC)',
    );
  }

  // Notes operations
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotes({String? searchQuery, int? limit}) async {
    final db = await database;

    String where = '';
    List<dynamic> whereArgs = [];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      where = 'WHERE content LIKE ? OR title LIKE ?';
      whereArgs = ['%$searchQuery%', '%$searchQuery%'];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: where.isEmpty ? null : where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<Note?> getNote(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'notes',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Corrections operations
  Future<int> insertCorrection(Correction correction) async {
    final db = await database;
    return await db.insert(
      'corrections',
      correction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Correction>> getCorrections() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'corrections',
      orderBy: 'usage_count DESC, wrong_text ASC',
    );

    return List.generate(maps.length, (i) => Correction.fromMap(maps[i]));
  }

  Future<int> deleteCorrection(int id) async {
    final db = await database;
    return await db.delete(
      'corrections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementCorrectionUsage(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE corrections SET usage_count = usage_count + 1 WHERE id = ?',
      [id],
    );
  }

  Future<String> applyCorrections(String text) async {
    final corrections = await getCorrections();
    String correctedText = text;

    for (final correction in corrections) {
      correctedText = correctedText.replaceAll(
        RegExp(correction.wrongText, caseSensitive: false),
        correction.correctText,
      );
      if (correctedText != text) {
        await incrementCorrectionUsage(correction.id!);
      }
    }

    return correctedText;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
