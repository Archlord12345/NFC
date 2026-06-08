import 'package:flutter_test/flutter_test.dart';
import 'package:mon_projet_nfc/features/auth/domain/entities/utilisateur.dart';
import 'package:mon_projet_nfc/features/auth/domain/repositories/auth_repository.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/get_utilisateur_connecte_usecase.dart';

/// Mock manuel du AuthRepository.
class MockAuthRepository implements AuthRepository {
  Utilisateur? utilisateurConnecte;

  @override
  Future<Utilisateur> login(String email, String motDePasse) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<Utilisateur?> getUtilisateurConnecte() async {
    return utilisateurConnecte;
  }
}

void main() {
  late GetUtilisateurConnecteUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetUtilisateurConnecteUseCase(mockRepository);
  });

  const tUtilisateur = Utilisateur(
    id: 'user-001',
    email: 'test@example.com',
    estConnecte: true,
  );

  group('GetUtilisateurConnecteUseCase', () {
    test('devrait retourner l\'utilisateur quand une session est active',
        () async {
      mockRepository.utilisateurConnecte = tUtilisateur;

      final result = await useCase();

      expect(result, isNotNull);
      expect(result!.id, 'user-001');
      expect(result.estConnecte, true);
    });

    test('devrait retourner null quand aucune session n\'est active',
        () async {
      mockRepository.utilisateurConnecte = null;

      final result = await useCase();

      expect(result, isNull);
    });
  });
}
