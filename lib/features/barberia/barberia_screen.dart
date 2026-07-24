import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/theme/app_colors.dart';
import '../../data/database/app_database.dart';
import '../../shared/providers/business_profile_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/widgets/ad_banner_widget.dart';

class BarberiaScreen extends ConsumerStatefulWidget {
  const BarberiaScreen({super.key});

  @override
  ConsumerState<BarberiaScreen> createState() => _BarberiaScreenState();
}

class _BarberiaScreenState extends ConsumerState<BarberiaScreen> {
  final List<Map<String, dynamic>> _fallbackServices = [
    {'name': 'Corte Clásico', 'price': 10.0, 'duration': '30 min'},
    {'name': 'Corte + Barba VIP', 'price': 18.0, 'duration': '45 min'},
    {'name': 'Perfilado de Barba', 'price': 8.0, 'duration': '20 min'},
    {'name': 'Tinte / Colorimetría', 'price': 25.0, 'duration': '60 min'},
  ];

  void _addServiceDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo Servicio de Barbería'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del Servicio',
                hintText: 'Ej. Limpieza Facial',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio (\$)',
                hintText: '12.0',
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
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                final priceVal = double.tryParse(priceCtrl.text) ?? 10.0;
                await ref.read(productsDaoProvider).insertProduct(
                      ProductsCompanion.insert(
                        name: nameCtrl.text,
                        defaultPrice: (priceVal * 100).round(),
                        currency: 'USD',
                      ),
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _registerAttention(String serviceName, double price) async {
    final priceCents = (price * 100).round();
    await ref.read(incomesDaoProvider).insertIncome(
          IncomesCompanion.insert(
            amount: priceCents,
            currency: 'USD',
            paymentMethod: 'cash',
            description: 'Atención Barbería: $serviceName',
            createdAt: drift.Value(DateTime.now()),
          ),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Atención de "$serviceName" registrada (\$${price.toStringAsFixed(2)})'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider);
    final commissionRate = profile.defaultCommissionRate;
    final incomesAsync = ref.watch(allIncomesProvider);
    final productsAsync = ref.watch(activeProductsProvider);

    // Filtrar atenciones de barbería ingresadas hoy
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayIncomes = incomesAsync.maybeWhen(
      data: (list) => list.where((item) {
        final inc = item.income;
        return inc.description.contains('Barbería') && inc.createdAt.isAfter(todayStart);
      }).toList(),
      orElse: () => [],
    );

    final double totalToday = todayIncomes.fold(
      0.0,
      (sum, item) => sum + (item.income.amount / 100.0),
    );
    final double totalCommission = totalToday * (commissionRate / 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Barbería & Servicios'),
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
                  // ── Resumen de Comisiones ───────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.badge_rounded, color: Colors.amber),
                            SizedBox(width: 8),
                            Text(
                              'Resumen de Comisiones del Día',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Servicios Hoy',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 11),
                                ),
                                Text(
                                  '\$${totalToday.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Comisión (${commissionRate.toStringAsFixed(0)}%)',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 11),
                                ),
                                Text(
                                  '\$${totalCommission.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Catálogo de Servicios ──────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Catálogo de Servicios (Toca para registrar)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: _addServiceDialog,
                        icon: const Icon(Icons.add_circle_rounded,
                            color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  productsAsync.when(
                    data: (products) {
                      final servicesList = products.isNotEmpty
                          ? products
                              .map((p) => {
                                    'name': p.name,
                                    'price': p.defaultPrice / 100.0,
                                    'duration': 'Servicio',
                                  })
                              .toList()
                          : _fallbackServices;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: servicesList.length,
                        itemBuilder: (context, index) {
                          final item = servicesList[index];
                          final name = item['name'] as String;
                          final price = item['price'] as double;
                          final duration = item['duration'] as String;

                          return InkWell(
                            onTap: () => _registerAttention(name, price),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${price.toStringAsFixed(2)} • $duration',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
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

                  const SizedBox(height: 24),

                  // ── Atenciones del Día ─────────────────────────
                  const Text(
                    'Atenciones Registradas Hoy',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (todayIncomes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No hay atenciones registradas hoy. Toca un servicio arriba para agregar.',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayIncomes.length,
                      itemBuilder: (context, index) {
                        final item = todayIncomes[index];
                        final inc = item.income;
                        final price = inc.amount / 100.0;
                        final timeStr =
                            '${inc.createdAt.hour.toString().padLeft(2, '0')}:${inc.createdAt.minute.toString().padLeft(2, '0')}';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Icon(Icons.content_cut_rounded,
                                  color: Colors.white, size: 20),
                            ),
                            title: Text(inc.description ?? 'Atención Barbería'),
                            subtitle: Text('Efectivo • $timeStr'),
                            trailing: Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
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
