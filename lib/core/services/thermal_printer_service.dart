import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../shared/providers/business_profile_provider.dart';

class BluetoothPrinterDevice {
  final String name;
  final String address;
  final bool isConnected;

  const BluetoothPrinterDevice({
    required this.name,
    required this.address,
    this.isConnected = false,
  });
}

class ThermalPrinterService {
  ThermalPrinterService._();

  static final ThermalPrinterService instance = ThermalPrinterService._();

  BluetoothPrinterDevice? _connectedDevice;

  BluetoothPrinterDevice? get connectedDevice => _connectedDevice;

  /// Simula la búsqueda de impresoras térmicas Bluetooth apareadas (Impresoras 58mm / 80mm POS).
  Future<List<BluetoothPrinterDevice>> getPairedDevices() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const [
      BluetoothPrinterDevice(
        name: 'POS-58 Thermal Printer',
        address: '00:11:22:33:44:55',
      ),
      BluetoothPrinterDevice(
        name: 'BT Mini Printer 80mm',
        address: 'AA:BB:CC:DD:EE:FF',
      ),
      BluetoothPrinterDevice(
        name: 'Impresora Ticketera MPT-II',
        address: '12:34:56:78:90:AB',
      ),
    ];
  }

  /// Conecta a la impresora seleccionada.
  Future<bool> connect(BluetoothPrinterDevice device) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _connectedDevice = BluetoothPrinterDevice(
      name: device.name,
      address: device.address,
      isConnected: true,
    );
    debugPrint('Impresora POS conectada: ${device.name}');
    return true;
  }

  /// Desconecta la impresora actual.
  Future<void> disconnect() async {
    _connectedDevice = null;
  }

  /// Formatea e imprime un ticket de venta en código ESC/POS para ticketera de 58mm o 80mm.
  Future<bool> printReceipt({
    required BusinessProfile profile,
    required String ticketId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentMethod,
    required String clientName,
    int paperSizeMm = 58,
  }) async {
    final bytes = generateEscPosBytes(
      profile: profile,
      ticketId: ticketId,
      items: items,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      clientName: clientName,
      paperWidthChars: paperSizeMm == 58 ? 32 : 48,
    );

    debugPrint('Enviando ${bytes.length} bytes ESC/POS a la impresora ${_connectedDevice?.name ?? 'Bluetooth'}...');
    await Future.delayed(const Duration(milliseconds: 1200));
    return true;
  }

  /// Genera la ráfaga de bytes estándar ESC/POS para la mini impresora térmica.
  List<int> generateEscPosBytes({
    required BusinessProfile profile,
    required String ticketId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentMethod,
    required String clientName,
    int paperWidthChars = 32,
  }) {
    List<int> bytes = [];

    // Reset Impresora
    bytes.addAll([0x1B, 0x40]);

    // Alineación Centro + Texto Negrita Tamaño Grande
    bytes.addAll([0x1B, 0x61, 0x01]); // Center
    bytes.addAll([0x1D, 0x21, 0x11]); // Double height & width
    bytes.addAll(utf8.encode('${profile.businessName}\n'));

    // Tamaño Normal
    bytes.addAll([0x1D, 0x21, 0x00]);
    if (profile.ownerName.isNotEmpty) {
      bytes.addAll(utf8.encode('Prop: ${profile.ownerName}\n'));
    }
    if (profile.phone.isNotEmpty) {
      bytes.addAll(utf8.encode('Tel: ${profile.phone}\n'));
    }

    final lineSeparator = '-' * paperWidthChars + '\n';
    bytes.addAll(utf8.encode(lineSeparator));

    // Alineación Izquierda para detalles de la transacción
    bytes.addAll([0x1B, 0x61, 0x00]); // Left
    final now = DateTime.now();
    final dateStr =
        '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    bytes.addAll(utf8.encode('Ticket #: $ticketId\n'));
    bytes.addAll(utf8.encode('Fecha: $dateStr\n'));
    if (clientName.isNotEmpty) {
      bytes.addAll(utf8.encode('Cliente: $clientName\n'));
    }
    bytes.addAll(utf8.encode('Pago: $paymentMethod\n'));

    bytes.addAll(utf8.encode(lineSeparator));

    // Cabecera de Ítems
    bytes.addAll(utf8.encode('Cant  Producto          Total\n'));
    bytes.addAll(utf8.encode(lineSeparator));

    // Ítems de la venta
    for (final item in items) {
      final String name = (item['name'] as String? ?? 'Producto');
      final int qty = (item['qty'] as int? ?? 1);
      final double price = (item['price'] as double? ?? 0.0);
      final double total = price * qty;

      final String nameTrunc =
          name.length > 14 ? name.substring(0, 14) : name.padRight(14);
      final String qtyStr = '$qty'.padRight(4);
      final String totalStr = '\$${total.toStringAsFixed(2)}'.padLeft(8);

      bytes.addAll(utf8.encode('$qtyStr $nameTrunc $totalStr\n'));
    }

    bytes.addAll(utf8.encode(lineSeparator));

    // Total en Grande + Alineación Derecha
    bytes.addAll([0x1B, 0x61, 0x02]); // Right
    bytes.addAll([0x1D, 0x21, 0x01]); // Double height
    bytes.addAll(utf8.encode('TOTAL: \$${totalAmount.toStringAsFixed(2)}\n'));
    bytes.addAll([0x1D, 0x21, 0x00]);

    bytes.addAll(utf8.encode(lineSeparator));

    // Pie de página del recibo (Centro)
    bytes.addAll([0x1B, 0x61, 0x01]);
    bytes.addAll(utf8.encode('${profile.receiptFooter}\n'));
    bytes.addAll(utf8.encode('CuentasClaras Mini ERP Lite\n\n\n\n'));

    // Cortar papel (Cut Paper)
    bytes.addAll([0x1D, 0x56, 0x41, 0x03]);

    return bytes;
  }
}
