import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

/// Punto de entrada de CuentasClaras.
///
/// Inicializa dependencias necesarias antes de ejecutar la app:
/// - Flutter bindings
/// - Firebase (Analytics & Core)
/// - Locale de fechas en español
/// - Orientación del dispositivo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase (si se incluyó google-services.json)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init notice: $e');
  }

  // Inicializar locale español para fechas
  await initializeDateFormatting('es', null);

  // Orientación: solo vertical (óptimo para bodegueros)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar transparente
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: CuentasClarasApp(),
    ),
  );
}
