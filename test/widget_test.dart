import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet_nfc/main.dart';
import 'package:mon_projet_nfc/features/auth/presentation/providers/auth_provider.dart';
import 'package:mon_projet_nfc/features/auth/domain/entities/utilisateur.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/login_usecase.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/get_utilisateur_connecte_usecase.dart';
import 'package:mon_projet_nfc/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Utilisateur> login(String email, String motDePasse) async {
    return const Utilisateur(id: '1', email: 'a@a.com', estConnecte: true);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<Utilisateur?> getUtilisateurConnecte() async => null;
}

void main() {
  testWidgets('NfcCashApp smoke test', (WidgetTester tester) async {
    final repository = MockAuthRepository();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(
          loginUseCase: LoginUseCase(repository),
          logoutUseCase: LogoutUseCase(repository),
          getUtilisateurConnecteUseCase: GetUtilisateurConnecteUseCase(repository),
        )..checkSession(),
        child: const NfcCashApp(),
      ),
    );

    // L'application doit démarrer en affichant l'indicateur ou l'icône de splash
    expect(find.byIcon(Icons.nfc_rounded), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
