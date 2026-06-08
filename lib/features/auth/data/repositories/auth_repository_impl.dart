import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Implémentation concrète du [AuthRepository].
///
/// Délègue les opérations au [AuthLocalDataSource].
/// Gère la conversion des erreurs techniques en logique métier.
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl(this.localDataSource);

  @override
  Future<Utilisateur> login(String email, String motDePasse) async {
    // TODO: Hasher le mot de passe avant de le passer au datasource.
    // final hash = sha256.convert(utf8.encode(motDePasse)).toString();
    final utilisateur = await localDataSource.login(email, motDePasse);
    return utilisateur;
  }

  @override
  Future<void> logout() async {
    // TODO: Récupérer l'id de l'utilisateur connecté avant de déconnecter.
    // final user = await localDataSource.getUtilisateurConnecte();
    // if (user != null) await localDataSource.logout(user.id);
  }

  @override
  Future<Utilisateur?> getUtilisateurConnecte() {
    return localDataSource.getUtilisateurConnecte();
  }
}
