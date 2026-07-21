import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/business_profile_provider.dart';
import '../../shared/widgets/ad_banner_widget.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final List<Map<String, dynamic>> _quickProducts = [
    {'name': 'Arroz 1kg', 'price': 1.80, 'icon': Icons.shopping_basket_rounded},
    {'name': 'Aceite 1L', 'price': 3.50, 'icon': Icons.local_grocery_store_rounded},
    {'name': 'Leche 1L', 'price': 2.10, 'icon': Icons.local_drink_rounded},
    {'name': 'Café 250g', 'price': 2.90, 'icon': Icons.coffee_rounded},
    {'name': 'Harina Pan 1kg', 'price': 1.40, 'icon': Icons.bakery_dining_rounded},
    {'name': 'Azúcar 1kg', 'price': 1.60, 'icon': Icons.grain_rounded},
  ];

  final List<Map<String, dynamic>> _cart = [];

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      final idx = _cart.indexWhere((c) => c['name'] == item['name']);
      if (idx >= 0) {
        _cart[idx]['qty']++;
      } else {
        _cart.add({
          'name': item['name'],
          'price': item['price'],
          'qty': 1,
        });
      }
    });
  }

  double get _cartTotal => _cart.fold(
        0.0,
        (sum, item) => sum + ((item['price'] as double) * (item['qty'] as int)),
      );

  void _checkout(String paymentMethod) {
    if (_cart.isEmpty) return;

    final profile = ref.read(businessProfileProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Venta Registrada ($paymentMethod)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Negocio: ${profile.businessName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Total Cobrado: \$${_cartTotal.toStringAsFixed(2)}'),
            const SizedBox(height: 4),
            Text('Método: $paymentMethod'),
            const SizedBox(height: 12),
            const Text(
              'Ticket de venta generado. ¿Deseas enviarlo por WhatsApp?',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _cart.clear());
              Navigator.pop(ctx);
            },
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() => _cart.clear());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Abriendo WhatsApp con el ticket de venta...'),
                ),
              );
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text('Enviar WhatsApp'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Punto de Venta Express (POS)'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const AdBannerWidget(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Productos Rápidos ─────────────────────────
                  const Text(
                    'Selección Rápida de Productos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _quickProducts.length,
                    itemBuilder: (context, index) {
                      final p = _quickProducts[index];
                      return InkWell(
                        onTap: () => _addToCart(p),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(p['icon'] as IconData,
                                  color: AppColors.primary, size: 24),
                              const SizedBox(height: 4),
                              Text(
                                p['name'] as String,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${(p['price'] as double).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Carrito Actual ────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Carrito de Venta',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_cart.isNotEmpty)
                        TextButton(
                          onPressed: () => setState(() => _cart.clear()),
                          child: const Text(
                            'Vaciar',
                            style: TextStyle(color: AppColors.error, fontSize: 12),
                          ),
                        ),
                    ],
                  ),

                  Expanded(
                    child: _cart.isEmpty
                        ? Center(
                            child: Text(
                              'Toca un producto arriba para agregarlo al cobro',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _cart.length,
                            itemBuilder: (context, index) {
                              final item = _cart[index];
                              final total = (item['price'] as double) *
                                  (item['qty'] as int);
                              return ListTile(
                                dense: true,
                                title: Text(item['name']),
                                subtitle: Text(
                                    '${item['qty']} x \$${(item['price'] as double).toStringAsFixed(2)}'),
                                trailing: Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // ── Footer de Cobro ───────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total a Cobrar:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${_cartTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _cart.isEmpty
                                    ? null
                                    : () => _checkout('Efectivo'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.payments_rounded),
                                label: const Text('Efectivo'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _cart.isEmpty
                                    ? null
                                    : () => _checkout('Transferencia'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.account_balance_rounded),
                                label: const Text('Pago Móvil'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
