import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mon_projet_nfc/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture des écrans de l\'application', (WidgetTester tester) async {
    // Lancer l'application
    app.main();
    await tester.pumpAndSettle();

    // 1. Capture écran de connexion
    await binding.takeScreenshot('01_login_screen');

    // Ici, vous ajouteriez la logique de navigation pour tester les autres écrans
    // Exemple: await tester.tap(find.byType(ElevatedButton));
    // await tester.pumpAndSettle();
    // await binding.takeScreenshot('02_wallet_dashboard');
  });
}
