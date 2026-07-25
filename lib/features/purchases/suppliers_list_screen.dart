import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../shared/providers/database_provider.dart';
import '../../data/database/app_database.dart';

/// Pantalla de Directorio de Proveedores (Compras / CxP).
class SuppliersListScreen extends ConsumerWidget {
  const SuppliersListScreen({super.key});

  void _showAddSupplierDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final taxIdController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Registrar Proveedor'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre / Razón Social *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: taxIdController,
                    decoration: const InputDecoration(
                      labelText: 'RIF / Identificación Fiscal',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección Comercial',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final dao = ref.read(suppliersDaoProvider);
                  await dao.insertSupplier(
                    SuppliersCompanion(
                      name: drift.Value(nameController.text.trim()),
                      taxId: drift.Value(taxIdController.text.trim().isEmpty ? null : taxIdController.text.trim()),
                      phone: drift.Value(phoneController.text.trim().isEmpty ? null : phoneController.text.trim()),
                      address: drift.Value(addressController.text.trim().isEmpty ? null : addressController.text.trim()),
                    ),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(allSuppliersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directorio de Proveedores'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSupplierDialog(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Proveedor'),
      ),
      body: suppliersAsync.when(
        data: (suppliers) {
          if (suppliers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay proveedores registrados',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddSupplierDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Proveedor'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.withValues(alpha: 0.1),
                    child: const Icon(Icons.business, color: Colors.purple),
                  ),
                  title: Text(
                    supplier.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'RIF/NIT: ${supplier.taxId ?? "No especificado"} • Tel: ${supplier.phone ?? "N/A"}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
