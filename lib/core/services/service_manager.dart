import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ServiceManager {
  
  static Future<bool> ensureBluetoothEnabled() async {
    // Check permission
    if (await Permission.bluetooth.isDenied || await Permission.bluetoothConnect.isDenied) {
      await [Permission.bluetooth, Permission.bluetoothConnect, Permission.bluetoothScan].request();
    }

    // Check adapter state
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
      // In FlutterBluePlus, we can't directly turn it on programmatically on all platforms
      // but we can prompt the user to enable it.
      // This is a common limitation for privacy/security reasons.
      return false;
    }
    return true;
  }
}
