import 'package:flutter/material.dart';

class GoogleAuthProvider with ChangeNotifier {
  String? _accessToken;

  String? get accessToken => _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
    notifyListeners();
  }

  void clearAccessToken() {
    _accessToken = null;
    notifyListeners();
  }
}