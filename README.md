# NFC Wallet Application

![Logo](assets/images/logo.png)

Application mobile innovante utilisant la technologie NFC pour faciliter les transactions financières sécurisées et rapides.

## Fonctionnalités principales

- Portefeuille numérique : Gestion du solde en temps réel.
- Transactions NFC : Paiements et transferts sécurisés par simple contact NFC.
- Historique : Suivi détaillé des transactions.
- Rechargement : Ajout de fonds au portefeuille.

## Architecture technique

Le projet suit une architecture propre (Clean Architecture) pour assurer la maintenabilité et la testabilité :

- Core : Contient les bases partagées (thèmes, constantes, erreurs, usecases).
- Features :
  - auth : Gestion de l'authentification des utilisateurs.
  - nfc : Intégration du module de communication NFC.
  - wallet : Gestion du solde, des transactions et des recharges.

## Structure du projet (simplifiée)

/lib
  /core
  /features
    /auth
    /nfc
    /wallet

## Installation

1. Cloner le dépôt : git clone https://github.com/Archlord12345/NFC.git
2. Installer les dépendances : flutter pub get
3. Configurer les variables d'environnement (si nécessaire).
4. Lancer l'application : flutter run

---
*Projet développé avec Flutter.*
