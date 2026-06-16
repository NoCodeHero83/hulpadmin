# Especificación Técnica — REQ-002
**Título:** Visualización y descarga de documentos de proveedores desde el panel administrativo  
**Fecha:** 2026-06-08  
**Estado:** Implementado · Ampliado en v2.0.0  
**Metodología:** Spec Driven Development (SDD)

---

## Control de versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0.0 | 2026-06-08 | Equipo Hulp | Versión inicial: Zona A (documentos de registro) y Zona B (certificaciones) dentro del componente `InformacionProveedorWidget` (pop-up). |
| **v2.0.0** | **2026-06-16** | **Equipo Hulp** | **Migración del pop-up `InformacionProveedorWidget` (invocado vía `showDialog` desde la pantalla `Proveedores2`) a una PÁGINA DEDICADA `DetalleProveedorWidget` con el rediseño visual de referencia (encabezado de perfil, panel de documentos + certificaciones, panel de referencias con acciones Ver/Llamar, datos básicos, facturación, servicios ofrecidos y línea de tiempo de historial de servicios). Ver §11 (Adenda v2.0.0). La lógica de negocio, las consultas existentes y el rendimiento se preservan; el contrato de solo lectura (RN-01) se mantiene.** |

> **Razón del cambio (v2.0.0):** el pop-up resultaba estrecho (máx. 800px) y desbordaba en pantallas reales (overflow visible en el listado de categorías). Convertirlo en página permite el layout de paneles de la imagen de referencia, mejor legibilidad y navegación con breadcrumb, sin tocar la lógica de datos ya validada en v1.0.0.

---

## 1. Resumen del cambio

Se agregan dos zonas de solo lectura al widget `InformacionProveedorWidget`:

**Zona A — Documentos de Registro** (nueva sección).  
Muestra tres documentos vinculados al proveedor en la tabla `usuarios`: cédula, cuenta bancaria y contrato. Cada documento se presenta con su nombre descriptivo y dos acciones: "Ver" (abre la URL en el navegador/visor nativo) y "Descargar" (descarga el archivo localmente). Si una URL está vacía/nula se muestra un indicador de estado "No cargado".

**Zona B — Certificaciones** (sección existente, ampliada).  
La sección "Certificaciones" ya existe y ya consulta `CertificacionesTable`. Actualmente muestra el nombre de la entidad y un placeholder gris estático con el texto "Archivo". Se reemplaza ese placeholder por dos botones funcionales: "Ver" y "Descargar", operando sobre `documentoUrl`.

Ambas zonas son de **solo lectura**. No se agregan controles de edición, eliminación ni subida de archivos. El acceso está restringido al rol `administrador`.

**Punto de inserción en el widget:**  
- Zona A: justo antes de la sección "Certificaciones" (línea ~2242), dentro del `Column` principal del `FutureBuilder` de `UsuariosTable`.  
- Zona B: reemplaza el bloque `Container` con el placeholder gris (líneas ~2481–2540) dentro del `List.generate` de certificaciones.

---

## 2. Análisis de impacto

| Archivo | Acción | Justificación |
|---|---|---|
| `lib/components/informacion_proveedor_widget.dart` | **Modificar** | Es el único archivo de UI del componente. Aquí se inserta Zona A y se amplía Zona B. |
| `lib/components/informacion_proveedor_model.dart` | **Modificar** | Agregar estado de carga (`_isDownloading`) y el método `downloadDocument()`. |
| `lib/backend/supabase/database/tables/usuarios.dart` | Solo lectura | Ya expone `cedula`, `cuentaBancaria`, `contrato` como `String?`. Sin cambios. |
| `lib/backend/supabase/database/tables/certificaciones.dart` | Solo lectura | Ya expone `documentoUrl` y `entidadCertificadora`. Sin cambios. |
| `pubspec.yaml` | Sin cambios | `url_launcher: 6.3.1`, `file_saver: 0.2.14` y `http: 1.4.0` ya están declarados. |

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
- **Retorno:** `Widget` con el layout de tarjeta descrito en §6.3.

### 4.4 `_extractFilename` y `_isImageUrl` (helpers de utilidad — funciones privadas)

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
| C-05 | Certificación sin documentos | `containerCertificacionesRowList.isEmpty` | Se muestra el estado vacío de Zona B: ícono `Icons.folder_open` + texto `'Sin certificaciones registradas'` | N/A |
| C-06 | Todos los docs de registro ausentes | Los tres campos `cedula`, `cuentaBancaria`, `contrato` son null | Zona A muestra las tres filas con estado "No cargado" cada una | N/A |
| C-07 | Error de red al cargar datos del widget | `FutureBuilder` snapshot tiene `connectionState.done` y `!snapshot.hasData` | El widget ya maneja esto con `CircularProgressIndicator` (código existente, sin cambios) | N/A |

---

## 6. Especificación de UI

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

#### 6.1.2 Grid de tarjetas

Layout: `Wrap` con `spacing: 12`, `runSpacing: 12`, width máximo heredado del contenedor padre (800px). Cada tarjeta ocupa `~(anchoDisponible - 24) / 3` de ancho mínimo; si el ancho < 500px colapsa a 1 columna.  
Se renderizan siempre las 3 tarjetas (Cédula, Cuenta bancaria, Contrato), independientemente de si tienen URL o no.

Llamadas:
```
_buildDocumentCard(label: 'Cédula',          url: columnUsuariosRow?.cedula,         downloadPrefix: 'cedula',          proveedorId: widget.proveedorId)
_buildDocumentCard(label: 'Cuenta bancaria', url: columnUsuariosRow?.cuentaBancaria, downloadPrefix: 'cuenta_bancaria',  proveedorId: widget.proveedorId)
_buildDocumentCard(label: 'Contrato',        url: columnUsuariosRow?.contrato,        downloadPrefix: 'contrato',         proveedorId: widget.proveedorId)
```

### 6.2 Zona B — Ampliación de la sección Certificaciones existente

**Posición:** Dentro del `List.generate` de la línea 2309, reemplazar el `Container` con el placeholder gris (~líneas 2481–2540) por `_buildDocumentCard(...)`.

```
_buildDocumentCard(
  label: certItem.entidadCertificadora,
  url: certItem.documentoUrl,
  downloadPrefix: 'certificacion',
  proveedorId: certItem.id,
)
```

Layout de certificaciones: `Wrap` con `spacing: 12`, `runSpacing: 12`. Cada tarjeta tiene el mismo diseño que Zona A.

**Estado vacío de Zona B** (cuando `containerCertificacionesRowList.isEmpty`):  
Insertar **antes** del `List.generate`:
```dart
if (cuentasBancarias.isEmpty)
  return Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(children: [
        Icon(Icons.folder_open_outlined, size: 40, color: secondaryText),
        SizedBox(height: 8),
        Text('Sin certificaciones registradas', style: bodyMedium),
      ]),
    ),
  );
```

### 6.3 Layout de `_buildDocumentCard` ← reemplaza `_buildDocumentRow`

> **Nota:** El helper se renombra a `_buildDocumentCard` para reflejar el diseño en tarjeta. La firma se actualiza en §4.3.

```
┌─────────────────────────────┐
│  Label (centrado, bold)     │
├─────────────────────────────┤
│  ┌─────────────────────┐    │
│  │   THUMBNAIL         │    │  ← 120px alto
│  │   (imagen o ícono)  │    │
│  └─────────────────────┘    │
│  filename.pdf          ✅   │  ← nombre + check verde si URL presente
│  ─────────────────────────  │
│  [ 👁 Ver documento  ]      │  ← botón ancho completo
│  [ ↓  Descargar      ]      │  ← botón ancho completo
└─────────────────────────────┘
```

**Especificación detallada:**

**Contenedor tarjeta:**
- `width`: calculado por `Wrap` (~30% del ancho disponible, mín. 160px)
- `decoration`: `color: secondaryBackground`, `borderRadius: 12`, `border: Border.all(color: tertiary)`, `boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0,2))]`
- `padding: EdgeInsets.all(12)`

**Label (encabezado de tarjeta):**
- `Text(label)`, `fontSize: 14`, `fontWeight: w600`, `color: primary`, `textAlign: center`
- `padding bottom: 8`

**Thumbnail (zona de 120px de alto):**
- `ClipRRect(borderRadius: 8)` que contiene:
  - Si `url == null || url.isEmpty`: `Container(color: Color(0xFFEAEAEA), child: Icon(Icons.insert_drive_file_outlined, size: 40, color: secondaryText))`
  - Si la URL termina en `.jpg`, `.jpeg`, `.png`, `.webp` (case-insensitive): `Image.network(url, fit: BoxFit.cover, height: 120, width: double.infinity, errorBuilder: → ícono genérico)`
  - En cualquier otro caso (PDF u otro): `Container(color: Color(0xFFEAEAEA), child: Icon(Icons.picture_as_pdf_outlined, size: 40, color: Color(0xFFD32F2F)))`
- La detección se hace con `_isImageUrl(String url) → bool` (helper privado, ver §4).

**Fila de nombre de archivo:**
- `Row(MainAxisAlignment.spaceBetween)`
  - `Expanded(child: Text(_extractFilename(url), overflow: ellipsis, fontSize: 12, color: secondaryText))`
  - Si URL presente: `Icon(Icons.check_circle, size: 16, color: Color(0xFF43A047))`
  - Si URL ausente: `Container(padding: h:6 v:2, color: Color(0xFFE0E0E0), borderRadius:4, child: Text('No cargado', fontSize:11, color: secondaryText))`
- `padding top: 8, bottom: 8`

**Botones (solo si URL presente):**
- `SizedBox(width: double.infinity, child: OutlinedButton.icon(icon: Icon(Icons.remove_red_eye_outlined, size:16), label: Text('Ver documento'), onPressed: onView))`
  - `style`: `side: BorderSide(color: primary)`, `foregroundColor: primary`, `borderRadius: 8`, height 36
- `SizedBox(height: 6)`
- `SizedBox(width: double.infinity, child: OutlinedButton.icon(...))`
  - Cuando `!isDownloading`: `icon: Icon(Icons.download_outlined, size:16)`, `label: Text('Descargar')`, `onPressed: onDownload`
  - Cuando `isDownloading`: `icon: SizedBox(16×16, CircularProgressIndicator(strokeWidth:2))`, `label: Text('Descargando...')`, `onPressed: null`
  - `style`: mismo que "Ver documento"

**Si URL ausente:** no se renderizan los botones. Solo aparece el thumbnail vacío y el badge "No cargado".

### 6.4 Helpers de UI adicionales (actualización §4)

```dart
// Extrae el nombre de archivo del último segmento del path de la URL
// Ej: "https://xyz.supabase.co/storage/v1/.../cedula/andres_ce.pdf" → "andres_ce.pdf"
// Si url es null/vacío → "Sin archivo"
String _extractFilename(String? url)

// Retorna true si la URL apunta a un formato de imagen renderizable
bool _isImageUrl(String url)
```

`_extractFilename`: `uri.pathSegments.last` del `Uri.parse(url)`; si lanza excepción, retorna `'Sin archivo'`.  
`_isImageUrl`: `['.jpg','.jpeg','.png','.webp'].contains(url.toLowerCase().split('?').first.split('.').last)`.

### 6.5 Estados del componente completo

| Estado | Trigger | Render |
|---|---|---|
| **Cargando** | `FutureBuilder` snapshot sin datos | `CircularProgressIndicator` (código existente, sin cambios) |
| **Con documento — imagen** | URL presente + extensión imagen | `Image.network` como thumbnail + botones Ver/Descargar |
| **Con documento — PDF/otro** | URL presente + extensión no imagen | Ícono PDF rojo como thumbnail + botones Ver/Descargar |
| **Sin documento** | URL nula o vacía | Thumbnail con ícono genérico gris + badge "No cargado", sin botones |
| **Descargando** | `isDownloading == true` | Botón "Descargar" → "Descargando..." con spinner, deshabilitado |
| **Sin certificaciones** | Lista vacía | Ícono folder_open + texto "Sin certificaciones registradas" |

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
Cada fila maneja su propio flag `isDownloading` de forma independiente. No se bloquea la interacción con otras filas.

**RN-06 — Timeout de descarga.**  
Máximo 30 segundos para el `http.get`. Si se excede, se captura `TimeoutException` y se muestra `SnackBar` con `'La descarga tardó demasiado. Intente nuevamente.'`.

**RN-07 — Sin caché.**  
No se almacenan localmente las URLs ni los bytes descargados entre sesiones. Cada acción inicia una solicitud fresca.

---

## 8. Criterios de aceptación verificables

Los siguientes criterios se validan manualmente o con pruebas de widget. Cada uno es una afirmación binaria (true/false).

| ID | Afirmación | Mapeado a |
|---|---|---|
| CA-01 | Dado un proveedor con `cedula` no nula, el panel muestra una fila "Cédula" con botones "Ver" y "Descargar" visibles y habilitados. | PA-01 (visualización) |
| CA-02 | Dado un proveedor con `cuentaBancaria` nula, la fila "Cuenta bancaria" muestra el badge "No cargado" y **no** muestra botones de acción. | PA-03 (estado vacío) |
| CA-03 | Dado un proveedor con `contrato` no nulo, pulsar "Ver" invoca `launchUrl` con la URL exacta del contrato en modo `externalApplication`. | PA-01 (previsualización) |
| CA-04 | Dado un proveedor con `cedula` no nula, pulsar "Descargar" inicia un GET HTTP a esa URL; mientras el request está en vuelo el botón "Descargar" muestra un `CircularProgressIndicator`. | PA-02 (descarga + feedback) |
| CA-05 | Si el GET de descarga retorna código ≠ 200, se muestra un `SnackBar` con mensaje de error y el botón "Descargar" vuelve a su estado normal. | PA-02 (manejo de error) |
| CA-06 | Dado un proveedor con al menos una certificación, cada ítem de certificación muestra `entidadCertificadora` como texto y los botones "Ver" / "Descargar" sobre `documentoUrl`. | PA-01 (certificaciones) |
| CA-07 | Dado un proveedor sin certificaciones, la sección "Certificaciones" muestra el ícono `folder_open` y el texto "Sin certificaciones registradas", sin filas de items. | PA-03 (estado vacío certificaciones) |
| CA-08 | Ninguna fila de documentos expone controles de edición, eliminación o carga de archivos. | PA-04 (solo lectura) |
| CA-09 | El widget se renderiza sin errores cuando los tres campos de registro (`cedula`, `cuentaBancaria`, `contrato`) son simultáneamente nulos. | PA-03 (estado vacío total) |
| CA-10 | Los imports de `url_launcher` y `file_saver` están declarados en el archivo que los usa, y no hay errores de compilación. | PA-05 (integridad técnica) |

---

## 9. Riesgos y supuestos

### Supuestos

**S-01.** Las URLs en `cedula`, `cuentaBancaria` y `contrato` son URLs públicas de Supabase Storage (no requieren header de autenticación). Si son URLs privadas/signed, `http.get` recibirá 401 y el flujo de error de CA-05 se activará correctamente, pero la funcionalidad no será usable hasta que se use el cliente autenticado de Supabase.

**S-02.** El widget corre en un entorno web (Flutter Web) dado que es un panel administrativo exportado de FlutterFlow. `file_saver` en web activa la descarga del navegador nativamente; en desktop/mobile usa la API del sistema de archivos.

**S-03.** `url_launcher` en Flutter Web abre la URL en una nueva pestaña del mismo navegador. En desktop, abre el visor nativo del OS. En mobile, abre el browser o el app asociado. Este comportamiento es correcto para todos los targets de despliegue del panel.

**S-04.** El modelo ya importa los paquetes necesarios o los imports se agregarán en el mismo archivo donde se definen los helpers.

**S-05.** `widget.proveedorId` nunca es nulo en el contexto en que se muestra el widget (es parámetro `required` y está validado por quien lo invoca).

### Riesgos

**R-01 — CORS en Flutter Web.** Si Supabase Storage no tiene configurada la política CORS para el dominio del panel, `http.get` fallará en web con un error de CORS. **Mitigación:** verificar la configuración CORS del bucket en Supabase antes de la prueba. Si hay CORS, usar `launchUrl` para ver y notificar al usuario que la descarga directa no está disponible en web.

**R-02 — Archivos grandes.** PDFs pesados pueden causar timeout de 30 s o consumir memoria excesiva al cargar `response.bodyBytes` completo en memoria. **Mitigación aceptada:** para el alcance de este requerimiento se acepta el riesgo; una solución de streaming está fuera del scope.

**R-03 — `_isDownloading` con múltiples re-renders.** El `FutureBuilder` puede reconstruirse si el padre lo fuerza, reseteando el estado local. **Mitigación:** mover `_isDownloading` al `InformacionProveedorModel` (que sobrevive re-renders) y no al `State` del `StatefulWidget`.

**R-04 — Nombre de archivo sin extensión.** Si el header `Content-Type` está ausente o es genérico (`application/octet-stream`), el archivo se descargará sin extensión reconocible. **Mitigación aceptada:** se informa al usuario con el nombre `{tipo}_{id}.bin`.

---

## 10. Out of scope

Los siguientes puntos están **explícitamente excluidos** de este requerimiento:

- **Edición de URLs de documentos:** no se habilita ningún campo de texto ni botón de carga/reemplazo de documentos.
- **Eliminación de documentos:** no se agrega botón de borrado en ninguna sección.
- **Previsualización embebida (inline):** no se renderiza un `<iframe>` ni un visor PDF dentro del panel. La previsualización ocurre en una pestaña/app externa.
- **Validación de contenido del documento:** no se verifica que la URL apunte a un PDF, imagen u otro formato esperado.
- **Notificaciones o alertas al proveedor:** ninguna acción del administrador en esta sección dispara comunicación al proveedor.
- **Descarga masiva / ZIP:** no se implementa descarga de todos los documentos en un solo archivo.
- **Paginación o filtrado de certificaciones:** la lista se muestra completa sin paginación.
- **Auditoría de acceso:** no se registra en base de datos que el administrador vio o descargó un documento.
- **Control de acceso dentro del widget:** la verificación de rol `administrador` es responsabilidad de la capa de navegación, no de este widget.
- **Soporte offline:** todas las acciones requieren conexión activa.

---

# 11. Adenda v2.0.0 — Migración de pop-up a página dedicada `DetalleProveedor`

## 11.1 Resumen del cambio

Se reemplaza la apertura del pop-up `InformacionProveedorWidget` (vía `showDialog`) al pulsar el **nombre del proveedor** en la pantalla `Proveedores2`, por la navegación a una **página dedicada** `DetalleProveedorWidget`. La página reproduce con fidelidad el diseño de referencia (mockup tipo "perfil de proveedor"): encabezado con foto, estado, servicios principales, fecha de inscripción e ID; panel de documentos y certificaciones; panel de referencias con acciones; bloques de datos básicos, facturación y servicios ofrecidos; y una línea de tiempo de historial de servicios.

**Principios no negociables (heredados del proyecto):**
- **Cero cambios en lógica de negocio.** Se reutilizan exactamente las mismas consultas y helpers ya validados (`UsuariosTable`, `CuentasBancariasTable`, `CertificacionesTable`, `ReferenciasLaboralesTable`, `ProfesionalServiciosTable`, y los métodos `openDocument` / `downloadDocument`).
- **Solo lectura (RN-01).** No se agregan controles de edición, creación ni borrado. No se incluye el botón "Agregar referencia" del mockup por requerir lógica de creación inexistente (ver §11.9).
- **Rendimiento preservado.** Misma estrategia de `FutureBuilder` perezoso; no se introducen `Stream` nuevos. Las dos consultas adicionales (chips de servicios y línea de tiempo) solo se ejecutan al abrir la página de detalle, nunca en el listado.
- **Patrón FlutterFlow.** Página con par `*_widget.dart` / `*_model.dart`, `routeName`/`routePath` estáticos, registro en `nav.dart` y export en `index.dart`. El menú lateral se reutiliza con `MenuWidget`.

## 11.2 Análisis de impacto

| Archivo | Acción | Justificación |
|---|---|---|
| `lib/web/detalle_proveedor/detalle_proveedor_widget.dart` | **Crear** | Nueva página. UI del rediseño. |
| `lib/web/detalle_proveedor/detalle_proveedor_model.dart` | **Crear** | Modelo de la página: `menuModel`, `downloadingDocs`, `openDocument`, `downloadDocument`, `llamarTelefono`. |
| `lib/flutter_flow/nav/nav.dart` | **Modificar** | Registrar `FFRoute` de `DetalleProveedorWidget` con parámetros `proveedorId`, `categoriaid`, `categorianombre`. |
| `lib/index.dart` | **Modificar** | `export` de la nueva página. |
| `lib/web/proveedores2/proveedores2_widget.dart` | **Modificar** | Cambiar el `onTap` del nombre del proveedor de `showDialog(InformacionProveedorWidget)` a `context.pushNamed(DetalleProveedorWidget.routeName, ...)`. Eliminar el import no usado si corresponde. |
| `lib/components/informacion_proveedor_widget.dart` | **Sin cambios** | Se conserva intacto como referencia de la lógica de v1.0.0. No se elimina. |

**Archivos que NO se tocan:** auth, otras pantallas, esquema de base de datos, `pubspec.yaml` (todas las dependencias necesarias —`url_launcher`, `http`, `file_saver`, `google_fonts`— ya están declaradas).

## 11.3 Ruta y navegación

- **`routeName`:** `'DetalleProveedor'` · **`routePath`:** `'/detalleProveedor'`.
- **Parámetros (query):**
  - `proveedorId` (`String`, requerido) — `profesional_id` / `usuarios.id`.
  - `categoriaid` (`String`, opcional) — para el botón "Volver al listado" y breadcrumb.
  - `categorianombre` (`String`, opcional) — para el breadcrumb.
- **Entrada:** desde `Proveedores2`, `onTap` del nombre →
  ```
  context.pushNamed(
    DetalleProveedorWidget.routeName,
    queryParameters: {
      'proveedorId': serializeParam(itemsItem.profesionalId, ParamType.String),
      'categoriaid': serializeParam(widget!.categoriaid, ParamType.String),
      'categorianombre': serializeParam(widget!.categorianombre, ParamType.String),
    }.withoutNulls,
    extra: <String, dynamic>{ '__transition_info__': TransitionInfo(hasTransition: true, transitionType: PageTransitionType.fade, duration: Duration(milliseconds: 0)) },
  );
  ```
- **Salida ("← Volver al listado" y breadcrumb "Proveedores"):** `context.safePop()` cuando hay pila navegable; si no, `context.pushNamed(Proveedores2Widget.routeName, ...)` con `categoriaid`/`categorianombre`.

## 11.4 Fuentes de datos (todas ya existentes — solo lectura)

| Sección | Origen | Consulta |
|---|---|---|
| Encabezado, Datos básicos, Documentos de registro, RUT | `UsuariosTable` | `querySingleRow(id == proveedorId)` |
| Facturación (entidad, tipo, número de cuenta) | `CuentasBancariasTable` | `querySingleRow(usuario_id == proveedorId)` |
| Certificaciones | `CertificacionesTable` | `queryRows(usuario_id == proveedorId)` |
| Referencias | `ReferenciasLaboralesTable` | `queryRows(usuario_id == proveedorId)` |
| Servicios ofrecidos (seleccionados/no) | `ProfesionalServiciosTable` + `custom_widgets.CrearProveedor` | `queryRows(usuario_id == proveedorId)` (idéntico a v1.0.0) |
| **Servicios principales (chips header)** — NUEVO | `VwProfesionalesServiciosTable` | `queryRows(profesional_id == proveedorId)` → distintos `servicioNombre` |
| **Historial de servicios (timeline)** — NUEVO | `VwSolicitudesServiciosCompletaTable` | `queryRows(profesional_id == proveedorId)` |

## 11.5 ID de proveedor (derivado, solo presentación)

Como `usuarios` no tiene un código formateado, el "ID de proveedor" se **deriva en UI** (no se persiste):

```
PROV-{año}-{idUsuario con padding a 4 dígitos}
  año     = fechaRegistro?.year ?? año actual
  idUsuario = usuarios.id_usuario (int)
Ej.: fechaRegistro=2025, id_usuario=158  ->  "PROV-2025-0158"
```

Si `id_usuario` es nulo, se muestra `PROV-{año}-----`.

## 11.6 Especificación de UI (fiel al mockup)

Paleta tomada de `FlutterFlowTheme` y de los colores ya usados en el proyecto:
`primary #0B6244` (verde), `success #18AC4C`, `secondaryBackground #FFFFFF`, `primaryBackground #FBF8F4`, breadcrumb `#5E252B`, chip verde fondo `#DFF9D2` / texto `#18AC4C`, badge "Activo" fondo `#DFF9D2` texto `#18AC4C`, badge "Inactivo" fondo `#FFE9CC` texto `#D6A100`, enlaces `#0D70E7`.

**Estructura general:** `Scaffold` → `Row[ MenuWidget , Expanded(SingleChildScrollView) ]`. Ancho de contenido fluido con `padding` de 24–40px. Todas las tarjetas: `secondaryBackground`, `borderRadius 16`, borde `#7C766C` 0.5, sombra suave.

1. **Barra superior:** breadcrumb `Proveedores  ›  {nombre}` (izq., estilo itálico `#5E252B`) y botón `← Volver al listado` (der., contorno gris, `borderRadius 8`).
2. **Tarjeta de encabezado** (3 zonas en `Row` responsivo):
   - Izq.: avatar circular 96–100px (`fotoPerfilUrl`, fallback placeholder), nombre (22px bold `primaryText`), badge de estado (`Activo`/`Inactivo` según `disponibilidad`/`verificado` — ver §11.8), y fila de meta: ubicación (`ciudad, pais`), teléfono, Instagram (`redesSociales[0]` o "Sin Instagram"), Facebook (`redesSociales[1]` o "Sin Facebook"), cada uno con su ícono.
   - Centro: rótulo "Servicios principales" + `Wrap` de chips verdes (ícono check + `servicioNombre`), máximo 4 visibles y chip "+N" si hay más.
   - Der.: "Inscripción recibida" + `fechaRegistro` (`dd MMM, yyyy`, locale es) y "ID de proveedor" + valor derivado (§11.5, en `primary` bold).
3. **Fila media** (`Row`, en móvil `Column`):
   - **Documentos** (flex 2): título "Documentos" + badge "X/5 cargados" (cuenta de URLs no vacías entre cédula, cuenta bancaria, contrato y certificaciones con `documentoUrl`). Subsección "Documentos de registro": tarjetas Cédula / Cuenta bancaria / Contrato usando el helper `_buildDocumentCard` (idéntico a v1.0.0: thumbnail, nombre, check, "Ver documento", "Descargar", estado descargando). Subsección "Certificaciones": tarjetas por cada certificación con `documentoUrl` válido; estado vacío con ícono `workspace_premium_outlined` y texto.
   - **Referencias** (flex 1): título "Referencias". Por cada `ReferenciasLaboralesRow`: avatar con iniciales, `nombreReferencia` (bold), `telefonoReferencia` (en `primary`), `relacionLaboral` (gris), y botones **"Ver"** (ícono ojo) y **"Llamar"** (ícono teléfono). Estado vacío: "Sin referencias registradas".
4. **Fila inferior** (`Row` de 3 columnas, responsivo a `Column`):
   - **Datos básicos:** tipo de documento, número de documento, instagram, facebook, dirección, país — como texto de solo lectura (label gris + valor bold), sin `TextFormField` ni dropdowns.
   - **Facturación:** entidad, tipo de cuenta, número de cuenta (de `CuentasBancarias`), RUT (`registroTributario`) — texto de solo lectura.
   - **Servicios ofrecidos:** se reutiliza `custom_widgets.CrearProveedor` con `serviciosid` = lista de `servicioId` de `ProfesionalServicios` y `action: (_) async {}` (idéntico a v1.0.0; conserva la vista seleccionados/no seleccionados).
5. **Historial de servicios** (timeline): título + `SingleChildScrollView` horizontal con nodos conectados por líneas. Cada nodo: ícono circular verde, etiqueta de estado (mapeo §11.8), `servicioNombre`, `Cliente: {clienteNombreCompleto}` y `fecha`+`hora`. Si la lista está vacía: "Sin historial de servicios".

## 11.7 Acciones de la página

| Acción | Implementación | Notas |
|---|---|---|
| Ver documento | `_model.openDocument(url)` (reutilizado) | `launchUrl(externalApplication)` |
| Descargar documento | `_model.downloadDocument(url, fileName)` (reutilizado) | `http.get` + `FileSaver`; flag por documento en `downloadingDocs` |
| **Llamar** (referencia) | `_model.llamarTelefono(tel)` → `launchUrl(Uri(scheme:'tel', path: tel))` | NUEVO helper; solo presentación, no toca BD |
| **Ver** (referencia) | Diálogo de solo lectura con `nombreReferencia`, `telefonoReferencia`, `relacionLaboral` | No hay documento de referencia; solo muestra datos existentes |
| Volver al listado / breadcrumb | `context.safePop()` con fallback a `Proveedores2` | — |

## 11.8 Mapeos de estado (sin cambios de datos)

- **Badge de proveedor:** "Activo" si `disponibilidad == true`; en caso contrario "Inactivo" (colores §11.6). *(Se respeta el dato tal cual; no se calcula nada nuevo.)*
- **Estado en timeline** (`estado_solicitud`): `finalizadas`→"Servicio completado", `aceptadas`→"Servicio activo", `entrantes`→"Pendiente", `canceladas`→"Cancelado", otro→"Reprogramado/En curso". Idéntico al mapeo ya usado en `HistorialServiciosWidget`.

## 11.9 Criterios de aceptación (v2.0.0)

| ID | Afirmación |
|---|---|
| CA2-01 | Al pulsar el nombre de un proveedor en `Proveedores2` se navega a `/detalleProveedor` con `proveedorId` correcto (ya no se abre el pop-up). |
| CA2-02 | El encabezado muestra foto, nombre, badge de estado, ubicación, teléfono, redes, "Inscripción recibida" y "ID de proveedor" derivado `PROV-AAAA-####`. |
| CA2-03 | Los chips de "Servicios principales" muestran hasta 4 `servicioNombre` y "+N" cuando hay más. |
| CA2-04 | El panel de Documentos conserva exactamente el comportamiento de v1.0.0 (Ver/Descargar/estados/empty), incluida la subsección Certificaciones. |
| CA2-05 | El panel de Referencias lista cada referencia con "Ver" y "Llamar"; "Llamar" invoca `launchUrl(tel:)`. |
| CA2-06 | "Datos básicos" y "Facturación" se muestran como texto de solo lectura, sin campos editables. |
| CA2-07 | "Servicios ofrecidos" se renderiza con `CrearProveedor` y los `servicioId` del proveedor (sin cambios de lógica). |
| CA2-08 | La línea de tiempo muestra los servicios del proveedor con estado, cliente y fecha; vacío → mensaje. |
| CA2-09 | "Volver al listado" regresa a `Proveedores2`. |
| CA2-10 | El proyecto compila sin errores; `InformacionProveedorWidget` permanece intacto; no se introducen `Stream` nuevos. |

## 11.10 Riesgos y supuestos (v2.0.0)

- **S2-01.** `disponibilidad` es la fuente del estado Activo/Inactivo (consistente con el listado, que muestra "Inactivo" por defecto). Si el negocio define el estado por otra columna, se ajusta el mapeo en un único punto (§11.8) sin cambios estructurales.
- **S2-02.** `launchUrl(tel:)` abre el marcador en móvil/desktop; en Flutter Web puede no tener handler, en cuyo caso se captura la excepción y se muestra `SnackBar` (mismo patrón que documentos).
- **R2-01.** Dos `FutureBuilder` adicionales (chips + timeline) por apertura de detalle. Mitigación: solo corren en la página de detalle, no en el listado; lectura ligera.
- **R2-02.** El import de `InformacionProveedorWidget` en `Proveedores2` queda sin uso tras el cambio. Mitigación: se elimina dicho import si ningún otro uso permanece, para evitar warnings.

## 11.11 Out of scope (v2.0.0)

- Crear/editar/eliminar referencias ("Agregar referencia" del mockup) — requeriría lógica de escritura inexistente.
- Edición de cualquier dato del proveedor desde la página.
- Cambios en el esquema de base de datos o en vistas de Supabase.
- Eliminación del componente `InformacionProveedorWidget`.
