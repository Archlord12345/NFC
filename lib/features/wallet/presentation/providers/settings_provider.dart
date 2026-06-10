import 'package:flutter/foundation.dart';

class SettingsProvider extends ChangeNotifier {
  bool _bluetoothEnabled = true;
  bool _quickShareEnabled = true;
  bool _nfcEnabled = true;

  bool get bluetoothEnabled => _bluetoothEnabled;
  bool get quickShareEnabled => _quickShareEnabled;
  bool get nfcEnabled => _nfcEnabled;

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
}
