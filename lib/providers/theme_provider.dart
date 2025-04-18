import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeProvider() {
    // Aquí no deberías hacer la carga en el constructor, sino en un método que se ejecute después.
  }

  // Método que se debe llamar al iniciar el provider para cargar el estado del tema
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDarkTheme') ?? false;
    notifyListeners();  // Notificar para que la app se actualice con el nuevo tema.
  }

  void toggleTheme(bool isDarkMode) async {
    _isDark = isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDarkMode);
    notifyListeners();  // Notificar a los oyentes del cambio de tema.
  }

  ThemeData get currentTheme => _isDark ? ThemeData.dark() : ThemeData.light();
}
