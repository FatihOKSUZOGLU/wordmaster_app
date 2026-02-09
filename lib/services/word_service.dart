import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';

class WordService {
  static List<WordData> _cachedWords = [];

  // Hafıza Anahtarları
  static const String _recentWordsKey = 'recent_words';
  static const String _lastSuggestionsKey = 'last_suggestions';
  static const String _userLevelKey = 'user_level';
  static const String _dailyGoalKey = 'daily_goal';
  static const String _frequencyKey = 'frequency';

  // JSON'dan kelimeleri yükle
  static Future<List<WordData>> loadWords() async {
    if (_cachedWords.isNotEmpty) return _cachedWords;
    try {
      final String response =
          await rootBundle.loadString('assets/filtered_dictionary.json');
      final List<dynamic> data = json.decode(response);
      _cachedWords = data.map((json) => WordData.fromJson(json)).toList();
      return _cachedWords;
    } catch (e) {
      return [];
    }
  }

  // Kullanıcı ayarlarını kaydet
  static Future<void> saveUserSettings({
    required String level,
    required int dailyGoal,
    required String frequency,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userLevelKey, level);
    await prefs.setInt(_dailyGoalKey, dailyGoal);
    await prefs.setString(_frequencyKey, frequency);
    await prefs.setBool('is_first_run', false); // Kurulum tamamlandı işareti
  }

  // Ayarları oku
  static Future<String> getUserLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userLevelKey) ?? 'A1';
  }

  static Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyGoalKey) ?? 10;
  }

  // Son önerileri hafızaya al
  static Future<void> saveLastSuggestions(List<WordData> words) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> wordNames = words.map((w) => w.word).toList();
    await prefs.setStringList(_lastSuggestionsKey, wordNames);
  }

  static Future<List<WordData>> getLastSuggestions() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedNames = prefs.getStringList(_lastSuggestionsKey) ?? [];

    if (savedNames.isEmpty) return [];
    if (_cachedWords.isEmpty) await loadWords();

    // Her kelimeden sadece BİR TANE al (ilk eşleşeni)
    List<WordData> result = [];
    for (String name in savedNames) {
      final word = _cachedWords.firstWhere(
        (w) => w.word == name,
        orElse: () => WordData(word: '', level: '', meanings: []),
      );
      if (word.word.isNotEmpty) {
        result.add(word);
      }
    }

    return result;
  }

  // Son bakılan kelimeler (Ana Menü için)
  static Future<void> addRecentWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recentWords = prefs.getStringList(_recentWordsKey) ?? [];
    recentWords.remove(word);
    recentWords.insert(0, word);
    if (recentWords.length > 5) recentWords = recentWords.sublist(0, 5);
    await prefs.setStringList(_recentWordsKey, recentWords);
  }

  static Future<List<String>> getRecentWords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentWordsKey) ?? [];
  }
}
