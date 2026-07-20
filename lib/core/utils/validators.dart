/// Validadores de formularios para CuentasClaras.
class Validators {
  Validators._();

  /// Valida que el campo no esté vacío.
  static String? required(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  /// Valida un nombre de cliente (2-100 caracteres).
  static String? clientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (value.trim().length > 100) {
      return 'El nombre es demasiado largo';
    }
    return null;
  }

  /// Valida un monto monetario.
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El monto es obligatorio';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Ingrese un monto válido';
    }
    if (parsed <= 0) {
      return 'El monto debe ser mayor a 0';
    }
    if (parsed > 999999999) {
      return 'El monto es demasiado grande';
    }
    return null;
  }

  /// Valida un número de teléfono (opcional, pero si se proporciona debe ser válido).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Teléfono es opcional
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)+]'), '');
    if (cleaned.length < 7 || cleaned.length > 15) {
      return 'Número de teléfono inválido';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return 'Solo se permiten números';
    }
    return null;
  }

  /// Valida un PIN numérico.
  static String? pin(String? value, {int length = 4}) {
    if (value == null || value.isEmpty) {
      return 'Ingrese su PIN';
    }
    if (value.length != length) {
      return 'El PIN debe tener $length dígitos';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Solo se permiten números';
    }
    return null;
  }

  /// Valida una descripción opcional (máx. 200 caracteres).
  static String? description(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }
    if (value.length > 200) {
      return 'Máximo 200 caracteres';
    }
    return null;
  }

  /// Valida precio de producto.
  static String? productPrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El precio es obligatorio';
    }
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || parsed < 0) {
      return 'Ingrese un precio válido';
    }
    return null;
  }
}
