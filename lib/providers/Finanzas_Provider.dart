import 'package:flutter/material.dart';

class FinanzasProvider with ChangeNotifier {
  double _balance = 0;
  List<Map<String, dynamic>> _movimientos = [];

  double get balance => _balance;
  List<Map<String, dynamic>> get movimientos => _movimientos;

  void setBalance(double value) {
    _balance = value;
    notifyListeners();
  }

  void setMovimientos(List<Map<String, dynamic>> lista) {
    _movimientos = lista;
    notifyListeners();
  }

  void clear() {
    _balance = 0;
    _movimientos = [];
    notifyListeners();
  }
}