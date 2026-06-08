import '../../domain/entities/transaction_entity.dart';

/// Modèle de données représentant une transaction en base SQLite.
///
/// Étend [TransactionEntity] et ajoute la sérialisation
/// [fromMap] / [toMap].
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    super.walletSourceId,
    required super.walletDestId,
    required super.type,
    required super.montant,
    required super.statut,
    required super.dateCree,
  });

  /// Construit un [TransactionModel] depuis une ligne SQLite.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      walletSourceId: map['wallet_source_id'] as String?,
      walletDestId: map['wallet_dest_id'] as String,
      type: map['type'] as String,
      montant: (map['montant'] as num).toDouble(),
      statut: map['statut'] as int,
      dateCree: map['date_cree'] as String,
    );
  }

  /// Convertit le modèle en map pour l'insertion SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wallet_source_id': walletSourceId,
      'wallet_dest_id': walletDestId,
      'type': type,
      'montant': montant,
      'statut': statut,
      'date_cree': dateCree,
    };
  }
}
