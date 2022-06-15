import 'package:flutter/material.dart';

class ThemeModel with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void setTheme(bool val) {
    _isDark = val;
    notifyListeners();
  }
}
