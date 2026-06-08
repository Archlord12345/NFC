import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_summary.dart';

/// Service de base de données SQLite pour la persistance des transactions
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  static const String _dbName = 'nfc_coin_transfer.db';
  static const int _dbVersion = 1;
  static const String _tableName = 'transactions';

  /// Retourne l'instance de la base de données (crée si inexistante)
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id           TEXT PRIMARY KEY,
        senderId     TEXT NOT NULL,
        senderName   TEXT NOT NULL,
        receiverId   TEXT NOT NULL,
        receiverName TEXT NOT NULL,
        amount       REAL NOT NULL,
        type         TEXT NOT NULL,
        status       TEXT NOT NULL,
        timestamp    INTEGER NOT NULL,
        note         TEXT,
        nfcTagId     TEXT
      )
    ''');

    // Index pour accélérer les requêtes par utilisateur et date
    await db.execute(
      'CREATE INDEX idx_sender ON $_tableName (senderId)',
    );
    await db.execute(
      'CREATE INDEX idx_receiver ON $_tableName (receiverId)',
    );
    await db.execute(
      'CREATE INDEX idx_timestamp ON $_tableName (timestamp DESC)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Placeholder pour futures migrations
  }

  // ───────────────────────── CRUD ─────────────────────────

  /// Insère une nouvelle transaction
  Future<void> insertTransaction(Transaction transaction) async {
    final db = await database;
    await db.insert(
      _tableName,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insère plusieurs transactions en batch
  Future<void> insertTransactions(List<Transaction> transactions) async {
    final db = await database;
    final batch = db.batch();
    for (final t in transactions) {
      batch.insert(
        _tableName,
        t.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Récupère toutes les transactions d'un utilisateur avec filtres optionnels
  Future<List<Transaction>> getTransactions({
    required String userId,
    TransactionFilter? filter,
    int? limit,
    int offset = 0,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];

    // Filtre par utilisateur (expéditeur ou destinataire)
    where.add('(senderId = ? OR receiverId = ?)');
    args.addAll([userId, userId]);

    // Filtres optionnels
    if (filter != null) {
      if (filter.type != null) {
        where.add('type = ?');
        args.add(filter.type!.name);
      }
      if (filter.status != null) {
        where.add('status = ?');
        args.add(filter.status!.name);
      }
      if (filter.startDate != null) {
        where.add('timestamp >= ?');
        args.add(filter.startDate!.millisecondsSinceEpoch);
      }
      if (filter.endDate != null) {
        where.add('timestamp <= ?');
        args.add(filter.endDate!.millisecondsSinceEpoch);
      }
      if (filter.minAmount != null) {
        where.add('amount >= ?');
        args.add(filter.minAmount);
      }
      if (filter.maxAmount != null) {
        where.add('amount <= ?');
        args.add(filter.maxAmount);
      }
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final q = '%${filter.searchQuery}%';
        where.add('(senderName LIKE ? OR receiverName LIKE ? OR note LIKE ?)');
        args.addAll([q, q, q]);
      }
    }

    final maps = await db.query(
      _tableName,
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map(Transaction.fromMap).toList();
  }

  /// Récupère une transaction par son ID
  Future<Transaction?> getTransactionById(String id) async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Transaction.fromMap(maps.first);
  }

  /// Met à jour le statut d'une transaction
  Future<void> updateTransactionStatus(
    String id,
    TransactionStatus status,
  ) async {
    final db = await database;
    await db.update(
      _tableName,
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Supprime une transaction par son ID
  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Supprime tout l'historique d'un utilisateur
  Future<void> deleteUserHistory(String userId) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'senderId = ? OR receiverId = ?',
      whereArgs: [userId, userId],
    );
  }

  // ───────────────────────── STATISTIQUES ─────────────────────────

  /// Calcule le résumé statistique des transactions d'un utilisateur
  Future<TransactionSummary> getTransactionSummary(String userId) async {
    final db = await database;

    final sentResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total, COUNT(*) as count
      FROM $_tableName
      WHERE senderId = ? AND status = ?
    ''', [userId, TransactionStatus.completed.name]);

    final receivedResult = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total, COUNT(*) as count
      FROM $_tableName
      WHERE receiverId = ? AND status = ?
    ''', [userId, TransactionStatus.completed.name]);

    final lastResult = await db.rawQuery('''
      SELECT MAX(timestamp) as last
      FROM $_tableName
      WHERE senderId = ? OR receiverId = ?
    ''', [userId, userId]);

    final totalSent = (sentResult.first['total'] as num).toDouble();
    final sentCount = sentResult.first['count'] as int;
    final totalReceived = (receivedResult.first['total'] as num).toDouble();
    final receivedCount = receivedResult.first['count'] as int;
    final lastTs = lastResult.first['last'] as int?;

    return TransactionSummary(
      totalSent: totalSent,
      totalReceived: totalReceived,
      sentCount: sentCount,
      receivedCount: receivedCount,
      totalCount: sentCount + receivedCount,
      netBalance: totalReceived - totalSent,
      lastTransactionDate: lastTs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastTs)
          : null,
    );
  }

  /// Compte le nombre total de transactions (pour pagination)
  Future<int> countTransactions({
    required String userId,
    TransactionFilter? filter,
  }) async {
    final all = await getTransactions(userId: userId, filter: filter);
    return all.length;
  }

  /// Ferme la base de données (utile pour les tests)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
