import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/business_profile_provider.dart';
import '../../shared/widgets/ad_banner_widget.dart';

class BarberiaScreen extends ConsumerStatefulWidget {
  const BarberiaScreen({super.key});

  @override
  ConsumerState<BarberiaScreen> createState() => _BarberiaScreenState();
}

class _BarberiaScreenState extends ConsumerState<BarberiaScreen> {
  final List<Map<String, dynamic>> _services = [
    {'name': 'Corte Clásico', 'price': 10.0, 'duration': '30 min'},
    {'name': 'Corte + Barba VIP', 'price': 18.0, 'duration': '45 min'},
    {'name': 'Perfilado de Barba', 'price': 8.0, 'duration': '20 min'},
    {'name': 'Tinte / Colorimetría', 'price': 25.0, 'duration': '60 min'},
  ];

  final List<Map<String, dynamic>> _todayAttentions = [
    {
      'client': 'Carlos Gómez',
      'service': 'Corte + Barba VIP',
      'price': 18.0,
      'barber': 'Juan (Barbero 1)',
      'time': '10:30 AM',
    },
    {
      'client': 'Andrés Pérez',
      'service': 'Corte Clásico',
      'price': 10.0,
      'barber': 'Juan (Barbero 1)',
      'time': '11:15 AM',
    },
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
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                setState(() {
                  _services.add({
                    'name': nameCtrl.text,
                    'price': double.tryParse(priceCtrl.text) ?? 10.0,
                    'duration': '30 min',
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(businessProfileProvider);
    final commissionRate = profile.defaultCommissionRate;

    double totalToday = _todayAttentions.fold(
      0.0,
      (sum, item) => sum + (item['price'] as double),
    );
    double totalCommission = totalToday * (commissionRate / 100);

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
                        'Catálogo de Servicios',
                        style: TextStyle(
                          fontSize: 15,
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

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final item = _services[index];
                      return Container(
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
                              item['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${(item['price'] as double).toStringAsFixed(2)} • ${item['duration']}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _todayAttentions.length,
                    itemBuilder: (context, index) {
                      final att = _todayAttentions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Icon(Icons.content_cut_rounded,
                                color: Colors.white, size: 20),
                          ),
                          title: Text(att['client']),
                          subtitle: Text('${att['service']} • ${att['time']}'),
                          trailing: Text(
                            '\$${(att['price'] as double).toStringAsFixed(2)}',
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
