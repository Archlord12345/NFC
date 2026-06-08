import 'package:sqflite/sqflite.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/utilisateur_model.dart';

/// Source de données locale pour l'authentification.
///
/// Effectue les requêtes SQLite concrètes via Sqflite.
class AuthLocalDataSource {
  final Database database;

  const AuthLocalDataSource(this.database);

  /// Recherche un utilisateur par email et vérifie le mot de passe hashé.
  /// Retourne le [UtilisateurModel] correspondant ou lève une [AuthException].
  Future<UtilisateurModel> login(String email, String motDePasseHash) async {
    final result = await database.query(
      'utilisateurs',
      where: 'email = ? AND mot_de_passe_hash = ?',
      whereArgs: [email, motDePasseHash],
    );

    if (result.isEmpty) {
      throw const AuthException('Identifiants incorrects');
    }

    final user = UtilisateurModel.fromMap(result.first);

    await database.update(
      'utilisateurs',
      {'est_connecte': 1},
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return UtilisateurModel(
      id: user.id,
      email: user.email,
      estConnecte: true,
      motDePasseHash: user.motDePasseHash,
    );
  }

  /// Met à jour le champ `est_connecte` à 0 pour l'utilisateur donné.
  Future<void> logout(String utilisateurId) async {
    await database.update(
      'utilisateurs',
      {'est_connecte': 0},
      where: 'id = ?',
      whereArgs: [utilisateurId],
    );
  }

  /// Recherche un utilisateur dont `est_connecte = 1`.
  /// Retourne `null` si aucune session active.
  Future<UtilisateurModel?> getUtilisateurConnecte() async {
    final result = await database.query(
      'utilisateurs',
      where: 'est_connecte = ?',
      whereArgs: [1],
    );

    if (result.isEmpty) return null;
    return UtilisateurModel.fromMap(result.first);
  }
}
