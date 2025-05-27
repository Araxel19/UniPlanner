import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isDark => _isDark;

  Future<void> initialize() async {
    await _loadLocalTheme();
    await _loadRemoteTheme();
  }

  Future<void> _loadLocalTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDarkTheme') ?? false;
    notifyListeners();
  }

  Future<void> _loadRemoteTheme() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final themePreference = doc.data()?['themePreference'];
      if (themePreference != null) {
        _isDark = themePreference == 'dark';
        notifyListeners();
        
        // Sincronizar con preferencias locales
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkTheme', _isDark);
      }
    }
  }

  Future<void> toggleTheme(bool isDarkMode) async {
    _isDark = isDarkMode;
    
    // Guardar localmente
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _isDark);
    
    // Guardar en Firebase
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'themePreference': _isDark ? 'dark' : 'light',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    notifyListeners();
  }

  ThemeData get currentTheme => _isDark ? ThemeData.dark() : ThemeData.light();
}