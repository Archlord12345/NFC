import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mon_projet_nfc/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture complète des écrans de l\'application', (WidgetTester tester) async {
    // 1. Lancer l'application
    app.main();
    await tester.pumpAndSettle();
    await binding.takeScreenshot('01_login_screen');

    // 2. Simuler une connexion (Note: Assurez-vous d'avoir des données de test ou une logique de bypass)
    // Pour ce TP, nous simulons la navigation vers le dashboard après authentification
    // Si la page de connexion s'affiche, on pourrait remplir le formulaire ici:
    // await tester.enterText(find.byType(TextField).first, 'test@example.com');
    // await tester.enterText(find.byType(TextField).last, 'password123');
    // await tester.tap(find.text('Login'));
    // await tester.pumpAndSettle(const Duration(seconds: 2));

    // 3. Wallet Dashboard (Capture)
    await binding.takeScreenshot('02_wallet_dashboard');

    // 4. Navigate to Settings
    await tester.tap(find.byIcon(Icons.settings)); // Assuming there's a settings icon
    await tester.pumpAndSettle();
    await binding.takeScreenshot('03_settings_screen');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 5. Navigate to History
    await tester.tap(find.text('Tout voir')); 
    await tester.pumpAndSettle();
    await binding.takeScreenshot('04_history_screen');
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 6. Navigate to Transfer Method Selection & Scan
    await tester.tap(find.text('Envoyer')); 
    await tester.pumpAndSettle();
    await binding.takeScreenshot('05_transfer_method_dialog');
    
    // Select NFC/Bluetooth/QuickShare (e.g., NFC)
    await tester.tap(find.text('NFC'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    await binding.takeScreenshot('06_solar_system_scan');
  });
}
