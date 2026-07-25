import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:go_router/go_router.dart';
import '../../shared/providers/database_provider.dart';
import '../../data/database/app_database.dart';
import '../../core/utils/currency_utils.dart';

/// Formulario para la emisión de una nueva Factura / Comprobante.
class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'invoice'; // 'invoice', 'credit_note', 'debit_note'
  String _partyName = 'Cliente de Contado';
  String _currency = 'USD';
  String _paymentMethod = 'Efectivo';
  String _nextCorrelativo = 'Cargando...';

  final TextEditingController _subtotalController = TextEditingController(text: '10.00');
  final TextEditingController _taxController = TextEditingController(text: '0.00');
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNextNumber();
  }

  Future<void> _loadNextNumber() async {
    final dao = ref.read(invoicesDaoProvider);
    final number = await dao.getNextInvoiceNumber(_selectedType);
    if (mounted) {
      setState(() {
        _nextCorrelativo = number;
      });
    }
  }

  @override
  void dispose() {
    _subtotalController.dispose();
    _taxController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    final subtotalCents = CurrencyUtils.parseToCents(_subtotalController.text);
    final taxCents = CurrencyUtils.parseToCents(_taxController.text);
    final totalCents = subtotalCents + taxCents;

    final dao = ref.read(invoicesDaoProvider);

    await dao.insertInvoice(
      InvoicesCompanion(
        invoiceNumber: drift.Value(_nextCorrelativo),
        type: drift.Value(_selectedType),
        entityType: const drift.Value('client'),
        partyName: drift.Value(_partyName.trim().isEmpty ? 'Cliente de Contado' : _partyName.trim()),
        subtotalCents: drift.Value(subtotalCents),
        taxCents: drift.Value(taxCents),
        totalCents: drift.Value(totalCents),
        currency: drift.Value(_currency),
        status: const drift.Value('paid'),
        paymentMethod: drift.Value(_paymentMethod),
        notes: drift.Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
        issueDate: drift.Value(DateTime.now()),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Factura $_nextCorrelativo registrada con éxito')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emitir Factura / Comprobante'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ── Correlativo & Tipo ─────────────────────────
            Card(
              color: Colors.blue.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Correlativo Automático',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _nextCorrelativo,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: _selectedType,
                      items: const [
                        DropdownMenuItem(value: 'invoice', child: Text('Factura')),
                        DropdownMenuItem(value: 'credit_note', child: Text('Nota de Crédito')),
                        DropdownMenuItem(value: 'debit_note', child: Text('Nota de Débito')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedType = val);
                          _loadNextNumber();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Cliente ────────────────────────────────────
            TextFormField(
              initialValue: _partyName,
              decoration: const InputDecoration(
                labelText: 'Cliente / Nombre Comercial',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => _partyName = val,
            ),
            const SizedBox(height: 16),

            // ── Montos ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _subtotalController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Subtotal (\$) ',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _taxController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Impuesto / IVA (\$) ',
                      prefixIcon: Icon(Icons.percent),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Moneda & Método de Pago ────────────────────
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: const InputDecoration(
                      labelText: 'Moneda',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'USD', child: Text('USD - Dólar')),
                      DropdownMenuItem(value: 'VES', child: Text('VES - Bolívar')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _currency = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Método de Pago',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                      DropdownMenuItem(value: 'Pago Móvil', child: Text('Pago Móvil')),
                      DropdownMenuItem(value: 'Zelle', child: Text('Zelle')),
                      DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _paymentMethod = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Observaciones ──────────────────────────────
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notas / Observaciones (opcional)',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Botón Emitir ───────────────────────────────
            ElevatedButton.icon(
              onPressed: _saveInvoice,
              icon: const Icon(Icons.check_circle),
              label: Text('Emitir Factura $_nextCorrelativo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
