import 'package:flutter_test/flutter_test.dart';
import 'package:mon_projet_nfc/features/auth/data/models/utilisateur_model.dart';

void main() {
  group('UtilisateurModel', () {
    const tModel = UtilisateurModel(
      id: 'user-001',
      email: 'test@example.com',
      estConnecte: true,
      motDePasseHash: 'abc123hash',
    );

    final tMap = {
      'id': 'user-001',
      'email': 'test@example.com',
      'mot_de_passe_hash': 'abc123hash',
      'est_connecte': 1,
    };

    test('devrait être une sous-classe de Utilisateur', () {
      expect(tModel, isA<UtilisateurModel>());
    });

    group('fromMap', () {
      test('devrait retourner un modèle valide depuis un Map SQLite', () {
        final result = UtilisateurModel.fromMap(tMap);

        expect(result.id, 'user-001');
        expect(result.email, 'test@example.com');
        expect(result.estConnecte, true);
        expect(result.motDePasseHash, 'abc123hash');
      });

      test('devrait convertir est_connecte=0 en false', () {
        final mapDeconnecte = {
          'id': 'user-002',
          'email': 'other@example.com',
          'mot_de_passe_hash': 'xyz789',
          'est_connecte': 0,
        };

        final result = UtilisateurModel.fromMap(mapDeconnecte);
        expect(result.estConnecte, false);
      });
    });

    group('toMap', () {
      test('devrait retourner un Map correct pour SQLite', () {
        final result = tModel.toMap();

        expect(result['id'], 'user-001');
        expect(result['email'], 'test@example.com');
        expect(result['mot_de_passe_hash'], 'abc123hash');
        expect(result['est_connecte'], 1);
      });

      test('devrait convertir estConnecte=false en 0', () {
        const modelDeconnecte = UtilisateurModel(
          id: 'user-003',
          email: 'off@example.com',
          estConnecte: false,
          motDePasseHash: 'hash000',
        );

        final result = modelDeconnecte.toMap();
        expect(result['est_connecte'], 0);
      });
    });

    test('fromMap puis toMap devrait retourner le même Map', () {
      final model = UtilisateurModel.fromMap(tMap);
      final result = model.toMap();

      expect(result, tMap);
    });
  });
}
