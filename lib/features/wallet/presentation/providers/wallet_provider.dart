import '../../../../core/services/notification_service.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/usecases/get_historique_usecase.dart';
import '../../domain/usecases/get_wallet_usecase.dart';
import '../../domain/usecases/recharger_usecase.dart';
import '../../domain/usecases/transfert_nfc_usecase.dart';

/// États possibles du wallet.
enum WalletStatus { initial, loading, loaded, error }

/// State management du module Wallet.
class WalletProvider extends ChangeNotifier {
  final GetWalletUseCase _getWallet;
  final GetHistoriqueUseCase _getHistorique;
  final RechargerUseCase _recharger;
  final TransfertNfcUseCase _transfertNfc;

  WalletProvider({
    required GetWalletUseCase getWallet,
    required GetHistoriqueUseCase getHistorique,
    required RechargerUseCase recharger,
    required TransfertNfcUseCase transfertNfc,
  })  : _getWallet = getWallet,
        _getHistorique = getHistorique,
        _recharger = recharger,
        _transfertNfc = transfertNfc;

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

  List<TransactionEntity> get transactionsRecentes =>
      _transactions.take(5).toList();

  // ─── Actions ──────────────────────────────────────────────────────────────

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

  Future<void> rafraichirHistorique() async {
    if (_wallet == null) return;
    try {
      _transactions = await _getHistorique(_wallet!.id);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> recharger(double montant) async {
    // ... (rest of code)
    try {
      await _recharger(
        RechargerParams(walletId: _wallet!.id, montant: montant),
      );
      _wallet = await _getWallet(_wallet!.utilisateurId);
      _transactions = await _getHistorique(_wallet!.id);
      _isRecharging = false;
      notifyListeners();
      
      // Notification
      NotificationService.showNotification('Recharge réussie', 'Votre solde a été mis à jour.');
      
      return true;
    } catch (e) {
      // ...
    }
  }

  Future<bool> transfertNfc({
    required double montant,
    required bool isEnvoi,
    String? peerWalletId,
  }) async {
    // ... (rest of code)
    try {
      await _transfertNfc(
        TransfertNfcParams(
          walletId: _wallet!.id,
          montant: montant,
          isEnvoi: isEnvoi,
          peerWalletId: peerWalletId,
        ),
      );
      _wallet = await _getWallet(_wallet!.utilisateurId);
      _transactions = await _getHistorique(_wallet!.id);
      _isRecharging = false;
      notifyListeners();
      
      // Notification
      NotificationService.showNotification(
        'Transaction réussie', 
        isEnvoi ? 'Envoi de $montant XAF effectué.' : 'Réception de $montant XAF effectuée.'
      );
      
      return true;
    } catch (e) {
      // ...
    }
  }

  // ─── Helpers privés ───────────────────────────────────────────────────────

  void _setStatus(WalletStatus status) {
    _status = status;
    notifyListeners();
  }
}
