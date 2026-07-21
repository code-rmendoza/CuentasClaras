import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/enums/business_type.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/business_profile_provider.dart';

/// Pantalla de Selección de Rubro / Smart Onboarding.
///
/// Permite al comerciante/emprendedor adaptar la experiencia completa
/// de CuentasClaras Mini ERP Lite en 1 solo clic.
class BusinessOnboardingScreen extends ConsumerStatefulWidget {
  const BusinessOnboardingScreen({super.key});

  @override
  ConsumerState<BusinessOnboardingScreen> createState() =>
      _BusinessOnboardingScreenState();
}

class _BusinessOnboardingScreenState
    extends ConsumerState<BusinessOnboardingScreen> {
  BusinessType? _selectedType;
  final _nameController = TextEditingController(text: 'Mi Negocio');
  final _ownerController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    final profile = ref.read(businessProfileProvider);
    _selectedType = profile.businessType;
    _nameController.text = profile.businessName;
    _ownerController.text = profile.ownerName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_selectedType == null) return;

    final notifier = ref.read(businessProfileProvider.notifier);
    await notifier.updateBusinessType(_selectedType!);
    final currentProfile = ref.read(businessProfileProvider);

    await notifier.updateDetails(
      businessName: _nameController.text.trim().isEmpty
          ? _selectedType!.label
          : _nameController.text.trim(),
      ownerName: _ownerController.text.trim(),
      phone: currentProfile.phone,
      address: currentProfile.address,
      commissionRate: currentProfile.defaultCommissionRate,
      receiptFooter: currentProfile.receiptFooter,
      logoPath: currentProfile.logoPath,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Configuración guardada para ${_selectedType!.label}!',
          ),
          backgroundColor: _selectedType!.primaryColor,
        ),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configurar tu Negocio'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Banner Superior ─────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CuentasClaras ERP Lite',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Selecciona tu actividad principal para adaptar tus funciones.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Datos del Negocio ─────────────────────────
              const Text(
                'Datos de tu Comercio / Actividad',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre Comercial / Marca',
                  hintText: 'Ej. Bodega Don Pedro, Barbería VIP, Repostería Dulce',
                  prefixIcon: const Icon(Icons.store_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ownerController,
                decoration: InputDecoration(
                  labelText: 'Tu Nombre / Propietario',
                  hintText: 'Ej. Carlos Mendoza',
                  prefixIcon: const Icon(Icons.person_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Selección de Rubro ────────────────────────
              const Text(
                'Selecciona tu Rubro Principal:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: BusinessType.values.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final type = BusinessType.values[index];
                  final isSelected = _selectedType == type;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? type.primaryColor.withValues(alpha: 0.08)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? type.primaryColor
                              : AppColors.border,
                          width: isSelected ? 2.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: type.primaryColor.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? type.primaryColor
                                  : type.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              type.icon,
                              color: isSelected ? Colors.white : type.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? type.primaryColor
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  type.subtitle,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: type.primaryColor,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // ── Botón Guardar ────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType?.primaryColor ?? AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(
                    'Guardar y Empezar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
