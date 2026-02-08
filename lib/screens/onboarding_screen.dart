import 'package:flutter/material.dart';
import '../services/word_service.dart';
import 'main_menu_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isEditing; // Ayar güncelleme modu mu?
  const OnboardingScreen({Key? key, this.isEditing = false}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _selectedLevel = 'A1';
  int _dailyWordGoal = 10;
  String _frequency = 'Daily';

  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  final List<int> _goals = [5, 10, 20, 50];
  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadCurrentSettings();
    }
  }

  // Eğer düzenleme modundaysak mevcut ayarları kutucuklara doldur
  Future<void> _loadCurrentSettings() async {
    final level = await WordService.getUserLevel();
    final goal = await WordService.getDailyGoal();
    setState(() {
      _selectedLevel = level;
      _dailyWordGoal = goal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1a1f3a)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditing ? 'Settings' : 'Welcome to\nWordMaster',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.isEditing
                      ? 'Update your preferences.'
                      : 'Let\'s customize your learning plan.',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),
                _buildTitle('English Level'),
                _buildDropdown<String>(
                  value: _selectedLevel,
                  items: _levels
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedLevel = val!),
                ),
                const SizedBox(height: 25),
                _buildTitle('Daily Word Goal'),
                _buildDropdown<int>(
                  value: _dailyWordGoal,
                  items: _goals
                      .map((g) =>
                          DropdownMenuItem(value: g, child: Text('$g Words')))
                      .toList(),
                  onChanged: (val) => setState(() => _dailyWordGoal = val!),
                ),
                const SizedBox(height: 25),
                _buildTitle('Review Frequency'),
                _buildDropdown<String>(
                  value: _frequency,
                  items: _frequencies
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (val) => setState(() => _frequency = val!),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await WordService.saveUserSettings(
                        level: _selectedLevel,
                        dailyGoal: _dailyWordGoal,
                        frequency: _frequency,
                      );

                      if (widget.isEditing) {
                        Navigator.pop(context); // Ayarlardan geldiyse geri dön
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainMenuScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(
                      widget.isEditing ? 'Save Changes' : 'Start Learning',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style:
              const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDropdown<T>(
      {required T value,
      required List<DropdownMenuItem<T>> items,
      required ValueChanged<T?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          dropdownColor: const Color(0xFF1a1f3a),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
        ),
      ),
    );
  }
}
