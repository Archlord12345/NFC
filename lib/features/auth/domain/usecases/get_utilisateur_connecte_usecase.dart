import '../entities/utilisateur.dart';
import '../repositories/auth_repository.dart';

/// Cas d'utilisation : Vérifier si un utilisateur est connecté.
///
/// Utilisé au démarrage de l'app pour restaurer la session.
class GetUtilisateurConnecteUseCase {
  final AuthRepository repository;

  const GetUtilisateurConnecteUseCase(this.repository);

  /// Retourne l'[Utilisateur] connecté ou `null` si aucune session active.
  Future<Utilisateur?> call() {
    return repository.getUtilisateurConnecte();
  }
}
