import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart' as app_date;
import '../../core/constants/app_constants.dart';
import '../../shared/providers/database_provider.dart';
import '../../data/database/daos/debts_dao.dart';

/// Pantalla de exportación de datos (CSV, JSON).
///
/// Permite exportar respaldos y compartir por WhatsApp.
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Datos'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Exporta tus datos como respaldo o para compartir estados de cuenta por WhatsApp.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // Opciones de exportación
          _ExportOption(
            icon: Icons.table_chart,
            title: 'Exportar CSV',
            description:
                'Archivo de hoja de cálculo con todos los clientes y deudas.',
            color: AppColors.success,
            isLoading: _isExporting,
            onTap: () => _exportCSV(context),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          _ExportOption(
            icon: Icons.data_object,
            title: 'Respaldo JSON',
            description:
                'Respaldo completo de datos. Úsalo para restaurar tu información.',
            color: AppColors.info,
            isLoading: _isExporting,
            onTap: () => _exportJSON(context),
          ),
          const SizedBox(height: AppTheme.spacingMd),

          _ExportOption(
            icon: Icons.share,
            title: 'Compartir por WhatsApp',
            description:
                'Envía un resumen de deudas pendientes a WhatsApp u otra app.',
            color: AppColors.primary,
            isLoading: _isExporting,
            onTap: () => _shareViaWhatsApp(context),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCSV(BuildContext context) async {
    setState(() => _isExporting = true);

    try {
      final dao = ref.read(debtsDaoProvider);
      final debts = await dao.getPendingDebts();

      // Crear CSV
      final rows = <List<dynamic>>[
        ['Cliente', 'Teléfono', 'Deuda', 'Moneda', 'Descripción', 'Fecha'],
        ...debts.map((d) => [
              d.client.name,
              d.client.phone ?? '',
              d.debt.amount,
              d.debt.currency,
              d.debt.description ?? '',
              app_date.DateUtils.formatShort(d.debt.createdAt),
            ]),
      ];

      final csvData = const ListToCsvConverter().convert(rows);

      // Guardar archivo
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = app_date.DateUtils.formatForFileName(DateTime.now());
      final file = File(
        '${dir.path}/${AppConstants.exportFolderName}_$timestamp.csv',
      );
      await file.writeAsString(csvData);

      // Compartir
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'CuentasClaras - Reporte de deudas',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV exportado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
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
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportJSON(BuildContext context) async {
    setState(() => _isExporting = true);

    try {
      final clientsDao = ref.read(clientsDaoProvider);
      final debtsDao = ref.read(debtsDaoProvider);

      final clients = await clientsDao.getAllClients();
      final debts = await debtsDao.getPendingDebts();

      final data = {
        'app': AppConstants.appName,
        'version': AppConstants.appVersion,
        'exportDate': DateTime.now().toIso8601String(),
        'clients': clients
            .map((c) => {
                  'id': c.id,
                  'name': c.name,
                  'phone': c.phone,
                  'createdAt': c.createdAt.toIso8601String(),
                })
            .toList(),
        'pendingDebts': debts
            .map((d) => {
                  'clientName': d.client.name,
                  'amount': d.debt.amount,
                  'currency': d.debt.currency,
                  'description': d.debt.description,
                  'createdAt': d.debt.createdAt.toIso8601String(),
                })
            .toList(),
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = app_date.DateUtils.formatForFileName(DateTime.now());
      final file = File(
        '${dir.path}/${AppConstants.exportFolderName}_$timestamp.json',
      );
      await file.writeAsString(jsonStr);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'CuentasClaras - Respaldo de datos',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Respaldo JSON exportado'),
            backgroundColor: AppColors.success,
          ),
        );
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
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareViaWhatsApp(BuildContext context) async {
    setState(() => _isExporting = true);

    try {
      final debts = await ref.read(debtsDaoProvider).getPendingDebts();

      if (debts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay deudas pendientes')),
          );
        }
        return;
      }

      // Crear mensaje de texto
      final buffer = StringBuffer();
      buffer.writeln('📋 *CuentasClaras - Resumen de Deudas*');
      buffer.writeln('📅 ${app_date.DateUtils.formatFull(DateTime.now())}');
      buffer.writeln('');

      // Agrupar por cliente
      final grouped = <String, List<DebtWithClient>>{};
      for (final d in debts) {
        grouped.putIfAbsent(d.client.name, () => []).add(d);
      }

      for (final entry in grouped.entries) {
        buffer.writeln('👤 *${entry.key}*');
        for (final d in entry.value) {
          buffer.writeln(
            '  • ${CurrencyUtils.formatAmount(d.debt.amount, d.debt.currency)}'
            '${d.debt.description != null ? " - ${d.debt.description}" : ""}',
          );
        }
        buffer.writeln('');
      }

      buffer.writeln('_Generado con CuentasClaras_');

      await Share.share(buffer.toString());
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
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(description,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
