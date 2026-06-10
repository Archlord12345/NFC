---
title: "Rapport de Projet Final : NFC Wallet Application"
author: "Équipe de développement - Projet UE ICT218"
date: "Juin 2026"
---

# 1. Présentation du Projet
La **NFC Wallet Application** est une solution mobile innovante développée pour faciliter les transactions financières sécurisées via des protocoles sans contact. Ce projet a été réalisé dans le cadre de l'unité d'enseignement **ICT218**.

## Équipe de développement
Le projet a été réalisé par une équipe de **5 personnes**, avec une répartition des tâches basée sur une méthodologie Agile :
- **Gestion de projet & Documentation**
- **Architecture & Clean Architecture**
- **Interface Utilisateur (UI/UX)**
- **Intégration NFC & Connectivité (Bluetooth/Nearby)**
- **Base de données & Persistance**

## Calendrier de réalisation
Le développement s'est étalé sur une période intense de **3 semaines** :
- **Semaine 1 :** Analyse des besoins, conception de l'architecture et mise en place de l'environnement.
- **Semaine 2 :** Implémentation des services de transfert (NFC, Bluetooth, Nearby) et logique métier.
- **Semaine 3 :** Développement de l'UI (Système Solaire), résolution des contraintes techniques, implémentation de la biométrie, du système de facturation PDF et tests finaux.

---

# 2. Stack Technologique
L'application repose sur un écosystème robuste et moderne :

| Domaine | Technologies |
| :--- | :--- |
| **Framework Mobile** | Flutter (Dart) |
| **Architecture** | Clean Architecture, Provider, GetIt |
| **Authentification** | Biométrie (Local Auth) |
| **Persistance** | SQLite (sqflite) |
| **Connectivité** | NFC, Flutter Blue Plus, Nearby Connections |
| **Utilitaires** | PDF Generation, Notification, Share Plus |
| **Outils de Build** | Gradle (Kotlin DSL), Pandoc |

---

# 3. Fonctionnalités Implémentées

### 3.1. Système de transfert & Connectivité
- **Multi-méthode :** NFC, Bluetooth et Quick Share (implémentation P2P fonctionnelle).
- **Interface Système Solaire :** Scan visuel intuitif permettant de sélectionner un destinataire unique parmi plusieurs appareils.
- **ServiceManager :** Gestion proactive de l'activation matérielle (Bluetooth/NFC).

### 3.2. Sécurité & User Experience
- **Biométrie :** Authentification sécurisée via empreinte digitale ou reconnaissance faciale.
- **Notifications :** Feedback temps réel pour toutes les transactions (recharges, envois, réceptions).
- **Facturation PDF :** Génération automatique de factures téléchargeables pour chaque transaction.

### 3.3. Interface Utilisateur (UI)
- **Hub Portefeuille :** Tableau de bord complet.
- **Paramètres :** Gestion granulaire des méthodes de transfert.
- **Historique :** Suivi détaillé des transactions.

---

# 4. Conclusion
Le projet **NFC Wallet** est une réussite technique. En 3 semaines, l'équipe a su implémenter une solution complexe tout en respectant une architecture de qualité. Ce travail valide les acquis de l'UE ICT218 et démontre une maîtrise de l'écosystème Flutter et des interactions matérielles. L'application est aujourd'hui fonctionnelle, sécurisée, documentée et prête pour une utilisation avancée.
