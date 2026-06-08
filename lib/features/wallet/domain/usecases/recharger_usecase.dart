import '../../../../core/errors/exceptions.dart';
import '../repositories/wallet_repository.dart';

/// Paramètres du [RechargerUseCase].
class RechargerParams {
  final String walletId;
  final double montant;

  const RechargerParams({
    required this.walletId,
    required this.montant,
  });
}

/// WA-3 — Recharge du portefeuille.
///
/// Valide le montant, puis délègue au repository pour
/// mettre à jour le solde et créer la transaction RECHARGE.
class RechargerUseCase {
  final WalletRepository repository;

  const RechargerUseCase(this.repository);

  Future<void> call(RechargerParams params) {
    if (params.montant <= 0) {
      throw ValidationException('Le montant doit être supérieur à 0.');
    }
    if (params.montant > 10000000) {
      throw ValidationException(
          'Le montant ne peut pas dépasser 10 000 000.');
    }
    return repository.recharger(params.walletId, params.montant);
  }
}
