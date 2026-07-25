import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:go_router/go_router.dart';
import '../../shared/providers/database_provider.dart';
import '../../data/database/app_database.dart';
import '../../core/utils/currency_utils.dart';

/// Formulario para registrar una nueva Compra a Proveedor.
class CreatePurchaseScreen extends ConsumerStatefulWidget {
  const CreatePurchaseScreen({super.key});

  @override
  ConsumerState<CreatePurchaseScreen> createState() => _CreatePurchaseScreenState();
}

class _CreatePurchaseScreenState extends ConsumerState<CreatePurchaseScreen> {
  final _formKey = GlobalKey<FormState>();

  Supplier? _selectedSupplier;
  final TextEditingController _invoiceNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(text: '50.00');
  final TextEditingController _descriptionController = TextEditingController();
  String _currency = 'USD';
  String _paymentMethod = 'Transferencia';
  bool _isPendingCxP = true;

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccione un proveedor')),
      );
      return;
    }

    final amountCents = CurrencyUtils.parseToCents(_amountController.text);
    final dao = ref.read(expensesDaoProvider);

    await dao.insertExpense(
      ExpensesCompanion(
        category: const drift.Value('mercaderia'),
        description: drift.Value(
          'Compra Fact #${_invoiceNumberController.text.trim()} - ${_selectedSupplier!.name} (${_descriptionController.text.trim()})',
        ),
        amount: drift.Value(amountCents),
        currency: drift.Value(_currency),
        paymentMethod: drift.Value(_paymentMethod),
        isRecurring: const drift.Value(false),
        createdAt: drift.Value(DateTime.now()),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Factura de compra a ${_selectedSupplier!.name} registrada con éxito')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(allSuppliersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Compra / CxP'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ── Selección de Proveedor ──────────────────────
            suppliersAsync.when(
              data: (suppliers) {
                return DropdownButtonFormField<Supplier>(
                  initialValue: _selectedSupplier,
                  decoration: const InputDecoration(
                    labelText: 'Proveedor *',
                    prefixIcon: Icon(Icons.local_shipping),
                    border: OutlineInputBorder(),
                  ),
                  items: suppliers.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSupplier = val),
                  validator: (val) => val == null ? 'Seleccione un proveedor' : null,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error al cargar proveedores: $err'),
            ),
            const SizedBox(height: 16),

            // ── Número de Factura del Proveedor ───────────────
            TextFormField(
              controller: _invoiceNumberController,
              decoration: const InputDecoration(
                labelText: 'Número de Factura / Comprobante de Origen *',
                prefixIcon: Icon(Icons.receipt),
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),

            // ── Monto & Moneda ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Monto Total',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                  ),
                ),
                const SizedBox(width: 12),
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
              ],
            ),
            const SizedBox(height: 16),

            // ── Método de Pago & Estado CxP ─────────────────
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Método de Pago',
                prefixIcon: Icon(Icons.payment),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                DropdownMenuItem(value: 'Pago Móvil', child: Text('Pago Móvil')),
                DropdownMenuItem(value: 'Zelle', child: Text('Zelle')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _paymentMethod = val);
              },
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Registrar como Cuenta por Pagar (Pendiente CxP)'),
              subtitle: const Text('Si se desactiva, se marcará como compra pagada al contado'),
              value: _isPendingCxP,
              onChanged: (val) => setState(() => _isPendingCxP = val),
            ),
            const SizedBox(height: 16),

            // ── Detalle / Notas ────────────────────────────
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Detalle de Mercadería / Observaciones',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Botón Guardar ──────────────────────────────
            ElevatedButton.icon(
              onPressed: _savePurchase,
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Guardar Factura de Compra'),
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
