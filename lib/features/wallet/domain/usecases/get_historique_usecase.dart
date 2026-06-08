import '../entities/transaction_entity.dart';
import '../repositories/wallet_repository.dart';

/// WA-2 — Historique des transactions.
///
/// Retourne toutes les transactions (entrées + sorties) du wallet [walletId],
/// triées de la plus récente à la plus ancienne.
class GetHistoriqueUseCase {
  final WalletRepository repository;

  const GetHistoriqueUseCase(this.repository);

  Future<List<TransactionEntity>> call(String walletId) {
    return repository.getHistorique(walletId);
  }
}
