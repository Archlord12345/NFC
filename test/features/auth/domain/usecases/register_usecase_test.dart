import 'package:flutter_test/flutter_test.dart';
import 'package:mon_projet_nfc/features/auth/domain/entities/utilisateur.dart';
import 'package:mon_projet_nfc/features/auth/domain/repositories/auth_repository.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository implements AuthRepository {
  Utilisateur? registerResult;
  Exception? registerException;

  @override
  Future<Utilisateur> register(String email, String motDePasse) async {
    if (registerException != null) throw registerException!;
    return registerResult!;
  }

  @override
  Future<Utilisateur> login(String email, String motDePasse) => throw UnimplementedError();
  @override
  Future<void> logout() => throw UnimplementedError();
  @override
  Future<Utilisateur?> getUtilisateurConnecte() => throw UnimplementedError();
}

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  const tUtilisateur = Utilisateur(
    id: 'user-new',
    email: 'new@example.com',
    estConnecte: true,
  );

  group('RegisterUseCase', () {
    test('devrait retourner un Utilisateur quand l\'inscription réussit', () async {
      mockRepository.registerResult = tUtilisateur;

      final result = await useCase('new@example.com', 'password123');

      expect(result, isA<Utilisateur>());
      expect(result.id, 'user-new');
      expect(result.email, 'new@example.com');
      expect(result.estConnecte, true);
    });

    test('devrait propager l\'exception quand l\'inscription échoue', () async {
      mockRepository.registerException = Exception('Email already exists');

      expect(
        () => useCase('existing@example.com', 'password123'),
        throwsException,
      );
    });
  });
}
