import 'package:flutter/material.dart';
import '../../domain/entities/utilisateur.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_utilisateur_connecte_usecase.dart';
import '../../domain/usecases/login_with_biometrics_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

/// États possibles de l'authentification.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Provider gérant l'état d'authentification.
class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetUtilisateurConnecteUseCase _getUtilisateurConnecteUseCase;
  final LoginWithBiometricsUseCase _loginWithBiometricsUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetUtilisateurConnecteUseCase getUtilisateurConnecteUseCase,
    required LoginWithBiometricsUseCase loginWithBiometricsUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getUtilisateurConnecteUseCase = getUtilisateurConnecteUseCase,
        _loginWithBiometricsUseCase = loginWithBiometricsUseCase,
        _updateProfileUseCase = updateProfileUseCase;

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
  Future<void> register(String email, String motDePasse, String firstname, String lastname) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _utilisateur = await _registerUseCase(email, motDePasse, firstname, lastname);
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

  /// Connecte l'utilisateur avec la biométrie.
  Future<void> loginWithBiometrics() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _utilisateur = await _loginWithBiometricsUseCase();
      _status = AuthStatus.authenticated;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
    }
    notifyListeners();
  }

  /// Met à jour le profil utilisateur.
  Future<void> updateProfile(String firstname, String lastname) async {
    if (_utilisateur == null) return;
    
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _updateProfileUseCase(_utilisateur!.id, firstname, lastname);
      _utilisateur = Utilisateur(
        id: _utilisateur!.id,
        email: _utilisateur!.email,
        firstname: firstname,
        lastname: lastname,
        estConnecte: _utilisateur!.estConnecte,
      );
      _status = AuthStatus.authenticated;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
    }
    notifyListeners();
  }
}
