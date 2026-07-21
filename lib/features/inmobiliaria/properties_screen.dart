import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/ad_banner_widget.dart';

class PropertiesScreen extends ConsumerStatefulWidget {
  const PropertiesScreen({super.key});

  @override
  ConsumerState<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends ConsumerState<PropertiesScreen> {
  final List<Map<String, dynamic>> _properties = [
    {
      'title': 'Apartamento 3 Hab. San Isidro',
      'type': 'Venta',
      'price': 120000.0,
      'commissionPct': 3.0,
      'location': 'Calle Los Olivos #402',
      'status': 'Disponible',
    },
    {
      'title': 'Local Comercial 80m2 Centro',
      'type': 'Alquiler',
      'price': 850.0,
      'commissionPct': 100.0, // 1 mes de alquiler
      'location': 'Av. Principal #12',
      'status': 'En Negociación',
    },
  ];

  void _addPropertyDialog() {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final commCtrl = TextEditingController(text: '3.0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Propiedad / Inmueble'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Título del Inmueble',
                hintText: 'Ej. Casa 2 Pisos con Garaje',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio (\$)',
                hintText: '85000',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: commCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Comisión Agente (%)',
                hintText: '3.0',
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
              if (titleCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                setState(() {
                  _properties.add({
                    'title': titleCtrl.text,
                    'type': 'Venta',
                    'price': double.tryParse(priceCtrl.text) ?? 50000.0,
                    'commissionPct': double.tryParse(commCtrl.text) ?? 3.0,
                    'location': 'Ubicación registrada',
                    'status': 'Disponible',
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inmobiliaria & Propiedades'),
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
                  // ── Banner Inmobiliario ────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.home_work_rounded,
                            color: Colors.white, size: 36),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gestor Inmobiliario Lite',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Catálogo de inmuebles, comisiones y recibos de separación.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _addPropertyDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF7C4DFF),
                          ),
                          child: const Text('+ Agregar'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Catálogo de Propiedades ────────────────────
                  const Text(
                    'Catálogo de Propiedades',
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
                    itemCount: _properties.length,
                    itemBuilder: (context, index) {
                      final prop = _properties[index];
                      final price = prop['price'] as double;
                      final commPct = prop['commissionPct'] as double;
                      final commissionAmount = price * (commPct / 100);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      prop['title'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: prop['type'] == 'Venta'
                                          ? AppColors.primaryLight
                                              .withValues(alpha: 0.2)
                                          : AppColors.info
                                              .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      prop['type'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: prop['type'] == 'Venta'
                                            ? AppColors.primaryDark
                                            : AppColors.info,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                prop['location'],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Precio: \$${price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Comisión (${commPct.toStringAsFixed(0)}%): +\$${commissionAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7C4DFF),
                                    ),
                                  ),
                                ],
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
