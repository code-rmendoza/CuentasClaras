# Guía de Configuración de Suscripciones e In-App Purchases (IAP)

Esta guía detalla los pasos para dar de alta los productos PRO de **CuentasClaras** en **Google Play Console** y **Apple App Store Connect**.

---

## 1. Identificadores de Producto (SKUs)

El código fuente de CuentasClaras utiliza los siguientes IDs estándar:

| ID de Producto | Tipo de Producto | Precio Recomendado | Descripción |
| :--- | :--- | :--- | :--- |
| `cuentasclaras_pro_monthly` | Suscripción Recurrente | $3.99 USD / mes | Acceso completo a funciones PRO (Impresora POS + Backup Drive + Sin Anuncios) |
| `cuentasclaras_pro_yearly` | Suscripción Recurrente | $29.99 USD / año | Ahorra 37% respecto a la suscripción mensual |

---

## 2. Configuración en Google Play Console

1. Inicia sesión en [Google Play Console](https://play.google.com/console).
2. Selecciona la aplicación **CuentasClaras**.
3. En el menú lateral izquierdo, ve a **Monetización** -> **Productos** -> **Suscripciones**.
4. Haz clic en **Crear suscripción**:
   - **ID de producto:** `cuentasclaras_pro_monthly`
   - **Nombre:** `CuentasClaras PRO Mensual`
   - Configura el plan básico de facturación mensual a **$3.99 USD**.
5. Repite el proceso para `cuentasclaras_pro_yearly` configurando la facturación anual a **$29.99 USD**.
6. **Probadores de licencias (*License Testing*):**
   - Ve a **Configuración del desarrollador** -> **Prueba de licencias**.
   - Agrega las cuentas de correo Gmail de los desarrolladores/QA para realizar compras de prueba sin cargo real.

---

## 3. Configuración en Apple App Store Connect

1. Inicia sesión en [App Store Connect](https://appstoreconnect.apple.com).
2. Selecciona **CuentasClaras** -> **Monetización** -> **In-App Purchases** / **Subscriptions**.
3. Crea un **Grupo de Suscripciones** llamado `CuentasClaras PRO`.
4. Agrega los productos:
   - **Product ID:** `cuentasclaras_pro_monthly`
   - **Product ID:** `cuentasclaras_pro_yearly`
5. **Cuentas de Sandbox:**
   - En **Users and Access** -> **Sandbox Testers**, crea usuarios de prueba para validar compras en iOS.
