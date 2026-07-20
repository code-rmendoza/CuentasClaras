import 'package:flutter/material.dart';

/// Paleta de colores principal de CuentasClaras.
///
/// Diseñada para evocar confianza financiera y profesionalismo,
/// optimizada para pantallas de gama baja en LATAM.
class AppColors {
  AppColors._();

  // ── Primarios ──────────────────────────────────────────────
  static const Color primary = Color(0xFF10B981);        // Verde esmeralda
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);
  static const Color onPrimary = Colors.white;

  // ── Secundarios ────────────────────────────────────────────
  static const Color secondary = Color(0xFF1E3A5F);      // Azul profundo
  static const Color secondaryLight = Color(0xFF2D5F8A);
  static const Color onSecondary = Colors.white;

  // ── Superficies ────────────────────────────────────────────
  static const Color surface = Color(0xFFFAFAF9);        // Blanco crema
  static const Color surfaceVariant = Color(0xFFF5F5F4);
  static const Color background = Color(0xFFFFFBFE);
  static const Color card = Colors.white;

  // ── Semánticos ─────────────────────────────────────────────
  static const Color error = Color(0xFFEF4444);           // Rojo coral - deudas
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);         // Ámbar - alerta
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color success = Color(0xFF10B981);         // Verde - pagos
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color info = Color(0xFF3B82F6);            // Azul - info

  // ── Texto ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF78716C);
  static const Color textTertiary = Color(0xFFA8A29E);
  static const Color textOnDark = Color(0xFFFAFAF9);

  // ── Bordes & Divisores ─────────────────────────────────────
  static const Color border = Color(0xFFE7E5E4);
  static const Color divider = Color(0xFFF5F5F4);

  // ── Dark Mode ──────────────────────────────────────────────
  static const Color darkSurface = Color(0xFF1C1917);
  static const Color darkSurfaceVariant = Color(0xFF292524);
  static const Color darkCard = Color(0xFF292524);
  static const Color darkBackground = Color(0xFF0C0A09);
  static const Color darkBorder = Color(0xFF44403C);
  static const Color darkTextPrimary = Color(0xFFFAFAF9);
  static const Color darkTextSecondary = Color(0xFFA8A29E);

  // ── Gradientes ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [secondary, Color(0xFF0F766E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient debtGradient = LinearGradient(
    colors: [error, Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
