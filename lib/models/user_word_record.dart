class UserWordRecord {
  final String word;
  final String level;
  final DateTime timestamp; // Ne zaman eklendiği (sıralama için)

  UserWordRecord({
    required this.word,
    required this.level,
    required this.timestamp,
  });

  // JSON'a çevir (SharedPreferences için)
  Map<String, dynamic> toJson() => {
        'word': word,
        'level': level,
        'timestamp': timestamp.toIso8601String(),
      };

  // JSON'dan oluştur
  factory UserWordRecord.fromJson(Map<String, dynamic> json) {
    return UserWordRecord(
      word: json['word'] ?? '',
      level: json['level'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Benzersiz anahtar (word + level)
  String get key => '$word|$level';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserWordRecord &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
}
