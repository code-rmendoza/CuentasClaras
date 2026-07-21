import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/thermal_printer_service.dart';
import '../../core/theme/app_colors.dart';
import '../providers/business_profile_provider.dart';
import '../providers/monetization_provider.dart';

/// Dialogo de selección e impresión en Ticketera Térmica POS Bluetooth (Función PRO).
class ThermalPrinterDialog extends ConsumerStatefulWidget {
  final String ticketId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String paymentMethod;
  final String clientName;

  const ThermalPrinterDialog({
    super.key,
    required this.ticketId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    this.clientName = '',
  });

  static Future<void> show(
    BuildContext context, {
    required String ticketId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentMethod,
    String clientName = '',
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => ThermalPrinterDialog(
        ticketId: ticketId,
        items: items,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        clientName: clientName,
      ),
    );
  }

  @override
  ConsumerState<ThermalPrinterDialog> createState() =>
      _ThermalPrinterDialogState();
}

class _ThermalPrinterDialogState extends ConsumerState<ThermalPrinterDialog> {
  final ThermalPrinterService _service = ThermalPrinterService.instance;
  List<BluetoothPrinterDevice> _devices = [];
  BluetoothPrinterDevice? _selectedDevice;
  bool _isLoading = true;
  bool _isPrinting = false;
  int _paperSize = 58; // 58mm default

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    setState(() => _isLoading = true);
    final devices = await _service.getPairedDevices();
    setState(() {
      _devices = devices;
      _selectedDevice = _service.connectedDevice ?? (devices.isNotEmpty ? devices.first : null);
      _isLoading = false;
    });
  }

  Future<void> _startPrint() async {
    final monetization = ref.read(monetizationProvider);

    // Verificación de Derechos PRO
    if (!monetization.isPro && !monetization.thermalPrinterEnabled) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La impresión térmica es una función PRO. ¡Desbloquéala en Ajustes o mira un video!',
          ),
          backgroundColor: Colors.amber,
        ),
      );
      context.push('/pro-upgrade');
      return;
    }

    if (_selectedDevice == null) return;

    setState(() => _isPrinting = true);
    await _service.connect(_selectedDevice!);

    final profile = ref.read(businessProfileProvider);
    final success = await _service.printReceipt(
      profile: profile,
      ticketId: widget.ticketId,
      items: widget.items,
      totalAmount: widget.totalAmount,
      paymentMethod: widget.paymentMethod,
      clientName: widget.clientName,
      paperSizeMm: _paperSize,
    );

    setState(() => _isPrinting = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '¡Ticket impreso en ${_selectedDevice!.name}!'
                : 'Error al enviar ticket a la impresora',
          ),
          backgroundColor: success ? AppColors.primary : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final monetization = ref.watch(monetizationProvider);
    final isProUnlocked = monetization.isPro || monetization.thermalPrinterEnabled;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.print_rounded, color: Colors.blueAccent),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Imprimir Ticket POS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'PRO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isProUnlocked) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_rounded, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Función PRO: Activa tu suscripción para conectar tu ticketera Bluetooth.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            const Text(
              'Seleccionar Impresora Bluetooth:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_devices.isEmpty)
              const Text(
                'No se encontraron impresoras vincularas. Enciende tu bluetooth y empareja tu ticketera.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              )
            else
              DropdownButtonFormField<BluetoothPrinterDevice>(
                initialValue: _selectedDevice,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _devices.map((device) {
                  return DropdownMenuItem(
                    value: device,
                    child: Text(
                      device.name,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedDevice = val),
              ),

            const SizedBox(height: 16),

            const Text(
              'Tamaño de Papel POS:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('58 mm (Estándar)'),
                    selected: _paperSize == 58,
                    onSelected: (sel) => setState(() => _paperSize = 58),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('80 mm (Ancho)'),
                    selected: _paperSize == 80,
                    onSelected: (sel) => setState(() => _paperSize = 80),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: (_selectedDevice == null || _isPrinting)
              ? null
              : _startPrint,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          icon: _isPrinting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.print_rounded),
          label: Text(_isPrinting ? 'Imprimiendo...' : 'Imprimir Ticket'),
        ),
      ],
    );
  }
}
