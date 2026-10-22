import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _modo = ThemeMode.light;
  ThemeMode get modo => _modo;
  bool get escuro => _modo == ThemeMode.dark;

  ThemeController() {
    _carregar();
  }

  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    _modo = (prefs.getBool('tema_escuro') ?? false)
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  Future<void> alternarTema() async {
    _modo = escuro ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tema_escuro', escuro);
  }
}
