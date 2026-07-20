# 📖 CuentasClaras

[![CI](https://github.com/code-rmendoza/CuentasClaras/actions/workflows/ci.yml/badge.svg)](https://github.com/code-rmendoza/CuentasClaras/actions/workflows/ci.yml)
[![Pages](https://github.com/code-rmendoza/CuentasClaras/actions/workflows/deploy-pages.yml/badge.svg)](https://github.com/code-rmendoza/CuentasClaras/actions/workflows/deploy-pages.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.12.2-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**CuentasClaras** es una aplicación móvil *offline-first* diseñada para la gestión rápida de fiados, créditos y cobros en bodegas y comercios locales de Latinoamérica.

---

## 🚀 Características Principales

- ⚡ **Registro en < 3 Clics:** Formulario optimizado para comerciantes ocupados.
- 📴 **100% Offline-First:** Persistencia local embebida con Drift (SQLite) sin dependencia de internet.
- 💵 **Precisión Financiera Decimal:** Todos los montos se gestionan internamente con precisión entera de centavos.
- 🔒 **Seguridad por PIN Salteado:** Autenticación local protegida mediante hashing `SHA-256 + Salt`.
- 📲 **Exportación & WhatsApp:** Generación de respaldos en CSV/JSON y envío de estados de cuenta por WhatsApp.
- 🎨 **Diseño Moderno & Accesible:** Soporte para modo oscuro/claro y respuesta táctil (Haptics).

---

## 🛠️ Stack Tecnológico

- **Framework:** Flutter SDK (Dart 3)
- **Gestión de Estado:** Flutter Riverpod (`flutter_riverpod`)
- **Persistencia Local:** Drift / SQLite (`drift`, `sqlite3_flutter_libs`)
- **Navegación:** GoRouter (`go_router`)
- **Seguridad:** Flutter Secure Storage & Crypto (`flutter_secure_storage`, `crypto`)
- **Analítica:** Firebase Analytics & Crashlytics

---

## 💻 Instalación y Desarrollo Local

### Prerrequisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) v3.12.2 o superior
- [Dart SDK](https://dart.dev/get-dart) v3.12.2 o superior
- Android Studio / VS Code con extensión Flutter

### Instrucciones
1. Clonar el repositorio:
   ```bash
   git clone https://github.com/code-rmendoza/CuentasClaras.git
   cd CuentasClaras
   ```
2. Instalar dependencias:
   ```bash
   flutter pub get
   ```
3. Generar código de Drift y Riverpod:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Ejecutar la aplicación en emulador o dispositivo:
   ```bash
   flutter run
   ```

---

## 🧪 Pruebas y Calidad de Código

- Ejecutar análisis estático:
  ```bash
  flutter analyze
  ```
- Ejecutar suite de pruebas unitarias y de widgets:
  ```bash
  flutter test
  ```

---

## 🌐 Despliegue & Landing Page

La página de inicio y distribución del proyecto está disponible en GitHub Pages:
👉 [https://code-rmendoza.github.io/CuentasClaras/](https://code-rmendoza.github.io/CuentasClaras/)

