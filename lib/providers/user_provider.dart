import 'package:flutter/material.dart';
import 'dart:io';

class UserProvider with ChangeNotifier {
  String _userName = '';
  String _emoji = '👤';
  File? _userImage;
  String? _userId;

  String get userName => _userName;
  String get emoji => _emoji;
  File? get userImage => _userImage;
  String? get userId => _userId;

  void setUserData({
    required String userName,
    required String emoji,
    File? userImage,
    required String userId,
  }) {
    _userName = userName;
    _emoji = emoji;
    _userImage = userImage;
    _userId = userId;
    notifyListeners();
  }

  void clear() {
    _userName = '';
    _emoji = '👤';
    _userImage = null;
    _userId = null;
    notifyListeners();
  }
}