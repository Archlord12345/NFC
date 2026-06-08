import '../repositories/auth_repository.dart';

/// Cas d'utilisation : Déconnexion de l'utilisateur (AU-2).
///
/// Encapsule la logique métier de déconnexion.
class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  /// Exécute la déconnexion de l'utilisateur courant.
  Future<void> call() {
    return repository.logout();
  }
}
