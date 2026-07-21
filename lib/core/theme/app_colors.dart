import 'package:flutter/material.dart';

/// Paleta de colores oficial de CuentasClaras inspirada en el Design System de Google Stitch MCP.
///
/// Combina "Financial Utility" con Deep Slate (#081425, #0F172A) y Emerald Green (#10B981, #4EDEA3).
class AppColors {
  AppColors._();

  // ── Primarios (Stitch Emerald) ──────────────────────────────
  static const Color primary = Color(0xFF10B981);        // Verde esmeralda Stitch
  static const Color primaryLight = Color(0xFF4EDEA3);   // Emerald tint
  static const Color primaryDark = Color(0xFF059669);
  static const Color onPrimary = Colors.white;

  // ── Secundarios (Stitch Deep Slate) ─────────────────────────
  static const Color secondary = Color(0xFF0F172A);      // Deep Slate
  static const Color secondaryLight = Color(0xFF1E293B); // Card Slate
  static const Color onSecondary = Colors.white;

  // ── Superficies Modo Claro ─────────────────────────────────
  static const Color surface = Color(0xFFF8FAFC);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Colors.white;

  // ── Semánticos ─────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);           // Rojo coral
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);         // Ámbar
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color success = Color(0xFF10B981);         // Verde esmeralda
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color info = Color(0xFF3B82F6);            // Azul cobalto

  // ── Texto Modo Claro ───────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnDark = Color(0xFFF8FAFC);

  // ── Bordes & Divisores ─────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);

  // ── Modo Oscuro (Stitch Financial Utility Dark Mode) ────────
  static const Color darkBackground = Color(0xFF081425);  // Slate Lowest
  static const Color darkSurface = Color(0xFF152031);     // Slate Container
  static const Color darkSurfaceVariant = Color(0xFF1F2A3C);
  static const Color darkCard = Color(0xFF152031);
  static const Color darkBorder = Color(0xFF2A3548);
  static const Color darkTextPrimary = Color(0xFFD8E3FB);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ── Gradientes Estilo Stitch ────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF081425), Color(0xFF064E3B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient debtGradient = LinearGradient(
    colors: [error, Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
