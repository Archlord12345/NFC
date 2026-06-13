/// Constantes de chaînes de caractères utilisées dans l'application.
///
/// Centralise tous les textes pour faciliter la traduction future
/// et éviter les chaînes en dur dans le code.
class AppStrings {
  AppStrings._();

  // ── Application ──
  static const String appName = 'PAP (PAYPOINT)';
  static const String appTagline = 'Secure. Fast. Effortless.';

  // ── Authentification ──
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String useBiometrics = 'Use Biometrics';
  static const String noAccount = "Don't have an account?";
  static const String signUp = 'Sign Up';
  static const String loginSuccess = 'Connexion réussie';
  static const String loginError = 'Identifiants incorrects';
  static const String emailRequired = 'Veuillez entrer votre e-mail';
  static const String emailInvalid = 'E-mail invalide';
  static const String passwordRequired = 'Veuillez entrer votre mot de passe';

  // ── Wallet ──
  static const String wallet = 'Wallet';
  static const String totalBalance = 'TOTAL BALANCE';
  static const String recharge = 'Recharge';
  static const String sendViaNfc = 'Send via NFC';
  static const String recentTransactions = 'Recent Transactions';
  static const String viewAll = 'View All';
  static const String rechargeAmount = 'Montant de la recharge';
  static const String insufficientBalance = 'Solde insuffisant';

  // ── NFC ──
  static const String searchingDevices = 'Searching for devices...';
  static const String holdPhoneNear =
      'Hold your phone near another device to transfer funds.';
  static const String rescanDevices = 'Rescan Devices';
  static const String nfcActive = 'NFC ACTIVE';
  static const String transferSuccessful = 'Transfer Successful';
  static const String transferProcessed =
      'Your transaction has been processed securely.';
  static const String downloadReceipt = 'Download Receipt';
  static const String backToHome = 'Back to Home';

  // ── Statuts de transaction ──
  static const String statusPending = 'En attente';
  static const String statusCompleted = 'Completed';
  static const String statusFailed = 'Échoué';

  // ── Navigation ──
  static const String home = 'Home';
  static const String history = 'History';
  static const String profile = 'Profile';

  // ── Erreurs ──
  static const String unexpectedError = 'Une erreur inattendue est survenue';
  static const String databaseError = 'Erreur de base de données';
  static const String nfcError = 'Erreur de communication NFC';
}
