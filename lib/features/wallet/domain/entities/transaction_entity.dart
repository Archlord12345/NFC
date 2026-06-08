import 'package:equatable/equatable.dart';

/// Entité métier représentant une transaction financière.
///
/// Nommée [TransactionEntity] pour éviter le conflit avec
/// le type [Transaction] de sqflite (dans la couche data).
class TransactionEntity extends Equatable {
  final String id;

  /// Null si le type est [TransactionType.recharge].
  final String? walletSourceId;

  final String walletDestId;
  final String type; // 'RECHARGE' ou 'TRANSFERT_NFC'
  final double montant;

  /// 0 = En attente, 1 = Validé, 2 = Échoué.
  final int statut;

  final String dateCree; // ISO 8601

  const TransactionEntity({
    required this.id,
    this.walletSourceId,
    required this.walletDestId,
    required this.type,
    required this.montant,
    required this.statut,
    required this.dateCree,
  });

  /// Indique si c'est une entrée d'argent pour le wallet donné.
  bool estEntree(String walletId) => walletDestId == walletId;

  @override
  List<Object?> get props => [
        id,
        walletSourceId,
        walletDestId,
        type,
        montant,
        statut,
        dateCree,
      ];
}
