import 'package:intl/intl.dart';

/// Utilidades de formateo de fechas para CuentasClaras.
class DateUtils {
  DateUtils._();

  /// Formato completo: "15 de julio de 2026"
  static String formatFull(DateTime date) {
    return DateFormat("d 'de' MMMM 'de' yyyy", 'es').format(date);
  }

  /// Formato corto: "15 jul 2026"
  static String formatShort(DateTime date) {
    return DateFormat('d MMM yyyy', 'es').format(date);
  }

  /// Formato relativo: "Hace 2 horas", "Ayer", "15 jul"
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Ahora';
    } else if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else {
      return formatShort(date);
    }
  }

  /// Solo hora: "14:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Fecha para nombre de archivo: "2026-07-15_14-30"
  static String formatForFileName(DateTime date) {
    return DateFormat('yyyy-MM-dd_HH-mm').format(date);
  }

  /// ¿Es hoy?
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
