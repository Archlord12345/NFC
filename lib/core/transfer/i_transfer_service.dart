enum TransferMethod {
  nfc,
  bluetooth,
  quickShare,
}

abstract class ITransferService {
  TransferMethod get method;

  Future<bool> requestPermissions();
  
  Future<void> startDiscovery();
  
  Future<void> stopDiscovery();

  Future<void> sendData({
    required String peerId,
    required double amount,
  });
}
