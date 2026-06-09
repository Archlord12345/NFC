import '../entities/wallet.dart';
import '../entities/transaction_entity.dart';

/// Contrat abstrait du repository Wallet.
///
/// Ce fichier NE doit PAS importer sqflite, NFC ou tout autre
/// package d'infrastructure. Il définit uniquement les opérations
/// disponibles en termes métier.
abstract class WalletRepository {
  /// Récupère le wallet associé à [utilisateurId].
  Future<Wallet> getWallet(String utilisateurId);

  /// Récupère l'historique complet des transactions du wallet [walletId].
  Future<List<TransactionEntity>> getHistorique(String walletId);

  /// Recharge le wallet [walletId] du montant [montant]
  /// et enregistre une transaction de type RECHARGE.
  Future<void> recharger(String walletId, double montant);

  /// Effectue un transfert NFC (envoi ou réception).
  /// [isEnvoi] indique si on retire de l'argent (true) ou si on en reçoit (false).
  Future<void> transfertNfc({
    required String walletId,
    required double montant,
    required bool isEnvoi,
    String? peerWalletId,
  });
}
