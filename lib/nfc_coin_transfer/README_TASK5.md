# NFC Coin Transfer — Tâche 5 : Développeur Data & Historique

## 👤 Rôle
**Responsable** : [Ton prénom]  
**Tâche** : 5 — Data & History Developer  
**Projet** : NFC Coin Transfer (Application Flutter)

---

## 📁 Structure des Fichiers (Tâche 5)

```
lib/
├── models/
│   ├── transaction.dart           # Modèle principal + enums
│   ├── transaction_filter.dart    # Modèle de filtres
│   └── transaction_summary.dart  # Modèle statistiques
│
├── services/
│   ├── database_service.dart      # Couche SQLite (CRUD)
│   └── transaction_service.dart   # Logique métier
│
├── providers/
│   └── transaction_provider.dart  # Gestion d'état (ChangeNotifier)
│
├── screens/
│   └── history/
│       ├── history_screen.dart            # Écran liste historique
│       └── transaction_detail_screen.dart # Écran détail transaction
│
└── widgets/
    └── history/
        ├── transaction_card.dart      # Carte transaction (swipe to delete)
        ├── history_summary_card.dart  # Résumé statistique (envoi/réception)
        └── filter_bottom_sheet.dart   # Feuille de filtres (type, statut, date)
```

---

## 🏗️ Architecture

```
UI (Screens/Widgets)
       ↓
TransactionProvider   ← ChangeNotifier (state management)
       ↓
TransactionService    ← Logique métier
       ↓
DatabaseService       ← SQLite (sqflite)
       ↓
   nfc_coin_transfer.db
```

---

## ✅ Fonctionnalités implémentées

### Modèles de données
- `Transaction` avec `toMap()` / `fromMap()` pour SQLite
- Enums `TransactionType` et `TransactionStatus` avec extensions
- `TransactionFilter` avec comptage des filtres actifs
- `TransactionSummary` pour les statistiques

### Service base de données (`DatabaseService`)
- Création/migration du schéma SQLite
- Index sur `senderId`, `receiverId`, `timestamp`
- CRUD complet : `insert`, `getTransactions`, `update`, `delete`
- Filtres dynamiques (type, statut, date, montant, recherche)
- Pagination avec `LIMIT` / `OFFSET`
- Requêtes agrégées pour les statistiques
- Opérations en batch pour l'insertion multiple

### Service métier (`TransactionService`)
- Création de transaction avec validation
- Confirmation / échec / annulation
- Chargement paginé (`page`, `pageSize`)
- Données de démo pour le développement

### Gestion d'état (`TransactionProvider`)
- `LoadingState` (idle, loading, success, error)
- Pagination infinie (`loadMore`)
- Pull-to-refresh
- Filtres avec rechargement automatique
- Mise à jour optimiste de la liste

### Écrans
- **HistoryScreen** : liste paginée, barre de recherche, filtre, menu
- **TransactionDetailScreen** : détail complet, suppression confirmée

### Widgets
- **TransactionCard** : swipe-to-delete, indicateur de statut coloré
- **HistorySummaryCard** : gradient, stats envoi/réception/net
- **FilterBottomSheet** : chips type/statut, sélecteur de période

---

## 🚀 Intégration dans l'app principale

Dans `main.dart` ou le fichier de navigation, ajoute le provider :

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => TransactionProvider()),
    // ... autres providers
  ],
  child: MyApp(),
)
```

Navigation vers l'écran :
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => HistoryScreen(userId: currentUser.id),
  ),
);
```

---

## 📦 Dépendances ajoutées (`pubspec.yaml`)

| Package | Version | Usage |
|---------|---------|-------|
| `sqflite` | ^2.3.3 | Base de données SQLite locale |
| `path` | ^1.9.0 | Chemin vers la DB |
| `provider` | ^6.1.2 | Gestion d'état |
| `uuid` | ^4.4.0 | Génération d'IDs uniques |
| `intl` | ^0.19.0 | Formatage date/monnaie (FCFA) |
