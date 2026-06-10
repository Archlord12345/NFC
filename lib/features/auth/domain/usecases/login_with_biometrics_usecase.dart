import '../entities/utilisateur.dart';
import '../repositories/auth_repository.dart';

/// Cas d'utilisation : Connexion via biométrie
class LoginWithBiometricsUseCase {
  final AuthRepository repository;

  const LoginWithBiometricsUseCase(this.repository);

  /// Connecte l'utilisateur par biométrie
  Future<Utilisateur> call() {
    return repository.loginWithBiometrics();
  }
}
