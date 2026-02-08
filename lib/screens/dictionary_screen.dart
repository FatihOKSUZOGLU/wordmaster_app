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
  final TextEditingController _searchController = TextEditingController();
  List<WordData> _allWords = [];
  List<WordData> _filteredWords = [];
  bool _isLoading = true;
  Set<String> _selectedLevels = {'A1', 'A2', 'B1', 'B2', 'C1', 'C2'};

  @override
  void initState() {
    super.initState();
    _loadWords();
    if (widget.initialWord != null) {
      _searchController.text = widget.initialWord!;
    }
  }

  Future<void> _loadWords() async {
    final words = await WordService.loadWords();
    setState(() {
      _allWords = words;
      _isLoading = false;
      if (widget.initialWord != null) {
        _filterWords(widget.initialWord!);
      } else {
        _filteredWords = []; // Başlangıçta boş liste (3 harf kuralı için)
      }
    });
  }

  void _filterWords(String query) {
    if (query.length < 3) {
      setState(() => _filteredWords = []);
      return;
    }

    setState(() {
      _filteredWords = _allWords.where((word) {
        final matchesSearch =
            word.word.toLowerCase().contains(query.toLowerCase());
        final matchesLevel = _selectedLevels.contains(word.level);
        return matchesSearch && matchesLevel;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color(0xFF0A0E27), // ← Bunu değiştirin (transparent yerine)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Dictionary',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      // ... geri kalan kod aynı
      body: Column(
        children: [
          // Search Bar (Ana menü stiline uygun)
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterWords,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search (min. 3 letters)...',
                hintStyle: TextStyle(color: Colors.white30),
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
            ),
          ),

          // Level Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((level) {
                final isSelected = _selectedLevels.contains(level);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(level),
                    selected: isSelected,
                    onSelected: (bool value) {
                      setState(() {
                        if (value)
                          _selectedLevels.add(level);
                        else
                          _selectedLevels.remove(level);
                        _filterWords(_searchController.text);
                      });
                    },
                    backgroundColor: Colors.white.withOpacity(0.05),
                    selectedColor: Colors.blue.withOpacity(0.3),
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 10),

          // Word List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.blue))
                : _searchController.text.length < 3
                    ? Center(
                        child: Text('Type at least 3 letters',
                            style: TextStyle(color: Colors.white30)))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _filteredWords.length,
                        itemBuilder: (context, index) {
                          final word = _filteredWords[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.05)),
                            ),
                            child: ListTile(
                              title: Text(word.word,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(word.level,
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 12)),
                              trailing: Icon(Icons.arrow_forward_ios,
                                  color: Colors.white24, size: 14),
                              onTap: () {
                                WordService.addRecentWord(word.word);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          WordDetailScreen(word: word)),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
