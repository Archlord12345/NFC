import 'package:flutter_test/flutter_test.dart';
import 'package:mon_projet_nfc/features/auth/domain/entities/utilisateur.dart';
import 'package:mon_projet_nfc/features/auth/domain/repositories/auth_repository.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/login_usecase.dart';

/// Mock manuel du AuthRepository pour les tests domain.
class MockAuthRepository implements AuthRepository {
  Utilisateur? loginResult;
  Utilisateur? utilisateurConnecte;
  Exception? loginException;
  bool logoutCalled = false;

  @override
  Future<Utilisateur> login(String email, String motDePasse) async {
    if (loginException != null) throw loginException!;
    return loginResult!;
  }

  @override
  Future<Utilisateur> register(String email, String motDePasse, String firstname, String lastname) async {
    throw UnimplementedError();
  }

  @override
  Future<Utilisateur> loginWithBiometrics() => throw UnimplementedError();

  @override
  Future<void> updateProfile(String id, String firstname, String lastname) => throw UnimplementedError();

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<Utilisateur?> getUtilisateurConnecte() async {
    return utilisateurConnecte;
  }
}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const tUtilisateur = Utilisateur(
    id: 'user-001',
    email: 'test@example.com',
    firstname: 'John',
    lastname: 'Doe',
    estConnecte: true,
  );

  group('LoginUseCase', () {
    test('devrait retourner un Utilisateur quand le login réussit', () async {
      mockRepository.loginResult = tUtilisateur;

      final result = await useCase('test@example.com', 'password123');

      expect(result, isA<Utilisateur>());
      expect(result.id, 'user-001');
      expect(result.email, 'test@example.com');
      expect(result.estConnecte, true);
    });

    test('devrait propager l\'exception quand le login échoue', () async {
      mockRepository.loginException = Exception('Identifiants incorrects');

      expect(
        () => useCase('wrong@example.com', 'badpass'),
        throwsException,
      );
    });
  });
}
