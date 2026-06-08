import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_summary.dart';
import 'database_service.dart';

/// Service métier pour la gestion des transactions NFC
class TransactionService {
  final DatabaseService _db;
  final _uuid = const Uuid();

  TransactionService({DatabaseService? databaseService})
      : _db = databaseService ?? DatabaseService();

  // ───────────────────────── CRÉATION ─────────────────────────

  /// Crée et persiste une nouvelle transaction NFC
  Future<Transaction> createTransaction({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required double amount,
    required TransactionType type,
    String? note,
    String? nfcTagId,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Le montant doit être supérieur à zéro.');
    }

    final transaction = Transaction(
      id: _uuid.v4(),
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      amount: amount,
      type: type,
      status: TransactionStatus.pending,
      timestamp: DateTime.now(),
      note: note,
      nfcTagId: nfcTagId,
    );

    await _db.insertTransaction(transaction);
    return transaction;
  }

  /// Confirme une transaction après succès NFC
  Future<Transaction?> confirmTransaction(String transactionId) async {
    await _db.updateTransactionStatus(
      transactionId,
      TransactionStatus.completed,
    );
    return _db.getTransactionById(transactionId);
  }

  /// Marque une transaction comme échouée
  Future<void> failTransaction(String transactionId) async {
    await _db.updateTransactionStatus(
      transactionId,
      TransactionStatus.failed,
    );
  }

  /// Annule une transaction en attente
  Future<void> cancelTransaction(String transactionId) async {
    final t = await _db.getTransactionById(transactionId);
    if (t == null) return;
    if (t.status != TransactionStatus.pending) {
      throw StateError(
        'Seules les transactions en attente peuvent être annulées.',
      );
    }
    await _db.updateTransactionStatus(
      transactionId,
      TransactionStatus.cancelled,
    );
  }

  // ───────────────────────── LECTURE ─────────────────────────

  /// Récupère l'historique des transactions avec filtres
  Future<List<Transaction>> getHistory({
    required String userId,
    TransactionFilter? filter,
    int page = 0,
    int pageSize = 20,
  }) async {
    return _db.getTransactions(
      userId: userId,
      filter: filter,
      limit: pageSize,
      offset: page * pageSize,
    );
  }

  /// Récupère les transactions récentes (pour le tableau de bord)
  Future<List<Transaction>> getRecentTransactions({
    required String userId,
    int limit = 5,
  }) async {
    return _db.getTransactions(userId: userId, limit: limit);
  }

  /// Récupère le détail d'une transaction
  Future<Transaction?> getTransactionDetail(String id) async {
    return _db.getTransactionById(id);
  }

  /// Calcule le résumé statistique
  Future<TransactionSummary> getSummary(String userId) async {
    return _db.getTransactionSummary(userId);
  }

  // ───────────────────────── SUPPRESSION ─────────────────────────

  /// Supprime une transaction de l'historique
  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
  }

  /// Efface tout l'historique d'un utilisateur
  Future<void> clearHistory(String userId) async {
    await _db.deleteUserHistory(userId);
  }

  // ───────────────────────── SEED (Développement) ─────────────────────────

  /// Génère des transactions fictives pour les tests
  Future<void> seedDemoData(String userId) async {
    final now = DateTime.now();
    final demos = [
      Transaction(
        id: _uuid.v4(),
        senderId: userId,
        senderName: 'Moi',
        receiverId: 'user_002',
        receiverName: 'Alice Mbarga',
        amount: 5000,
        type: TransactionType.transfer,
        status: TransactionStatus.completed,
        timestamp: now.subtract(const Duration(hours: 2)),
        note: 'Remboursement déjeuner',
        nfcTagId: 'NFC_ABC123',
      ),
      Transaction(
        id: _uuid.v4(),
        senderId: 'user_003',
        senderName: 'Bob Essono',
        receiverId: userId,
        receiverName: 'Moi',
        amount: 12500,
        type: TransactionType.receive,
        status: TransactionStatus.completed,
        timestamp: now.subtract(const Duration(days: 1)),
        nfcTagId: 'NFC_DEF456',
      ),
      Transaction(
        id: _uuid.v4(),
        senderId: userId,
        senderName: 'Moi',
        receiverId: 'user_004',
        receiverName: 'Claire Ngo',
        amount: 3000,
        type: TransactionType.transfer,
        status: TransactionStatus.failed,
        timestamp: now.subtract(const Duration(days: 2)),
        note: 'Erreur NFC',
      ),
      Transaction(
        id: _uuid.v4(),
        senderId: 'user_005',
        senderName: 'David Ateba',
        receiverId: userId,
        receiverName: 'Moi',
        amount: 25000,
        type: TransactionType.receive,
        status: TransactionStatus.completed,
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: _uuid.v4(),
        senderId: userId,
        senderName: 'Moi',
        receiverId: 'user_006',
        receiverName: 'Eva Moto',
        amount: 8000,
        type: TransactionType.transfer,
        status: TransactionStatus.pending,
        timestamp: now.subtract(const Duration(minutes: 30)),
        note: 'En attente confirmation',
      ),
    ];

    await _db.insertTransactions(demos);
  }
}
