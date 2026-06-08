import 'package:equatable/equatable.dart';

/// Entité métier représentant un portefeuille électronique.
///
/// Classe Dart pure — aucune dépendance Flutter ni package externe
/// (hormis Equatable pour la comparaison).
class Wallet extends Equatable {
  final String id;
  final String utilisateurId;
  final double solde;
  final String devise;

  const Wallet({
    required this.id,
    required this.utilisateurId,
    required this.solde,
    required this.devise,
  });

  @override
  List<Object?> get props => [id, utilisateurId, solde, devise];
}
