import '../repositories/auth_repository.dart';

/// Cas d'utilisation : Mise à jour du profil utilisateur
class UpdateProfileUseCase {
  final AuthRepository repository;

  const UpdateProfileUseCase(this.repository);

  /// Met à jour le profil avec [id], [firstname] et [lastname].
  Future<void> call(String id, String firstname, String lastname) {
    return repository.updateProfile(id, firstname, lastname);
  }
}
