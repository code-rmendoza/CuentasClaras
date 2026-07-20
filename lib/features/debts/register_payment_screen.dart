import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/validators.dart';
import '../../shared/providers/database_provider.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/debts_dao.dart';

/// Pantalla para registrar un abono (pago parcial o total).
class RegisterPaymentScreen extends ConsumerStatefulWidget {
  final int? preselectedDebtId;

  const RegisterPaymentScreen({super.key, this.preselectedDebtId});

  @override
  ConsumerState<RegisterPaymentScreen> createState() =>
      _RegisterPaymentScreenState();
}

class _RegisterPaymentScreenState
    extends ConsumerState<RegisterPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DebtSummary? _selectedDebt;
  bool _isSubmitting = false;
  bool _payAll = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedDebtId != null) {
      _loadPreselectedDebt();
    }
  }

  Future<void> _loadPreselectedDebt() async {
    try {
      final summary = await ref
          .read(debtsDaoProvider)
          .getDebtSummary(widget.preselectedDebtId!);
      if (mounted) {
        setState(() => _selectedDebt = summary);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Abono'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          children: [
            // ── Seleccionar deuda ──────────────────────────
            Text(
              'Deuda a abonar',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingSm),

            if (_selectedDebt != null) ...[
              _buildDebtInfo(),
              const SizedBox(height: AppTheme.spacingLg),
            ] else ...[
              _buildDebtSelector(),
              const SizedBox(height: AppTheme.spacingLg),
            ],

            // ── Monto ──────────────────────────────────────
            if (_selectedDebt != null) ...[
              Text(
                'Monto del abono',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingSm),

              // Botón "Pagar todo"
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      enabled: !_payAll,
                      decoration: InputDecoration(
                        hintText: '0.00',
                        labelText: 'Monto',
                        suffixText: _selectedDebt!.debt.currency,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                      validator: _payAll ? null : Validators.amount,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Column(
                    children: [
                      const Text('Pagar\ntodo',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11)),
                      Switch(
                        value: _payAll,
                        onChanged: (v) {
                          setState(() {
                            _payAll = v;
                            if (v) {
                              _amountController.text =
                                  _selectedDebt!.remainingAmount
                                      .toStringAsFixed(2);
                            } else {
                              _amountController.clear();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Notas
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLength: 200,
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Botón confirmar
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _isSubmitting ? 'Procesando...' : 'Registrar Abono',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDebtInfo() {
    final summary = _selectedDebt!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    summary.client.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.client.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (summary.debt.description != null)
                        Text(
                          summary.debt.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _showDebtPicker,
                  child: const Text('Cambiar'),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('Deuda total',
                    CurrencyUtils.formatAmount(
                        summary.debt.amount, summary.debt.currency),
                    AppColors.textPrimary),
                _buildInfoColumn('Pagado',
                    CurrencyUtils.formatAmount(
                        summary.totalPaid, summary.debt.currency),
                    AppColors.success),
                _buildInfoColumn('Restante',
                    CurrencyUtils.formatAmount(
                        summary.remainingAmount, summary.debt.currency),
                    AppColors.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDebtSelector() {
    return InkWell(
      onTap: _showDebtPicker,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.receipt_long, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Seleccionar deuda a abonar',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Future<void> _showDebtPicker() async {
    final pendingDebts = await ref.read(debtsDaoProvider).getPendingDebts();

    if (!mounted) return;

    final selected = await showModalBottomSheet<DebtWithClient>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        'Seleccionar deuda',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: pendingDebts.isEmpty
                      ? const Center(
                          child: Text('No hay deudas pendientes'),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: pendingDebts.length,
                          itemBuilder: (context, index) {
                            final item = pendingDebts[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.error.withValues(alpha: 0.15),
                                child: Text(
                                  item.client.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              title: Text(item.client.name),
                              subtitle: Text(
                                item.debt.description ?? 'Fiado',
                              ),
                              trailing: Text(
                                CurrencyUtils.formatAmount(
                                  item.debt.amount,
                                  item.debt.currency,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                              onTap: () =>
                                  Navigator.of(context).pop(item),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      final summary = await ref
          .read(debtsDaoProvider)
          .getDebtSummary(selected.debt.id);
      setState(() => _selectedDebt = summary);
    }
  }

  Future<void> _submitPayment() async {
    if (_selectedDebt == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final amount =
          double.parse(_amountController.text.replaceAll(',', '.'));
      final dao = ref.read(paymentsDaoProvider);

      final fullyPaid = await dao.insertPaymentAndCheck(
        PaymentsCompanion.insert(
          debtId: _selectedDebt!.debt.id,
          amount: amount,
          currency: _selectedDebt!.debt.currency,
          notes: drift.Value(
            _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          ),
        ),
      );

      HapticFeedback.mediumImpact();

      ref.invalidate(pendingDebtsProvider);
      ref.invalidate(totalDebtByCurrencyProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              fullyPaid
                  ? '¡Deuda pagada completamente! 🎉'
                  : 'Abono registrado exitosamente',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
