import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/validators.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/financial_providers.dart';
import '../../shared/providers/settings_provider.dart';
import '../../data/database/app_database.dart';

/// Pantalla para registrar un nuevo ingreso/venta.
class RegisterIncomeScreen extends ConsumerStatefulWidget {
  final int? preselectedClientId;

  const RegisterIncomeScreen({super.key, this.preselectedClientId});

  @override
  ConsumerState<RegisterIncomeScreen> createState() => _RegisterIncomeScreenState();
}

class _RegisterIncomeScreenState extends ConsumerState<RegisterIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Client? _selectedClient;
  String _selectedCurrency = AppConstants.defaultCurrency;
  String _selectedPaymentMethod = AppConstants.paymentMethods.first;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = ref.read(settingsProvider).defaultCurrency;
    if (widget.preselectedClientId != null) {
      _loadPreselectedClient();
    }
  }

  Future<void> _loadPreselectedClient() async {
    final client = await ref.read(clientsDaoProvider).getClientById(widget.preselectedClientId!);
    if (mounted && client != null) {
      setState(() => _selectedClient = client);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Ingreso')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          children: [
            // Paso 1: Cliente (opcional)
            Text(
              'PASO 1 — Cliente (opcional)',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _buildClientSelector(),
            const SizedBox(height: AppTheme.spacingLg),

            // Paso 2: Descripción
            Text(
              'PASO 2 — Descripción',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            TextFormField(
              controller: _descriptionController,
              autofocus: _selectedClient != null,
              decoration: const InputDecoration(
                labelText: 'Descripción *',
                hintText: 'Ej: Venta de productos, servicio...',
                prefixIcon: Icon(Icons.receipt),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 200,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'La descripción es obligatoria';
                return null;
              },
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Paso 3: Monto y moneda
            Text(
              'PASO 3 — Monto',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de moneda
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
                      items: AppConstants.supportedCurrencies.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(
                            '${AppConstants.currencySymbols[c]} $c',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedCurrency = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),

                // Campo de monto
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Monto *',
                      hintText: '0.00',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                    validator: Validators.amount,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Paso 4: Método de pago
            Text(
              'PASO 4 — Método de Pago',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              children: AppConstants.paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethod == method;
                return ChoiceChip(
                  label: Text(AppConstants.paymentMethodNames[method] ?? method.toUpperCase()),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedPaymentMethod = method),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppTheme.spacingXl),

            // Botón confirmar
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitIncome,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSubmitting ? 'Registrando...' : 'Registrar Ingreso', style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSelector() {
    if (_selectedClient != null) {
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              _selectedClient!.name[0].toUpperCase(),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          title: Text(_selectedClient!.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: _selectedClient!.phone != null ? Text(_selectedClient!.phone!) : null,
          trailing: IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => _showClientPicker(),
          ),
        ),
      );
    }

    return InkWell(
      onTap: _showClientPicker,
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
            Icon(Icons.person_search, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Seleccionar cliente (opcional)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Future<void> _showClientPicker() async {
    final clients = await ref.read(clientsDaoProvider).getAllClients();

    if (!mounted) return;

    final selected = await showModalBottomSheet<Client>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text('Seleccionar cliente', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            Expanded(
              child: clients.isEmpty
                  ? const Center(child: Text('No hay clientes registrados'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        final client = clients[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            child: Text(client.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ),
                          title: Text(client.name),
                          subtitle: client.phone != null ? Text(client.phone!) : null,
                          onTap: () => Navigator.of(context).pop(client),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() => _selectedClient = selected);
    }
  }

  Future<void> _submitIncome() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSubmitting = true);

    try {
      final amountDouble = double.parse(_amountController.text.replaceAll(',', '.'));
      final amountCents = CurrencyUtils.amountToCents(amountDouble);
      final dao = ref.read(incomesDaoProvider);

      await dao.insertIncome(
        IncomesCompanion.insert(
          clientId: _selectedClient != null ? drift.Value(_selectedClient!.id) : const drift.Value.absent(),
          description: _descriptionController.text.trim(),
          amount: amountCents,
          currency: _selectedCurrency,
          paymentMethod: _selectedPaymentMethod,
        ),
      );

      HapticFeedback.mediumImpact();

      ref.invalidate(allIncomesProvider);
      ref.invalidate(todayIncomeProvider);
      ref.invalidate(totalIncomeByCurrencyProvider);

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Ingreso de ${_amountController.text} $_selectedCurrency registrado'),
          backgroundColor: AppColors.success,
        ),
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}