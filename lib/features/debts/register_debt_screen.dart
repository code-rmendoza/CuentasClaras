import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/validators.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/settings_provider.dart';
import '../../data/database/app_database.dart';

/// Pantalla para registrar un nuevo fiado (deuda).
///
/// Flujo optimizado para completar en < 3 clics:
/// 1. Seleccionar cliente
/// 2. Ingresar monto
/// 3. Confirmar
class RegisterDebtScreen extends ConsumerStatefulWidget {
  final int? preselectedClientId;

  const RegisterDebtScreen({super.key, this.preselectedClientId});

  @override
  ConsumerState<RegisterDebtScreen> createState() =>
      _RegisterDebtScreenState();
}

class _RegisterDebtScreenState extends ConsumerState<RegisterDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Client? _selectedClient;
  String _selectedCurrency = AppConstants.defaultCurrency;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedClientId != null) {
      _loadPreselectedClient();
    }
  }

  Future<void> _loadPreselectedClient() async {
    final client = await ref
        .read(clientsDaoProvider)
        .getClientById(widget.preselectedClientId!);
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
    final settings = ref.watch(settingsProvider);
    _selectedCurrency = settings.defaultCurrency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Fiado'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          children: [
            // ── Paso 1: Seleccionar cliente ────────────────
            Text(
              'PASO 1 — Cliente',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            _buildClientSelector(),
            const SizedBox(height: AppTheme.spacingLg),

            // ── Paso 2: Monto ──────────────────────────────
            Text(
              'PASO 2 — Monto',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
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
                    autofocus: _selectedClient != null,
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      labelText: 'Monto',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.,]'),
                      ),
                    ],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    validator: Validators.amount,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Descripción (opcional)
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Ej: 2 kg de arroz, aceite...',
                labelText: 'Descripción (opcional)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLength: 200,
              validator: Validators.description,
            ),
            const SizedBox(height: AppTheme.spacingXl),

            // ── Paso 3: Confirmar ──────────────────────────
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitDebt,
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
                  _isSubmitting ? 'Registrando...' : 'Registrar Fiado',
                  style: const TextStyle(fontSize: 18),
                ),
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
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            _selectedClient!.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: _selectedClient!.phone != null
              ? Text(_selectedClient!.phone!)
              : null,
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
                'Seleccionar cliente',
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

  Future<void> _showClientPicker() async {
    final clients = await ref.read(clientsDaoProvider).getAllClients();

    if (!mounted) return;

    final selected = await showModalBottomSheet<Client>(
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
                // Handle
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
                        'Seleccionar cliente',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: clients.isEmpty
                      ? const Center(
                          child: Text('No hay clientes registrados'),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: clients.length,
                          itemBuilder: (context, index) {
                            final client = clients[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.15),
                                child: Text(
                                  client.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              title: Text(client.name),
                              subtitle: client.phone != null
                                  ? Text(client.phone!)
                                  : null,
                              onTap: () => Navigator.of(context).pop(client),
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
      setState(() => _selectedClient = selected);
    }
  }

  Future<void> _submitDebt() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un cliente')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final amount =
          double.parse(_amountController.text.replaceAll(',', '.'));
      final dao = ref.read(debtsDaoProvider);

      await dao.insertDebt(
        DebtsCompanion.insert(
          clientId: _selectedClient!.id,
          amount: amount,
          currency: _selectedCurrency,
          description: drift.Value(
            _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
          ),
        ),
      );

      // Haptic feedback
      HapticFeedback.mediumImpact();

      // Invalidar providers
      ref.invalidate(pendingDebtsProvider);
      ref.invalidate(totalDebtByCurrencyProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Fiado de ${_amountController.text} $_selectedCurrency registrado',
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
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
