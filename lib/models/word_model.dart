// Bu dosya bir "kelime"nin nasıl bir yapıda olduğunu tanımlar
// Örnek: { "word": "apple", "level": "A1", "meanings": [...] }

class WordData {
  // Bir kelimenin 3 temel özelliği var:
  final String word; // Kelimenin kendisi (örn: "apple")
  final String level; // Seviyesi (A1, B1, C2 gibi)
  final List<Meaning>
      meanings; // Anlamları (liste halinde, birden fazla olabilir)

  // Constructor (yapıcı metod): Yeni bir WordData oluştururken bu bilgiler gerekli
  WordData({
    required this.word, // required = zorunlu parametre
    required this.level,
    required this.meanings,
  });

  // JSON'dan WordData'ya dönüştürme fonksiyonu
  // JSON = { "word": "apple", "level": "A1", ... } şeklinde veri formatı
  factory WordData.fromJson(Map<String, dynamic> json) {
    return WordData(
      // json['word'] varsa al, yoksa boş string koy
      word: json['word'] ?? '',
      level: json['level'] ?? '',

      // meanings listesini al, her birini Meaning nesnesine çevir
      // Eğer meanings yoksa veya liste değilse, boş liste döndür
      meanings: (json['meanings'] as List<dynamic>?)
              ?.map((m) => Meaning.fromJson(m))
              .toList() ??
          [],
    );
  }
}

// Meaning = Bir kelimenin bir anlamı
// Örnek: "apple" kelimesinin "noun" (isim) anlamı
class Meaning {
  final String partOfSpeech; // Kelime türü (noun, verb, adjective vb.)
  final List<Definition>
      definitions; // Bu anlamın tanımları (birden fazla olabilir)

  Meaning({
    required this.partOfSpeech,
    required this.definitions,
  });

  // JSON'dan Meaning'e dönüştürme
  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'] ?? '',
      definitions: (json['definitions'] as List<dynamic>?)
              ?.map((d) => Definition.fromJson(d))
              .toList() ??
          [],
    );
  }
}

// Definition = Bir anlamın detaylı açıklaması
class Definition {
  final String definition; // Tanım metni
  final String example; // Örnek cümle
  final List<String> synonyms; // Eş anlamlılar

  Definition({
    required this.definition,
    required this.example,
    required this.synonyms,
  });

  // JSON'dan Definition'a dönüştürme
  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'] ?? '',
      example: json['example'] ?? '',
      // synonyms bir liste, her elemanı String'e çevir
      synonyms: (json['synonyms'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
    );
  }
}
