import 'package:flutter/material.dart';
import '../services/word_service.dart';
import 'onboarding_screen.dart';
import 'dictionary_screen.dart';
import 'suggest_me_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  List<String> _recentWords = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final words = await WordService.getRecentWords();
    setState(() => _recentWords = words);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('WordMaster',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          // AYARLAR BUTONU
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const OnboardingScreen(isEditing: true)),
              );
              _loadRecent(); // Ayarlardan dönünce verileri tazele
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Explore',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Menü Kartları
            _buildMenuCard(
                context,
                'Dictionary',
                'Search thousands of words',
                Icons.search,
                Colors.blue,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DictionaryScreen()))),
            const SizedBox(height: 15),
            _buildMenuCard(
                context,
                'Suggest Me',
                'Personalized word list',
                Icons.auto_awesome,
                Colors.orange,
                () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SuggestMeScreen()))),

            const SizedBox(height: 30),
            const Text('Recently Viewed',
                style: TextStyle(color: Colors.white70, fontSize: 18)),
            const SizedBox(height: 10),

            Expanded(
              child: _recentWords.isEmpty
                  ? const Center(
                      child: Text('No history yet',
                          style: TextStyle(color: Colors.white24)))
                  : ListView.builder(
                      itemCount: _recentWords.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(_recentWords[index],
                            style: const TextStyle(color: Colors.white)),
                        leading:
                            const Icon(Icons.history, color: Colors.white24),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DictionaryScreen(
                                    initialWord: _recentWords[index]))),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String sub,
      IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(sub,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
