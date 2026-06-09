import '../../../../core/errors/exceptions.dart';
import '../repositories/wallet_repository.dart';

class TransfertNfcParams {
  final String walletId;
  final double montant;
  final bool isEnvoi;
  final String? peerWalletId;

  const TransfertNfcParams({
    required this.walletId,
    required this.montant,
    required this.isEnvoi,
    this.peerWalletId,
  });
}

class TransfertNfcUseCase {
  final WalletRepository repository;

  const TransfertNfcUseCase(this.repository);

  Future<void> call(TransfertNfcParams params) {
    if (params.montant <= 0) {
      throw ValidationException('Le montant doit être supérieur à 0.');
    }
    return repository.transfertNfc(
      walletId: params.walletId,
      montant: params.montant,
      isEnvoi: params.isEnvoi,
      peerWalletId: params.peerWalletId,
    );
  }
}
