import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cuentas_claras/shared/widgets/empty_state.dart';

void main() {
  group('EmptyState Widget Tests', () {
    testWidgets('renders title and description correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.people_outline,
              title: 'Sin clientes',
              description: 'Agrega tu primer cliente para comenzar',
            ),
          ),
        ),
      );

      expect(find.text('Sin clientes'), findsOneWidget);
      expect(find.text('Agrega tu primer cliente para comenzar'), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('renders action button and triggers callback on tap', (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.add,
              title: 'Sin datos',
              description: 'Toca el botón para agregar',
              actionLabel: 'Agregar cliente',
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Agregar cliente'), findsOneWidget);

      await tester.tap(find.text('Agregar cliente'));
      await tester.pump();

      expect(actionTapped, isTrue);
    });
  });
}
