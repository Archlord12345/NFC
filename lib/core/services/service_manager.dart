import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ServiceManager {
  
  static Future<bool> ensureBluetoothEnabled() async {
    // 1. Demander les permissions selon la version Android
    Map<Permission, PermissionStatus> statuses = {};
    
    if (Platform.isAndroid) {
      if (await Permission.bluetooth.isGranted && 
          await Permission.bluetoothScan.isGranted && 
          await Permission.bluetoothConnect.isGranted &&
          await Permission.location.isGranted) {
        // Déjà tout bon
      } else {
        statuses = await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
          Permission.location,
        ].request();
      }
    }

    // Vérifier si toutes les permissions nécessaires sont accordées
    if (statuses.values.any((status) => status.isDenied || status.isPermanentlyDenied)) {
      return false;
    }

    // 2. Activer le Bluetooth si possible
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
      // Sur Android, on peut demander d'activer le Bluetooth via l'API, 
      // mais FlutterBluePlus ne le permet pas directement sans intents natifs.
      // On retourne false pour que la UI puisse afficher un message.
      return false;
    }
    return true;
  }
}
