import 'package:flutter_test/flutter_test.dart';
import 'package:mon_projet_nfc/features/auth/domain/entities/utilisateur.dart';
import 'package:mon_projet_nfc/features/auth/domain/repositories/auth_repository.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository implements AuthRepository {
  bool logoutCalled = false;
  Exception? logoutException;

  @override
  Future<void> logout() async {
    if (logoutException != null) throw logoutException!;
    logoutCalled = true;
  }

  @override
  Future<Utilisateur> login(String email, String motDePasse) => throw UnimplementedError();
  @override
  Future<Utilisateur> register(String email, String motDePasse, String firstname, String lastname) => throw UnimplementedError();
  @override
  Future<Utilisateur?> getUtilisateurConnecte() => throw UnimplementedError();
  @override
  Future<Utilisateur> loginWithBiometrics() => throw UnimplementedError();
  @override
  Future<void> updateProfile(String id, String firstname, String lastname) => throw UnimplementedError();
}

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  group('LogoutUseCase', () {
    test('devrait appeler logout sur le repository', () async {
      await useCase();
      expect(mockRepository.logoutCalled, true);
    });

    test('devrait propager l\'exception quand le logout échoue', () async {
      mockRepository.logoutException = Exception('Erreur logout');
      expect(() => useCase(), throwsException);
    });
  });
}
