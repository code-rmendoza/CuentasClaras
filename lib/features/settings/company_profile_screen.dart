import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../shared/providers/database_provider.dart';
import '../../data/database/app_database.dart';

/// Pantalla de Datos de la Empresa / Perfil del Negocio.
class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _taxIdController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _headerController;
  late TextEditingController _footerController;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _taxIdController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _headerController = TextEditingController();
    _footerController = TextEditingController();
  }

  void _populateData(CompanyProfileData data) {
    if (!_isLoaded) {
      _nameController.text = data.name;
      _taxIdController.text = data.taxId ?? '';
      _phoneController.text = data.phone ?? '';
      _emailController.text = data.email ?? '';
      _addressController.text = data.address ?? '';
      _headerController.text = data.invoiceHeader ?? '';
      _footerController.text = data.invoiceFooter ?? '';
      _isLoaded = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taxIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final dao = ref.read(companyProfileDaoProvider);
    await dao.updateCompanyProfile(
      CompanyProfileCompanion(
        name: drift.Value(_nameController.text.trim()),
        taxId: drift.Value(_taxIdController.text.trim().isEmpty ? null : _taxIdController.text.trim()),
        phone: drift.Value(_phoneController.text.trim().isEmpty ? null : _phoneController.text.trim()),
        email: drift.Value(_emailController.text.trim().isEmpty ? null : _emailController.text.trim()),
        address: drift.Value(_addressController.text.trim().isEmpty ? null : _addressController.text.trim()),
        invoiceHeader: drift.Value(_headerController.text.trim().isEmpty ? null : _headerController.text.trim()),
        invoiceFooter: drift.Value(_footerController.text.trim().isEmpty ? null : _footerController.text.trim()),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos de la empresa guardados en la base de datos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(companyProfileStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Negocio / Empresa'),
      ),
      body: profileAsync.when(
        data: (data) {
          _populateData(data);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Negocio / Razón Social *',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxIdController,
                  decoration: const InputDecoration(
                    labelText: 'RIF / Identificación Fiscal (NIT/RUT)',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono de Contacto',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Dirección Comercial',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Membrete de Facturas & Comprobantes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _headerController,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje de Encabezado (Ej: ¡Gracias por su preferencia!)',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _footerController,
                  decoration: const InputDecoration(
                    labelText: 'Pie de Página / Notas (Ej: Comprobante de entrega sin enmiendas)',
                    prefixIcon: Icon(Icons.short_text),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Cambios'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
