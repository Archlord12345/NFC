import 'package:flutter_test/flutter_test.dart';
import 'package:mon_projet_nfc/features/auth/domain/entities/utilisateur.dart';
import 'package:mon_projet_nfc/features/auth/domain/repositories/auth_repository.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/logout_usecase.dart';

/// Mock manuel du AuthRepository.
class MockAuthRepository implements AuthRepository {
  bool logoutCalled = false;
  Exception? logoutException;

  @override
  Future<Utilisateur> login(String email, String motDePasse) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    if (logoutException != null) throw logoutException!;
    logoutCalled = true;
  }

  @override
  Future<Utilisateur?> getUtilisateurConnecte() async => null;
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
      mockRepository.logoutException = Exception('Erreur de déconnexion');

      expect(() => useCase(), throwsException);
    });
  });
}
