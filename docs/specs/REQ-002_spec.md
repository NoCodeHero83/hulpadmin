# Especificación Técnica — REQ-002
**Título:** Visualización y descarga de documentos de proveedores desde el panel administrativo
**Fecha:** 2026-06-08
**Estado:** Implementado
**Metodología:** Spec Driven Development (SDD)

> **Alcance de este spec:** visualización y descarga (solo lectura) de los documentos del proveedor —documentos de registro y certificaciones— y el diseño de esa sección (grid, estados, responsividad).
>
> El rediseño que migró el pop-up `InformacionProveedorWidget` a la página dedicada `DetalleProveedor` se trasladó a [REQ-005](REQ-005_spec.md) (era la antigua Adenda §11 de este archivo). Este spec ya no la contiene.

---

## Control de versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0.0 | 2026-06-08 | Equipo Hulp | Versión inicial: Zona A (documentos de registro) y Zona B (certificaciones) dentro del componente `InformacionProveedorWidget` (pop-up). |
| **v1.1.0** | **2026-06-09** | **Equipo Hulp** | **Rediseño de la sección Documentos (fusionado desde el antiguo REQ-003): grid de 3 columnas en desktop con slots vacíos invisibles; empty states útiles en ambas zonas (incl. Zona A cuando no hay ningún documento de registro); certificaciones organizadas en filas de 3; fecha de subida (`created_at`) en tarjetas de certificación; diseño responsivo (1 columna < 600px, 3 columnas ≥ 600px) vía `LayoutBuilder`. Ver §6 y §8 (CA-11 a CA-15). Solo presentación; sin cambios en la lógica de `openDocument`/`downloadDocument`/queries.** |
| **v1.2.0** | **2026-06-18** | **Equipo Hulp** | **Extracción de la Adenda §11 (migración de pop-up a página `DetalleProveedor`) a su propio requerimiento [REQ-005](REQ-005_spec.md). Este archivo queda enfocado exclusivamente en el feature de documentos. Sin cambios de código asociados a esta reorganización documental.** |

---

## 1. Resumen del cambio

Se agregan dos zonas de solo lectura al widget `InformacionProveedorWidget`:

**Zona A — Documentos de Registro** (nueva sección).
Muestra tres documentos vinculados al proveedor en la tabla `usuarios`: cédula, cuenta bancaria y contrato. Cada documento se presenta con su nombre descriptivo y dos acciones: "Ver" (abre la URL en el navegador/visor nativo) y "Descargar" (descarga el archivo localmente). Si una URL está vacía/nula se muestra un indicador de estado "No cargado".

**Zona B — Certificaciones** (sección existente, ampliada).
La sección "Certificaciones" ya existe y ya consulta `CertificacionesTable`. Actualmente muestra el nombre de la entidad y un placeholder gris estático con el texto "Archivo". Se reemplaza ese placeholder por dos botones funcionales: "Ver" y "Descargar", operando sobre `documentoUrl`, e incluye la fecha de subida (`created_at`).

Ambas zonas son de **solo lectura**. No se agregan controles de edición, eliminación ni subida de archivos. El acceso está restringido al rol `administrador`.

**Diseño (v1.1.0):** ambas zonas se renderizan en un grid de 3 columnas en desktop (≥ 600px) y en 1 columna en móvil (< 600px), con empty states explícitos y slots vacíos invisibles para mantener la uniformidad del grid.

> **Nota de reutilización:** la página `DetalleProveedor` ([REQ-005](REQ-005_spec.md)) consume el mismo helper `_buildDocumentCard` y los métodos `openDocument` / `downloadDocument` definidos aquí. Cualquier cambio de comportamiento en este feature debe reflejarse en ambos contextos.

---

## 2. Análisis de impacto

| Archivo | Acción | Justificación |
|---|---|---|
| `lib/components/informacion_proveedor_widget.dart` | **Modificar** | Es el único archivo de UI del componente. Aquí se inserta Zona A, se amplía Zona B y se aplica el grid/responsividad (v1.1.0). |
| `lib/components/informacion_proveedor_model.dart` | **Modificar** | Agregar estado de carga (`_isDownloading`) y el método `downloadDocument()`. |
| `lib/backend/supabase/database/tables/usuarios.dart` | Solo lectura | Ya expone `cedula`, `cuentaBancaria`, `contrato` como `String?`. Sin cambios. |
| `lib/backend/supabase/database/tables/certificaciones.dart` | **Modificar (v1.1.0)** | Agregar getter `DateTime? get createdAt` mapeado a la columna `created_at`. Ya expone `documentoUrl` y `entidadCertificadora`. |
| Migración SQL Supabase (producción y sandbox) | **Aplicar (v1.1.0)** | Columna `created_at` en la tabla `certificaciones`. Migración aplicada. |
| `pubspec.yaml` | Sin cambios | `url_launcher: 6.3.1`, `file_saver: 0.2.14`, `http: 1.4.0` e `intl: 0.20.2` ya están declarados. |

**Archivos que NO se tocan:** rutas de navegación, auth, cualquier otra pantalla o widget.

---

## 3. Modelo de datos

### 3.1 Tabla `usuarios` (ya consultada en el widget)

| Campo Dart | Columna Supabase | Tipo | Nullable | Descripción |
|---|---|---|---|---|
| `cedula` | `cedula` | `String?` | Sí | URL al archivo PDF/imagen de la cédula en Storage |
| `cuentaBancaria` | `cuenta_bancaria` | `String?` | Sí | URL al archivo de cuenta bancaria en Storage |
| `contrato` | `contrato` | `String?` | Sí | URL al archivo de contrato firmado en Storage |

La fila se obtiene en el `FutureBuilder` de la línea 87 del widget, disponible como `columnUsuariosRow`. No se requiere nueva consulta.

### 3.2 Tabla `certificaciones` (ya consultada en el widget)

| Campo Dart | Columna Supabase | Tipo | Nullable | Descripción |
|---|---|---|---|---|
| `id` | `id` | `String` | No | PK de la certificación |
| `usuarioId` | `usuario_id` | `String` | No | FK hacia `usuarios.id` |
| `entidadCertificadora` | `entidad_certificadora` | `String` | No | Nombre de la entidad |
| `documentoUrl` | `documento_url` | `String` | No | URL al documento en Storage |
| `createdAt` *(v1.1.0)* | `created_at` | `DateTime?` | Sí | Fecha de subida de la certificación; se muestra como "Subido el DD/MM/YYYY" |

La lista se obtiene en el `FutureBuilder<List<CertificacionesRow>>` de la línea 2269. No se requiere nueva consulta.

---

## 4. Contratos de función / servicio

Todos los helpers se ubican en `informacion_proveedor_model.dart`, como métodos de instancia de `InformacionProveedorModel`, o como funciones privadas top-level del mismo archivo.

### 4.1 `openDocument`

```
Future<void> openDocument(String url) async
```

- **Propósito:** Abrir la URL en el navegador o visor nativo del sistema operativo.
- **Parámetros:** `url` — URL absoluta no vacía (validada antes de llamar).
- **Efecto:** Llama `launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)`.
- **Error:** Si `launchUrl` retorna `false` o lanza excepción, relanza `Exception('No se pudo abrir el documento')`. El llamador es responsable de mostrar el error al usuario.
- **Imports requeridos:** `package:url_launcher/url_launcher.dart`.

### 4.2 `downloadDocument`

```
Future<void> downloadDocument(String url, String fileName) async
```

- **Propósito:** Descargar el archivo desde `url` y guardarlo localmente usando `file_saver`.
- **Parámetros:**
  - `url` — URL absoluta no vacía.
  - `fileName` — nombre sugerido para el archivo descargado (ej. `cedula_<proveedorId>.pdf`).
- **Flujo interno:**
  1. `setState` → `_isDownloading = true` (en el modelo).
  2. `GET url` con `http.Client()`. Timeout de 30 segundos.
  3. Si `response.statusCode != 200` → lanza `Exception('Error al descargar: ${response.statusCode}')`.
  4. Infiere `mimeType` desde `Content-Type` del header (`response.headers['content-type'] ?? 'application/octet-stream'`). Extrae solo el tipo base antes del `;`.
  5. Llama `FileSaver.instance.saveFile(name: fileName, bytes: response.bodyBytes, mimeType: MimeType.other)`.
  6. Finalmente: `setState` → `_isDownloading = false`.
- **Error:** Cualquier excepción se captura, se asigna `_isDownloading = false`, y se relanza para que el llamador la muestre.
- **Imports requeridos:** `package:http/http.dart`, `package:file_saver/file_saver.dart`.

### 4.3 `_buildDocumentCard` (helper de UI — función privada top-level o método del State)

```
Widget _buildDocumentCard(
  BuildContext context, {
  required String label,
  required String? url,
  required String downloadPrefix,
  required String? proveedorId,
  required bool isDownloading,
  required VoidCallback? onView,
  required VoidCallback? onDownload,
  DateTime? uploadDate,   // v1.1.0 — muestra "Subido el DD/MM/YYYY"
})
```

- **Propósito:** Renderizar una tarjeta de documento reutilizable para Zona A y Zona B.
- **Parámetros:**
  - `label` — título de la tarjeta (ej. `'Cédula'`, o `entidadCertificadora`).
  - `url` — URL del documento; si es `null` o vacía se muestra estado "No cargado" sin botones.
  - `downloadPrefix` — prefijo del nombre de archivo descargado (ej. `'cedula'` → `'cedula_<proveedorId>.<ext>'`).
  - `proveedorId` — usado para construir el `downloadFileName`.
  - `isDownloading` — si `true`, el botón "Descargar" muestra spinner y está deshabilitado.
  - `onView` / `onDownload` — `null` cuando `url` es vacía/nula (botones no se renderizan).
  - `uploadDate` *(v1.1.0)* — si no es nulo, se muestra "Subido el DD/MM/YYYY" (formato `intl`). Usado por las certificaciones.
- **Retorno:** `Widget` con el layout de tarjeta descrito en §6.3.

### 4.4 Helpers de grid y responsividad (v1.1.0)

```dart
Widget _buildEmptyColumn();                 // => const Expanded(child: SizedBox());  slot invisible
Widget _buildDocRow(List<Widget> cards);    // fila de 3 con spacers invisibles para slots faltantes
```

- `_buildEmptyColumn`: devuelve `Expanded(child: SizedBox())` para rellenar columnas faltantes y mantener la uniformidad del grid de 3.
- `_buildDocRow`: agrupa hasta 3 tarjetas por fila; los huecos se completan con `_buildEmptyColumn()`.

### 4.5 `_extractFilename` y `_isImageUrl` (helpers de utilidad — funciones privadas)

```dart
String _extractFilename(String? url)
bool _isImageUrl(String url)
```

- `_extractFilename`: retorna el último segmento del path de la URL como nombre de archivo. Si `url` es nula, vacía, o el parse falla, retorna `'Sin archivo'`.
- `_isImageUrl`: retorna `true` si la extensión del path (ignorando query params y case) es una de: `jpg`, `jpeg`, `png`, `webp`. Se usa para decidir entre thumbnail real o ícono PDF.

---

## 5. Comportamiento por caso

| # | Caso | Entrada | Salida esperada | Manejo de error |
|---|---|---|---|---|
| C-01 | URL presente, usuario pulsa "Ver" | `url` válida no vacía | `launchUrl` abre el documento en el navegador/app nativa | Si `launchUrl` falla: `SnackBar` con mensaje `'No se pudo abrir el documento'` |
| C-02 | URL presente, usuario pulsa "Descargar" | `url` válida no vacía | Botón muestra spinner, se descarga el archivo, `file_saver` activa el diálogo de guardado nativo | Si `http.get` falla (timeout, 4xx, 5xx): `SnackBar` con `'Error al descargar el documento'` |
| C-03 | URL ausente (null o vacía) | `url == null \|\| url.isEmpty` | Se muestra chip/badge `'No cargado'`; botones "Ver" y "Descargar" **no se renderizan** | N/A (estado estático) |
| C-04 | Descarga en progreso | `isDownloading == true` | Botón "Descargar" reemplazado por `CircularProgressIndicator` de 18×18; botón "Ver" sigue habilitado | N/A |
| C-05 | Certificación sin documentos | `containerCertificacionesRowList.isEmpty` | Se muestra el estado vacío de Zona B: ícono `workspace_premium_outlined` + texto descriptivo | N/A |
| C-06 | Todos los docs de registro ausentes | Los tres campos `cedula`, `cuentaBancaria`, `contrato` son null | Zona A muestra el empty state (ícono `Icons.upload_file_outlined` + texto, ver §6.1.3) | N/A |
| C-07 | Error de red al cargar datos del widget | `FutureBuilder` snapshot tiene `connectionState.done` y `!snapshot.hasData` | El widget ya maneja esto con `CircularProgressIndicator` (código existente, sin cambios) | N/A |
| C-08 | Ancho < 600px (móvil) | `constraints.maxWidth < 600` | Ambas zonas colapsan a 1 tarjeta por fila a ancho completo | N/A |

---

## 6. Especificación de UI

> **Header de la sección (v1.1.0):** título "Documentos" con ícono `Icons.description_outlined`.
>
> **Responsividad (v1.1.0):** la sección se envuelve en `LayoutBuilder`. `isMobile = constraints.maxWidth < 600`. En desktop (≥ 600px) se usa el grid de 3 columnas (`_buildDocRow`); en móvil (< 600px) se usa una `Column` de tarjetas a ancho completo. **El diseño desktop existente no se modifica; solo se agrega la rama móvil.**

### 6.1 Zona A — Documentos de Registro

**Posición:** Insertar como nuevo bloque hijo del `Column` principal, **inmediatamente antes** del `Align` que contiene el `Text('Certificaciones')` (~línea 2242).

#### 6.1.1 Encabezado de sección

```
Row: MainAxisAlignment.spaceBetween
  Text "Documentos de registro"
    fontSize: 20, fontWeight: w600, color: primaryText
    padding top: 24, bottom: 12
  Badge "X/X cargados"           ← contador verde
    color fondo: Color(0xFFE8F5E9)
    color texto: Color(0xFF2E7D32)
    fontSize: 12, borderRadius: 20
    padding: horizontal 10, vertical 4
```

El contador `X` (cargados) = número de campos entre `cedula`, `cuentaBancaria`, `contrato` cuyo valor no es nulo ni vacío. El total es siempre `3`.

#### 6.1.2 Grid de tarjetas (desktop ≥ 600px)

Layout: 3 columnas con `Expanded`. Las tarjetas Cédula / Cuenta bancaria / Contrato se renderizan mediante `_buildDocRow`; los slots faltantes se rellenan con `_buildEmptyColumn()` (invisibles) para mantener uniformidad.

Llamadas:
```
_buildDocumentCard(label: 'Cédula',          url: columnUsuariosRow?.cedula,         downloadPrefix: 'cedula',          proveedorId: widget.proveedorId)
_buildDocumentCard(label: 'Cuenta bancaria', url: columnUsuariosRow?.cuentaBancaria, downloadPrefix: 'cuenta_bancaria',  proveedorId: widget.proveedorId)
_buildDocumentCard(label: 'Contrato',        url: columnUsuariosRow?.contrato,        downloadPrefix: 'contrato',         proveedorId: widget.proveedorId)
```

**Móvil (< 600px):** `Column` de tarjetas a ancho completo, separadas por `SizedBox(height: 12)`:
```dart
Column(
  children: [
    if (cedula != null && cedula.isNotEmpty)   _buildDocumentCard(context, label: 'Cédula', ...),
    if (cuenta != null && cuenta.isNotEmpty)   _buildDocumentCard(context, label: 'Cuenta bancaria', ...),
    if (contrato != null && contrato.isNotEmpty)_buildDocumentCard(context, label: 'Contrato', ...),
  ].separatedBy(const SizedBox(height: 12)),
)
```

#### 6.1.3 Empty state de Zona A (v1.1.0)

Cuando los **tres** documentos (`cedula`, `cuentaBancaria`, `contrato`) son null/vacíos (`loadedA == 0`), en lugar del grid se muestra:
- Ícono: `Icons.upload_file_outlined`.
- Texto: *"Este proveedor aún no tiene documentos de registro cargados"*.
- Subtexto: *"Los documentos de cédula, cuenta bancaria y contrato aparecerán aquí una vez que el proveedor los cargue."*

```dart
if (loadedA == 0) {
  // mostrar empty state
} else {
  // mostrar LayoutBuilder con grid (desktop) / Column (móvil)
}
```

### 6.2 Zona B — Ampliación de la sección Certificaciones existente

**Posición:** Dentro del `List.generate` de la línea 2309, reemplazar el `Container` con el placeholder gris (~líneas 2481–2540) por `_buildDocumentCard(...)`.

```
_buildDocumentCard(
  label: certItem.entidadCertificadora,
  url: certItem.documentoUrl,
  downloadPrefix: 'certificacion',
  proveedorId: certItem.id,
  uploadDate: certItem.createdAt,   // v1.1.0
)
```

**Layout de certificaciones (desktop):** filas de 3 usando `_buildDocRow`; la 4ª certificación pasa a la siguiente fila; los slots faltantes son invisibles. Solo se renderizan tarjetas de certificación con `documentoUrl` no vacío.

**Móvil (< 600px):** 1 tarjeta de certificación por fila a ancho completo:
```dart
Column(
  children: validCerts.map((cert) =>
    _buildDocumentCard(context, label: cert.entidadCertificadora, uploadDate: cert.createdAt, ...)
  ).toList().separatedBy(const SizedBox(height: 12)),
)
```

**Estado vacío de Zona B** (cuando no hay certificaciones con `documentoUrl` válido): ícono `workspace_premium_outlined` + mensaje descriptivo (ej. "Sin certificaciones registradas").

### 6.3 Layout de `_buildDocumentCard`

```
┌─────────────────────────────┐
│  Label (centrado, bold)     │
├─────────────────────────────┤
│  ┌─────────────────────┐    │
│  │   THUMBNAIL         │    │  ← 120px alto
│  │   (imagen o ícono)  │    │
│  └─────────────────────┘    │
│  filename.pdf          ✅   │  ← nombre + check verde si URL presente
│  Subido el DD/MM/YYYY       │  ← solo si uploadDate != null (v1.1.0)
│  ─────────────────────────  │
│  [ 👁 Ver documento  ]      │  ← botón ancho completo
│  [ ↓  Descargar      ]      │  ← botón ancho completo
└─────────────────────────────┘
```

**Especificación detallada:**

**Contenedor tarjeta:**
- `decoration`: `color: secondaryBackground`, `borderRadius: 12`, `border: Border.all(color: tertiary)`, `boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0,2))]`
- `padding: EdgeInsets.all(12)`

**Label (encabezado de tarjeta):**
- `Text(label)`, `fontSize: 14`, `fontWeight: w600`, `color: primary`, `textAlign: center`
- `padding bottom: 8`

**Thumbnail (zona de 120px de alto):**
- `ClipRRect(borderRadius: 8)` que contiene:
  - Si `url == null || url.isEmpty`: `Container(color: Color(0xFFEAEAEA), child: Icon(Icons.insert_drive_file_outlined, size: 40, color: secondaryText))`
  - Si la URL es imagen (`_isImageUrl`): `Image.network(url, fit: BoxFit.cover, height: 120, width: double.infinity, errorBuilder: → ícono genérico)`
  - En cualquier otro caso (PDF u otro): `Container(color: Color(0xFFEAEAEA), child: Icon(Icons.picture_as_pdf_outlined, size: 40, color: Color(0xFFD32F2F)))`

**Fila de nombre de archivo:**
- `Row(MainAxisAlignment.spaceBetween)`
  - `Expanded(child: Text(_extractFilename(url), overflow: ellipsis, fontSize: 12, color: secondaryText))`
  - Si URL presente: `Icon(Icons.check_circle, size: 16, color: Color(0xFF43A047))`
  - Si URL ausente: badge `'No cargado'`

**Fecha de subida (v1.1.0):** si `uploadDate != null`, `Text('Subido el ' + DateFormat('dd/MM/yyyy').format(uploadDate), fontSize: 11, color: secondaryText)`.

**Botones (solo si URL presente):**
- `OutlinedButton.icon` "Ver documento" (`Icons.remove_red_eye_outlined`) → `onView`.
- `OutlinedButton.icon` "Descargar" (`Icons.download_outlined`) → `onDownload`; cuando `isDownloading` muestra `CircularProgressIndicator` y texto "Descargando...", deshabilitado.

**Si URL ausente:** no se renderizan los botones. Solo aparece el thumbnail vacío y el badge "No cargado".

### 6.4 Estados del componente completo

| Estado | Trigger | Render |
|---|---|---|
| **Cargando** | `FutureBuilder` snapshot sin datos | `CircularProgressIndicator` (código existente, sin cambios) |
| **Con documento — imagen** | URL presente + extensión imagen | `Image.network` como thumbnail + botones Ver/Descargar |
| **Con documento — PDF/otro** | URL presente + extensión no imagen | Ícono PDF rojo como thumbnail + botones Ver/Descargar |
| **Sin documento** | URL nula o vacía | Thumbnail con ícono genérico gris + badge "No cargado", sin botones |
| **Descargando** | `isDownloading == true` | Botón "Descargar" → "Descargando..." con spinner, deshabilitado |
| **Zona A vacía** | 3 docs de registro null/vacíos | Empty state §6.1.3 (`upload_file_outlined`) |
| **Sin certificaciones** | Sin certs con `documentoUrl` válido | Ícono `workspace_premium_outlined` + texto |
| **Móvil** | ancho < 600px | 1 tarjeta por fila, ancho completo, ambas zonas |

---

## 7. Restricciones y reglas de negocio

**RN-01 — Solo lectura.**
No se renderizará ningún control de edición, eliminación ni carga de archivos. El widget completo ya es usado en modo lectura por el administrador; esta sección hereda esa restricción.

**RN-02 — Acceso restringido al rol administrador.**
El widget `InformacionProveedorWidget` solo es accesible desde la pantalla de administración. No se agrega guard adicional dentro del widget; la restricción se gestiona en la capa de navegación existente (fuera del alcance de este REQ).

**RN-03 — URLs son opacas.**
El código no valida el formato de la URL más allá de verificar que no sea nula ni vacía (`url != null && url.isNotEmpty`). No se valida extensión, dominio ni protocolo.

**RN-04 — `filename` para descarga.**
El nombre del archivo descargado se construye como `{tipo}_{proveedorId}.{ext}` donde `{ext}` se infiere del `Content-Type` del response HTTP. Si no se puede inferir, se usa la extensión `bin`. Para certificaciones: `certificacion_{id}.{ext}`.

**RN-05 — Un download a la vez por documento.**
Cada tarjeta maneja su propio flag `isDownloading` de forma independiente. No se bloquea la interacción con otras tarjetas.

**RN-06 — Timeout de descarga.**
Máximo 30 segundos para el `http.get`. Si se excede, se captura `TimeoutException` y se muestra `SnackBar` con `'La descarga tardó demasiado. Intente nuevamente.'`.

**RN-07 — Sin caché.**
No se almacenan localmente las URLs ni los bytes descargados entre sesiones. Cada acción inicia una solicitud fresca.

---

## 8. Criterios de aceptación verificables

| ID | Afirmación | Mapeado a |
|---|---|---|
| CA-01 | Dado un proveedor con `cedula` no nula, el panel muestra una tarjeta "Cédula" con botones "Ver" y "Descargar" visibles y habilitados. | PA-01 (visualización) |
| CA-02 | Dado un proveedor con `cuentaBancaria` nula, la tarjeta "Cuenta bancaria" muestra el badge "No cargado" y **no** muestra botones de acción. | PA-03 (estado vacío) |
| CA-03 | Dado un proveedor con `contrato` no nulo, pulsar "Ver" invoca `launchUrl` con la URL exacta del contrato en modo `externalApplication`. | PA-01 (previsualización) |
| CA-04 | Dado un proveedor con `cedula` no nula, pulsar "Descargar" inicia un GET HTTP a esa URL; mientras el request está en vuelo el botón "Descargar" muestra un `CircularProgressIndicator`. | PA-02 (descarga + feedback) |
| CA-05 | Si el GET de descarga retorna código ≠ 200, se muestra un `SnackBar` con mensaje de error y el botón "Descargar" vuelve a su estado normal. | PA-02 (manejo de error) |
| CA-06 | Dado un proveedor con al menos una certificación, cada ítem muestra `entidadCertificadora` y los botones "Ver" / "Descargar" sobre `documentoUrl`. | PA-01 (certificaciones) |
| CA-07 | Dado un proveedor sin certificaciones, la sección "Certificaciones" muestra el ícono `workspace_premium_outlined` y un texto descriptivo, sin tarjetas. | PA-03 (estado vacío certificaciones) |
| CA-08 | Ninguna tarjeta de documentos expone controles de edición, eliminación o carga de archivos. | PA-04 (solo lectura) |
| CA-09 | El widget se renderiza sin errores cuando los tres campos de registro son simultáneamente nulos (muestra el empty state de Zona A). | PA-03 (estado vacío total) |
| CA-10 | Los imports de `url_launcher`, `file_saver` e `intl` están declarados en el archivo que los usa, y no hay errores de compilación. | PA-05 (integridad técnica) |
| **CA-11** | **[v1.1.0]** Header "Documentos" con ícono `Icons.description_outlined`. En desktop, Zona A usa 3 `Expanded` y los slots vacíos son `Expanded(SizedBox())` invisibles. | PA-01 |
| **CA-12** | **[v1.1.0]** Zona B se organiza en filas de 3 (`_buildDocRow`); la 4ª certificación va a la siguiente fila; solo se renderizan certs con `documentoUrl` no vacío. | PA-02 |
| **CA-13** | **[v1.1.0]** `_buildDocumentCard` acepta `uploadDate: DateTime?` y muestra "Subido el DD/MM/YYYY"; Zona B pasa `cert.createdAt`. `certificaciones.dart` expone `DateTime? get createdAt` mapeado a `created_at`. | PA-02 |
| **CA-14** | **[v1.1.0]** Zona A muestra empty state (`Icons.upload_file_outlined` + texto/subtexto §6.1.3) cuando los 3 docs son null/vacíos. | PA-04 |
| **CA-15** | **[v1.1.0]** `LayoutBuilder`: ancho < 600px → 1 columna ancho completo en ambas zonas; ancho ≥ 600px → grid de 3 columnas. El diseño desktop previo no se modifica. | PA-01 |

---

## 9. Riesgos y supuestos

### Supuestos

**S-01.** Las URLs en `cedula`, `cuentaBancaria` y `contrato` son URLs públicas de Supabase Storage (no requieren header de autenticación). Si son URLs privadas/signed, `http.get` recibirá 401 y el flujo de error de CA-05 se activará correctamente, pero la funcionalidad no será usable hasta que se use el cliente autenticado de Supabase.

**S-02.** El widget corre en un entorno web (Flutter Web) dado que es un panel administrativo exportado de FlutterFlow. `file_saver` en web activa la descarga del navegador nativamente; en desktop/mobile usa la API del sistema de archivos.

**S-03.** `url_launcher` en Flutter Web abre la URL en una nueva pestaña del mismo navegador. En desktop, abre el visor nativo del OS. En mobile, abre el browser o el app asociado.

**S-04.** El modelo ya importa los paquetes necesarios o los imports se agregarán en el mismo archivo donde se definen los helpers.

**S-05.** `widget.proveedorId` nunca es nulo en el contexto en que se muestra el widget (es parámetro `required` y está validado por quien lo invoca).

**S-06.** *(v1.1.0)* La migración SQL que agrega `created_at` a `certificaciones` ya fue aplicada en producción y sandbox; los registros previos sin fecha devuelven `null` y la tarjeta omite la línea "Subido el...".

### Riesgos

**R-01 — CORS en Flutter Web.** Si Supabase Storage no tiene configurada la política CORS para el dominio del panel, `http.get` fallará en web con un error de CORS. **Mitigación:** verificar la configuración CORS del bucket antes de la prueba; si hay CORS, usar `launchUrl` para ver y notificar que la descarga directa no está disponible en web.

**R-02 — Archivos grandes.** PDFs pesados pueden causar timeout de 30 s o consumir memoria al cargar `response.bodyBytes` completo. **Mitigación aceptada:** fuera de scope una solución de streaming.

**R-03 — `_isDownloading` con múltiples re-renders.** El `FutureBuilder` puede reconstruirse y resetear el estado local. **Mitigación:** mover `_isDownloading` al `InformacionProveedorModel` (que sobrevive re-renders).

**R-04 — Nombre de archivo sin extensión.** Si `Content-Type` está ausente o es genérico, el archivo se descargará como `{tipo}_{id}.bin`. **Mitigación aceptada.**

---

## 10. Out of scope

- **Edición / reemplazo / eliminación de documentos:** no se habilita ningún control de escritura sobre documentos.
- **Previsualización embebida (inline):** la previsualización ocurre en pestaña/app externa, no en un visor dentro del panel.
- **Validación de contenido del documento:** no se verifica el formato real del archivo.
- **Notificaciones al proveedor / auditoría de acceso:** ninguna acción del administrador dispara comunicación ni se registra en BD.
- **Descarga masiva / ZIP, paginación o filtrado de certificaciones.**
- **Soporte offline:** todas las acciones requieren conexión activa.
- **Migración de pop-up a página `DetalleProveedor`:** trasladada a [REQ-005](REQ-005_spec.md).

---

## 11. Pruebas de aceptación (requerimiento original)

> Conservadas del requerimiento funcional. CA-01..CA-15 se mapean a estas PA.

- **PA-01 — Visualización de documentos de registro:** proveedor con cédula, cuenta bancaria y contrato; el administrador abre cada documento y se visualiza correctamente.
- **PA-02 — Visualización de certificaciones:** proveedor con ≥1 certificación; cada certificación se visualiza correctamente.
- **PA-03 — Descarga de documentos:** el documento se descarga íntegro y abre correctamente fuera de la aplicación. Incluye estados vacíos.
- **PA-04 — Proveedor sin documentos:** el sistema indica de forma clara la ausencia de documentos, sin errores.
- **PA-05 — Restricción de acceso por rol:** un usuario no administrador no accede a los documentos del proveedor.

> **Documentación de proceso:** la guía de metodología SDD usada para este requerimiento está en [REQ-002_guia-sdd.md](REQ-002_guia-sdd.md).
