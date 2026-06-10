import '../entities/utilisateur.dart';

/// Contrat abstrait du repository d'authentification.
///
/// Définit les opérations disponibles sans détail d'implémentation.
/// L'implémentation concrète se trouve dans `data/repositories/`.
abstract class AuthRepository {
  /// Connecte un utilisateur avec ses identifiants.
  /// Retourne l'[Utilisateur] en cas de succès, lève une exception sinon.
  Future<Utilisateur> login(String email, String motDePasse);

  /// Inscrit un nouvel utilisateur.
  Future<Utilisateur> register(String email, String motDePasse, String firstname, String lastname);

  /// Déconnecte l'utilisateur courant.
  Future<void> logout();

  /// Vérifie si un utilisateur est actuellement connecté.
  /// Retourne l'[Utilisateur] connecté ou `null`.
  Future<Utilisateur?> getUtilisateurConnecte();

  /// Connecte via l'authentification biométrique
  Future<Utilisateur> loginWithBiometrics();

  /// Met à jour le profil de l'utilisateur
  Future<void> updateProfile(String id, String firstname, String lastname);
}
