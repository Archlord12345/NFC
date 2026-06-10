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
- **Semaine 3 :** Développement de l'UI (Système Solaire), résolution des contraintes techniques et tests finaux.

---

# 2. Stack Technologique
L'application repose sur un écosystème robuste et moderne :

| Domaine | Technologies |
| :--- | :--- |
| **Framework Mobile** | Flutter (Dart) |
| **Architecture** | Clean Architecture, Provider, GetIt |
| **Persistance** | SQLite (sqflite) |
| **Connectivité** | NFC, Flutter Blue Plus, Nearby Connections |
| **Services Système** | Permission Handler |
| **Outils de Build** | Gradle (Kotlin DSL), Pandoc (Génération PDF) |

---

# 3. Contraintes Techniques & Défis rencontrés
Le développement a été ponctué de défis majeurs :
- **Compatibilité des plugins :** Gestion des conflits lors de l'intégration de multiples services de connectivité (Nearby, NFC).
- **Contraintes LaTeX :** Difficultés lors de la génération automatique de la documentation PDF (Pandoc) dues à l'incompatibilité des caractères Unicode/Emojis.
- **Robustesse du scan :** Gestion des interférences en cas de proximité de plusieurs appareils (résolu par l'interface "Système Solaire").
- **Migration AGP :** Adaptation aux nouvelles exigences d'Android Gradle Plugin (9.0+) et migration vers le mécanisme de "Built-in Kotlin".

---

# 4. Fonctionnalités Implémentées

### 4.1. Système de transfert robuste
- **Multi-méthode :** NFC, Bluetooth et Quick Share.
- **Interface Système Solaire :** Scan visuel intuitif permettant de sélectionner un destinataire unique parmi plusieurs appareils.
- **ServiceManager :** Gestion proactive de l'activation matérielle (Bluetooth/NFC).

### 4.2. Interface & Sécurité
- **Clean UI :** Design moderne axé sur l'expérience utilisateur.
- **Sécurisation :** Validation des transactions via des cas d'usage stricts.

---

# 5. Conclusion
Le projet **NFC Wallet** est une réussite technique et organisationnelle. En 3 semaines, l'équipe a su surmonter des contraintes techniques complexes tout en respectant une architecture de qualité. Ce travail valide les acquis de l'UE ICT218 et démontre une maîtrise de l'écosystème Flutter et des interactions matérielles.
