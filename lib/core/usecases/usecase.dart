/// Classe abstraite définissant le contrat d'un cas d'utilisation.
///
/// Chaque use case encapsule **une seule action métier**.
///
/// - [Type] : le type de retour du use case.
/// - [Params] : le type des paramètres d'entrée.
///
/// Utiliser [NoParams] quand le use case n'a pas de paramètre.
///
/// Exemple :
/// ```dart
/// class GetSoldeUseCase extends UseCase<Wallet, String> {
///   final WalletRepository repository;
///   GetSoldeUseCase(this.repository);
///
///   @override
///   Future<Type> call(String utilisateurId) {
///     return repository.getWallet(utilisateurId);
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  /// Exécute le cas d'utilisation avec les [params] donnés.
  Future<Type> call(Params params);
}

/// Classe sentinelle pour les use cases sans paramètre.
///
/// Exemple :
/// ```dart
/// class LogoutUseCase extends UseCase<void, NoParams> {
///   @override
///   Future<void> call(NoParams params) => repository.logout();
/// }
///
/// // Appel :
/// await logoutUseCase(NoParams());
/// ```
class NoParams {
  const NoParams();
}
