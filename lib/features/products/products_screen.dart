import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_utils.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../data/database/app_database.dart';

/// Pantalla de gestión de productos (catálogo).
class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(activeProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Sin productos',
              description:
                  'Crea un catálogo de productos con precios predefinidos para agilizar el registro de fiados.',
              actionLabel: 'Agregar producto',
              onAction: () => _showProductForm(context, ref),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductCard(
                product: product,
                onDelete: () => _deleteProduct(context, ref, product),
              );
            },
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(context, ref),
        heroTag: 'fab_products',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showProductForm(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String currency = AppConstants.defaultCurrency;
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppTheme.spacingLg,
            right: AppTheme.spacingLg,
            top: AppTheme.spacingLg,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Text('Nuevo Producto',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppTheme.spacingMd),
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nombre obligatorio'
                      : null,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: currency,
                      items: AppConstants.supportedCurrencies
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                    '${AppConstants.currencySymbols[c]} $c'),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => currency = v);
                      },
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio *',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Precio obligatorio';
                          }
                          if (double.tryParse(v.replaceAll(',', '.')) == null) {
                            return 'Precio inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingLg),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Guardar Producto'),
                ),
                const SizedBox(height: AppTheme.spacingMd),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      final priceDouble =
          double.parse(priceController.text.replaceAll(',', '.'));
      await ref.read(productsDaoProvider).insertProduct(
            ProductsCompanion.insert(
              name: nameController.text.trim(),
              defaultPrice: CurrencyUtils.amountToCents(priceDouble),
              currency: currency,
            ),
          );
      ref.invalidate(activeProductsProvider);
    }

    nameController.dispose();
    priceController.dispose();
  }

  Future<void> _deleteProduct(
      BuildContext context, WidgetRef ref, Product product) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Eliminar producto',
      message: '¿Eliminar "${product.name}" del catálogo?',
      confirmLabel: 'Eliminar',
      confirmColor: AppColors.error,
    );

    if (confirmed) {
      await ref.read(productsDaoProvider).deactivateProduct(product.id);
      ref.invalidate(activeProductsProvider);
    }
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;

  const _ProductCard({required this.product, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: const Icon(Icons.inventory_2, color: AppColors.primary),
        ),
        title: Text(product.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          CurrencyUtils.formatCents(product.defaultPrice, product.currency),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
