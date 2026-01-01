class Correction {
  final int? id;
  final String wrongText;
  final String correctText;
  final DateTime createdAt;
  final int usageCount;

  Correction({
    this.id,
    required this.wrongText,
    required this.correctText,
    required this.createdAt,
    this.usageCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wrong_text': wrongText,
      'correct_text': correctText,
      'created_at': createdAt.millisecondsSinceEpoch,
      'usage_count': usageCount,
    };
  }

  factory Correction.fromMap(Map<String, dynamic> map) {
    return Correction(
      id: map['id'] as int?,
      wrongText: map['wrong_text'] as String,
      correctText: map['correct_text'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      usageCount: (map['usage_count'] as int?) ?? 0,
    );
  }

  Correction copyWith({
    int? id,
    String? wrongText,
    String? correctText,
    DateTime? createdAt,
    int? usageCount,
  }) {
    return Correction(
      id: id ?? this.id,
      wrongText: wrongText ?? this.wrongText,
      correctText: correctText ?? this.correctText,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
