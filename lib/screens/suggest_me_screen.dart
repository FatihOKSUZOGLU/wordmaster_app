import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/word_service.dart';
import 'dictionary_screen.dart';

class SuggestMeScreen extends StatefulWidget {
  @override
  _SuggestMeScreenState createState() => _SuggestMeScreenState();
}

class _SuggestMeScreenState extends State<SuggestMeScreen> {
  List<WordData> _suggestedWords = [];
  bool _isLoading = true;
  String _userLevel = 'A1';
  int _userGoal = 10;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);

    // 1. Ana ayarlardan seviye ve hedefi oku
    _userLevel = await WordService.getUserLevel();
    _userGoal = await WordService.getDailyGoal();

    // 2. Hafızada bu ayarlara uygun eski öneri var mı?
    final saved = await WordService.getLastSuggestions();

    // Eğer hafızadaki kelimelerin seviyesi şu anki seviyeyle aynıysa onları göster
    if (saved.isNotEmpty && saved.first.level == _userLevel) {
      setState(() {
        _suggestedWords = saved;
        _isLoading = false;
      });
    } else {
      _loadNewSuggestions();
    }
  }

  Future<void> _loadNewSuggestions() async {
    setState(() => _isLoading = true);

    final allWords = await WordService.loadWords();
    // Sadece kullanıcının ana ayarlarındaki seviyeye göre filtrele
    final levelWords = allWords.where((w) => w.level == _userLevel).toList();
    levelWords.shuffle();

    final newList = levelWords.take(_userGoal).toList();

    await WordService.saveLastSuggestions(newList);

    setState(() {
      _suggestedWords = newList;
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
        title: const Text('My Suggestions',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Bilgi Paneli (Değiştirilemez, sadece bilgi verir)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level: $_userLevel',
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                    Text('Goal: $_userGoal Words',
                        style: const TextStyle(
                            color: Colors.orange, fontSize: 12)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _loadNewSuggestions,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text("New List"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.2)),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blue))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _suggestedWords.length,
                    itemBuilder: (context, index) {
                      final word = _suggestedWords[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(word.word,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18)),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              color: Colors.white24, size: 14),
                          onTap: () {
                            WordService.addRecentWord(word.word);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DictionaryScreen(
                                        initialWord: word.word)));
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
