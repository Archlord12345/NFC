# Rapport de fin de Projet Pratique : NFC Wallet Application

**UE :** ICT218  
**Sujet :** Développement d'une application mobile de portefeuille numérique avec transfert sécurisé.

---

## 1. Introduction & Objectifs
Ce projet a été réalisé dans le cadre de l'UE **ICT218**. L'objectif principal était de concevoir et implémenter une application mobile sécurisée permettant de gérer un portefeuille numérique et d'effectuer des transferts d'argent entre utilisateurs via des technologies sans contact (NFC, Bluetooth, Quick Share).

Le projet met l'accent sur trois piliers :
- **Sécurité et Robustesse** des transactions.
- **Expérience Utilisateur (UX)** intuitive.
- **Maintenabilité du code** grâce à une architecture logicielle rigoureuse.

## 2. Architecture Technique
Le projet adopte la **Clean Architecture**, assurant une séparation stricte des responsabilités entre les couches métier, données et présentation.

- **Couche Domain (Business Logic) :** Définit les entités (Wallet, Transaction) et les Use Cases (Transfert, Historique).
- **Couche Data :** Gère les sources de données locales et l'implémentation des dépôts (Repositories).
- **Couche Presentation :** Gère l'état de l'application via `Provider` et expose l'interface utilisateur.

## 3. Implémentations techniques

### 3.1. Système de transfert multi-méthodes
Le projet implémente une abstraction (`ITransferService`) permettant de supporter trois méthodes de transfert interchangeables :
1.  **NFC :** Communication de proximité.
2.  **Bluetooth :** Utilisation de `flutter_blue_plus` pour la découverte et le transfert de données.
3.  **Quick Share :** Utilisation de `nearby_connections` pour le transfert P2P sécurisé.

### 3.2. Robustesse et sécurité
Pour garantir la fiabilité des transferts :
- **ServiceManager :** Un gestionnaire centralisé vérifie automatiquement l'activation des services (Bluetooth/NFC) et demande les permissions nécessaires avant toute opération.
- **Sélection précise :** L'interface de scan "Système Solaire" permet de visualiser les appareils proches et de sélectionner un destinataire unique, éliminant les risques d'envoi vers le mauvais utilisateur.

## 4. Structure du projet (simplifiée)

```
/lib
  /core
    /services      # Gestion robuste des services matériels
    /transfer      # Abstractions des services de transfert
  /features
    /auth          # Authentification
    /nfc           # Communication NFC spécifique
    /wallet        # Logique portefeuille et scan
```

## 5. Conclusion
Ce projet de fin d'UE ICT218 a permis de mettre en œuvre des concepts avancés de développement mobile : gestion fine de la connectivité, implémentation d'une Clean Architecture et création d'interfaces utilisateur complexes et intuitives. L'application est aujourd'hui fonctionnelle, sécurisée et évolutive.

---
*Projet développé avec Flutter.*
