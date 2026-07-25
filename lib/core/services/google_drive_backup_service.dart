import 'dart:io';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../data/database/app_database.dart';

class BackupMetadata {
  final DateTime? lastBackupDate;
  final int fileSizeBytes;
  final bool isAutoBackupEnabled;
  final String? googleUserEmail;

  const BackupMetadata({
    this.lastBackupDate,
    this.fileSizeBytes = 0,
    this.isAutoBackupEnabled = true,
    this.googleUserEmail,
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

/// Servicio de Respaldo y Restauración Real en Google Drive API v3 (Función PRO).
class GoogleDriveBackupService {
  GoogleDriveBackupService._();
  static final GoogleDriveBackupService instance = GoogleDriveBackupService._();

  static const _storage = FlutterSecureStorage();
  static const _keyLastBackup = 'cc_last_backup_timestamp';
  static const _keyAutoBackup = 'cc_auto_backup_enabled';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveAppdataScope,
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Autentica al usuario mediante OAuth2 con permisos de Google Drive.
  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser;
    } catch (e) {
      debugPrint('Error durante Google Sign-In: $e');
      return null;
    }
  }

  /// Cierra sesión de Google.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint('Error al cerrar sesión de Google: $e');
    }
  }

  /// Obtiene la ruta del archivo de base de datos SQLite activo.
  Future<File> getDatabaseFile() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    return File(p.join(dbFolder.path, AppConstants.databaseName));
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
      googleUserEmail: _currentUser?.email,
    );
  }

  /// Cambia el estado del auto-respaldo en Google Drive.
  Future<void> setAutoBackupEnabled(bool enabled) async {
    await _storage.write(key: _keyAutoBackup, value: enabled.toString());
  }

  /// Exporta y sube el respaldo de la base de datos a Google Drive API v3 en appDataFolder.
  Future<bool> backupToGoogleDrive() async {
    try {
      final dbFile = await getDatabaseFile();
      if (!await dbFile.exists()) {
        debugPrint('El archivo de base de datos no existe aún.');
        return false;
      }

      // Autenticar si no se ha iniciado sesión
      _currentUser ??= await _googleSignIn.signIn();
      if (_currentUser == null) {
        debugPrint('Autenticación cancelada. Exportando mediante Share local fallback...');
        return _fallbackShareBackup(dbFile);
      }

      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        return _fallbackShareBackup(dbFile);
      }

      final driveApi = drive.DriveApi(httpClient);
      final Stream<List<int>> mediaStream = dbFile.openRead();
      final media = drive.Media(mediaStream, await dbFile.length());

      const fileName = 'cuentas_claras_backup.sqlite';

      // Buscar si ya existe un respaldo previo en la carpeta de la app en Google Drive
      final fileList = await driveApi.files.list(
        q: "name = '$fileName' and 'appDataFolder' in parents",
        spaces: 'appDataFolder',
      );

      final now = DateTime.now();

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        // Actualizar archivo existente
        final fileId = fileList.files!.first.id!;
        final driveFile = drive.File()..modifiedTime = now.toUtc();
        await driveApi.files.update(driveFile, fileId, uploadMedia: media);
        debugPrint('Respaldo actualizado en Google Drive (appDataFolder): $fileId');
      } else {
        // Crear nuevo archivo en appDataFolder
        final driveFile = drive.File()
          ..name = fileName
          ..parents = ['appDataFolder'];
        final created = await driveApi.files.create(driveFile, uploadMedia: media);
        debugPrint('Respaldo creado exitosamente en Google Drive: ${created.id}');
      }

      await _storage.write(
        key: _keyLastBackup,
        value: now.toIso8601String(),
      );

      return true;
    } catch (e) {
      debugPrint('Error durante el respaldo en Google Drive API: $e. Intentando exportación local...');
      final dbFile = await getDatabaseFile();
      return _fallbackShareBackup(dbFile);
    }
  }

  Future<bool> _fallbackShareBackup(File dbFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final now = DateTime.now();
      final dateSuffix = DateFormat('yyyyMMdd_HHmmss').format(now);
      final backupFileName = 'CuentasClaras_Backup_$dateSuffix.sqlite';
      final backupFile = File(p.join(tempDir.path, backupFileName));

      await dbFile.copy(backupFile.path);

      final xFile = XFile(backupFile.path, name: backupFileName);
      await Share.shareXFiles(
        [xFile],
        subject: 'Respaldo CuentasClaras Google Drive ($dateSuffix)',
        text: 'Copia de seguridad de CuentasClaras Mini ERP Lite.',
      );

      await _storage.write(
        key: _keyLastBackup,
        value: now.toIso8601String(),
      );
      return true;
    } catch (e) {
      debugPrint('Error en exportación compartida fallback: $e');
      return false;
    }
  }

  /// Restaura la base de datos desde un archivo de copia de seguridad importado.
  Future<bool> restoreFromBackup(
    String sourceFilePath, {
    AppDatabase? currentDb,
  }) async {
    try {
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        debugPrint('El archivo de origen no existe: $sourceFilePath');
        return false;
      }

      if (currentDb != null) {
        await currentDb.close();
      }

      final activeDbFile = await getDatabaseFile();

      final walFile = File('${activeDbFile.path}-wal');
      final shmFile = File('${activeDbFile.path}-shm');
      final journalFile = File('${activeDbFile.path}-journal');

      if (await walFile.exists()) await walFile.delete();
      if (await shmFile.exists()) await shmFile.delete();
      if (await journalFile.exists()) await journalFile.delete();

      if (sourceFile.path != activeDbFile.path) {
        await sourceFile.copy(activeDbFile.path);
      }

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
