class WordData {
  final String word;
  final String level;
  final List<Meaning> meanings;

  WordData({required this.word, required this.level, required this.meanings});

  factory WordData.fromJson(Map<String, dynamic> json) {
    return WordData(
      word: json['word'] ?? '',
      level: json['level'] ?? 'A1',
      meanings: (json['meanings'] as List<dynamic>? ?? [])
          .map((m) => Meaning.fromJson(m))
          .toList(),
    );
  }
}

class Meaning {
  final String? partOfSpeech;
  final List<Definition> definitions; // Liste olarak güncellendi

  Meaning({this.partOfSpeech, required this.definitions});

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'],
      definitions: (json['definitions'] as List<dynamic>? ?? [])
          .map((d) => Definition.fromJson(d))
          .toList(),
    );
  }
}

class Definition {
  final String definition;
  final String? example;
  final List<String>? synonyms;

  Definition({required this.definition, this.example, this.synonyms});

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'] ?? '',
      example: json['example'],
      synonyms: (json['synonyms'] as List<dynamic>?)
          ?.map((s) => s.toString())
          .toList(),
    );
  }
}
