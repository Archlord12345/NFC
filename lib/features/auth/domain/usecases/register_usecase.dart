import '../entities/utilisateur.dart';
import '../repositories/auth_repository.dart';

/// Cas d'utilisation : Inscription d'un nouvel utilisateur.
class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  /// Exécute l'inscription avec [email], [motDePasse], [firstname] et [lastname].
  Future<Utilisateur> call(String email, String motDePasse, String firstname, String lastname) {
    return repository.register(email, motDePasse, firstname, lastname);
  }
}
