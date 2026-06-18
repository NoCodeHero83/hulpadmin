# Especificación Técnica — REQ-005
**Título:** Rediseño — migración del pop-up de información del proveedor a página dedicada `DetalleProveedor`
**Fecha:** 2026-06-16
**Estado:** Implementado
**Metodología:** Spec Driven Development (SDD)

> **Origen:** Este requerimiento se extrajo de la antigua Adenda §11 de [REQ-002](REQ-002_spec.md) (v2.0.0–v2.0.3). REQ-002 quedó enfocado exclusivamente en el feature de visualización/descarga de documentos; el rediseño de pop-up → página vive aquí como requerimiento independiente. La numeración de versiones se reinició a v1.x.x para este spec; entre paréntesis se indica la versión equivalente que tenía dentro de REQ-002.

---

## Control de versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0.0 (ex REQ-002 v2.0.0) | 2026-06-16 | Equipo Hulp | Migración del pop-up `InformacionProveedorWidget` (invocado vía `showDialog` desde la pantalla `Proveedores2`) a una PÁGINA DEDICADA `DetalleProveedorWidget` con el rediseño visual de referencia (encabezado de perfil, panel de documentos + certificaciones, panel de referencias con acciones Ver/Llamar, datos básicos, facturación, servicios ofrecidos y línea de tiempo de historial de servicios). La lógica de negocio, las consultas existentes y el rendimiento se preservan; el contrato de solo lectura (RN-01 de REQ-002) se mantiene. |
| v1.0.1 (ex REQ-002 v2.0.1) | 2026-06-16 | Equipo Hulp | Ajuste de fidelidad en "Servicios ofrecidos": se reemplaza el widget de árbol con checkboxes (`custom_widgets.CrearProveedor`, que desbordaba y no correspondía al diseño) por etiquetas planas agrupadas en "Servicios seleccionados" (chip verde + check) y "No seleccionados" (chip gris + X). Misma lógica de datos: se carga el catálogo completo de `servicios` y se marca como seleccionado el servicio cuyo id esté en `profesional_servicios` del proveedor. Solo presentación; sin cambios de negocio. |
| v1.0.2 (ex REQ-002 v2.0.2) | 2026-06-16 | Equipo Hulp | UX de "Servicios ofrecidos": (a) se mueve a su propia fila a ancho completo (ya no comparte fila con Datos básicos/Facturación) para dar más espacio horizontal a las etiquetas; (b) cada grupo (seleccionados / no seleccionados) muestra hasta `_maxChipsVisible = 12` etiquetas y, si hay más, un chip "Ver más (N)" que abre un pop-up con TODAS las etiquetas de ese grupo y scroll interno (alto máx. 80% de la pantalla, ancho máx. 640px). Solo presentación; sin cambios de negocio. |
| v1.0.3 (ex REQ-002 v2.0.3) | 2026-06-16 | Equipo Hulp | (a) Se agrega el botón "+ Agregar referencia" en el panel de Referencias, que abre un pop-up con formulario (Nombre, Teléfono, Relación, todos obligatorios) e **inserta** un registro en `referencias_laborales` (`usuario_id`, `nombre_referencia`, `telefono_referencia`, `relacion_laboral`), refrescando el listado al guardar. Esto introduce la ÚNICA operación de escritura del REQ y constituye una excepción explícita a la regla de solo lectura (ver RN-01). (b) Facturación: los campos (Entidad, Tipo de cuenta, Número de cuenta, RUT) muestran estado vacío ("—") cuando el dato no existe o está vacío/espacios en el backend; nunca un valor mock/placeholder (helper `_valorReal`). (c) Los labels de campo se muestran en azul `#133CC2` (Inter, peso 500). |

> **Razón del cambio (v1.0.0):** el pop-up resultaba estrecho (máx. 800px) y desbordaba en pantallas reales (overflow visible en el listado de categorías). Convertirlo en página permite el layout de paneles de la imagen de referencia, mejor legibilidad y navegación con breadcrumb, sin tocar la lógica de datos ya validada en REQ-002.

---

## 1. Resumen del cambio

Se reemplaza la apertura del pop-up `InformacionProveedorWidget` (vía `showDialog`) al pulsar el **nombre del proveedor** en la pantalla `Proveedores2`, por la navegación a una **página dedicada** `DetalleProveedorWidget`. La página reproduce con fidelidad el diseño de referencia (mockup tipo "perfil de proveedor"): encabezado con foto, estado, servicios principales, fecha de inscripción e ID; panel de documentos y certificaciones; panel de referencias con acciones; bloques de datos básicos, facturación y servicios ofrecidos; y una línea de tiempo de historial de servicios.

El **feature de documentos** (Zona A registro + Zona B certificaciones, Ver/Descargar) no cambia: se reutiliza el helper `_buildDocumentCard` y los métodos `openDocument` / `downloadDocument` ya especificados en [REQ-002](REQ-002_spec.md). Esta página los consume tal cual.

**Principios no negociables (heredados del proyecto):**
- **Cero cambios en lógica de negocio.** Se reutilizan exactamente las mismas consultas y helpers ya validados (`UsuariosTable`, `CuentasBancariasTable`, `CertificacionesTable`, `ReferenciasLaboralesTable`, `ProfesionalServiciosTable`, y los métodos `openDocument` / `downloadDocument`).
- **Solo lectura.** No se agregan controles de edición ni borrado. La única excepción de escritura es "Agregar referencia" (v1.0.3, ver RN-01).
- **Rendimiento preservado.** Misma estrategia de `FutureBuilder` perezoso; no se introducen `Stream` nuevos. Las dos consultas adicionales (chips de servicios y línea de tiempo) solo se ejecutan al abrir la página de detalle, nunca en el listado.
- **Patrón FlutterFlow.** Página con par `*_widget.dart` / `*_model.dart`, `routeName`/`routePath` estáticos, registro en `nav.dart` y export en `index.dart`. El menú lateral se reutiliza con `MenuWidget`.

---

## 2. Análisis de impacto

| Archivo | Acción | Justificación |
|---|---|---|
| `lib/web/detalle_proveedor/detalle_proveedor_widget.dart` | **Crear** | Nueva página. UI del rediseño. |
| `lib/web/detalle_proveedor/detalle_proveedor_model.dart` | **Crear** | Modelo de la página: `menuModel`, `downloadingDocs`, `openDocument`, `downloadDocument`, `llamarTelefono`. |
| `lib/flutter_flow/nav/nav.dart` | **Modificar** | Registrar `FFRoute` de `DetalleProveedorWidget` con parámetros `proveedorId`, `categoriaid`, `categorianombre`. |
| `lib/index.dart` | **Modificar** | `export` de la nueva página. |
| `lib/web/proveedores2/proveedores2_widget.dart` | **Modificar** | Cambiar el `onTap` del nombre del proveedor de `showDialog(InformacionProveedorWidget)` a `context.pushNamed(DetalleProveedorWidget.routeName, ...)`. Eliminar el import no usado si corresponde. |
| `lib/components/informacion_proveedor_widget.dart` | **Sin cambios** | Se conserva intacto como referencia de la lógica de REQ-002. No se elimina. |

**Archivos que NO se tocan:** auth, otras pantallas, esquema de base de datos, `pubspec.yaml` (todas las dependencias necesarias —`url_launcher`, `http`, `file_saver`, `google_fonts`— ya están declaradas).

---

## 3. Ruta y navegación

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

---

## 4. Fuentes de datos (todas ya existentes — solo lectura)

| Sección | Origen | Consulta |
|---|---|---|
| Encabezado, Datos básicos, Documentos de registro, RUT | `UsuariosTable` | `querySingleRow(id == proveedorId)` |
| Facturación (entidad, tipo, número de cuenta) | `CuentasBancariasTable` | `querySingleRow(usuario_id == proveedorId)` |
| Certificaciones | `CertificacionesTable` | `queryRows(usuario_id == proveedorId)` |
| Referencias | `ReferenciasLaboralesTable` | `queryRows(usuario_id == proveedorId)` |
| Servicios ofrecidos (seleccionados/no) | `ServiciosTable` + `ProfesionalServiciosTable` | `ServiciosTable.queryRows()` (catálogo) + `ProfesionalServiciosTable.queryRows(usuario_id == proveedorId)` |
| **Servicios principales (chips header)** — NUEVO | `VwProfesionalesServiciosTable` | `queryRows(profesional_id == proveedorId)` → distintos `servicioNombre` |
| **Historial de servicios (timeline)** — NUEVO | `VwSolicitudesServiciosCompletaTable` | `queryRows(profesional_id == proveedorId)` |

---

## 5. ID de proveedor (derivado, solo presentación)

Como `usuarios` no tiene un código formateado, el "ID de proveedor" se **deriva en UI** (no se persiste):

```
PROV-{año}-{idUsuario con padding a 4 dígitos}
  año     = fechaRegistro?.year ?? año actual
  idUsuario = usuarios.id_usuario (int)
Ej.: fechaRegistro=2025, id_usuario=158  ->  "PROV-2025-0158"
```

Si `id_usuario` es nulo, se muestra `PROV-{año}-----`.

---

## 6. Especificación de UI (fiel al mockup)

Paleta tomada de `FlutterFlowTheme` y de los colores ya usados en el proyecto:
`primary #0B6244` (verde), `success #18AC4C`, `secondaryBackground #FFFFFF`, `primaryBackground #FBF8F4`, breadcrumb `#5E252B`, chip verde fondo `#DFF9D2` / texto `#18AC4C`, badge "Activo" fondo `#DFF9D2` texto `#18AC4C`, badge "Inactivo" fondo `#FFE9CC` texto `#D6A100`, enlaces `#0D70E7`, labels de campo `#133CC2`.

**Estructura general:** `Scaffold` → `Row[ MenuWidget , Expanded(SingleChildScrollView) ]`. Ancho de contenido fluido con `padding` de 24–40px. Todas las tarjetas: `secondaryBackground`, `borderRadius 16`, borde `#7C766C` 0.5, sombra suave.

1. **Barra superior:** breadcrumb `Proveedores  ›  {nombre}` (izq., estilo itálico `#5E252B`) y botón `← Volver al listado` (der., contorno gris, `borderRadius 8`).
2. **Tarjeta de encabezado** (3 zonas en `Row` responsivo):
   - Izq.: avatar circular 96–100px (`fotoPerfilUrl`, fallback placeholder), nombre (22px bold `primaryText`), badge de estado (`Activo`/`Inactivo` según `disponibilidad` — ver §8), y fila de meta: ubicación (`ciudad, pais`), teléfono, Instagram (`redesSociales[0]` o "Sin Instagram"), Facebook (`redesSociales[1]` o "Sin Facebook"), cada uno con su ícono.
   - Centro: rótulo "Servicios principales" + `Wrap` de chips verdes (ícono check + `servicioNombre`), máximo 4 visibles y chip "+N" si hay más.
   - Der.: "Inscripción recibida" + `fechaRegistro` (`dd MMM, yyyy`, locale es) y "ID de proveedor" + valor derivado (§5, en `primary` bold).
3. **Fila media** (`Row`, en móvil `Column`):
   - **Documentos** (flex 2): título "Documentos" + badge "X/5 cargados" (cuenta de URLs no vacías entre cédula, cuenta bancaria, contrato y certificaciones con `documentoUrl`). Subsección "Documentos de registro" y subsección "Certificaciones" según el feature de [REQ-002](REQ-002_spec.md) (helper `_buildDocumentCard`, grid responsivo, empty states).
   - **Referencias** (flex 1): título "Referencias" + botón "+ Agregar referencia" (ver §7). Por cada `ReferenciasLaboralesRow`: avatar con iniciales, `nombreReferencia` (bold), `telefonoReferencia` (en `primary`), `relacionLaboral` (gris), y botones **"Ver"** (ícono ojo) y **"Llamar"** (ícono teléfono). Estado vacío: "Sin referencias registradas".
4. **Fila inferior** (`Row` de 2 columnas, responsivo a `Column`):
   - **Datos básicos:** tipo de documento, número de documento, instagram, facebook, dirección, país — como texto de solo lectura (label `#133CC2` + valor bold), sin `TextFormField` ni dropdowns.
   - **Facturación:** entidad, tipo de cuenta, número de cuenta (de `CuentasBancarias`), RUT (`registroTributario`) — texto de solo lectura; estado vacío "—" cuando el dato es nulo/vacío (helper `_valorReal`, RN-03).
5. **Servicios ofrecidos** (fila propia, ancho completo): etiquetas planas, no árbol de checkboxes. Se consulta el catálogo completo (`ServiciosTable.queryRows()`) y el conjunto de `servicioId` del proveedor (`ProfesionalServiciosTable` por `usuario_id`). Los servicios se agrupan, distintos por nombre y preservando el orden de aparición, en dos grupos: **"Servicios seleccionados"** (chip fondo `#DFF9D2`, ícono `check_circle_outline`, texto `#18AC4C`) y **"No seleccionados"** (chip fondo `#F0F0EF`, ícono `close`, texto `#8A8A8A`); cada grupo muestra su conteo `(N)`. Cada grupo limita a `_maxChipsVisible = 12` etiquetas visibles; si hay más, se muestra un chip **"Ver más (N)"** (contorno primario) que abre un pop-up (`Dialog`, ancho máx. 640px, alto máx. 80% pantalla) con TODAS las etiquetas de ese grupo y **scroll interno** (`SingleChildScrollView` + `Wrap`) y botón "Cerrar". Estado vacío total: "Sin servicios registrados". Solo lectura.
6. **Historial de servicios** (timeline): título + `SingleChildScrollView` horizontal con nodos conectados por líneas. Cada nodo: ícono circular verde, etiqueta de estado (mapeo §8), `servicioNombre`, `Cliente: {clienteNombreCompleto}` y `fecha`+`hora`. Si la lista está vacía: "Sin historial de servicios".

---

## 7. Acciones de la página

| Acción | Implementación | Notas |
|---|---|---|
| Ver documento | `_model.openDocument(url)` (reutilizado de REQ-002) | `launchUrl(externalApplication)` |
| Descargar documento | `_model.downloadDocument(url, fileName)` (reutilizado de REQ-002) | `http.get` + `FileSaver`; flag por documento en `downloadingDocs` |
| **Llamar** (referencia) | `_model.llamarTelefono(tel)` → `launchUrl(Uri(scheme:'tel', path: tel))` | NUEVO helper; solo presentación, no toca BD |
| **Ver** (referencia) | Diálogo de solo lectura con `nombreReferencia`, `telefonoReferencia`, `relacionLaboral` | No hay documento de referencia; solo muestra datos existentes |
| **+ Agregar referencia** | Pop-up con formulario (Nombre, Teléfono, Relación obligatorios) → `insert` en `referencias_laborales` → refresca listado | ÚNICA escritura del REQ (RN-01) |
| Volver al listado / breadcrumb | `context.safePop()` con fallback a `Proveedores2` | — |

---

## 8. Mapeos de estado (sin cambios de datos)

- **Badge de proveedor:** "Activo" si `disponibilidad == true`; en caso contrario "Inactivo" (colores §6). *(Se respeta el dato tal cual; no se calcula nada nuevo.)*
- **Estado en timeline** (`estado_solicitud`): `finalizadas`→"Servicio completado", `aceptadas`→"Servicio activo", `entrantes`→"Pendiente", `canceladas`→"Cancelado", otro→"Reprogramado/En curso". Idéntico al mapeo ya usado en `HistorialServiciosWidget`.

---

## 9. Restricciones y reglas de negocio

**RN-01 — Excepción a solo lectura para Referencias.** La página es de solo lectura salvo por la acción "Agregar referencia", que inserta en `referencias_laborales`. El formulario valida que Nombre, Teléfono y Relación no estén vacíos antes de insertar. No se permite editar ni eliminar referencias existentes (fuera de alcance). Tras una inserción exitosa se refresca el listado (`safeSetState`).

**RN-02 — Acceso restringido al rol administrador.** La página solo es accesible desde la navegación administrativa; la restricción de rol se gestiona en la capa de navegación existente, no dentro de la página.

**RN-03 — Sin valores mock.** Los campos de Facturación solo muestran datos provenientes del backend; si el valor es nulo o vacío/espacios, se muestra el estado vacío "—" (helper `_valorReal`). No se usan valores por defecto/placeholder de negocio.

**RN-04 — Color de labels.** Los labels de campo usan `#133CC2` (Inter, peso 500), conforme al diseño.

**RN-05 — Feature de documentos preservado.** El comportamiento Ver/Descargar/estados/empty del panel de documentos es el de [REQ-002](REQ-002_spec.md); esta página no lo modifica, solo lo reubica en el nuevo layout.

---

## 10. Criterios de aceptación verificables

| ID | Afirmación |
|---|---|
| CA-01 | Al pulsar el nombre de un proveedor en `Proveedores2` se navega a `/detalleProveedor` con `proveedorId` correcto (ya no se abre el pop-up). |
| CA-02 | El encabezado muestra foto, nombre, badge de estado, ubicación, teléfono, redes, "Inscripción recibida" y "ID de proveedor" derivado `PROV-AAAA-####`. |
| CA-03 | Los chips de "Servicios principales" muestran hasta 4 `servicioNombre` y "+N" cuando hay más. |
| CA-04 | El panel de Documentos conserva exactamente el comportamiento de REQ-002 (Ver/Descargar/estados/empty), incluida la subsección Certificaciones. |
| CA-05 | El panel de Referencias lista cada referencia con "Ver" y "Llamar"; "Llamar" invoca `launchUrl(tel:)`. |
| CA-06 | "Datos básicos" y "Facturación" se muestran como texto de solo lectura, sin campos editables; Facturación muestra "—" cuando el dato es nulo/vacío. |
| CA-07 | "Servicios ofrecidos" se renderiza como etiquetas planas en dos grupos (seleccionados / no seleccionados) con "Ver más (N)" cuando un grupo supera 12 etiquetas. |
| CA-08 | La línea de tiempo muestra los servicios del proveedor con estado, cliente y fecha; vacío → mensaje. |
| CA-09 | "+ Agregar referencia" inserta en `referencias_laborales` solo con Nombre, Teléfono y Relación no vacíos, y refresca el listado. |
| CA-10 | "Volver al listado" regresa a `Proveedores2`. |
| CA-11 | El proyecto compila sin errores; `InformacionProveedorWidget` permanece intacto; no se introducen `Stream` nuevos. |

---

## 11. Riesgos y supuestos

- **S-01.** `disponibilidad` es la fuente del estado Activo/Inactivo (consistente con el listado, que muestra "Inactivo" por defecto). Si el negocio define el estado por otra columna, se ajusta el mapeo en un único punto (§8) sin cambios estructurales.
- **S-02.** `launchUrl(tel:)` abre el marcador en móvil/desktop; en Flutter Web puede no tener handler, en cuyo caso se captura la excepción y se muestra `SnackBar` (mismo patrón que documentos).
- **R-01.** Dos `FutureBuilder` adicionales (chips + timeline) por apertura de detalle. Mitigación: solo corren en la página de detalle, no en el listado; lectura ligera.
- **R-02.** El import de `InformacionProveedorWidget` en `Proveedores2` queda sin uso tras el cambio. Mitigación: se elimina dicho import si ningún otro uso permanece, para evitar warnings.

---

## 12. Out of scope

- Editar o eliminar referencias existentes (solo se permite agregar, v1.0.3).
- Edición de cualquier dato del proveedor desde la página.
- Cambios en el esquema de base de datos o en vistas de Supabase.
- Eliminación del componente `InformacionProveedorWidget`.
- Cualquier cambio al comportamiento de Ver/Descargar de documentos (definido en [REQ-002](REQ-002_spec.md)).
