import 'package:flutter/material.dart';

/// Tipos de negocio / rubros soportados por CuentasClaras Mini ERP Lite.
enum BusinessType {
  bodega(
    id: 'bodega',
    label: 'Bodega / Minimarket',
    subtitle: 'Ventas rápidas, fiados, stock y caja chica',
    icon: Icons.storefront_rounded,
    primaryColor: Color(0xFF00A86B), // Verde Esmeralda
    clientLabel: 'Cliente',
    transactionLabel: 'Fiado / Venta',
    itemLabel: 'Producto',
  ),
  barberia(
    id: 'barberia',
    label: 'Barbería / Peluquería / Estética',
    subtitle: 'Servicios, comisiones por barbero, citas y productos',
    icon: Icons.content_cut_rounded,
    primaryColor: Color(0xFF1E88E5), // Azul Cobalto
    clientLabel: 'Cliente',
    transactionLabel: 'Servicio / Corte',
    itemLabel: 'Servicio / Producto',
  ),
  reposteria(
    id: 'reposteria',
    label: 'Repostería / Panadería / Encargos',
    subtitle: 'Costeo de recetas, insumos, pedidos y anticipos',
    icon: Icons.cake_rounded,
    primaryColor: Color(0xFFE91E63), // Rosa Frambuesa
    clientLabel: 'Cliente / Pedido',
    transactionLabel: 'Encargo / Venta',
    itemLabel: 'Receta / Insumo',
  ),
  inmobiliaria(
    id: 'inmobiliaria',
    label: 'Inmobiliaria / Bienes Raíces',
    subtitle: 'Catálogo de inmuebles, comisiones y recibos de reserva',
    icon: Icons.home_work_rounded,
    primaryColor: Color(0xFF7C4DFF), // Violeta Real
    clientLabel: 'Comprador / Inquilino',
    transactionLabel: 'Comisión / Reserva',
    itemLabel: 'Propiedad',
  ),
  general(
    id: 'general',
    label: 'Emprendedor / Comercio General',
    subtitle: 'Control de caja, inventario, clientes y finanzas',
    icon: Icons.point_of_sale_rounded,
    primaryColor: Color(0xFFFF9800), // Naranja Ámbar
    clientLabel: 'Cliente',
    transactionLabel: 'Venta / Cobro',
    itemLabel: 'Producto / Servicio',
  );

  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final String clientLabel;
  final String transactionLabel;
  final String itemLabel;

  const BusinessType({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.clientLabel,
    required this.transactionLabel,
    required this.itemLabel,
  });

  static BusinessType fromId(String? id) {
    return BusinessType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => BusinessType.general,
    );
  }
}
