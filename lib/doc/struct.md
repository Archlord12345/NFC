# 📄 Documentation du Projet — `mon_projet_nfc`

> Application mobile Flutter permettant l'échange de fonds via NFC entre deux appareils,
> avec un portefeuille électronique intégré et un système d'authentification local.

---

## Table des matières

1. [Exigences Fonctionnelles](#1--exigences-fonctionnelles)
2. [Schéma de Base de Données](#2--schéma-de-base-de-données)
3. [Dépendances](#3--dépendances)
4. [Guide Clean Architecture — Comment travailler sur un module](#4--guide-clean-architecture--comment-travailler-sur-un-module)

---

## 1 — Exigences Fonctionnelles

Les capacités du système sont organisées par module (cas d'utilisation).

### 1.1 Module : Authentification

| # | Cas d'utilisation | Description |
|---|---|---|
| AU-1 | **Connexion** | L'utilisateur saisit ses identifiants (e-mail + mot de passe ou biométrie) pour accéder à son espace personnel. |
| AU-2 | **Déconnexion** | L'utilisateur peut se déconnecter à tout moment pour sécuriser sa session. |

### 1.2 Module : Wallet (Portefeuille Électronique)

#### Consultation et Stockage

| # | Cas d'utilisation | Description |
|---|---|---|
| WA-1 | **Consultation du solde** | L'utilisateur consulte son solde disponible en temps réel dès l'ouverture du portefeuille. |
| WA-2 | **Historique des transactions** | L'utilisateur voit l'historique détaillé de ses transactions passées (achats, envois, réceptions). |
| WA-3 | **Recharge** | L'utilisateur effectue une recharge en saisissant le montant souhaité. |

#### Envoi et Transfert

| # | Cas d'utilisation | Description |
|---|---|---|
| WA-4 | **Scan des appareils à proximité** | L'utilisateur scanne les appareils aux alentours pour déterminer celui à qui il souhaite envoyer des fonds. Un pop-up de confirmation apparaît simultanément sur les **deux** appareils ; les deux parties doivent valider avant tout échange. |
| WA-5 | **Confirmation de transfert** | L'utilisateur reçoit une confirmation immédiate (reçu numérique) après la validation d'un transfert. |

### 1.3 Module : Connexion NFC

#### Association et Appairage

| # | Cas d'utilisation | Description |
|---|---|---|
| NF-1 | **Initiation de connexion** | L'utilisateur approche son appareil d'un autre terminal pour initier une connexion sans fil instantanée. |
| NF-2 | **Validation / Refus** | L'utilisateur valide ou refuse l'association avec l'appareil détecté via une notification visuelle (pop-up). |
| NF-3 | **Transfert via NFC** | L'utilisateur transfère des données ou des fonds du Wallet directement via la liaison NFC sécurisée. |

---

## 2 — Schéma de Base de Données

### 2.1 Modèle Relationnel

```
[UTILISATEUR] (1) ———— (1) [WALLET] (1) ———— (N) [TRANSACTION]
```

- L'utilisateur possède **un** portefeuille.
- Le portefeuille possède **plusieurs** transactions (incluant les échanges NFC).

### 2.2 Tables (SQLite / Sqflite)

#### Table `utilisateurs`

Contient le strict minimum pour maintenir la session locale ouverte ou fermée.

| Champ | Type SQLite | Propriétés |
|---|---|---|
| `id` | `TEXT` | `PRIMARY KEY` — UUID généré par l'application |
| `email` | `TEXT` | `UNIQUE` |
| `mot_de_passe_hash` | `TEXT` | Hash du mot de passe (première connexion) |
| `est_connecte` | `INTEGER` | `1` = connecté, `0` = déconnecté — évite de se reconnecter à chaque ouverture |

#### Table `wallets`

Gère le solde en temps réel.

| Champ | Type SQLite | Propriétés |
|---|---|---|
| `id` | `TEXT` | `PRIMARY KEY` |
| `utilisateur_id` | `TEXT` | `FOREIGN KEY REFERENCES utilisateurs(id)` |
| `solde` | `REAL` | Solde actuel (ex : `250.50`) |
| `devise` | `TEXT` | Valeur par défaut `'EUR'` ou `'XAF'` |

#### Table `transactions`

Fusionne l'historique classique et la validation NFC.
Pour un transfert NFC, l'application crée la ligne en statut `0` (en attente), puis passe à `1` (validé) dès que les deux téléphones ont validé le pop-up.

| Champ | Type SQLite | Propriétés |
|---|---|---|
| `id` | `TEXT` | `PRIMARY KEY` |
| `wallet_source_id` | `TEXT` | `NULL` si c'est une `RECHARGE` |
| `wallet_dest_id` | `TEXT` | Portefeuille du récepteur |
| `type` | `TEXT` | `'RECHARGE'` ou `'TRANSFERT_NFC'` |
| `montant` | `REAL` | Somme transférée |
| `statut` | `INTEGER` | `0` = En attente (pop-up), `1` = Validé, `2` = Échoué |
| `date_cree` | `TEXT` | Format ISO 8601 (`YYYY-MM-DD HH:MM:SS`) |

### 2.3 Diagramme Entité-Relation

```
┌──────────────────┐       1:1       ┌──────────────────┐       1:N       ┌──────────────────────┐
│   utilisateurs   │───────────────▶│      wallets     │───────────────▶│     transactions     │
├──────────────────┤                 ├──────────────────┤                 ├──────────────────────┤
│ id          (PK) │                 │ id          (PK) │                 │ id              (PK) │
│ email       (UQ) │                 │ utilisateur_id   │──┐              │ wallet_source_id     │
│ mot_de_passe_hash│                 │ solde            │  │              │ wallet_dest_id       │
│ est_connecte     │                 │ devise           │  │              │ type                 │
└──────────────────┘                 └──────────────────┘  │              │ montant              │
                                                           │              │ statut               │
                                                           │              │ date_cree            │
                                                           │              └──────────────────────┘
                                                           │                       ▲
                                                           │       FK (source)     │
                                                           └───────────────────────┘
```

---

## 3 — Dépendances

### 3.1 Dépendances de production

| Package | Version | Rôle |
|---|---|---|
| `flutter` | SDK | Framework UI principal |
| `cupertino_icons` | `^1.0.8` | Icônes style iOS (CupertinoIcons) |
| `nfc_manager` | `^4.2.1` | Lecture / écriture de tags NFC et communication peer-to-peer |
| `flutter_nfc_kit` | `^3.6.2` | Couche complémentaire NFC — détection, lecture NDEF, transceive APDU |

### 3.2 Dépendances à ajouter (recommandées)

| Package | Rôle | Justification |
|---|---|---|
| `sqflite` | Base de données SQLite locale | Persistance des tables `utilisateurs`, `wallets`, `transactions` |
| `path_provider` | Chemin du système de fichiers | Requis par `sqflite` pour localiser le fichier `.db` |
| `uuid` | Génération d'UUID | Clés primaires uniques pour chaque entité |
| `provider` ou `flutter_bloc` | Gestion d'état | Injection des use cases dans l'UI et réactivité |
| `equatable` | Comparaison d'objets | Simplifier l'égalité des entités et des états |
| `get_it` | Injection de dépendances | Enregistrer et résoudre les dépendances (Service Locator) |
| `dartz` | Types fonctionnels (`Either`, `Option`) | Gérer les résultats succès/échec dans les use cases |
| `crypto` | Hachage SHA-256 / bcrypt | Hasher les mots de passe avant stockage |
| `local_auth` | Authentification biométrique | Empreinte digitale / Face ID |

### 3.3 Dépendances de développement

| Package | Version | Rôle |
|---|---|---|
| `flutter_test` | SDK | Framework de tests unitaires et widget |
| `flutter_lints` | `^6.0.0` | Règles de lint recommandées par Flutter |

---

## 4 — Guide Clean Architecture : Comment travailler sur un module

### 4.1 Principes fondamentaux

La Clean Architecture sépare le code en **couches concentriques** où les dépendances pointent **toujours vers l'intérieur** :

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION                            │
│               (Pages, Widgets, State)                       │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                   DOMAIN                            │    │
│  │          (Entities, Use Cases, Repos*)              │    │
│  │  ┌─────────────────────────────────────────────┐    │    │
│  │  │                  DATA                       │    │    │
│  │  │     (Models, Repos Impl, Data Sources)      │    │    │
│  │  └─────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘

  * Repos = interfaces (contrats) uniquement dans domain
```

**Règle d'or** : `domain/` ne dépend de **rien** d'extérieur (ni Flutter, ni Sqflite, ni aucun package tiers).

### 4.2 Arborescence cible par module

Chaque module (feature) suit la même structure. Voici l'arborescence attendue dans `lib/` :

```
lib/
├── core/
│   ├── constants/          # Constantes globales (couleurs, strings, config)
│   ├── errors/             # Classes Failure & Exception personnalisées
│   ├── usecases/           # Classe abstraite UseCase<Type, Params>
│   └── database/           # Helper Sqflite (singleton, création des tables)
│
├── features/
│   ├── auth/                          ← MODULE AUTHENTIFICATION
│   │   ├── domain/
│   │   │   ├── entities/             # Utilisateur (classe Dart pure)
│   │   │   ├── repositories/         # AuthRepository (contrat abstrait)
│   │   │   └── usecases/            # LoginUseCase, LogoutUseCase
│   │   ├── data/
│   │   │   ├── models/              # UtilisateurModel (extends Utilisateur + fromMap/toMap)
│   │   │   ├── repositories/        # AuthRepositoryImpl (implémente le contrat)
│   │   │   └── datasources/         # AuthLocalDataSource (requêtes Sqflite)
│   │   └── presentation/
│   │       ├── pages/               # LoginPage
│   │       ├── widgets/             # Composants réutilisables du module
│   │       └── providers/ (ou bloc/) # AuthProvider / AuthCubit
│   │
│   ├── wallet/                        ← MODULE WALLET
│   │   ├── domain/
│   │   │   ├── entities/             # Wallet, Transaction
│   │   │   ├── repositories/         # WalletRepository (contrat)
│   │   │   └── usecases/            # GetSoldeUseCase, RechargeUseCase, TransfertUseCase
│   │   ├── data/
│   │   │   ├── models/              # WalletModel, TransactionModel
│   │   │   ├── repositories/        # WalletRepositoryImpl
│   │   │   └── datasources/         # WalletLocalDataSource
│   │   └── presentation/
│   │       ├── pages/               # WalletPage, HistoriquePage
│   │       ├── widgets/             # SoldeCard, TransactionTile
│   │       └── providers/           # WalletProvider
│   │
│   └── nfc/                           ← MODULE CONNEXION NFC
│       ├── domain/
│       │   ├── entities/             # NfcPeer (appareil détecté)
│       │   ├── repositories/         # NfcRepository (contrat)
│       │   └── usecases/            # ScanNfcUseCase, ValidateTransferUseCase
│       ├── data/
│       │   ├── models/              # NfcPeerModel
│       │   ├── repositories/        # NfcRepositoryImpl
│       │   └── datasources/         # NfcDataSource (appels nfc_manager / flutter_nfc_kit)
│       └── presentation/
│           ├── pages/               # NfcScanPage, NfcConfirmationPage
│           ├── widgets/             # PeerCard, ScanAnimation
│           └── providers/           # NfcProvider
│
├── doc/
│   └── struct.md                     # ← CE FICHIER
│
└── main.dart                         # Point d'entrée, injection des dépendances
```

### 4.3 Procédure pas à pas — Travailler sur un nouveau module

Voici la marche à suivre pour implémenter (ou modifier) un module en respectant la Clean Architecture.

#### Étape 1 : Définir les Entités (`domain/entities/`)

- Créer des **classes Dart pures** (aucune dépendance Flutter ni package).
- Elles représentent les objets métier : `Utilisateur`, `Wallet`, `Transaction`.
- Utiliser `Equatable` pour faciliter les comparaisons.

```dart
// Exemple : lib/features/wallet/domain/entities/wallet.dart
class Wallet {
  final String id;
  final String utilisateurId;
  final double solde;
  final String devise;

  const Wallet({
    required this.id,
    required this.utilisateurId,
    required this.solde,
    required this.devise,
  });
}
```

#### Étape 2 : Définir les contrats Repository (`domain/repositories/`)

- Créer des **classes abstraites** décrivant les opérations disponibles.
- Retourner des types fonctionnels (`Either<Failure, Type>`) ou des `Future`.
- **Ne jamais mentionner** Sqflite, NFC, ou tout autre détail technique ici.

```dart
// Exemple : lib/features/wallet/domain/repositories/wallet_repository.dart
abstract class WalletRepository {
  Future<Wallet> getWallet(String utilisateurId);
  Future<void> recharger(String walletId, double montant);
  Future<List<Transaction>> getHistorique(String walletId);
}
```

#### Étape 3 : Implémenter les Use Cases (`domain/usecases/`)

- Chaque use case encapsule **une seule action métier**.
- Il dépend du **contrat** Repository (pas de l'implémentation).

```dart
// Exemple : lib/features/wallet/domain/usecases/get_solde_usecase.dart
class GetSoldeUseCase {
  final WalletRepository repository;

  GetSoldeUseCase(this.repository);

  Future<Wallet> call(String utilisateurId) {
    return repository.getWallet(utilisateurId);
  }
}
```

#### Étape 4 : Créer les Models (`data/models/`)

- Les models **étendent** les entités et ajoutent les méthodes de sérialisation.
- `fromMap(Map)` — pour lire depuis SQLite.
- `toMap()` — pour écrire dans SQLite.

```dart
// Exemple : lib/features/wallet/data/models/wallet_model.dart
class WalletModel extends Wallet {
  const WalletModel({
    required super.id,
    required super.utilisateurId,
    required super.solde,
    required super.devise,
  });

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'],
      utilisateurId: map['utilisateur_id'],
      solde: map['solde'],
      devise: map['devise'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utilisateur_id': utilisateurId,
      'solde': solde,
      'devise': devise,
    };
  }
}
```

#### Étape 5 : Implémenter les Data Sources (`data/datasources/`)

- Les data sources effectuent les **appels concrets** : requêtes SQL, appels NFC, etc.
- C'est ici qu'on importe `sqflite`, `nfc_manager`, etc.

```dart
// Exemple : lib/features/wallet/data/datasources/wallet_local_datasource.dart
class WalletLocalDataSource {
  final Database database;

  WalletLocalDataSource(this.database);

  Future<WalletModel> getWallet(String utilisateurId) async {
    final result = await database.query(
      'wallets',
      where: 'utilisateur_id = ?',
      whereArgs: [utilisateurId],
    );
    return WalletModel.fromMap(result.first);
  }
}
```

#### Étape 6 : Implémenter le Repository (`data/repositories/`)

- Il **implémente** le contrat défini dans `domain/`.
- Il délègue le travail au(x) data source(s).
- Il gère la conversion erreurs techniques → `Failure` métier.

```dart
// Exemple : lib/features/wallet/data/repositories/wallet_repository_impl.dart
class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource localDataSource;

  WalletRepositoryImpl(this.localDataSource);

  @override
  Future<Wallet> getWallet(String utilisateurId) {
    return localDataSource.getWallet(utilisateurId);
  }
  // ...
}
```

#### Étape 7 : Construire la Présentation (`presentation/`)

- Les **pages** appellent les use cases (injectés via Provider ou GetIt).
- Les **providers / blocs** gèrent l'état et notifient l'UI.
- Les **widgets** sont des composants visuels réutilisables.

### 4.4 Règles à respecter impérativement

| Règle | Explication |
|---|---|
| ❌ Ne **jamais** importer `data/` depuis `domain/` | Le domaine est la couche la plus interne, il ne connaît pas les détails d'implémentation. |
| ❌ Ne **jamais** importer `presentation/` depuis `data/` ou `domain/` | La couche données ne sait pas comment l'UI est construite. |
| ✅ `presentation/` → `domain/` | L'UI dépend des use cases et des entités. |
| ✅ `data/` → `domain/` | L'implémentation dépend des contrats abstraits. |
| ✅ Un use case = **une seule responsabilité** | Pas de use case « fourre-tout ». |
| ✅ Tester chaque couche **indépendamment** | Mocker les repositories pour tester les use cases, mocker les data sources pour tester les repositories. |

### 4.5 Résumé visuel du flux de données

```
┌───────────┐    appelle     ┌───────────┐    appelle     ┌───────────────┐    requête    ┌──────────┐
│   Page    │ ─────────────▶ │  UseCase  │ ─────────────▶ │  Repository   │ ───────────▶ │  SQLite  │
│   (UI)    │                │ (Domain)  │                │  Impl (Data)  │              │  (Sqflite│
└───────────┘                └───────────┘                └───────────────┘              └──────────┘
      ▲                                                          │
      │                    retourne Entity                       │
      └──────────────────────────────────────────────────────────┘
```

---

> **Note** : Ce document est un guide de référence vivant. Il doit être mis à jour au fur et à mesure de l'avancement du projet.
