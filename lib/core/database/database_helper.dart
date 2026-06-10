import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Helper Sqflite — Singleton de la base de données.
///
/// Responsable de :
/// - L'ouverture / création du fichier `.db`
/// - La création du schéma (3 tables : utilisateurs, wallets, transactions)
class DatabaseHelper {
  DatabaseHelper._();

  /// Instance unique (singleton).
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _databaseName = 'nfc_cash.db';
  static const int _databaseVersion = 2;

  Database? _database;

  /// Retourne l'instance de la base de données (lazy init).
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialise la base de données.
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Gère les migrations de schéma.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE utilisateurs ADD COLUMN firstname TEXT NOT NULL DEFAULT ""');
      await db.execute('ALTER TABLE utilisateurs ADD COLUMN lastname TEXT NOT NULL DEFAULT ""');
    }
  }

  /// Crée les tables lors de la première installation.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE utilisateurs (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        firstname TEXT NOT NULL DEFAULT '',
        lastname TEXT NOT NULL DEFAULT '',
        mot_de_passe_hash TEXT NOT NULL,
        est_connecte INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE wallets (
        id TEXT PRIMARY KEY,
        utilisateur_id TEXT NOT NULL,
        solde REAL NOT NULL DEFAULT 0.0,
        devise TEXT NOT NULL DEFAULT 'XAF',
        FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        wallet_source_id TEXT,
        wallet_dest_id TEXT NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('RECHARGE', 'TRANSFERT_NFC')),
        montant REAL NOT NULL,
        statut INTEGER NOT NULL DEFAULT 0,
        date_cree TEXT NOT NULL,
        FOREIGN KEY (wallet_source_id) REFERENCES wallets(id),
        FOREIGN KEY (wallet_dest_id) REFERENCES wallets(id)
      )
    ''');
  }

  /// Retourne l'ID de l'utilisateur actuellement connecté.
  /// Retourne null si aucun utilisateur n'est connecté.
  Future<String?> getConnectedUserId() async {
    final db = await database;
    final rows = await db.query(
      'utilisateurs',
      columns: ['id'],
      where: 'est_connecte = 1',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as String;
  }

  /// Supprime et recrée la base (utile en développement).
  Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    await deleteDatabase(path);
    _database = null;
  }
}
