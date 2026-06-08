import '../models/utilisateur_model.dart';

/// Source de données locale pour l'authentification.
///
/// Effectue les requêtes SQLite concrètes via Sqflite.
/// C'est ici que les dépendances techniques sont importées.
class AuthLocalDataSource {
  // TODO: Injecter la Database Sqflite via le constructeur.
  // final Database database;
  // AuthLocalDataSource(this.database);

  /// Recherche un utilisateur par email et vérifie le mot de passe hashé.
  /// Retourne le [UtilisateurModel] correspondant ou lève une exception.
  Future<UtilisateurModel> login(String email, String motDePasseHash) async {
    // TODO: Implémenter la requête SQL :
    // final result = await database.query(
    //   'utilisateurs',
    //   where: 'email = ? AND mot_de_passe_hash = ?',
    //   whereArgs: [email, motDePasseHash],
    // );
    // if (result.isEmpty) throw Exception('Identifiants incorrects');
    // final user = UtilisateurModel.fromMap(result.first);
    // await database.update(
    //   'utilisateurs',
    //   {'est_connecte': 1},
    //   where: 'id = ?',
    //   whereArgs: [user.id],
    // );
    // return user;
    throw UnimplementedError();
  }

  /// Met à jour le champ `est_connecte` à 0 pour l'utilisateur donné.
  Future<void> logout(String utilisateurId) async {
    // TODO: Implémenter la requête SQL :
    // await database.update(
    //   'utilisateurs',
    //   {'est_connecte': 0},
    //   where: 'id = ?',
    //   whereArgs: [utilisateurId],
    // );
    throw UnimplementedError();
  }

  /// Recherche un utilisateur dont `est_connecte = 1`.
  /// Retourne `null` si aucune session active.
  Future<UtilisateurModel?> getUtilisateurConnecte() async {
    // TODO: Implémenter la requête SQL :
    // final result = await database.query(
    //   'utilisateurs',
    //   where: 'est_connecte = ?',
    //   whereArgs: [1],
    // );
    // if (result.isEmpty) return null;
    // return UtilisateurModel.fromMap(result.first);
    throw UnimplementedError();
  }
}
