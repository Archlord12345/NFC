/// Entité métier représentant un utilisateur.
///
/// Classe Dart pure — aucune dépendance externe.
/// Utilisée par les use cases et la couche présentation.
class Utilisateur {
  final String id;
  final String email;
  final bool estConnecte;

  const Utilisateur({
    required this.id,
    required this.email,
    required this.estConnecte,
  });
}
