import 'package:flutter/material.dart';

/// Paleta de colores oficial de CuentasClaras extraída directamente del
/// Design System "Precision Minimalist" generado en Stitch MCP.
///
/// Principios: Minimalismo Funcional, jerarquía tipográfica, fondo neutro claro
/// con contenedor acentuado en azul eléctrico (#0052FF / #003EC7).
class AppColors {
  AppColors._();

  // ── Stitch Primary & Accent ──────────────────────────────────
  static const Color primary = Color(0xFF003EC7);          // Primary Blue
  static const Color primaryContainer = Color(0xFF0052FF); // Electric Accent
  static const Color primaryLight = Color(0xFFB7C4FF);
  static const Color primaryDark = Color(0xFF003EC7);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFDFE3FF);

  // ── Stitch Secondary & Tonal ─────────────────────────────────
  static const Color secondary = Color(0xFF4459A8);
  static const Color secondaryContainer = Color(0xFF95AAFE);
  static const Color secondaryLight = Color(0xFF95AAFE);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ── Superficies & Contenedores (Clean Slate) ─────────────────
  static const Color background = Color(0xFFFBF8FF);
  static const Color surface = Color(0xFFFBF8FF);
  static const Color surfaceVariant = Color(0xFFF3F2FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Pure white cards
  static const Color surfaceContainerLow = Color(0xFFF3F2FF);    // Sunken wells
  static const Color surfaceContainer = Color(0xFFEDEDFB);       // Light container
  static const Color surfaceContainerHigh = Color(0xFFE7E7F5);
  static const Color surfaceContainerHighest = Color(0xFFE1E1EF);
  static const Color card = Color(0xFFFFFFFF);

  // ── Texto & Contraste ───────────────────────────────────────
  static const Color onSurface = Color(0xFF191B25);        // Charcoal primary text
  static const Color onSurfaceVariant = Color(0xFF434656); // Slate secondary text
  static const Color textPrimary = Color(0xFF191B25);
  static const Color textSecondary = Color(0xFF434656);
  static const Color textTertiary = Color(0xFF737688);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── Bordes & Líneas (1px Clean Grid) ─────────────────────────
  static const Color outline = Color(0xFF737688);
  static const Color outlineVariant = Color(0xFFC3C5D9);     // Tonal 1px borders
  static const Color border = Color(0xFFC3C5D9);
  static const Color divider = Color(0xFFE1E1EF);

  // ── Semánticos ─────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorLight = Color(0xFFFFDAD6);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color warning = Color(0xFFBF3003);
  static const Color warningLight = Color(0xFFFFDBD2);
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color info = Color(0xFF004CED);

  // ── Gradientes Minimalistas ──────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient debtGradient = LinearGradient(
    colors: [error, Color(0xFF93000A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Dark Mode Precision ─────────────────────────────────────
  static const Color darkBackground = Color(0xFF191B25);
  static const Color darkSurface = Color(0xFF2E303A);
  static const Color darkSurfaceVariant = Color(0xFF434656);
  static const Color darkCard = Color(0xFF2E303A);
  static const Color darkBorder = Color(0xFF434656);
  static const Color darkTextPrimary = Color(0xFFF0EFFE);
  static const Color darkTextSecondary = Color(0xFFC3C5D9);
}
