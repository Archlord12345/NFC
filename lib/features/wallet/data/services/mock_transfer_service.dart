import '../../../core/transfer/i_transfer_service.dart';

/// Implémentation fictive pour les tests unitaires et d'intégration
class MockTransferService implements ITransferService {
  @override
  TransferMethod get method => TransferMethod.nfc;

  @override
  Future<bool> requestPermissions() async {
    return true; // Simuler une permission accordée
  }

  @override
  Future<void> startDiscovery() async {
    // Simuler une découverte réussie
  }

  @override
  Future<void> stopDiscovery() async {
    // Simuler l'arrêt de la découverte
  }

  @override
  Future<void> sendData({
    required String peerId,
    required double amount,
  }) async {
    // Simuler l'envoi de données avec succès
    print("Mock: Envoi réussi de $amount à $peerId");
  }
}
