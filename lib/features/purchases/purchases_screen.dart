import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/database_provider.dart';

/// Pantalla del Módulo de Compras (Facturas de Proveedores, CxP y Órdenes de Compra).
class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(allSuppliersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compras & Proveedores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt),
            tooltip: 'Directorio de Proveedores',
            onPressed: () => context.push('/suppliers'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nueva Compra',
            onPressed: () => context.push('/purchases/new'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/purchases/new'),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Nueva Compra'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Cuentas por Pagar (CxP)',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$ 450.00',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/suppliers'),
                    icon: const Icon(Icons.contacts),
                    label: const Text('Proveedores'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Directorio de Proveedores',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.push('/suppliers'),
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          suppliersAsync.when(
            data: (suppliers) {
              if (suppliers.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text('No hay proveedores registrados todavía.'),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/suppliers'),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Registrar Proveedor'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: suppliers.take(3).map((s) {
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.business),
                      ),
                      title: Text(s.name),
                      subtitle: Text('RIF/NIT: ${s.taxId ?? "N/A"}'),
                      trailing: Text(s.phone ?? ''),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
          ),

          const SizedBox(height: 20),
          Text(
            'Historial de Compras Recientes',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.local_shipping, color: Colors.white),
            ),
            title: const Text('Distribuidora El Sol C.A.'),
            subtitle: const Text('Factura #COMP-0012 • 20/07/2026'),
            trailing: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$ 250.00',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Pendiente',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
