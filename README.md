# NFC Wallet Application

![Logo](assets/images/logo.png)

Application mobile innovante utilisant la technologie NFC pour faciliter les transactions financières sécurisées et rapides.

## Fonctionnalités principales

- **Portefeuille numérique :** Gestion du solde en temps réel.
- **Transactions multi-méthodes :** Envois sécurisés via NFC, Bluetooth et Quick Share.
- **Découverte robuste :** Interface de scan "Système Solaire" intuitive pour sélectionner le destinataire.
- **Activation automatique :** Gestion proactive de l'activation des services (Bluetooth/NFC).
- **Historique :** Suivi détaillé des transactions.
- **Rechargement :** Ajout de fonds au portefeuille.

## Architecture technique

Le projet suit une architecture propre (Clean Architecture) pour assurer la maintenabilité et la testabilité :

- **Core :** Contient les bases partagées (thèmes, constantes, services de gestion, erreurs).
- **Features :**
  - `auth` : Gestion de l'authentification des utilisateurs.
  - `nfc` : Intégration du module de communication NFC.
  - `wallet` : Gestion du solde, des transactions et des recharges.

## Structure du projet (simplifiée)

/lib
  /core
    /services      # Gestion robuste des services (ServiceManager)
    /transfer      # Abstractions des transferts (ITransferService)
  /features
    /auth
    /nfc
    /wallet

## Système de transfert robuste

- **ServiceManager :** Vérifie et demande automatiquement l'activation du Bluetooth et du NFC avant chaque transfert.
- **Interface Système Solaire :** Scan visuel des appareils proches orbitant autour de l'appareil utilisateur pour une sélection précise du destinataire.

## Installation

1. Cloner le dépôt : `git clone https://github.com/Archlord12345/NFC.git`
2. Installer les dépendances : `flutter pub get`
3. Configurer les variables d'environnement (si nécessaire).
4. Lancer l'application : `flutter run`

---
*Projet développé avec Flutter.*
