class Note {
  final int? id;
  final String? title;
  final String content;
  final String? rawTranscription;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? language;
  final bool isFavorite;
  final bool isPinned;

  Note({
    this.id,
    this.title,
    required this.content,
    this.rawTranscription,
    required this.createdAt,
    required this.updatedAt,
    this.language,
    this.isFavorite = false,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'raw_transcription': rawTranscription,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'language': language,
      'is_favorite': isFavorite ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String?,
      content: map['content'] as String,
      rawTranscription: map['raw_transcription'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      language: map['language'] as String?,
      isFavorite: (map['is_favorite'] as int?) == 1,
      isPinned: (map['is_pinned'] as int?) == 1,
    );
  }

  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? rawTranscription,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? language,
    bool? isFavorite,
    bool? isPinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      rawTranscription: rawTranscription ?? this.rawTranscription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      language: language ?? this.language,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  String get preview {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  String get displayTitle {
    if (title != null && title!.isNotEmpty) return title!;
    // Use first line of content as title
    final firstLine = content.split('\n').first;
    if (firstLine.length <= 50) return firstLine;
    return '${firstLine.substring(0, 50)}...';
  }
}
