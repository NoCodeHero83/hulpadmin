# Especificación Técnica — REQ-002
**Título:** Visualización y descarga de documentos de proveedores desde el panel administrativo  
**Fecha:** 2026-06-08  
**Estado:** Borrador — pendiente de implementación  
**Metodología:** Spec Driven Development (SDD)

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

### 4.3 `_buildDocumentRow` (helper de UI — función privada top-level o método del State)

```
Widget _buildDocumentRow(
  BuildContext context, {
  required String label,
  required String? url,
  required String downloadFileName,
  required bool isDownloading,
  required VoidCallback onView,
  required VoidCallback onDownload,
})
```

- **Propósito:** Renderizar una fila de documento reutilizable para Zona A y Zona B.  
- **Parámetros:**  
  - `label` — texto descriptivo del documento (ej. `'Cédula'`).  
  - `url` — URL del documento; si es `null` o vacía se muestra estado "No cargado".  
  - `downloadFileName` — pasado a `downloadDocument`.  
  - `isDownloading` — si `true`, reemplaza el botón "Descargar" por un `CircularProgressIndicator` de 18×18.  
  - `onView` / `onDownload` — callbacks inyectados.  
- **Retorno:** `Widget` con el layout descrito en §6.

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

**Estructura visual:**

```
──────────────────────────────────────────
[Sección encabezado]
  Text: "Documentos de registro"
  Estilo: fontSize 20, fontWeight w600, color primaryText
  Padding top: 24, bottom: 12

[Fila: Cédula]
  _buildDocumentRow(label: 'Cédula', url: columnUsuariosRow?.cedula, ...)

[Fila: Cuenta bancaria]
  _buildDocumentRow(label: 'Cuenta bancaria', url: columnUsuariosRow?.cuentaBancaria, ...)

[Fila: Contrato]
  _buildDocumentRow(label: 'Contrato', url: columnUsuariosRow?.contrato, ...)
──────────────────────────────────────────
```

### 6.2 Zona B — Ampliación de la sección Certificaciones existente

**Posición:** Dentro del `List.generate` de la línea 2309, reemplazar el `Container` con el placeholder gris (~líneas 2481–2540) por `_buildDocumentRow(...)`.

```
_buildDocumentRow(
  label: 'Documento de certificación',
  url: cuentasBancariasItem.documentoUrl,   // var del loop
  downloadFileName: 'certificacion_${cuentasBancariasItem.id}.pdf',
  ...
)
```

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

### 6.3 Layout de `_buildDocumentRow`

```
┌──────────────────────────────────────────────────────┐
│  [Icon: description 20px]  Label          [Ver] [↓]  │
│                            — Si URL nula —            │
│  [Icon: description 20px]  Label   [Badge: No cargado]│
└──────────────────────────────────────────────────────┘
```

Especificación detallada:

- **Contenedor:** `width: double.infinity`, `padding: EdgeInsets.all(12)`, `decoration: BoxDecoration(color: Color(0xFFF0F0EF), borderRadius: 8, border: Border.all(color: tertiary))`.
- **Row principal:** `MainAxisAlignment.spaceBetween`, `CrossAxisAlignment.center`.
- **Lado izquierdo:** `Icon(Icons.description_outlined, size: 20, color: secondary)` + `SizedBox(width: 8)` + `Text(label, style: bodyMedium, fontSize: 14)`.
- **Lado derecho (URL presente):**  
  - Botón "Ver": `TextButton` con texto `'Ver'`, ícono `Icons.open_in_new` (16px), `onPressed: onView`. Color: `primary`.  
  - `SizedBox(width: 8)`.  
  - Botón "Descargar": `TextButton` con texto `'Descargar'`, ícono `Icons.download_outlined` (16px), `onPressed: onDownload`. Si `isDownloading`: reemplazar con `SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))`.
- **Lado derecho (URL ausente):** `Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: 4), child: Text('No cargado', style: bodySmall, color: secondaryText))`.
- **Separación entre filas:** `SizedBox(height: 10)` (consistente con `.divide(SizedBox(height: 10))` del widget).

### 6.4 Estados del componente completo

| Estado | Trigger | Render |
|---|---|---|
| **Cargando** | `FutureBuilder` snapshot sin datos | `CircularProgressIndicator` (código existente, sin cambios) |
| **Con documentos** | URL no nula/vacía | Fila con botones "Ver" / "Descargar" |
| **Sin documento** | URL nula o vacía | Fila con badge "No cargado", sin botones |
| **Descargando** | `_isDownloading == true` | Spinner inline en lugar del botón "Descargar" |
| **Sin certificaciones** | Lista vacía | Ícono + texto "Sin certificaciones registradas" |

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
