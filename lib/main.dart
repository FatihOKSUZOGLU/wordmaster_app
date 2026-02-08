import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_menu_screen.dart';

void main() async {
  // Flutter motorunun hazır olduğundan emin oluyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // Cihaz hafızasına erişiyoruz
  final prefs = await SharedPreferences.getInstance();

  // 'is_first_run' değeri yoksa true (ilk açılış) kabul et
  bool isFirstRun = prefs.getBool('is_first_run') ?? true;

  runApp(WordMasterApp(
    startScreen: isFirstRun ? OnboardingScreen() : MainMenuScreen(),
  ));
}

class WordMasterApp extends StatelessWidget {
  final Widget startScreen;

  const WordMasterApp({Key? key, required this.startScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordMaster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        // Tüm geri oklarını beyaz yapar
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: startScreen,
    );
  }
}
