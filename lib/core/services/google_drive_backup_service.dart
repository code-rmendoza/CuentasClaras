import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class BackupMetadata {
  final DateTime? lastBackupDate;
  final int fileSizeBytes;
  final bool isAutoBackupEnabled;

  const BackupMetadata({
    this.lastBackupDate,
    this.fileSizeBytes = 0,
    this.isAutoBackupEnabled = true,
  });

  String get formattedDate {
    if (lastBackupDate == null) return 'Nunca realizado';
    return DateFormat('dd/MM/yyyy hh:mm a').format(lastBackupDate!);
  }

  String get formattedSize {
    if (fileSizeBytes == 0) return '0 KB';
    final kb = fileSizeBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(2)} MB';
  }
}

/// Servicio de Respaldo y Restauración Automática en Google Drive (Función PRO).
class GoogleDriveBackupService {
  GoogleDriveBackupService._();
  static final GoogleDriveBackupService instance = GoogleDriveBackupService._();

  static const _storage = FlutterSecureStorage();
  static const _keyLastBackup = 'cc_last_backup_timestamp';
  static const _keyAutoBackup = 'cc_auto_backup_enabled';

  /// Obtiene la ruta del archivo de base de datos SQLite activo.
  Future<File> getDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, 'cuentas_claras.sqlite'));
  }

  /// Obtiene los metadatos del último respaldo.
  Future<BackupMetadata> getBackupMetadata() async {
    final lastStr = await _storage.read(key: _keyLastBackup);
    final autoStr = await _storage.read(key: _keyAutoBackup);

    DateTime? lastDate;
    if (lastStr != null) {
      lastDate = DateTime.tryParse(lastStr);
    }

    final dbFile = await getDatabaseFile();
    int size = 0;
    if (await dbFile.exists()) {
      size = await dbFile.length();
    }

    return BackupMetadata(
      lastBackupDate: lastDate,
      fileSizeBytes: size,
      isAutoBackupEnabled: autoStr != 'false',
    );
  }

  /// Cambia el estado del auto-respaldo en Google Drive.
  Future<void> setAutoBackupEnabled(bool enabled) async {
    await _storage.write(key: _keyAutoBackup, value: enabled.toString());
  }

  /// Exporta y sube el respaldo de la base de datos a Google Drive (Función PRO).
  Future<bool> backupToGoogleDrive() async {
    try {
      final dbFile = await getDatabaseFile();
      if (!await dbFile.exists()) {
        debugPrint('El archivo de base de datos no existe aún.');
        return false;
      }

      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final dateSuffix = DateFormat('yyyyMMdd_HHmmss').format(now);
      final backupFileName = 'CuentasClaras_Backup_$dateSuffix.sqlite';
      final backupFile = File(p.join(tempDir.path, backupFileName));

      // Copia de seguridad temporal
      await dbFile.copy(backupFile.path);

      // Abrir selector de Google Drive / Compartir archivo
      final xFile = XFile(backupFile.path, name: backupFileName);
      final result = await Share.shareXFiles(
        [xFile],
        subject: 'Respaldo CuentasClaras Google Drive ($dateSuffix)',
        text: 'Copia de seguridad de CuentasClaras Mini ERP Lite.',
      );

      // Registrar timestamp del respaldo
      await _storage.write(
        key: _keyLastBackup,
        value: now.toIso8601String(),
      );

      debugPrint('Respaldo exportado con estado: ${result.status}');
      return true;
    } catch (e) {
      debugPrint('Error durante el respaldo a Google Drive: $e');
      return false;
    }
  }

  /// Restaura la base de datos desde un archivo de copia de seguridad importado.
  Future<bool> restoreFromBackup(String sourceFilePath) async {
    try {
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        return false;
      }

      final activeDbFile = await getDatabaseFile();

      // Sobrescribe la base de datos actual con la del respaldo
      await sourceFile.copy(activeDbFile.path);

      final now = DateTime.now();
      await _storage.write(
        key: _keyLastBackup,
        value: now.toIso8601String(),
      );

      debugPrint('Base de datos restaurada exitosamente desde: $sourceFilePath');
      return true;
    } catch (e) {
      debugPrint('Error al restaurar la base de datos: $e');
      return false;
    }
  }
}
