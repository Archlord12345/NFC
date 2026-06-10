import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mon_projet_nfc/main.dart';
import 'package:mon_projet_nfc/features/auth/presentation/providers/auth_provider.dart';
import 'package:mon_projet_nfc/features/auth/domain/entities/utilisateur.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/login_usecase.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/register_usecase.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/get_utilisateur_connecte_usecase.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/login_with_biometrics_usecase.dart';
import 'package:mon_projet_nfc/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:mon_projet_nfc/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Utilisateur> login(String email, String motDePasse) async {
    return const Utilisateur(id: '1', email: 'a@a.com', firstname: 'Test', lastname: 'User', estConnecte: true);
  }

  @override
  Future<Utilisateur> register(String email, String motDePasse, String firstname, String lastname) async {
    return const Utilisateur(id: '1', email: 'a@a.com', firstname: 'Test', lastname: 'User', estConnecte: true);
  }

  @override
  Future<Utilisateur> loginWithBiometrics() async {
    return const Utilisateur(id: '1', email: 'a@a.com', firstname: 'Test', lastname: 'User', estConnecte: true);
  }

  @override
  Future<void> updateProfile(String id, String firstname, String lastname) async {}

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
          registerUseCase: RegisterUseCase(repository),
          logoutUseCase: LogoutUseCase(repository),
          getUtilisateurConnecteUseCase: GetUtilisateurConnecteUseCase(repository),
          loginWithBiometricsUseCase: LoginWithBiometricsUseCase(repository),
          updateProfileUseCase: UpdateProfileUseCase(repository),
        )..checkSession(),
        child: const NfcCashApp(),
      ),
    );

    // Au début on devrait voir le splash screen (loading)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Attendre que la session soit vérifiée et que l'on arrive sur la page de login
    await tester.pumpAndSettle();

    // La page de login contient l'icône nfc_rounded
    expect(find.byIcon(Icons.nfc_rounded), findsAtLeast(1));
  });
}
