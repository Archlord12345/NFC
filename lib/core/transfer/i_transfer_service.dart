enum TransferMethod {
  nfc,
  bluetooth,
  quickShare,
}

class Peer {
  final String id;
  final String name;

  Peer({required this.id, required this.name});
}

abstract class ITransferService {
  TransferMethod get method;

  Future<bool> requestPermissions();
  
  Future<void> startDiscovery();
  
  Future<void> startAdvertising();
  
  Future<void> stopDiscovery();

  Stream<List<Peer>> get discoveredPeers;

  Stream<Map<String, dynamic>> get onDataReceived;

  Future<void> sendData({
    required String peerId,
    required double amount,
  });
}
