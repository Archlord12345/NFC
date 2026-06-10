import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../../core/transfer/i_transfer_service.dart';
import '../../../../core/services/service_manager.dart';

class BluetoothTransferService implements ITransferService {
  @override
  TransferMethod get method => TransferMethod.bluetooth;

  @override
  Stream<List<Peer>> get discoveredPeers => FlutterBluePlus.scanResults.map(
    (results) => results.map((r) => Peer(
      id: r.device.remoteId.str,
      name: r.device.platformName.isEmpty ? 'Appareil Inconnu' : r.device.platformName,
    )).toList()
  );

  @override
  Future<bool> requestPermissions() async {
    return await ServiceManager.ensureBluetoothEnabled();
  }

  @override
  Future<void> startDiscovery() async {
    // Start scanning for devices
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
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
    await device.connect();
    
    // Simulation du transfert de données
    await Future.delayed(const Duration(seconds: 2));
    
    await device.disconnect();
  }
}
