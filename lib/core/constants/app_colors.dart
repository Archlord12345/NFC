import 'package:flutter/material.dart';

/// Palette de couleurs de l'application NFC Cash.
///
/// Extraite du Design System Figma.
/// Utilisation : `AppColors.primary`, `AppColors.accent`, etc.
class AppColors {
  AppColors._(); // Empêche l'instanciation

  // ───────────────────────── Couleurs principales ─────────────────────────

  /// Navy profond — fond principal du mode sombre, headers
  static const Color primary = Color(0xFF16213E);

  /// Navy intermédiaire — cartes et surfaces en mode sombre
  static const Color primaryLight = Color(0xFF1F2943);

  /// Navy clair — éléments secondaires en mode sombre
  static const Color primarySoft = Color(0xFF2E3754);

  /// Vert teal — couleur d'accent, boutons d'action, indicateurs de succès
  static const Color accent = Color(0xFF2CCF7C);

  /// Vert teal sombre — variante pour états pressés / hover
  static const Color accentDark = Color(0xFF24A663);

  /// Vert teal très clair — fonds subtils, badges
  static const Color accentLight = Color(0xFFE6FAF1);

  /// Indigo / Purple — Troisième couleur d'accent
  static const Color tertiary = Color(0xFF6366F1);

  // ───────────────────────── Fonds (Light mode) ───────────────────────────

  /// Fond principal mode clair
  static const Color backgroundLight = Color(0xFFF8FAFC);

  /// Surface / cartes mode clair
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Fond des champs de saisie mode clair
  static const Color inputFillLight = Color(0xFFF1F5F9);

  // ───────────────────────── Fonds (Dark mode) ─────────────────────────────

  /// Fond principal mode sombre
  static const Color backgroundDark = Color(0xFF0F172A);

  /// Surface / cartes mode sombre
  static const Color surfaceDark = Color(0xFF1E293B);

  /// Fond des champs de saisie mode sombre
  static const Color inputFillDark = Color(0xFF334155);

  // ───────────────────────── Texte ─────────────────────────────────────────

  /// Texte principal mode clair
  static const Color textPrimaryLight = Color(0xFF0F172A);

  /// Texte secondaire mode clair
  static const Color textSecondaryLight = Color(0xFF64748B);

  /// Texte principal mode sombre
  static const Color textPrimaryDark = Color(0xFFF8FAFC);

  /// Texte secondaire mode sombre
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ───────────────────────── Sémantiques ───────────────────────────────────

  /// Succès — transactions validées, confirmation
  static const Color success = Color(0xFF2CCF7C);

  /// Erreur — échecs, champs invalides
  static const Color error = Color(0xFFEF4444);

  /// Avertissement — statut en attente
  static const Color warning = Color(0xFFF59E0B);

  /// Info — notifications, badges
  static const Color info = Color(0xFF3B82F6);

  // ───────────────────────── Utilitaires ───────────────────────────────────

  /// Bordures mode clair
  static const Color borderLight = Color(0xFFE2E8F0);

  /// Bordures mode sombre
  static const Color borderDark = Color(0xFF334155);

  /// Ombre légère
  static const Color shadow = Color(0x1A000000);

  /// Divider mode clair
  static const Color dividerLight = Color(0xFFF1F5F9);

  /// Divider mode sombre
  static const Color dividerDark = Color(0xFF334155);

  // ───────────────────────── Gradients ─────────────────────────────────────

  /// Gradient principal — carte solde, en-tête wallet
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF16213E),
      Color(0xFF1F2943),
    ],
  );

  /// Gradient accent — boutons principaux
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2CCF7C),
      Color(0xFF24A663),
    ],
  );

  /// Gradient de fond clair — nuance mint subtile (fond login)
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFE6FAF1),
    ],
  );
}
