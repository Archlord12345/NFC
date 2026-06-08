/// Classes d'échec métier (Failures).
///
/// Utilisées pour représenter les erreurs de manière typée
/// dans la couche domain, sans exposer les exceptions techniques.

/// Classe de base pour toutes les Failures.
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

/// Échec lié au serveur / base de données.
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Erreur de base de données']);
}

/// Échec lié à l'authentification (identifiants incorrects, session expirée).
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Échec d\'authentification']);
}

/// Échec lié au réseau ou à la connectivité NFC.
class ConnectionFailure extends Failure {
  const ConnectionFailure([super.message = 'Erreur de connexion']);
}

/// Échec lié à une opération sur le wallet (solde insuffisant, etc.).
class WalletFailure extends Failure {
  const WalletFailure([super.message = 'Erreur de portefeuille']);
}

/// Échec lié à une opération NFC (tag non lu, appairage échoué).
class NfcFailure extends Failure {
  const NfcFailure([super.message = 'Erreur NFC']);
}

/// Échec générique / inattendu.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Erreur inattendue']);
}
