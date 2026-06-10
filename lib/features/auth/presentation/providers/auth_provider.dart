import 'package:flutter/material.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_utilisateur_connecte_usecase.dart';

/// États possibles de l'authentification.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Provider gérant l'état d'authentification.
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetUtilisateurConnecteUseCase _getUtilisateurConnecteUseCase;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetUtilisateurConnecteUseCase getUtilisateurConnecteUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getUtilisateurConnecteUseCase = getUtilisateurConnecteUseCase;

  // ── État ──
  AuthStatus _status = AuthStatus.initial;
  Utilisateur? _utilisateur;
  String? _errorMessage;

  AuthStatus get status => _status;
  Utilisateur? get utilisateur => _utilisateur;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Vérifie si un utilisateur a une session active (au démarrage).
  Future<void> checkSession() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      _utilisateur = await _getUtilisateurConnecteUseCase();
      _status = _utilisateur != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  /// Connecte l'utilisateur avec [email] et [motDePasse].
  Future<void> login(String email, String motDePasse) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _utilisateur = await _loginUseCase(email, motDePasse);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  /// Inscrit un nouvel utilisateur.
  Future<void> register(String email, String motDePasse) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _utilisateur = await _registerUseCase(email, motDePasse);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  /// Déconnecte l'utilisateur courant.
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _logoutUseCase();
      _utilisateur = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
    }
    notifyListeners();
  }
}
