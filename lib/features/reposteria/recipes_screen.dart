import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/ad_banner_widget.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  final List<Map<String, dynamic>> _recipes = [
    {
      'title': 'Pastel de Chocolate VIP (12 Porciones)',
      'rawCost': 14.50,
      'margin': 60.0,
      'suggestedPrice': 36.25,
      'ingredientsCount': 6,
    },
    {
      'title': 'Tarta de Fresa & Crema',
      'rawCost': 9.20,
      'margin': 50.0,
      'suggestedPrice': 18.40,
      'ingredientsCount': 5,
    },
  ];

  final List<Map<String, dynamic>> _orders = [
    {
      'client': 'Sra. María L.',
      'product': 'Pastel de Chocolate VIP',
      'deliveryDate': 'Mañana, 4:00 PM',
      'total': 36.25,
      'deposit': 20.0,
      'pending': 16.25,
    },
  ];

  void _calculateNewRecipeDialog() {
    final titleCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final marginCtrl = TextEditingController(text: '50');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Calculador de Costo de Receta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Producto / Receta',
                hintText: 'Ej. Galletas de Chispas (12 u)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Costo Total de Insumos (\$) ',
                hintText: 'Ej. 5.50',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: marginCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Margen de Ganancia (%)',
                hintText: '50',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final cost = double.tryParse(costCtrl.text) ?? 0.0;
              final margin = double.tryParse(marginCtrl.text) ?? 50.0;
              final price = cost * (1 + (margin / 100));

              if (titleCtrl.text.isNotEmpty && cost > 0) {
                setState(() {
                  _recipes.add({
                    'title': titleCtrl.text,
                    'rawCost': cost,
                    'margin': margin,
                    'suggestedPrice': price,
                    'ingredientsCount': 4,
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Calcular y Guardar'),
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
        title: const Text('Repostería & Costeo de Recetas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const AdBannerWidget(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Banner Costeo ──────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE91E63), Color(0xFFFF4081)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cake_rounded,
                            color: Colors.white, size: 36),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calculador de Utilidad Real',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Calcula el costo exacto de materia prima y tu ganancia neta.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _calculateNewRecipeDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFE91E63),
                          ),
                          child: const Text(' + Nueva'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Lista de Recetas ───────────────────────────
                  const Text(
                    'Recetas & Costo de Producción',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final item = _recipes[index];
                      final netProfit =
                          (item['suggestedPrice'] as double) - (item['rawCost'] as double);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Insumos: \$${(item['rawCost'] as double).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Margen: ${(item['margin'] as double).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: AppColors.info,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Precio Venta: \$${(item['suggestedPrice'] as double).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Ganancia Neta por Unidad: +\$${netProfit.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Encargos & Pedidos ─────────────────────────
                  const Text(
                    'Pedidos por Encargo & Anticipos',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE91E63),
                            child: Icon(Icons.shopping_bag_rounded,
                                color: Colors.white, size: 20),
                          ),
                          title: Text('${order['client']} - ${order['product']}'),
                          subtitle: Text('Entrega: ${order['deliveryDate']}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Resta: \$${(order['pending'] as double).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Seña: \$${(order['deposit'] as double).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
