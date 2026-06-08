import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_local_datasource.dart';

/// Implémentation concrète de [WalletRepository].
///
/// Délègue les opérations à [WalletLocalDataSource] et convertit
/// les exceptions techniques en [Failure] métier.
class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource localDataSource;

  const WalletRepositoryImpl(this.localDataSource);

  @override
  Future<Wallet> getWallet(String utilisateurId) async {
    try {
      return await localDataSource.getWallet(utilisateurId);
    } on NotFoundException catch (e) {
      throw WalletFailure(e.message);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw UnexpectedFailure('$e');
    }
  }

  @override
  Future<List<TransactionEntity>> getHistorique(String walletId) async {
    try {
      return await localDataSource.getHistorique(walletId);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw UnexpectedFailure('$e');
    }
  }

  @override
  Future<void> recharger(String walletId, double montant) async {
    try {
      await localDataSource.recharger(walletId, montant);
    } on NotFoundException catch (e) {
      throw WalletFailure(e.message);
    } on DatabaseException catch (e) {
      throw DatabaseFailure(e.message);
    } catch (e) {
      throw UnexpectedFailure('$e');
    }
  }
}
