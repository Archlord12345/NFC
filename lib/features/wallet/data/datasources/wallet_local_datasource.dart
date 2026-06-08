import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

/// Source de données locale — requêtes SQLite pour le module Wallet.
///
/// C'est ici et UNIQUEMENT ici que sqflite est importé pour ce module.
class WalletLocalDataSource {
  final sqflite.Database database;
  static const _uuid = Uuid();

  const WalletLocalDataSource(this.database);

  // ─────────────────────────── Wallet ────────────────────────────────────────

  /// Récupère le wallet de l'utilisateur [utilisateurId].
  Future<WalletModel> getWallet(String utilisateurId) async {
    try {
      final rows = await database.query(
        'wallets',
        where: 'utilisateur_id = ?',
        whereArgs: [utilisateurId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw const NotFoundException('Aucun wallet trouvé pour cet utilisateur.');
      }
      return WalletModel.fromMap(rows.first);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Erreur lecture wallet : $e');
    }
  }

  // ─────────────────────────── Transactions ──────────────────────────────────

  /// Récupère toutes les transactions du wallet [walletId].
  /// Inclut les entrées (wallet_dest) ET les sorties (wallet_source).
  Future<List<TransactionModel>> getHistorique(String walletId) async {
    try {
      final rows = await database.query(
        'transactions',
        where: 'wallet_dest_id = ? OR wallet_source_id = ?',
        whereArgs: [walletId, walletId],
        orderBy: 'date_cree DESC',
      );
      return rows.map(TransactionModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Erreur lecture historique : $e');
    }
  }

  // ─────────────────────────── Recharge ──────────────────────────────────────

  /// Met à jour le solde et crée une ligne RECHARGE dans les transactions.
  /// Exécuté dans une transaction SQLite atomique.
  Future<void> recharger(String walletId, double montant) async {
    try {
      await database.transaction((txn) async {
        // 1. Mise à jour du solde
        final updated = await txn.rawUpdate(
          'UPDATE wallets SET solde = solde + ? WHERE id = ?',
          [montant, walletId],
        );
        if (updated == 0) {
          throw const NotFoundException('Wallet introuvable pour la recharge.');
        }

        // 2. Création de la transaction RECHARGE
        await txn.insert('transactions', {
          'id': _uuid.v4(),
          'wallet_source_id': null,
          'wallet_dest_id': walletId,
          'type': 'RECHARGE',
          'montant': montant,
          'statut': 1, // Validé directement
          'date_cree': DateTime.now().toIso8601String(),
        });
      });
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Erreur lors de la recharge : $e');
    }
  }
}
