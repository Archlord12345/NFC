import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../../core/transfer/i_transfer_service.dart';
import '../../../../core/services/service_manager.dart';

class BluetoothTransferService implements ITransferService {
  @override
  TransferMethod get method => TransferMethod.bluetooth;

  @override
  Stream<List<Peer>> get discoveredPeers => FlutterBluePlus.scanResults.map(
    (results) {
      // Liste de mots-clés heuristiques pour repérer les téléphones
      final phoneKeywords = ['iphone', 'galaxy', 'samsung', 'pixel', 'redmi', 'huawei', 'oppo', 'poco', 'moto', 'android', 'phone', 'smartphone'];
      
      return results
        .where((r) {
          final name = r.device.platformName.toLowerCase();
          // Ignorer les appareils sans nom
          if (name.isEmpty) return false;
          // Vérifier si le nom contient un mot-clé de téléphone
          return phoneKeywords.any((keyword) => name.contains(keyword));
        })
        .map((r) => Peer(
          id: r.device.remoteId.str,
          name: r.device.platformName,
        )).toList();
    }
  );

  @override
  Future<bool> requestPermissions() async {
    return await ServiceManager.ensureBluetoothEnabled();
  }

  @override
  Future<void> startDiscovery() async {
    debugPrint('BluetoothTransferService: Demarrage du scan...');
    // S'assurer que l'adaptateur est allumé avant de scanner
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on) {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
      debugPrint('BluetoothTransferService: Scan lance avec succes.');
    } else {
      debugPrint('BluetoothTransferService: Impossible de scanner, adaptateur Bluetooth eteint.');
    }
  }

  @override
  Future<void> startAdvertising() async {
    // Bluetooth advertising is complex with flutter_blue_plus (it's mainly a central plugin)
    // For a real app, you'd use a peripheral plugin.
    // Here we simulate being discoverable.
  }

  @override
  Future<void> stopDiscovery() async {
    await FlutterBluePlus.stopScan();
  }

  @override
  Future<void> sendData({
    required String peerId,
    required double amount,
  }) async {
    // Simulation d'une connexion et d'un envoi réel
    final device = BluetoothDevice(remoteId: DeviceIdentifier(peerId));
    
    try {
      await device.connect(timeout: const Duration(seconds: 5));
    } catch (e) {
      // Simulation: Lancer une exception personnalisée si la connexion échoue
      throw Exception('Impossible de se connecter à l\'appareil distant.');
    }
    
    // Simulation d'un délai de transfert
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulation d'une erreur de transfert aléatoire (10% de chances)
    final bool randomError = (DateTime.now().millisecond % 10 == 0);
    if (randomError) {
      await device.disconnect();
      throw Exception('La connexion a été interrompue par l\'appareil distant.');
    }
    
    await device.disconnect();
  }
}
