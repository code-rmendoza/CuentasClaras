import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/google_drive_backup_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/monetization_provider.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  final GoogleDriveBackupService _backupService =
      GoogleDriveBackupService.instance;

  BackupMetadata _metadata = const BackupMetadata();
  bool _isLoading = true;
  bool _isBackingUp = false;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    setState(() => _isLoading = true);
    final meta = await _backupService.getBackupMetadata();
    setState(() {
      _metadata = meta;
      _isLoading = false;
    });
  }

  /// Ejecuta el proceso de respaldo a Google Drive.
  Future<void> _triggerBackup() async {
    setState(() => _isBackingUp = true);

    try {
      final success = await _backupService.backupToGoogleDrive();
      setState(() => _isBackingUp = false);

      if (success) {
        await _loadMetadata();
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('¡Respaldo Generado!'),
                ],
              ),
              content: const Text(
                'Tu copia de seguridad de CuentasClaras se ha preparado exitosamente. Puedes guardarla en Google Drive, enviártela por correo o guardar una copia local.',
                style: TextStyle(fontSize: 13),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isBackingUp = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error durante el respaldo: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Diálogo interactivo para restaurar respaldos.
  void _confirmRestore() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Restaurar Respaldo'),
          ],
        ),
        content: const Text(
          'Al restaurar una copia de seguridad, los datos actuales de tu negocio (clientes, deudas e inventario) serán reemplazados por los del respaldo.\n\n¿Deseas seleccionar un archivo de copia de seguridad?',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await _processRestoreFile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.folder_open_rounded, size: 18),
            label: const Text('Seleccionar Archivo'),
          ),
        ],
      ),
    );
  }

  Future<void> _processRestoreFile() async {
    final dbFile = await _backupService.getDatabaseFile();
    if (await dbFile.exists()) {
      final success =
          await _backupService.restoreFromBackup(dbFile.path);
      if (mounted && success) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.verified_rounded, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Restauración Exitosa'),
              ],
            ),
            content: const Text(
              'Tus datos han sido restaurados correctamente desde la copia de seguridad.',
              style: TextStyle(fontSize: 13),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ir al Inicio'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final monetization = ref.watch(monetizationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final cardBg = isDark ? AppColors.darkCard : Colors.white;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.border;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: const Text('Respaldo en Google Drive'),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tarjeta de Estado Cloud ───────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: monetization.isPro
                            ? [const Color(0xFF081425), const Color(0xFF064E3B)]
                            : [const Color(0xFF0F172A), const Color(0xFF1E3A5F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.cloud_done_rounded,
                                    color: AppColors.primaryLight,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Google Drive Cloud',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      monetization.isPro
                                          ? 'Sincronizado • Plan PRO'
                                          : 'Modo Manual (Plan Gratuito)',
                                      style: TextStyle(
                                        color: monetization.isPro
                                            ? AppColors.primaryLight
                                            : Colors.amberAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!monetization.isPro)
                              InkWell(
                                onTap: () => context.push('/pro-upgrade'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Último respaldo:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _metadata.formattedDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tamaño de base de datos:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _metadata.formattedSize,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Acciones Principales ─────────────────────────
                  Text(
                    'Acciones de Respaldo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botón 1: Crear Respaldo (Elevated High Contrast)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isBackingUp ? null : _triggerBackup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _isBackingUp
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                      label: Text(
                        _isBackingUp
                            ? 'Generando Respaldo...'
                            : 'Crear Respaldo en Google Drive Ahora',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botón 2: Restaurar Respaldo (Outlined High Contrast)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _confirmRestore,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark.withValues(alpha: 0.08),
                        foregroundColor: AppColors.primaryDark,
                        side: const BorderSide(
                          color: AppColors.primaryDark,
                          width: 2.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(
                        Icons.cloud_download_rounded,
                        color: AppColors.primaryDark,
                      ),
                      label: const Text(
                        'Restaurar Respaldo de Google Drive',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Switch Container con Alto Contraste ─────────────
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCol, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SwitchListTile(
                      title: Text(
                        'Auto-Respaldo Diario',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Genera una copia automática de seguridad cada 24 horas.',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                      value: _metadata.isAutoBackupEnabled,
                      activeTrackColor: AppColors.primary,
                      activeThumbColor: Colors.white,
                      onChanged: (val) async {
                        await _backupService.setAutoBackupEnabled(val);
                        _loadMetadata();
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Beneficios Nube con Alto Contraste ───────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.shield_rounded,
                              color: AppColors.primaryDark,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '¿Por qué guardar tus respaldos en la Nube?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildFeatureItem(
                          '100% Privado:',
                          'Tus datos van directo a tu Google Drive personal, sin servidores de terceros.',
                          textPrimary,
                        ),
                        const SizedBox(height: 8),
                        _buildFeatureItem(
                          'Cambio de Teléfono:',
                          'Restaura tus clientes, fiados e inventario en segundos si cambias de móvil.',
                          textPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureItem(String title, String desc, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: textColor),
              children: [
                TextSpan(
                  text: '$title ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
