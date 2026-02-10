import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../services/word_service.dart';
import 'word_detail_screen.dart';

class SuggestMeScreen extends StatefulWidget {
  @override
  _SuggestMeScreenState createState() => _SuggestMeScreenState();
}

class _SuggestMeScreenState extends State<SuggestMeScreen> {
  List<WordData> _suggestedWords = [];
  Set<String> _markedAsKnown = {}; // Yeşil işaretlenenler (geçici)
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

    _userLevel = await WordService.getUserLevel();
    _userGoal = await WordService.getDailyGoal();

    final saved = await WordService.getLastSuggestions();

    // DAHA ÖNCE İŞARETLENMİŞLERİ YÜKLE (Kalıcılık için)
    final knownWords = await WordService.getKnownWords();

    setState(() {
      _suggestedWords = saved;
      // Eğer kayıtlı kelimeler şu anki listede varsa onları işaretli göster
      _markedAsKnown = _suggestedWords
          .map((w) => w.word)
          .where((name) => knownWords.contains(name))
          .toSet();
      _isLoading = false;
    });
  }

  Future<void> _loadNewSuggestions() async {
    // Önce yeşil işaretlileri kaydet
    if (_markedAsKnown.isNotEmpty) {
      await WordService.addKnownWords(_markedAsKnown.toList());
    }

    setState(() {
      _isLoading = true;
      _suggestedWords = [];
      _markedAsKnown.clear(); // Yeni liste için sıfırla
    });

    final allWords = await WordService.loadWords();
    final knownWords = await WordService.getKnownWords();

    // Kullanıcının seviyesine göre filtrele VE bilinen kelimeleri çıkar
    final levelWords = allWords
        .where((w) => w.level == _userLevel && !knownWords.contains(w.word))
        .toList();

    if (levelWords.isEmpty) {
      // Eğer o seviyede kelime kalmadıysa, tüm bilinmeyen kelimelerden al
      levelWords.addAll(
        allWords.where((w) => !knownWords.contains(w.word)).toList(),
      );
    }

    levelWords.shuffle();
    final newList = levelWords.take(_userGoal).toList();

    await WordService.saveLastSuggestions(newList);

    if (mounted) {
      setState(() {
        _suggestedWords = newList;
        _isLoading = false;
      });
    }
  }

  void _toggleKnown(String wordName) async {
    setState(() {
      if (_markedAsKnown.contains(wordName)) {
        _markedAsKnown.remove(wordName);
      } else {
        _markedAsKnown.add(wordName);
      }
    });

    // ANLIK KAYIT: Kullanıcı sayfadan çıksa bile veri kaybolmaz
    if (_markedAsKnown.contains(wordName)) {
      await WordService.addKnownWords([wordName]);
    } else {
      // Eğer işareti kaldırdıysa hafızadan da silmek isterseniz
      _markedAsKnown.remove(wordName);
      await WordService.removeKnownWord(wordName);
    }
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
          // Üst Panel
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
                    Text('Daily Goal: $_userGoal Words',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    Text('Marked: ${_markedAsKnown.length}',
                        style: const TextStyle(
                            color: Colors.greenAccent, fontSize: 11)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _loadNewSuggestions,
                  icon: const Icon(Icons.auto_awesome,
                      size: 18, color: Colors.white),
                  label: const Text("New List",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ],
            ),
          ),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blue))
                : _suggestedWords.isEmpty
                    ? _buildEmptyState()
                    : _buildWordList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text('No active suggestions',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap "New List" to generate your daily word suggestions.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _suggestedWords.length,
      itemBuilder: (context, index) {
        final word = _suggestedWords[index];
        final isKnown = _markedAsKnown.contains(word.word);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isKnown
                ? Colors.green.withOpacity(0.15)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isKnown
                  ? Colors.greenAccent.withOpacity(0.5)
                  : Colors.white.withOpacity(0.05),
              width: isKnown ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            title: Text(word.word,
                style: TextStyle(
                    color: isKnown ? Colors.greenAccent : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Yeşil İşaret Butonu
                IconButton(
                  icon: Icon(
                    isKnown ? Icons.check_circle : Icons.check_circle_outline,
                    color: isKnown ? Colors.greenAccent : Colors.white38,
                  ),
                  onPressed: () => _toggleKnown(word.word),
                ),
                // Detay Oku
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white24),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WordDetailScreen(word: word),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
