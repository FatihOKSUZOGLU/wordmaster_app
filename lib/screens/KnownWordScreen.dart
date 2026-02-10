import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/word_service.dart';
import 'word_detail_screen.dart';

class KnownWordsScreen extends StatefulWidget {
  const KnownWordsScreen({Key? key}) : super(key: key);

  @override
  _KnownWordsScreenState createState() => _KnownWordsScreenState();
}

class _KnownWordsScreenState extends State<KnownWordsScreen> {
  List<WordData> _knownWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKnownWords();
  }

  Future<void> _loadKnownWords() async {
    setState(() => _isLoading = true);

    final knownNames = await WordService.getKnownWords();
    if (knownNames.isEmpty) {
      setState(() {
        _knownWords = [];
        _isLoading = false;
      });
      return;
    }

    final allWords = await WordService.loadWords();
    final filtered =
        allWords.where((w) => knownNames.contains(w.word)).toList();

    setState(() {
      _knownWords = filtered;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Known Words',
            style: TextStyle(
                color: Colors.greenAccent, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent))
          : _knownWords.isEmpty
              ? _buildEmptyState()
              : _buildWordList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories,
              size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          const Text('No words learned yet',
              style: TextStyle(color: Colors.white54, fontSize: 18)),
          const SizedBox(height: 10),
          const Text('Words you mark as known will appear here.',
              style: TextStyle(color: Colors.white24, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildWordList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _knownWords.length,
      itemBuilder: (context, index) {
        final word = _knownWords[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.1)),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: const Icon(Icons.check_circle, color: Colors.greenAccent),
            title: Text(word.word,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            subtitle:
                Text(word.level, style: const TextStyle(color: Colors.white38)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WordDetailScreen(word: word)),
              );
            },
          ),
        );
      },
    );
  }
}
