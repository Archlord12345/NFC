import 'package:flutter_test/flutter_test.dart';
import 'package:mon_projet_nfc/features/auth/domain/entities/utilisateur.dart';
import 'package:mon_projet_nfc/features/auth/domain/repositories/auth_repository.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/get_utilisateur_connecte_usecase.dart';

class MockAuthRepository implements AuthRepository {
  Utilisateur? utilisateurConnecte;

  @override
  Future<Utilisateur?> getUtilisateurConnecte() async {
    return utilisateurConnecte;
  }

  @override
  Future<Utilisateur> login(String email, String motDePasse) => throw UnimplementedError();
  @override
  Future<Utilisateur> register(String email, String motDePasse) => throw UnimplementedError();
  @override
  Future<void> logout() => throw UnimplementedError();
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
    test('devrait retourner l\'utilisateur quand une session est active', () async {
      mockRepository.utilisateurConnecte = tUtilisateur;
      final result = await useCase();
      expect(result, tUtilisateur);
    });

    test('devrait retourner null quand aucune session n\'est active', () async {
      mockRepository.utilisateurConnecte = null;
      final result = await useCase();
      expect(result, isNull);
    });
  });
}
