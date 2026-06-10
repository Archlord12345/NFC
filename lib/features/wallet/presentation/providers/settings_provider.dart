import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _bluetoothEnabled = true;
  bool _quickShareEnabled = true;
  bool _nfcEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;

  bool get bluetoothEnabled => _bluetoothEnabled;
  bool get quickShareEnabled => _quickShareEnabled;
  bool get nfcEnabled => _nfcEnabled;
  ThemeMode get themeMode => _themeMode;

  void toggleBluetooth(bool value) {
    _bluetoothEnabled = value;
    notifyListeners();
  }

  void toggleQuickShare(bool value) {
    _quickShareEnabled = value;
    notifyListeners();
  }

  void toggleNfc(bool value) {
    _nfcEnabled = value;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }
}
