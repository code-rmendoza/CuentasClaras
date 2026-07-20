import 'package:flutter_test/flutter_test.dart';
import 'package:cuentas_claras/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    test('clientName validates correctly', () {
      expect(Validators.clientName(''), equals('El nombre es obligatorio'));
      expect(Validators.clientName('A'), equals('El nombre debe tener al menos 2 caracteres'));
      expect(Validators.clientName('Juan Pérez'), isNull);
    });

    test('amount validates correctly', () {
      expect(Validators.amount(''), equals('El monto es obligatorio'));
      expect(Validators.amount('invalid'), equals('Ingrese un monto válido'));
      expect(Validators.amount('0'), equals('El monto debe ser mayor a 0'));
      expect(Validators.amount('50.00'), isNull);
    });

    test('phone validates optional phone numbers', () {
      expect(Validators.phone(null), isNull);
      expect(Validators.phone(''), isNull);
      expect(Validators.phone('123'), equals('Número de teléfono inválido'));
      expect(Validators.phone('+58 412 1234567'), isNull);
    });

    test('pin validates length and numeric format', () {
      expect(Validators.pin(''), equals('Ingrese su PIN'));
      expect(Validators.pin('12'), equals('El PIN debe tener 4 dígitos'));
      expect(Validators.pin('12ab'), equals('Solo se permiten números'));
      expect(Validators.pin('1234'), isNull);
    });
  });
}
