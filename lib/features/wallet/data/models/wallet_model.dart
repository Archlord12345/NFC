import '../../domain/entities/wallet.dart';

/// Modèle de données représentant un wallet en base SQLite.
///
/// Étend [Wallet] et ajoute les méthodes de sérialisation
/// [fromMap] / [toMap] pour les échanges avec sqflite.
class WalletModel extends Wallet {
  const WalletModel({
    required super.id,
    required super.utilisateurId,
    required super.solde,
    required super.devise,
  });

  /// Construit un [WalletModel] depuis une ligne SQLite.
  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'] as String,
      utilisateurId: map['utilisateur_id'] as String,
      solde: (map['solde'] as num).toDouble(),
      devise: map['devise'] as String,
    );
  }

  /// Convertit le modèle en map pour l'insertion SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'solde': solde,
      'devise': devise,
    };
  }
}
