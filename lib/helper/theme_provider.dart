import 'package:chat_app/helper/user_preferences.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _selectedTheme;
  ThemeData get getTheme => _selectedTheme;

  ThemeData light = ThemeData(
    primarySwatch: Colors.red,
    useMaterial3: true,
    brightness: Brightness.light,
  );
  ThemeData dark = ThemeData(
      primarySwatch: Colors.red,
      useMaterial3: true,
      brightness: Brightness.dark);

  ThemeProvider({required bool isDarkMode}) {
    _selectedTheme = isDarkMode ? dark : light;
  }

  swapTheme() {
    _selectedTheme = _selectedTheme == light ? dark : light;
    UserPreferences.preferences!.setBool("dark_theme", _selectedTheme == dark);
    notifyListeners();
  }
}
