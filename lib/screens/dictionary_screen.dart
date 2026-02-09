import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/word_service.dart';
import 'word_detail_screen.dart';

class DictionaryScreen extends StatefulWidget {
  final String? initialWord;
  const DictionaryScreen({Key? key, this.initialWord}) : super(key: key);

  @override
  _DictionaryScreenState createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  List<WordData> _allWords = [];
  List<WordData> _filteredWords = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWords();
    if (widget.initialWord != null) {
      _searchController.text = widget.initialWord!;
    }
  }

  Future<void> _loadWords() async {
    setState(() => _isLoading = true);
    _allWords = await WordService.loadWords();
    _filterWords(_searchController.text);
    setState(() => _isLoading = false);
  }

  void _filterWords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredWords = [];
      } else {
        _filteredWords = _allWords
            .where((w) => w.word.toLowerCase().startsWith(query.toLowerCase()))
            .take(50)
            .toList();
      }
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
        title: const Text('Dictionary',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Arama Kutusu
            TextField(
              controller: _searchController,
              onChanged: _filterWords,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search word...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Sonuçlar
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue))
                  : _filteredWords.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'Start typing to search...'
                                : 'No results found',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredWords.length,
                          itemBuilder: (context, index) {
                            final word = _filteredWords[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(word.word,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16)),
                                subtitle: Text(
                                  'Level: ${word.level}',
                                  style: const TextStyle(
                                      color: Colors.orange, fontSize: 12),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white24, size: 14),
                                onTap: () {
                                  WordService.addRecentWord(word.word);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          WordDetailScreen(word: word),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
