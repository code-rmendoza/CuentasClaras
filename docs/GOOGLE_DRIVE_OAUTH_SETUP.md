# Guía de Configuración de Google Drive API v3 y OAuth2

Para habilitar el respaldo automático en Google Drive API v3 dentro de **CuentasClaras**, sigue estos pasos:

---

## 1. Obtener la Huella SHA-1 del Keystore

Ejecuta en tu terminal el siguiente comando para obtener la huella digital SHA-1 de la llave de firma:

```bash
keytool -list -v -keystore android/app/release.jks -alias cuentasclaras_release_key
```

Copia la huella `SHA-1` resultante (ejemplo: `AA:BB:CC:DD:11:22:33:44...`).

---

## 2. Habilitar la API en Google Cloud Console

1. Inicia sesión en [Google Cloud Console](https://console.cloud.google.com/).
2. Crea un nuevo proyecto llamado `CuentasClaras App`.
3. Ve a **APIs y servicios** -> **Biblioteca**.
4. Busca **Google Drive API** y haz clic en **Habilitar**.
5. Ve a **Pantalla de consentimiento de OAuth**:
   - Tipo de usuario: **Externo**.
   - Nombre de la app: **CuentasClaras**.
   - Agrega el alcance (*scope*): `.../auth/drive.appdata` y `.../auth/drive.file`.
6. Ve a **Credenciales** -> **Crear credenciales** -> **ID de cliente de OAuth**:
   - **Tipo de aplicación:** Android.
   - **Nombre del paquete:** `com.cuentasclaras.cuentas_claras`
   - **Huella digital SHA-1:** Pega la huella obtenida en el paso 1.

---

## 3. Descarga del Archivo google-services.json

1. Si utilizas Firebase para Analytics / OAuth, ve a la Consola de Firebase y descarga el archivo `google-services.json`.
2. Colócalo en el directorio del proyecto:
   `android/app/google-services.json`
3. Recuerda que este archivo está excluido en `.gitignore` por seguridad.
