# CuentasClaras: Estrategia MVP Costo Cero (\$0)

## Guía de Arquitectura, Distribución Alternativa y Hackeo de Costos para el Contexto LATAM 2026

Como consultor de producto y arquitecto, la opción de iniciar un MVP con
un presupuesto de \$0 USD estrictos no solo es completamente viable para
CuentasClaras, sino que metodológicamente es la decisión más
inteligente.

Al ser una aplicación diseñada bajo la filosofía **Local-First**, la
dependencia de infraestructura en la nube durante las primeras etapas es
opcional, eliminando los costos iniciales de servidores.

**Premisa Estratégica:** Validar el encaje producto-mercado
(Product-Market Fit) y la retención real de los bodegueros antes de
gastar dinero en infraestructura de servidores o licencias de
distribución.

------------------------------------------------------------------------

# 1. El Stack Técnico Completamente Gratuito (\$0)

Para lograr operaciones sin costo, se sustituyen servicios de pago o
capas de infraestructura centralizadas por componentes locales de código
abierto y plataformas con niveles gratuitos robustos.

  -----------------------------------------------------------------------
  Componente        Solución          Alternativa Costo Estrategia
                    Tradicional       Cero (\$0)        Operativa
  ----------------- ----------------- ----------------- -----------------
  Desarrollo Mobile Suscripciones /   Flutter SDK + VS  Código abierto,
                    Licencias         Code              multiplataforma y
                                                        entorno local
                                                        gratuito.

  Base de Datos     Cloud NoSQL / RDS Isar Database     Motor embebido
                    AWS (\$15+/mes)   (Local)           ultrarrápido en
                                                        el teléfono.
                                                        Costo cero de
                                                        transferencia de
                                                        datos.

  Respaldo de Datos Sincronización    JSON / CSV        El usuario
                    Cloud Automática  Export + WhatsApp exporta su
                    (\$10+/mes)                         respaldo local y
                                                        lo envía por
                                                        WhatsApp.

  Autenticación     Auth SMS OTP      Sin Registro      Acceso inmediato
                    (\$0.05/SMS)      Inicial / PIN     sin fricción.
                                      Local             

  Métricas y        Plataformas       Firebase          Eventos
  Analítica         Enterprise        Analytics (Free   analíticos
                                      Tier)             estándar y
                                                        reportes de
                                                        Crashlytics.
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# 2. El Hack de Distribución: Evitando los \$25 de Google Play

El primer obstáculo financiero es la tarifa única de Google para abrir
una cuenta de desarrollador.

## Distribución Directa P2P vía WhatsApp/Telegram

Compilar el archivo de producción `app-release.apk` optimizado y
compartirlo directamente en:

-   Grupos de comerciantes.
-   Cámaras de comercio locales.
-   Contacto directo con propietarios de negocios.

## Tiendas de Aplicaciones Alternativas Gratuitas

Publicar el APK sin costo en:

-   Uptodown.
-   APKPure.
-   Huawei AppGallery.

## Landing Page de Descarga con Infraestructura Gratuita

Crear una página web profesional usando:

-   GitHub Pages.
-   Vercel Free Tier.

La página funcionará como centro oficial de descarga e instrucciones de
instalación.

------------------------------------------------------------------------

# 3. Publicidad (AdMob) Desde el Día 1 Sin Costo

El registro en Google AdMob es gratuito.

El MVP incorporará anuncios desde las primeras instalaciones compartidas
por WhatsApp.

Los ingresos generados por los primeros usuarios activos se reservarán
para financiar la cuenta oficial de Google Play Store.

## Control de Fraude de AdMob

Al distribuir el APK fuera de Google Play es necesario configurar
correctamente:

-   Archivo `app-ads.txt`.
-   Landing page gratuita.
-   Validación del origen del inventario publicitario.

------------------------------------------------------------------------

# 4. Cronograma de Ejecución Ágil: MVP en 30 Días

## Semana 1: Configuración Local y Estructura Basal

-   Configuración del entorno Flutter.

-   Creación del repositorio privado gratuito en GitHub.

-   Diseño del esquema de datos local con Isar DB:

    -   Clientes.
    -   Deudas.
    -   Productos.
    -   Historial de tasas.

-   Implementación de calculadora multimoneda local.

------------------------------------------------------------------------

## Semana 2: Desarrollo del Módulo de Operaciones Core

-   Pantallas principales:

    -   Registrar Fiado.
    -   Registrar Abono.

-   Flujo optimizado en menos de 3 clics.

-   Generación de archivos estructurados o PDF locales.

-   Compartir documentos mediante `share_plus` hacia WhatsApp.

------------------------------------------------------------------------

## Semana 3: Integración de Monetización y Landing Page

-   Implementación del SDK de Google AdMob.
-   Colocación de banners adaptativos.
-   Construcción de landing page estática en GitHub Pages.
-   Enlace directo de descarga del APK.

------------------------------------------------------------------------

## Semana 4: Abordaje Orgánico Directo (Guerrilla Marketing)

-   Visitas presenciales a 15 bodegas o puestos comerciales piloto.
-   Instalación manual del APK.
-   Monitoreo mediante Firebase.
-   Iteración de errores críticos durante las primeras 72 horas.

------------------------------------------------------------------------

# 5. Criterios de Control Para el Siguiente Paso (Escala de Capital)

El enfoque bootstrap de \$0 se mantiene hasta cumplir alguno de estos
hitos:

1.  Alcanzar 200 usuarios activos diarios (DAU) que registren al menos 5
    deudas al día.
2.  Acumular \$25 USD netos en AdMob para financiar posteriormente la
    Play Store formal.
3.  Tener una tasa de retención al día 7 (D7) superior al 35%.

Al cumplir estos indicadores, el producto habrá demostrado tracción real
sin arriesgar capital, permitiendo una migración hacia canales de
distribución tradicionales.
