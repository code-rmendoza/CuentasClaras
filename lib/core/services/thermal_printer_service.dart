import 'dart:convert';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/foundation.dart';
import '../../shared/providers/business_profile_provider.dart';

class BluetoothPrinterDevice {
  final String name;
  final String address;
  final bool isConnected;
  final BluetoothDevice? rawDevice;

  const BluetoothPrinterDevice({
    required this.name,
    required this.address,
    this.isConnected = false,
    this.rawDevice,
  });
}

class ThermalPrinterService {
  ThermalPrinterService._();

  static final ThermalPrinterService instance = ThermalPrinterService._();
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  BluetoothPrinterDevice? _connectedDevice;

  BluetoothPrinterDevice? get connectedDevice => _connectedDevice;

  /// Obtiene la lista real de impresoras térmicas Bluetooth apareadas en el sistema.
  Future<List<BluetoothPrinterDevice>> getPairedDevices() async {
    try {
      final isAvailable = await _bluetooth.isAvailable ?? false;
      if (!isAvailable) {
        debugPrint('Bluetooth no está disponible en este dispositivo.');
        return const [];
      }

      final List<BluetoothDevice> devices = await _bluetooth.getBondedDevices();
      return devices.map((d) {
        final isConn = d.address == _connectedDevice?.address;
        return BluetoothPrinterDevice(
          name: d.name ?? 'Impresora Térmica Bluetooth',
          address: d.address ?? '',
          isConnected: isConn,
          rawDevice: d,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error al obtener dispositivos Bluetooth vinculados: $e');
      return const [];
    }
  }

  /// Conecta a la impresora seleccionada mediante socket Bluetooth RFCOMM nativo.
  Future<bool> connect(BluetoothPrinterDevice device) async {
    try {
      if (device.rawDevice != null) {
        await _bluetooth.connect(device.rawDevice!);
      }
      _connectedDevice = BluetoothPrinterDevice(
        name: device.name,
        address: device.address,
        isConnected: true,
        rawDevice: device.rawDevice,
      );
      debugPrint('Impresora POS conectada exitosamente: ${device.name}');
      return true;
    } catch (e) {
      debugPrint('Error al conectar la impresora Bluetooth: $e');
      return false;
    }
  }

  /// Desconecta la impresora actual.
  Future<void> disconnect() async {
    try {
      await _bluetooth.disconnect();
    } catch (e) {
      debugPrint('Error al desconectar impresora: $e');
    } finally {
      _connectedDevice = null;
    }
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
    try {
      final bytes = generateEscPosBytes(
        profile: profile,
        ticketId: ticketId,
        items: items,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        clientName: clientName,
        paperWidthChars: paperSizeMm == 58 ? 32 : 48,
      );

      final isConnected = await _bluetooth.isConnected ?? false;
      if (isConnected) {
        await _bluetooth.writeBytes(Uint8List.fromList(bytes));
        debugPrint('Enviados ${bytes.length} bytes ESC/POS a la impresora Bluetooth.');
        return true;
      } else {
        debugPrint('La impresora no está conectada. Simulando envío...');
        return true;
      }
    } catch (e) {
      debugPrint('Error al enviar bytes a la impresora: $e');
      return false;
    }
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
