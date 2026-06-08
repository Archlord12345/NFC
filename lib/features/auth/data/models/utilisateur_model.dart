import '../../domain/entities/utilisateur.dart';

/// Modèle de données pour [Utilisateur].
///
/// Étend l'entité et ajoute la sérialisation SQLite (fromMap / toMap).
class UtilisateurModel extends Utilisateur {
  final String motDePasseHash;

  const UtilisateurModel({
    required super.id,
    required super.email,
    required super.estConnecte,
    required this.motDePasseHash,
  });

  /// Construit un [UtilisateurModel] depuis une ligne SQLite.
  factory UtilisateurModel.fromMap(Map<String, dynamic> map) {
    return UtilisateurModel(
      id: map['id'] as String,
      email: map['email'] as String,
      estConnecte: (map['est_connecte'] as int) == 1,
      motDePasseHash: map['mot_de_passe_hash'] as String,
    );
  }

  /// Convertit en Map pour insertion/mise à jour SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'mot_de_passe_hash': motDePasseHash,
      'est_connecte': estConnecte ? 1 : 0,
    };
  }
}
