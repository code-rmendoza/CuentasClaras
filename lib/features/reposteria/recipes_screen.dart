import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/settings_provider.dart';
import '../../shared/widgets/ad_banner_widget.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  final List<Map<String, dynamic>> _fallbackRecipes = [
    {
      'title': 'Pastel de Chocolate VIP (12 Porciones)',
      'rawCost': 14.50,
      'margin': 60.0,
      'suggestedPrice': 36.25,
      'ingredientsCount': 6,
    },
    {
      'title': 'Cupcakes Red Velvet (Docena)',
      'rawCost': 6.20,
      'margin': 50.0,
      'suggestedPrice': 12.40,
      'ingredientsCount': 5,
    },
  ];

  void _showRecipeCalculatorDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final marginCtrl = TextEditingController(text: '50.0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Calculadora de Costos & Receta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Receta / Producto',
                hintText: 'Ej. Torta de Vainilla 1Kg',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Costo Directo de Insumos (\$)',
                hintText: '12.50',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: marginCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Margen de Ganancia (%)',
                hintText: '50.0',
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
            onPressed: () async {
              final cost = double.tryParse(costCtrl.text) ?? 0.0;
              final margin = double.tryParse(marginCtrl.text) ?? 50.0;
              final price = cost * (1 + (margin / 100));

              if (titleCtrl.text.isNotEmpty && cost > 0) {
                await ref.read(productsDaoProvider).insertProduct(
                      ProductsCompanion.insert(
                        name: titleCtrl.text,
                        defaultPrice: (price * 100).round(),
                        currency: 'USD',
                      ),
                    );
                if (ctx.mounted) Navigator.pop(ctx);
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
    final currency = ref.watch(settingsProvider).defaultCurrency;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Repostería & Calculadora'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const AdBannerWidget(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Calculadora
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
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
                          onPressed: () => _showRecipeCalculatorDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFFE91E63),
                          ),
                          child: const Text('+ Nueva'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingLg),

                  Text(
                    'Recetas & Costo de Producción',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),

                  ref.watch(activeProductsProvider).when(
                    data: (products) {
                      final recipeList = products.isNotEmpty
                          ? products.map((p) {
                              final suggestedPrice = p.defaultPrice / 100.0;
                              final rawCost = suggestedPrice * 0.6;
                              const margin = 50.0;
                              return {
                                'title': p.name,
                                'rawCost': rawCost,
                                'margin': margin,
                                'suggestedPrice': suggestedPrice,
                              };
                            }).toList()
                          : _fallbackRecipes;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recipeList.length,
                        itemBuilder: (context, index) {
                          final item = recipeList[index];
                          final rawCost = item['rawCost'] as double;
                          final margin = item['margin'] as double;
                          final suggestedPrice =
                              item['suggestedPrice'] as double;
                          final netProfit = suggestedPrice - rawCost;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] as String,
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
                                        'Insumos: \$$currency${rawCost.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'Margen: ${margin.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          color: AppColors.info,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Precio: \$$currency${suggestedPrice.toStringAsFixed(2)}',
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
                                      'Ganancia Neta: +\$$currency${netProfit.toStringAsFixed(2)}',
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
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => const SizedBox(),
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
