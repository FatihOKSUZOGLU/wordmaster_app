class WordKey {
  final String word;
  final String level;

  const WordKey({required this.word, required this.level});

  /// Unique id for storage & compare
  String get id => '$word|$level';

  Map<String, dynamic> toJson() => {
        'word': word,
        'level': level,
      };

  factory WordKey.fromJson(Map<String, dynamic> json) {
    return WordKey(
      word: (json['word'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
    );
  }

  factory WordKey.fromId(String id) {
    final parts = id.split('|');
    return WordKey(
      word: parts.isNotEmpty ? parts[0] : '',
      level: parts.length > 1 ? parts[1] : '',
    );
  }
}
