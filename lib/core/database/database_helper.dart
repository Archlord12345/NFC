/// Helper Sqflite — Singleton de la base de données.
///
/// Gère l'initialisation, la création des tables et l'accès
/// à l'instance unique de [Database].
///
/// Utilisation :
/// ```dart
/// final db = await DatabaseHelper.instance.database;
/// ```
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  // TODO: Décommenter après ajout de sqflite et path_provider dans pubspec.yaml
  // import 'package:sqflite/sqflite.dart';
  // import 'package:path/path.dart';
  // import 'package:path_provider/path_provider.dart';

  static const String _databaseName = 'nfc_cash.db';
  static const int _databaseVersion = 1;

  // Database? _database;

  // /// Retourne l'instance de la base de données (lazy init).
  // Future<Database> get database async {
  //   _database ??= await _initDatabase();
  //   return _database!;
  // }

  // /// Initialise la base de données.
  // Future<Database> _initDatabase() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final path = join(directory.path, _databaseName);
  //
  //   return await openDatabase(
  //     path,
  //     version: _databaseVersion,
  //     onCreate: _onCreate,
  //   );
  // }

  // /// Crée les tables lors de la première installation.
  // Future<void> _onCreate(Database db, int version) async {
  //   // ── Table utilisateurs ──
  //   await db.execute('''
  //     CREATE TABLE utilisateurs (
  //       id TEXT PRIMARY KEY,
  //       email TEXT UNIQUE NOT NULL,
  //       mot_de_passe_hash TEXT NOT NULL,
  //       est_connecte INTEGER NOT NULL DEFAULT 0
  //     )
  //   ''');
  //
  //   // ── Table wallets ──
  //   await db.execute('''
  //     CREATE TABLE wallets (
  //       id TEXT PRIMARY KEY,
  //       utilisateur_id TEXT NOT NULL,
  //       solde REAL NOT NULL DEFAULT 0.0,
  //       devise TEXT NOT NULL DEFAULT 'XAF',
  //       FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id)
  //         ON DELETE CASCADE
  //     )
  //   ''');
  //
  //   // ── Table transactions ──
  //   await db.execute('''
  //     CREATE TABLE transactions (
  //       id TEXT PRIMARY KEY,
  //       wallet_source_id TEXT,
  //       wallet_dest_id TEXT NOT NULL,
  //       type TEXT NOT NULL CHECK(type IN ('RECHARGE', 'TRANSFERT_NFC')),
  //       montant REAL NOT NULL,
  //       statut INTEGER NOT NULL DEFAULT 0,
  //       date_cree TEXT NOT NULL,
  //       FOREIGN KEY (wallet_source_id) REFERENCES wallets(id),
  //       FOREIGN KEY (wallet_dest_id) REFERENCES wallets(id)
  //     )
  //   ''');
  // }

  // /// Supprime et recrée la base (utile en développement).
  // Future<void> resetDatabase() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final path = join(directory.path, _databaseName);
  //   await deleteDatabase(path);
  //   _database = null;
  // }
}
