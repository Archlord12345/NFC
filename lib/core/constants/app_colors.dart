import 'package:flutter/material.dart';

/// Palette de couleurs de l'application NFC Cash.
///
/// Extraite du Design System Figma.
/// Utilisation : `AppColors.primary`, `AppColors.accent`, etc.
class AppColors {
  AppColors._(); // Empêche l'instanciation

  // ───────────────────────── Couleurs principales ─────────────────────────

  /// Navy profond — fond principal du mode sombre, headers
  static const Color primary = Color(0xFF1A1F36);

  /// Navy intermédiaire — cartes et surfaces en mode sombre
  static const Color primaryLight = Color(0xFF252D4A);

  /// Navy clair — éléments secondaires en mode sombre
  static const Color primarySoft = Color(0xFF2E3754);

  /// Vert teal — couleur d'accent, boutons d'action, indicateurs de succès
  static const Color accent = Color(0xFF00D09E);

  /// Vert teal sombre — variante pour états pressés / hover
  static const Color accentDark = Color(0xFF00B386);

  /// Vert teal très clair — fonds subtils, badges
  static const Color accentLight = Color(0xFFE6FAF5);

  // ───────────────────────── Fonds (Light mode) ───────────────────────────

  /// Fond principal mode clair
  static const Color backgroundLight = Color(0xFFF5F7FA);

  /// Surface / cartes mode clair
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Fond des champs de saisie mode clair
  static const Color inputFillLight = Color(0xFFF0F2F5);

  // ───────────────────────── Fonds (Dark mode) ─────────────────────────────

  /// Fond principal mode sombre
  static const Color backgroundDark = Color(0xFF111528);

  /// Surface / cartes mode sombre
  static const Color surfaceDark = Color(0xFF1A1F36);

  /// Fond des champs de saisie mode sombre
  static const Color inputFillDark = Color(0xFF252D4A);

  // ───────────────────────── Texte ─────────────────────────────────────────

  /// Texte principal mode clair
  static const Color textPrimaryLight = Color(0xFF1A1F36);

  /// Texte secondaire mode clair
  static const Color textSecondaryLight = Color(0xFF7C8BA0);

  /// Texte principal mode sombre
  static const Color textPrimaryDark = Color(0xFFFFFFFF);

  /// Texte secondaire mode sombre
  static const Color textSecondaryDark = Color(0xFF9BA4B5);

  // ───────────────────────── Sémantiques ───────────────────────────────────

  /// Succès — transactions validées, confirmation
  static const Color success = Color(0xFF00D09E);

  /// Erreur — échecs, champs invalides
  static const Color error = Color(0xFFFF4D6A);

  /// Avertissement — statut en attente
  static const Color warning = Color(0xFFFFB946);

  /// Info — notifications, badges
  static const Color info = Color(0xFF4DA6FF);

  // ───────────────────────── Utilitaires ───────────────────────────────────

  /// Bordures mode clair
  static const Color borderLight = Color(0xFFE2E6ED);

  /// Bordures mode sombre
  static const Color borderDark = Color(0xFF2E3754);

  /// Ombre légère
  static const Color shadow = Color(0x1A000000);

  /// Divider mode clair
  static const Color dividerLight = Color(0xFFEEF0F4);

  /// Divider mode sombre
  static const Color dividerDark = Color(0xFF2E3754);

  // ───────────────────────── Gradients ─────────────────────────────────────

  /// Gradient principal — carte solde, en-tête wallet
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1F36),
      Color(0xFF252D4A),
    ],
  );

  /// Gradient accent — boutons principaux
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00D09E),
      Color(0xFF00B386),
    ],
  );

  /// Gradient de fond clair — nuance mint subtile (fond login)
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFE6FAF5),
    ],
  );
}
