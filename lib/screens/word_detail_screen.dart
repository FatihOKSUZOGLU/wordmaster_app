import 'package:flutter/material.dart';
import '../models/word_model.dart';

class WordDetailScreen extends StatelessWidget {
  final WordData word;

  const WordDetailScreen({Key? key, required this.word}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(word.word, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık Kartı
            _buildHeader(),
            const SizedBox(height: 30),
            const Text('Meanings',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Anlamlar Listesi
            ...word.meanings
                .map((meaning) => _buildMeaningCard(meaning))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.blue.withOpacity(0.2),
          Colors.purple.withOpacity(0.2)
        ]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(word.word,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20)),
            child: Text(word.level,
                style: const TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningCard(Meaning meaning) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İsim/Fiil Etiketi
          if (meaning.partOfSpeech != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(meaning.partOfSpeech!.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 12),

          // Definitions Listesi (İç içe döngü)
          ...meaning.definitions
              .map((def) => _buildDefinitionItem(def))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildDefinitionItem(Definition def) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ${def.definition}",
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, height: 1.4)),
          if (def.example != null && def.example!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10)),
              child: Text("\"${def.example}\"",
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontStyle: FontStyle.italic)),
            ),
          if (def.synonyms != null && def.synonyms!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 10),
              child: Wrap(
                spacing: 6,
                children: def.synonyms!
                    .map((s) => Text("#$s",
                        style: const TextStyle(
                            color: Colors.purpleAccent, fontSize: 12)))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
