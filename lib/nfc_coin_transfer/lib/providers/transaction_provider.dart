import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_summary.dart';
import '../services/transaction_service.dart';

/// États possibles du chargement
enum LoadingState { idle, loading, success, error }

/// Provider de gestion d'état pour les transactions (ChangeNotifier)
class TransactionProvider extends ChangeNotifier {
  final TransactionService _service;

  TransactionProvider({TransactionService? service})
      : _service = service ?? TransactionService();

  // ───────────────────────── STATE ─────────────────────────

  List<Transaction> _transactions = [];
  TransactionSummary _summary = TransactionSummary.empty();
  TransactionFilter _filter = const TransactionFilter();
  LoadingState _state = LoadingState.idle;
  String? _errorMessage;
  String? _currentUserId;
  int _currentPage = 0;
  bool _hasMore = true;

  static const int _pageSize = 20;

  // ───────────────────────── GETTERS ─────────────────────────

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  TransactionSummary get summary => _summary;
  TransactionFilter get filter => _filter;
  LoadingState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadingState.loading;
  bool get hasMore => _hasMore;
  bool get hasError => _state == LoadingState.error;
  int get filterCount => _filter.activeCount;

  // ───────────────────────── INITIALISATION ─────────────────────────

  /// Initialise le provider pour un utilisateur donné
  Future<void> init(String userId) async {
    _currentUserId = userId;
    _currentPage = 0;
    _transactions = [];
    _hasMore = true;
    await Future.wait([
      loadTransactions(),
      loadSummary(),
    ]);
  }

  // ───────────────────────── CHARGEMENT ─────────────────────────

  /// Charge la première page de transactions
  Future<void> loadTransactions() async {
    if (_currentUserId == null) return;
    _setState(LoadingState.loading);
    _currentPage = 0;

    try {
      final results = await _service.getHistory(
        userId: _currentUserId!,
        filter: _filter,
        page: 0,
        pageSize: _pageSize,
      );
      _transactions = results;
      _hasMore = results.length == _pageSize;
      _setState(LoadingState.success);
    } catch (e) {
      _setError('Erreur lors du chargement: $e');
    }
  }

  /// Charge la page suivante (pagination infinie)
  Future<void> loadMore() async {
    if (_currentUserId == null || !_hasMore || isLoading) return;
    _currentPage++;

    try {
      final results = await _service.getHistory(
        userId: _currentUserId!,
        filter: _filter,
        page: _currentPage,
        pageSize: _pageSize,
      );
      _transactions = [..._transactions, ...results];
      _hasMore = results.length == _pageSize;
      notifyListeners();
    } catch (e) {
      _currentPage--;
      _setError('Erreur de pagination: $e');
    }
  }

  /// Recharge les données (pull-to-refresh)
  Future<void> refresh() async {
    await Future.wait([loadTransactions(), loadSummary()]);
  }

  /// Charge les statistiques de l'utilisateur
  Future<void> loadSummary() async {
    if (_currentUserId == null) return;
    try {
      _summary = await _service.getSummary(_currentUserId!);
      notifyListeners();
    } catch (_) {
      // Silencieux — les stats ne bloquent pas l'affichage
    }
  }

  // ───────────────────────── FILTRES ─────────────────────────

  /// Applique un nouveau filtre et recharge
  Future<void> applyFilter(TransactionFilter newFilter) async {
    _filter = newFilter;
    await loadTransactions();
  }

  /// Réinitialise tous les filtres
  Future<void> clearFilter() async {
    _filter = const TransactionFilter();
    await loadTransactions();
  }

  // ───────────────────────── ACTIONS ─────────────────────────

  /// Ajoute une nouvelle transaction (appelé après succès NFC)
  Future<Transaction?> addTransaction({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required double amount,
    required TransactionType type,
    String? note,
    String? nfcTagId,
  }) async {
    try {
      final t = await _service.createTransaction(
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        receiverName: receiverName,
        amount: amount,
        type: type,
        note: note,
        nfcTagId: nfcTagId,
      );
      // Insère en tête de liste pour un affichage immédiat
      _transactions = [t, ..._transactions];
      await loadSummary();
      notifyListeners();
      return t;
    } catch (e) {
      _setError('Impossible de créer la transaction: $e');
      return null;
    }
  }

  /// Confirme une transaction en attente
  Future<void> confirmTransaction(String transactionId) async {
    try {
      final updated = await _service.confirmTransaction(transactionId);
      if (updated != null) {
        _updateInList(updated);
        await loadSummary();
      }
    } catch (e) {
      _setError('Erreur de confirmation: $e');
    }
  }

  /// Supprime une transaction de l'historique
  Future<void> deleteTransaction(String id) async {
    try {
      await _service.deleteTransaction(id);
      _transactions = _transactions.where((t) => t.id != id).toList();
      await loadSummary();
      notifyListeners();
    } catch (e) {
      _setError('Erreur de suppression: $e');
    }
  }

  /// Efface tout l'historique
  Future<void> clearHistory() async {
    if (_currentUserId == null) return;
    try {
      await _service.clearHistory(_currentUserId!);
      _transactions = [];
      _summary = TransactionSummary.empty();
      _setState(LoadingState.success);
    } catch (e) {
      _setError('Erreur lors de la suppression: $e');
    }
  }

  // ───────────────────────── HELPERS PRIVÉS ─────────────────────────

  void _updateInList(Transaction updated) {
    _transactions = _transactions.map((t) {
      return t.id == updated.id ? updated : t;
    }).toList();
    notifyListeners();
  }

  void _setState(LoadingState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _state = LoadingState.error;
    _errorMessage = message;
    notifyListeners();
  }
}
