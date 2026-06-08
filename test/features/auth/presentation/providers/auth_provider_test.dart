import 'package:flutter_test/flutter_test.dart';
import 'package:mon_projet_nfc/features/auth/domain/entities/utilisateur.dart';
import 'package:mon_projet_nfc/features/auth/domain/repositories/auth_repository.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/login_usecase.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/get_utilisateur_connecte_usecase.dart';
import 'package:mon_projet_nfc/features/auth/presentation/providers/auth_provider.dart';

/// Mock manuel du AuthRepository pour tester le provider.
class MockAuthRepository implements AuthRepository {
  Utilisateur? loginResult;
  Utilisateur? utilisateurConnecte;
  Exception? loginException;
  Exception? logoutException;
  bool logoutCalled = false;

  @override
  Future<Utilisateur> login(String email, String motDePasse) async {
    if (loginException != null) throw loginException!;
    return loginResult!;
  }

  @override
  Future<void> logout() async {
    if (logoutException != null) throw logoutException!;
    logoutCalled = true;
  }

  @override
  Future<Utilisateur?> getUtilisateurConnecte() async {
    return utilisateurConnecte;
  }
}

void main() {
  late AuthProvider provider;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    provider = AuthProvider(
      loginUseCase: LoginUseCase(mockRepository),
      logoutUseCase: LogoutUseCase(mockRepository),
      getUtilisateurConnecteUseCase:
          GetUtilisateurConnecteUseCase(mockRepository),
    );
  });

  const tUtilisateur = Utilisateur(
    id: 'user-001',
    email: 'test@example.com',
    estConnecte: true,
  );

  group('AuthProvider — état initial', () {
    test('devrait avoir le status initial', () {
      expect(provider.status, AuthStatus.initial);
      expect(provider.utilisateur, isNull);
      expect(provider.errorMessage, isNull);
      expect(provider.isAuthenticated, false);
    });
  });

  group('AuthProvider — login', () {
    test('devrait passer à authenticated après un login réussi', () async {
      mockRepository.loginResult = tUtilisateur;

      await provider.login('test@example.com', 'password123');

      expect(provider.status, AuthStatus.authenticated);
      expect(provider.utilisateur, isNotNull);
      expect(provider.utilisateur!.email, 'test@example.com');
      expect(provider.isAuthenticated, true);
    });

    test('devrait passer à error après un login échoué', () async {
      mockRepository.loginException = Exception('Identifiants incorrects');

      await provider.login('wrong@example.com', 'badpass');

      expect(provider.status, AuthStatus.error);
      expect(provider.errorMessage, isNotNull);
      expect(provider.isAuthenticated, false);
    });
  });

  group('AuthProvider — logout', () {
    test('devrait passer à unauthenticated après un logout réussi', () async {
      mockRepository.loginResult = tUtilisateur;
      await provider.login('test@example.com', 'password123');

      await provider.logout();

      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.utilisateur, isNull);
      expect(provider.isAuthenticated, false);
    });

    test('devrait passer à error si le logout échoue', () async {
      mockRepository.loginResult = tUtilisateur;
      await provider.login('test@example.com', 'password123');

      mockRepository.logoutException = Exception('Erreur de déconnexion');

      await provider.logout();

      expect(provider.status, AuthStatus.error);
      expect(provider.errorMessage, isNotNull);
    });
  });

  group('AuthProvider — checkSession', () {
    test('devrait être authenticated quand une session existe', () async {
      mockRepository.utilisateurConnecte = tUtilisateur;

      await provider.checkSession();

      expect(provider.status, AuthStatus.authenticated);
      expect(provider.utilisateur, isNotNull);
    });

    test('devrait être unauthenticated quand aucune session n\'existe',
        () async {
      mockRepository.utilisateurConnecte = null;

      await provider.checkSession();

      expect(provider.status, AuthStatus.unauthenticated);
      expect(provider.utilisateur, isNull);
    });
  });
}
