import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

/// WA-1 — Consultation du solde.
///
/// Récupère le [Wallet] de l'utilisateur identifié par [utilisateurId].
class GetWalletUseCase {
  final WalletRepository repository;

  const GetWalletUseCase(this.repository);

  Future<Wallet> call(String utilisateurId) {
    return repository.getWallet(utilisateurId);
  }
}
