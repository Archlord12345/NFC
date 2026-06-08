import 'dart:math';
import '../../data/models/transaction_model.dart';

class NfcSimulationService {
  // Simule le comportement d'un scan NFC avec un délai d'attente
  Future<TransactionModel> executeMockNfcTransfer({
    required double amount, 
    required String senderId, 
    required String receiverId
  }) async {
    // Simule les 3 secondes où les téléphones restent collés ensemble
    await Future.delayed(const Duration(seconds: 3));

    // Génère un succès (90% de chances) ou un échec (10% de chances)
    final isSuccess = Random().nextDouble() > 0.1;

    if (isSuccess) {
      return TransactionModel(
        id: 'TX-${Random().nextInt(1000000)}',
        amount: amount,
        timestamp: DateTime.now(),
        senderId: senderId,
        receiverId: receiverId,
        status: 'success',
      );
    } else {
      throw Exception("Connexion NFC interrompue. Veuillez rapprocher les appareils.");
    }
  }
}