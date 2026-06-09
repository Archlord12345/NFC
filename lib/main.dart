import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/database/database_helper.dart';
import 'core/navigation/main_shell.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/get_utilisateur_connecte_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/nfc/presentation/pages/nfc_scan_page.dart';
import 'features/nfc/presentation/pages/nfc_receipt_page.dart';
import 'features/wallet/data/datasources/wallet_local_datasource.dart';
import 'features/wallet/data/repositories/wallet_repository_impl.dart';
import 'features/wallet/domain/usecases/get_historique_usecase.dart';
import 'features/wallet/domain/usecases/get_wallet_usecase.dart';
import 'features/wallet/domain/usecases/recharger_usecase.dart';
import 'features/wallet/domain/usecases/transfert_nfc_usecase.dart';
import 'features/wallet/presentation/providers/wallet_provider.dart';
import 'features/nfc/presentation/providers/nfc_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la base de données
  final db = await DatabaseHelper.instance.database;

  // Construire la chaîne de dépendances (auth)
  final authDataSource = AuthLocalDataSource(db);
  final authRepository = AuthRepositoryImpl(authDataSource);

  // Construire la chaîne de dépendances (wallet)
  final walletLocalDataSource = WalletLocalDataSource(db);
  final walletRepository = WalletRepositoryImpl(walletLocalDataSource);

  // Use cases
  final getWalletUseCase = GetWalletUseCase(walletRepository);
  final getHistoriqueUseCase = GetHistoriqueUseCase(walletRepository);
  final rechargerUseCase = RechargerUseCase(walletRepository);
  final transfertNfcUseCase = TransfertNfcUseCase(walletRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUseCase: LoginUseCase(authRepository),
            logoutUseCase: LogoutUseCase(authRepository),
            getUtilisateurConnecteUseCase:
                GetUtilisateurConnecteUseCase(authRepository),
          )..checkSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletProvider(
            getWallet: getWalletUseCase,
            getHistorique: getHistoriqueUseCase,
            recharger: rechargerUseCase,
            transfertNfc: transfertNfcUseCase,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => NfcProvider(),
        ),
      ],
      child: const NfcCashApp(),
    ),
  );
}

/// Widget racine de l'application NFC Cash.
class NfcCashApp extends StatelessWidget {
  const NfcCashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Cash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      // Route initiale gérée par le Consumer ci-dessous
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // Pendant le chargement initial
          if (auth.status == AuthStatus.initial ||
              auth.status == AuthStatus.loading) {
            return const _SplashScreen();
          }
          // Si authentifié → shell principal
          if (auth.isAuthenticated) {
            return MainShell(
              onLogout: () => auth.logout(),
            );
          }
          // Sinon → page de connexion
          return const LoginPage();
        },
      ),
      // Routes nommées pour la navigation interne
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(
              builder: (_) => Consumer<AuthProvider>(
                builder: (context, auth, _) => MainShell(
                  onLogout: () => auth.logout(),
                ),
              ),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
            );
          case '/nfc-scan':
            final mode = settings.arguments as NfcMode? ?? NfcMode.receive;
            return MaterialPageRoute(
              builder: (_) => NfcScanPage(mode: mode),
            );
          case '/nfc-receipt':
            return MaterialPageRoute(
              builder: (_) => const NfcReceiptPage(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const LoginPage(),
            );
        }
      },
    );
  }
}

/// Écran de chargement affiché pendant la vérification de session.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nfc_rounded, size: 64, color: AppColors.accent),
            SizedBox(height: 16),
            CircularProgressIndicator(color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
