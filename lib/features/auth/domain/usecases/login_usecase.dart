import '../entities/utilisateur.dart';
import '../repositories/auth_repository.dart';

/// Cas d'utilisation : Connexion de l'utilisateur (AU-1).
///
/// Encapsule la logique métier de connexion.
/// Dépend du contrat [AuthRepository], pas de l'implémentation.
class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  /// Exécute la connexion avec [email] et [motDePasse].
  Future<Utilisateur> call(String email, String motDePasse) {
    return repository.login(email, motDePasse);
  }
}
