import '../entities/utilisateur.dart';
import '../repositories/auth_repository.dart';

/// Cas d'utilisation : Inscription d'un nouvel utilisateur.
class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  /// Exécute l'inscription avec [email] et [motDePasse].
  Future<Utilisateur> call(String email, String motDePasse) {
    return repository.register(email, motDePasse);
  }
}
