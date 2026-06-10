/// Entité métier représentant un utilisateur.
///
/// Classe Dart pure — aucune dépendance externe.
/// Utilisée par les use cases et la couche présentation.
class Utilisateur {
  final String id;
  final String email;
  final String firstname;
  final String lastname;
  final bool estConnecte;

  const Utilisateur({
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.estConnecte,
  });
}
