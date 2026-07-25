import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla de Gestión de Usuarios y Roles.
class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios y Permisos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Nuevo Usuario',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Crear nuevo usuario')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Usuarios Registrados',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.admin_panel_settings)),
              title: const Text('Administrador Principal'),
              subtitle: const Text('Rol: Administrador (Acceso total)'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Activo',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.point_of_sale)),
              title: const Text('Cajero 1'),
              subtitle: const Text('Rol: Cajero / POS'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Activo',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
