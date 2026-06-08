import 'package:flutter/foundation.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/usecases/get_historique_usecase.dart';
import '../../domain/usecases/get_wallet_usecase.dart';
import '../../domain/usecases/recharger_usecase.dart';

/// États possibles du wallet.
enum WalletStatus { initial, loading, loaded, error }

/// State management du module Wallet.
///
/// Expose le wallet courant, l'historique de transactions,
/// et les opérations de recharge.
/// Doit être fourni via [ChangeNotifierProvider] dans le widget tree.
class WalletProvider extends ChangeNotifier {
  final GetWalletUseCase _getWallet;
  final GetHistoriqueUseCase _getHistorique;
  final RechargerUseCase _recharger;

  WalletProvider({
    required GetWalletUseCase getWallet,
    required GetHistoriqueUseCase getHistorique,
    required RechargerUseCase recharger,
  })  : _getWallet = getWallet,
        _getHistorique = getHistorique,
        _recharger = recharger;

  // ─── État ─────────────────────────────────────────────────────────────────

  Wallet? _wallet;
  List<TransactionEntity> _transactions = [];
  WalletStatus _status = WalletStatus.initial;
  String? _errorMessage;
  bool _isRecharging = false;

  // ─── Getters ──────────────────────────────────────────────────────────────

  Wallet? get wallet => _wallet;
  List<TransactionEntity> get transactions => _transactions;
  WalletStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isRecharging => _isRecharging;
  bool get isLoaded => _status == WalletStatus.loaded;

  /// Retourne les 5 dernières transactions (pour l'aperçu).
  List<TransactionEntity> get transactionsRecentes =>
      _transactions.take(5).toList();

  // ─── Actions ──────────────────────────────────────────────────────────────

  /// WA-1 : Charge le wallet et l'historique de l'utilisateur [utilisateurId].
  Future<void> chargerWallet(String utilisateurId) async {
    _setStatus(WalletStatus.loading);

    try {
      _wallet = await _getWallet(utilisateurId);
      _transactions = await _getHistorique(_wallet!.id);
      _setStatus(WalletStatus.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(WalletStatus.error);
    }
  }

  /// WA-2 : Rafraîchit uniquement l'historique (sans recharger le wallet).
  Future<void> rafraichirHistorique() async {
    if (_wallet == null) return;
    try {
      _transactions = await _getHistorique(_wallet!.id);
      notifyListeners();
    } catch (_) {}
  }

  /// WA-3 : Recharge le wallet du [montant] donné.
  /// Retourne `true` en cas de succès, `false` sinon.
  Future<bool> recharger(double montant) async {
    if (_wallet == null) return false;

    _isRecharging = true;
    notifyListeners();

    try {
      await _recharger(
        RechargerParams(walletId: _wallet!.id, montant: montant),
      );
      // Rafraîchissement du wallet et de l'historique après recharge
      _wallet = await _getWallet(_wallet!.utilisateurId);
      _transactions = await _getHistorique(_wallet!.id);
      _isRecharging = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isRecharging = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Helpers privés ───────────────────────────────────────────────────────

  void _setStatus(WalletStatus status) {
    _status = status;
    notifyListeners();
  }
}
