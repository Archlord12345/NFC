import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Implémentation concrète du [AuthRepository].
///
/// Délègue les opérations au [AuthLocalDataSource].
/// Gère le hachage du mot de passe et la conversion des erreurs.
class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl(this.localDataSource);

  @override
  Future<Utilisateur> login(String email, String motDePasse) async {
    final hash = sha256.convert(utf8.encode(motDePasse)).toString();
    return await localDataSource.login(email, hash);
  }

  @override
  Future<Utilisateur> register(String email, String motDePasse) async {
    final hash = sha256.convert(utf8.encode(motDePasse)).toString();
    return await localDataSource.register(email, hash);
  }

  @override
  Future<void> logout() async {
    final user = await localDataSource.getUtilisateurConnecte();
    if (user != null) {
      await localDataSource.logout(user.id);
    }
  }

  @override
  Future<Utilisateur?> getUtilisateurConnecte() {
    return localDataSource.getUtilisateurConnecte();
  }
}
