/// Exceptions personnalisées pour la couche data.
///
/// Ces exceptions sont levées par les data sources
/// et converties en [Failure] par les repositories.

/// Exception levée lorsqu'une requête SQLite échoue.
class DatabaseException implements Exception {
  final String message;
  const DatabaseException([this.message = 'Erreur de base de données']);

  @override
  String toString() => 'DatabaseException: $message';
}

/// Exception levée lors d'un échec d'authentification.
class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Identifiants incorrects']);

  @override
  String toString() => 'AuthException: $message';
}

/// Exception levée lorsqu'un utilisateur ou une ressource n'est pas trouvé.
class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Ressource introuvable']);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception levée lorsque le solde est insuffisant pour un transfert.
class InsufficientBalanceException implements Exception {
  final String message;
  const InsufficientBalanceException(
      [this.message = 'Solde insuffisant pour cette opération']);

  @override
  String toString() => 'InsufficientBalanceException: $message';
}

/// Exception levée lors d'un échec de communication NFC.
class NfcException implements Exception {
  final String message;
  const NfcException([this.message = 'Erreur de communication NFC']);

  @override
  String toString() => 'NfcException: $message';
}
