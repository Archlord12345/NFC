# 📘 Module Auth — Documentation Technique

> Module d'authentification de l'application **NFC Cash**.
> Gère la connexion (e-mail + mot de passe), la déconnexion et la persistance de session via SQLite.

---

## Table des matières

1. [Vue d'ensemble](#1--vue-densemble)
2. [Cas d'utilisation](#2--cas-dutilisation)
3. [Architecture du module](#3--architecture-du-module)
4. [Couche Domain](#4--couche-domain)
5. [Couche Data](#5--couche-data)
6. [Couche Presentation](#6--couche-presentation)
7. [Flux de données](#7--flux-de-données)
8. [Tests unitaires](#8--tests-unitaires)
9. [Intégration dans main.dart](#9--intégration-dans-maindart)

---

## 1 — Vue d'ensemble

Le module **Auth** est le premier point d'entrée de l'application. Il permet :

- La **connexion** de l'utilisateur via e-mail et mot de passe (hashé SHA-256)
- La **déconnexion** sécurisée (mise à jour du flag `est_connecte` en base)
- La **restauration de session** au démarrage (vérification de `est_connecte = 1`)

### Table SQLite associée

```sql
CREATE TABLE utilisateurs (
  id                TEXT PRIMARY KEY,
  email             TEXT UNIQUE NOT NULL,
  mot_de_passe_hash TEXT NOT NULL,
  est_connecte      INTEGER NOT NULL DEFAULT 0
)
```

---

## 2 — Cas d'utilisation

| ID | Nom | Description |
|----|-----|-------------|
| AU-1 | **Connexion** | L'utilisateur saisit e-mail + mot de passe → le système vérifie les identifiants en base → retourne l'utilisateur authentifié |
| AU-2 | **Déconnexion** | L'utilisateur déclenche la déconnexion → le système met `est_connecte = 0` en base |
| AU-3 | **Restauration de session** | Au démarrage, le système vérifie si un utilisateur a `est_connecte = 1` → redirige vers le dashboard ou la page login |

---

## 3 — Architecture du module

```
lib/features/auth/
├── domain/                         ← Logique métier pure
│   ├── entities/
│   │   └── utilisateur.dart
│   ├── repositories/
│   │   └── auth_repository.dart    ← Contrat abstrait
│   └── usecases/
│       ├── login_usecase.dart
│       ├── logout_usecase.dart
│       └── get_utilisateur_connecte_usecase.dart
│
├── data/                           ← Implémentation technique
│   ├── models/
│   │   └── utilisateur_model.dart  ← Sérialisation SQLite
│   ├── datasources/
│   │   └── auth_local_datasource.dart  ← Requêtes Sqflite
│   └── repositories/
│       └── auth_repository_impl.dart   ← Implémente le contrat
│
└── presentation/                   ← Interface utilisateur
    ├── pages/
    │   └── login_page.dart         ← Formulaire de connexion
    └── providers/
        └── auth_provider.dart      ← Gestion d'état (ChangeNotifier)
```

---

## 4 — Couche Domain

### 4.1 Entité : `Utilisateur`

Classe Dart pure sans aucune dépendance externe.

```dart
class Utilisateur {
  final String id;
  final String email;
  final bool estConnecte;
}
```

### 4.2 Contrat : `AuthRepository`

Interface abstraite définissant les opérations disponibles.

```dart
abstract class AuthRepository {
  Future<Utilisateur> login(String email, String motDePasse);
  Future<void> logout();
  Future<Utilisateur?> getUtilisateurConnecte();
}
```

### 4.3 Use Cases

Chaque use case encapsule **une seule action métier** et dépend du contrat (pas de l'implémentation).

| Use Case | Entrée | Sortie | Rôle |
|----------|--------|--------|------|
| `LoginUseCase` | `email`, `motDePasse` | `Future<Utilisateur>` | Connexion de l'utilisateur |
| `LogoutUseCase` | aucune | `Future<void>` | Déconnexion |
| `GetUtilisateurConnecteUseCase` | aucune | `Future<Utilisateur?>` | Vérification de session |

---

## 5 — Couche Data

### 5.1 Modèle : `UtilisateurModel`

Étend `Utilisateur` et ajoute :
- `motDePasseHash` : champ supplémentaire pour la couche data
- `fromMap(Map)` : désérialisation depuis SQLite
- `toMap()` : sérialisation vers SQLite

**Correspondance SQLite ↔ Dart :**

| Colonne SQLite | Champ Dart | Conversion |
|----------------|------------|------------|
| `id` | `id` | direct |
| `email` | `email` | direct |
| `mot_de_passe_hash` | `motDePasseHash` | direct |
| `est_connecte` | `estConnecte` | `1 → true`, `0 → false` |

### 5.2 Data Source : `AuthLocalDataSource`

Requêtes SQLite exécutées :

| Méthode | Requête SQL | Comportement |
|---------|-------------|-------------|
| `login(email, hash)` | `SELECT * FROM utilisateurs WHERE email = ? AND mot_de_passe_hash = ?` + `UPDATE est_connecte = 1` | Lève `AuthException` si résultat vide |
| `logout(id)` | `UPDATE utilisateurs SET est_connecte = 0 WHERE id = ?` | Silencieux |
| `getUtilisateurConnecte()` | `SELECT * FROM utilisateurs WHERE est_connecte = 1` | Retourne `null` si vide |

### 5.3 Repository : `AuthRepositoryImpl`

- **login** : Hash le mot de passe avec `sha256` (package `crypto`) avant de le transmettre au datasource
- **logout** : Récupère l'utilisateur connecté puis appelle `datasource.logout(id)`
- **getUtilisateurConnecte** : Délègue directement au datasource

---

## 6 — Couche Presentation

### 6.1 `AuthProvider` (ChangeNotifier)

Gère les transitions d'état de l'authentification.

**États possibles :**

```
initial → loading → authenticated
                  → unauthenticated
                  → error
```

| Propriété | Type | Description |
|-----------|------|-------------|
| `status` | `AuthStatus` | État courant |
| `utilisateur` | `Utilisateur?` | Utilisateur connecté |
| `errorMessage` | `String?` | Message d'erreur |
| `isAuthenticated` | `bool` | Raccourci pour `status == authenticated` |

**Méthodes :**

| Méthode | Action |
|---------|--------|
| `checkSession()` | Appelle `GetUtilisateurConnecteUseCase` → met à jour le statut |
| `login(email, mdp)` | Appelle `LoginUseCase` → `authenticated` ou `error` |
| `logout()` | Appelle `LogoutUseCase` → `unauthenticated` ou `error` |

### 6.2 `LoginPage`

Page de connexion avec :
- Formulaire `email` + `mot de passe` avec validation
- Bouton **Login** (déclenche `AuthProvider.login`)
- Bouton **Use Biometrics** (prêt pour `local_auth`)
- Lien **Sign Up** (navigation future)
- Lien **Forgot Password?** (navigation future)

---

## 7 — Flux de données

### Connexion (AU-1)

```
┌──────────┐   email/mdp   ┌──────────────┐   call()   ┌──────────────┐
│ LoginPage│ ────────────▶ │ AuthProvider  │ ────────▶ │ LoginUseCase │
└──────────┘               │ (notifyAll)   │           └──────┬───────┘
      ▲                    └──────────────┘                   │
      │                           ▲                           ▼
      │                           │                  ┌────────────────────┐
      │           Utilisateur     │                  │ AuthRepositoryImpl │
      │◀──────────────────────────┘                  │ (sha256 hash)      │
      │                                              └────────┬───────────┘
      │                                                       │
      │                                                       ▼
      │                                              ┌─────────────────────┐
      │                                              │ AuthLocalDataSource │
      │                                              │ (SQLite query)      │
      │                                              └────────┬────────────┘
      │                                                       │
      │                                                       ▼
      │                                                   [SQLite]
      └───────────────────────────── status: authenticated ───┘
```

### Déconnexion (AU-2)

```
LoginPage ← AuthProvider ← LogoutUseCase ← AuthRepositoryImpl ← DataSource ← SQLite
                                                  │
                                        getConnecte() puis logout(id)
                                        UPDATE est_connecte = 0
```

---

## 8 — Tests unitaires

Les tests se trouvent dans `test/features/auth/` et suivent la même structure que le code source.

```
test/features/auth/
├── data/
│   └── models/
│       └── utilisateur_model_test.dart     (7 tests)
├── domain/
│   └── usecases/
│       ├── login_usecase_test.dart          (2 tests)
│       ├── logout_usecase_test.dart         (2 tests)
│       └── get_utilisateur_connecte_usecase_test.dart  (2 tests)
└── presentation/
    └── providers/
        └── auth_provider_test.dart          (6 tests)
```

### Couverture des tests

| Couche | Fichier testé | Scénarios |
|--------|--------------|-----------|
| **Data** | `UtilisateurModel` | `fromMap` valide, conversion 0/1 ↔ bool, `toMap` valide, roundtrip fromMap→toMap |
| **Domain** | `LoginUseCase` | Login réussi → retourne Utilisateur, Login échoué → propage exception |
| **Domain** | `LogoutUseCase` | Logout réussi → appelle repository, Logout échoué → propage exception |
| **Domain** | `GetUtilisateurConnecteUseCase` | Session active → retourne Utilisateur, Pas de session → retourne null |
| **Presentation** | `AuthProvider` | État initial correct, login réussi/échoué, logout réussi/échoué, checkSession avec/sans session |

### Exécution des tests

```bash
# Tous les tests du module auth
flutter test test/features/auth/

# Un fichier spécifique
flutter test test/features/auth/presentation/providers/auth_provider_test.dart
```

---

## 9 — Intégration dans main.dart

Pour brancher le module auth dans l'application :

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/database/database_helper.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/get_utilisateur_connecte_usecase.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la base de données
  final db = await DatabaseHelper.instance.database;

  // Construire la chaîne de dépendances
  final authDataSource = AuthLocalDataSource(db);
  final authRepository = AuthRepositoryImpl(authDataSource);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(
        loginUseCase: LoginUseCase(authRepository),
        logoutUseCase: LogoutUseCase(authRepository),
        getUtilisateurConnecteUseCase:
            GetUtilisateurConnecteUseCase(authRepository),
      )..checkSession(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Cash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const LoginPage(),
    );
  }
}
```

> **Note** : Pour une application plus complexe, utiliser `get_it` comme Service Locator
> pour enregistrer les dépendances de manière centralisée dans un fichier `injection_container.dart`.
