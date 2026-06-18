# Especificación Técnica — REQ-007
**Título:** Edición integral de la página de detalle del proveedor (`DetalleProveedor`)
**Fecha:** 2026-06-18
**Estado:** Especificado (pendiente de implementación)
**Metodología:** Spec Driven Development (SDD)

> **Contexto:** amplía la página `DetalleProveedor` (definida en [REQ-005](REQ-005_spec.md), hoy de **solo lectura** salvo "Agregar referencia") para permitir que el **administrador edite** todas sus secciones. No se altera la lógica de negocio existente ni el diseño; se reutilizan los patrones ya presentes en el proyecto.

---

## Control de versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0.0 | 2026-06-18 | Equipo Hulp | Versión inicial. Edición de: datos del cliente (encabezado, con foto de perfil), datos básicos, facturación, servicios ofrecidos (toggle por categoría), documentos (subir/eliminar + Storage), referencias (editar/eliminar). |

---

## 1. Resumen del cambio

Cada sección de la página gana un **ícono de lápiz** (acción de edición) que abre un **pop-up** cuyo contenido depende del tipo de sección. Además, Documentos gana acciones de **subir** y **eliminar** (con confirmación), y Referencias gana **editar** y **eliminar** (con confirmación). Todas las operaciones son del rol **administrador** y refrescan la vista al terminar.

Se reutilizan exactamente los patrones ya existentes en el repositorio:
- **Diálogo con formulario:** patrón de `_agregarReferenciaDialog` (`showDialog` + `Dialog` + `Form` + `TextFormField` con la decoración y colores actuales).
- **Escritura en BD:** `UsuariosTable().update`, `CuentasBancariasTable().update/insert`, `ReferenciasLaboralesTable().update/delete`, `ProfesionalServiciosTable().delete/insert`, `CertificacionesTable().insert/delete` (todos ya usados en `editar_proveedor_widget`, `crear_proveedor_widget`, etc.).
- **Storage:** `uploadSupabaseStorageFile(bucketName: 'archivos', selectedFile)` y `deleteSupabaseFileFromPublicUrl(url)` (de `lib/backend/supabase/storage/storage.dart`), con `selectFiles` de `lib/flutter_flow/upload_data.dart`.
- **Confirmación de borrado:** componente existente `NotificacioneliminarWidget`.
- **Notificación de éxito:** componente existente `Notificacion2Widget`.
- **Refresco:** `safeSetState(() {})` re-ejecuta los `FutureBuilder` inline (incluido el `FutureBuilder<List<UsuariosRow>>` de nivel superior que carga `usuario`).

---

## 2. Decisiones de diseño confirmadas (con el usuario)

1. **Servicios ofrecidos = por categoría.** Al seleccionar una categoría se agregan a `profesional_servicios` **todos los servicios activos** de esa categoría; al deseleccionarla, se eliminan todos. (No edición servicio por servicio.)
2. **Datos del cliente incluye foto de perfil.** Además de los campos de texto, se permite **cambiar la foto** (subida a Storage bucket `archivos`, actualiza `usuarios.foto_perfil_url`).
3. **Documentos: borrado físico en Storage.** Al eliminar o reemplazar un documento se borra también el archivo de Storage (`deleteSupabaseFileFromPublicUrl`). La **alta de certificación** exige nombre de entidad + archivo.
4. **Estado/verificación fuera de alcance.** `disponibilidad` (Activo/Inactivo) y `verificado` se siguen gestionando en su flujo actual (no se tocan aquí).

---

## 3. Análisis de impacto

| Archivo | Acción | Justificación |
|---|---|---|
| `lib/web/detalle_proveedor/detalle_proveedor_widget.dart` | **Modificar** | Agregar el ícono de lápiz por sección, los pop-ups de edición, los botones de subir/eliminar (documentos) y editar/eliminar (referencias). |
| `lib/web/detalle_proveedor/detalle_proveedor_model.dart` | **Modificar** | Estado de subida/guardado por sección (flags `isSaving`/`isUploading`) y, si aplica, helpers de actualización. (Los formularios usan controladores locales al diálogo, como en `_agregarReferenciaDialog`.) |
| `lib/backend/supabase/storage/storage.dart` | **Sin cambios (reuso)** | `uploadSupabaseStorageFile`, `deleteSupabaseFileFromPublicUrl`. |
| `lib/flutter_flow/upload_data.dart` | **Sin cambios (reuso)** | `selectFiles` / `SelectedFile`. |
| `lib/components/notificacioneliminar_widget.dart` · `notificacion2_widget.dart` | **Sin cambios (reuso)** | Confirmación de borrado y notificación de éxito. |
| Tablas Supabase (`usuarios`, `cuentas_bancarias`, `referencias_laborales`, `profesional_servicios`, `certificaciones`, `servicios`, `subcategorias`, `categorias`) | **Sin cambios de esquema** | Solo operaciones CRUD ya soportadas. |

**No se tocan:** rutas/navegación, auth, otras pantallas, esquema de BD, `pubspec.yaml`, ni la lógica de `disponibilidad`/`verificado`/historial.

---

## 4. Modelo de datos — operaciones de escritura por sección

| Sección | Tabla(s) | Operación | Campos |
|---|---|---|---|
| Datos del cliente | `usuarios` | `update` (por `id == proveedorId`) | `nombres`, `apellidos`, `telefono`, `ciudad`, `redes_sociales` ([instagram, facebook]), `foto_perfil_url` |
| Datos básicos | `usuarios` | `update` | `tipo_documento`, `numero_documento`, `direccion`, `pais` |
| Facturación | `cuentas_bancarias` (+ `usuarios`) | `update` si existe fila, `insert` si no; `update` en usuarios | `entidad_bancaria`, `tipo_cuenta`, `numero_cuenta` (+ `nombre_titular` al insertar); `usuarios.registro_tributario` (RUT) |
| Servicios ofrecidos | `profesional_servicios` | `delete` (todos por `usuario_id`) + `insert` por cada servicio | `usuario_id`, `servicio_id` |
| Documentos · registro | `usuarios` + Storage | `update` del campo URL; subir/borrar archivo | `cedula` \| `cuenta_bancaria` \| `contrato` |
| Documentos · certificación | `certificaciones` + Storage | `insert` / `delete`; subir/borrar archivo | `usuario_id`, `entidad_certificadora`, `documento_url` |
| Referencias | `referencias_laborales` | `update` / `delete` (por `id`) | `nombre_referencia`, `telefono_referencia`, `relacion_laboral` |

---

## 5. Patrón común de UI (consistencia obligatoria)

- **Ícono de lápiz por sección:** `Icon(Icons.edit_outlined)` (o `Icons.edit`), tamaño ~18–20, color `primary` (`#0B6244`), ubicado a la derecha del `_sectionTitle` de cada tarjeta (Row con `MainAxisAlignment.spaceBetween`). Para Documentos, el lápiz/acción abre el pop-up de subir; para Referencias, el lápiz va **por ítem**.
- **Pop-up de formulario:** mismo patrón visual que `_agregarReferenciaDialog` — `Dialog` (`borderRadius 16`, `insetPadding 24`, `maxWidth ~480`), encabezado con ícono + título (Inter w700, 18), campos con `TextFormField` (relleno `#FBFAF9`, borde `alternate`/`primary`, label en azul `_labelBlue #133CC2`), y una fila final de **dos botones**:
  - **Cancelar** (texto/contorno gris) → cierra sin cambios.
  - **Actualizar** (relleno `primary`) → valida, escribe, cierra, refresca y muestra `Notificacion2Widget` de éxito.
- **Estado de guardado:** mientras se escribe, el botón "Actualizar" muestra spinner y se deshabilitan los campos (flag local `saving`, como en el patrón existente).
- **Confirmación de borrado:** `showDialog` con `NotificacioneliminarWidget` (titulo, texto, succes, acción de confirmar) antes de cualquier `delete`.
- **Colores y formas:** se respetan los ya definidos en la página (`_cardDecoration`, `_chipBg #DFF9D2`, `_chipText #18AC4C`, `_labelBlue #133CC2`, `primary #0B6244`). No se introducen estilos nuevos.
- **Refresco:** tras cada operación exitosa, `safeSetState(() {})` para re-ejecutar los `FutureBuilder` (las cards y el `usuario` de nivel superior se reconstruyen con datos frescos).

---

## 6. Especificación por sección

### 6.1 Datos del cliente (tarjeta de encabezado)

**Acción:** lápiz junto al nombre/encabezado → pop-up "Editar datos del cliente".
**Formulario (montado con valores actuales):** `nombres`, `apellidos`, `telefono`, `ciudad`, `Instagram` (`redes_sociales[0]`), `Facebook` (`redes_sociales[1]`), y **foto de perfil**.
- **Foto:** botón "Cambiar foto" → `selectFiles` → `uploadSupabaseStorageFile(bucketName:'archivos')` → nueva URL. Si había `foto_perfil_url` previa, borrar la anterior con `deleteSupabaseFileFromPublicUrl`. Previsualización del avatar en el diálogo.
- **Guardar:** `UsuariosTable().update(data: { nombres, apellidos, telefono, ciudad, redes_sociales: [instagram, facebook], foto_perfil_url }, matchingRows: id == proveedorId)`.
- **Validación:** `nombres` y `apellidos` obligatorios; teléfono/ciudad/redes opcionales (pueden quedar vacíos). `redes_sociales` se reconstruye como lista de 2 posiciones.
> **Nota de diseño (overlap de redes):** Instagram/Facebook (`redes_sociales`) se editan **solo aquí**. La tarjeta "Datos básicos" los seguirá **mostrando** (lectura), pero su pop-up no los edita (ver 6.2), para evitar dos formularios escribiendo el mismo campo.

### 6.2 Datos básicos

**Acción:** lápiz junto al título "Datos básicos" → pop-up "Editar datos básicos".
**Formulario:** `tipo_documento`, `numero_documento`, `direccion`, `pais`.
- **Guardar:** `UsuariosTable().update(data: { tipo_documento, numero_documento, direccion, pais }, matchingRows: id == proveedorId)`.
- **Validación:** campos opcionales salvo que el negocio indique lo contrario; sin valores mock.
> Instagram/Facebook se editan en 6.1 (no aquí). `tipo_documento` puede presentarse como dropdown si ya existe un catálogo de tipos en el proyecto; si no, `TextFormField`.

### 6.3 Facturación

**Acción:** lápiz junto al título "Facturación" → pop-up "Editar facturación".
**Formulario:** `entidad_bancaria`, `tipo_cuenta`, `numero_cuenta`, `RUT` (= `usuarios.registro_tributario`).
- **Guardar (upsert):**
  - Si existe fila en `cuentas_bancarias` (`usuario_id == proveedorId`): `update` de `entidad_bancaria`, `tipo_cuenta`, `numero_cuenta`.
  - Si **no** existe: `insert` con esos campos + `usuario_id` + `nombre_titular` = nombre completo del proveedor (`'{nombres} {apellidos}'`), ya que `cuentas_bancarias.nombre_titular` es **NOT NULL** y la UI no lo expone.
  - Además: `UsuariosTable().update(data: { registro_tributario: RUT }, matchingRows: id == proveedorId)`.
- **Validación:** campos opcionales; si todos quedan vacíos no se crea fila nueva (se mantiene el estado "—").

### 6.4 Servicios ofrecidos (toggle por categoría)

**Acción:** lápiz junto al título "Servicios ofrecidos" → pop-up "Editar servicios".
**Contenido del pop-up:** misma presentación por **categorías** de [REQ-005 v1.0.4](REQ-005_spec.md): dos grupos visibles, **"Seleccionadas"** (chip verde) y **"No seleccionadas"** (chip gris). Cada chip es **clicable**: al hacer clic se **mueve** entre grupos (toggle de selección). Estado de selección mantenido localmente en el diálogo.
- **Origen de categorías:** `CategoriasTable` (solo `estado == 'activo'`), mapeo de categorías ofrecidas vía `servicio.subcategoria_id → subcategoria.categoria_id` (idéntico a REQ-005 v1.0.4).
- **Guardar (Actualizar):**
  1. Determinar el conjunto final de **categorías seleccionadas**.
  2. Derivar **todos los servicios activos** (`servicios.estado == 'activo'`) cuya categoría (vía subcategoría) esté en ese conjunto → lista de `servicio_id`.
  3. Reemplazar la relación (patrón de `editar_proveedor_widget`): `ProfesionalServiciosTable().delete(usuario_id == proveedorId)` y luego `insert` de cada `servicio_id`.
- **Validación:** se permite dejar 0 categorías (elimina todos los servicios) — confirmar con el comportamiento de negocio; por defecto se permite.
> **Consecuencia (documentada):** seleccionar una categoría suscribe al proveedor a **todos** los servicios activos de esa categoría; deseleccionarla los quita. Es la semántica acordada (Decisión §2.1).

### 6.5 Documentos (subir / eliminar)

**Acción de sección:** lápiz/acción junto al título "Documentos" → pop-up "Gestionar documentos" con opciones de **subir**.

**a) Documentos de registro (cédula, cuenta bancaria, contrato):**
- Cada slot permite **subir/reemplazar**: `selectFiles` → `uploadSupabaseStorageFile('archivos')` → `UsuariosTable().update({ <campo>: nuevaUrl })`. Si el slot tenía URL previa, borrar el archivo anterior (`deleteSupabaseFileFromPublicUrl`).
- Cada tarjeta de documento gana un **ícono de basura** (`Icons.delete_outline`, color `error`) → `NotificacioneliminarWidget` (confirmar) → `deleteSupabaseFileFromPublicUrl(url)` + `UsuariosTable().update({ <campo>: null })`.
- Campos: `cedula` → `usuarios.cedula`; `cuenta bancaria` → `usuarios.cuenta_bancaria`; `contrato` → `usuarios.contrato`.

**b) Certificaciones:**
- **Agregar certificación:** formulario con `entidad_certificadora` (**obligatorio**) + archivo (**obligatorio**) → subir a Storage → `CertificacionesTable().insert({ usuario_id: proveedorId, entidad_certificadora, documento_url })`.
- **Eliminar certificación:** ícono de basura por tarjeta → `NotificacioneliminarWidget` → `deleteSupabaseFileFromPublicUrl(documento_url)` + `CertificacionesTable().delete(id == certId)`.

**Tipos/format:** se reutiliza la detección de imagen/PDF existente (`_isImageUrl`) para el thumbnail; no se valida extensión más allá de lo actual.

### 6.6 Referencias (editar / eliminar)

**Acción por ítem:** cada referencia gana un botón **"Editar"** con ícono de lápiz → pop-up "Editar referencia" (mismo formulario que "Agregar referencia", pero **montado** con los valores actuales).
- **Botón principal:** "Actualizar" (no "Guardar", porque el dato ya existe) → `ReferenciasLaboralesTable().update(data: { nombre_referencia, telefono_referencia, relacion_laboral }, matchingRows: id == refId)`.
- **Eliminar:** dentro del pop-up de edición hay un botón **"Eliminar"** → abre un **segundo** pop-up de confirmación (`NotificacioneliminarWidget`) → `ReferenciasLaboralesTable().delete(id == refId)`.
- **Validación:** `nombre_referencia`, `telefono_referencia`, `relacion_laboral` obligatorios (igual que el alta).
- Se conserva el botón existente "Agregar referencia" (REQ-005 v1.0.3) sin cambios.

---

## 7. Restricciones y reglas de negocio

**RN-01 — Solo administrador.** Todas las acciones de edición son del rol administrador; el acceso se gestiona en la capa de navegación existente (no se agrega guard en la página).

**RN-02 — No romper la lógica de negocio.** Se reutilizan tablas, helpers y patrones existentes; no se introduce arquitectura nueva ni se modifica el esquema. La página debe seguir compilando y comportándose igual en lo no editado.

**RN-03 — Refresco tras escritura.** Tras cada operación exitosa se llama `safeSetState(() {})`; las cards (FutureBuilder inline) y el `usuario` de nivel superior se recargan. No se introducen `Stream` nuevos.

**RN-04 — Storage consistente.** Toda subida usa el bucket `archivos`. Todo borrado/reemplazo elimina el archivo anterior con `deleteSupabaseFileFromPublicUrl` para no dejar huérfanos (Decisión §2.3).

**RN-05 — `nombre_titular` en facturación.** Al **crear** una `cuentas_bancarias` inexistente, `nombre_titular` se completa con el nombre del proveedor (campo NOT NULL no expuesto en UI).

**RN-06 — `redes_sociales` se edita en un solo lugar.** Solo el pop-up "Datos del cliente" (6.1) escribe `redes_sociales`; "Datos básicos" no.

**RN-07 — Confirmación antes de borrar.** Ningún `delete` (documento, certificación, referencia) se ejecuta sin pasar por `NotificacioneliminarWidget`.

**RN-08 — Validación de obligatorios.** Formularios con campos obligatorios bloquean "Actualizar"/"Subir" hasta que estén completos (patrón `validator` existente).

---

## 8. Criterios de aceptación verificables

| ID | Afirmación |
|---|---|
| CA-01 | Cada sección (cliente, datos básicos, facturación, servicios, documentos) muestra un ícono de lápiz que abre su pop-up correspondiente; referencias muestra lápiz por ítem. |
| CA-02 | "Editar datos del cliente" guarda `nombres`, `apellidos`, `telefono`, `ciudad`, `redes_sociales` y permite cambiar `foto_perfil_url` (subida a `archivos`, borrando la foto anterior); la vista se refresca. |
| CA-03 | "Editar datos básicos" guarda `tipo_documento`, `numero_documento`, `direccion`, `pais`. |
| CA-04 | "Editar facturación" hace update si existe `cuentas_bancarias` o insert (con `nombre_titular` = nombre del proveedor) si no, y actualiza `registro_tributario`. |
| CA-05 | En "Editar servicios", al alternar una categoría y Actualizar, `profesional_servicios` queda con exactamente los servicios activos de las categorías seleccionadas (delete-all + insert). |
| CA-06 | En Documentos, subir un archivo de registro actualiza la URL en `usuarios` (y borra el archivo previo si lo había); el badge "X/3 cargados" se actualiza. |
| CA-07 | El ícono de basura en un documento/certificación pide confirmación (`NotificacioneliminarWidget`) y, al confirmar, borra el archivo de Storage y limpia la URL (registro) o elimina la fila (certificación). |
| CA-08 | "Agregar certificación" exige entidad + archivo e inserta en `certificaciones` con la URL subida. |
| CA-09 | Cada referencia se edita con un pop-up montado y botón "Actualizar" (`update`); el botón "Eliminar" interno pide segunda confirmación antes de `delete`. |
| CA-10 | Ninguna operación rompe la compilación; las secciones no editadas (historial, encabezado de servicios principales, etc.) se mantienen igual; no se modifica el esquema ni `disponibilidad`/`verificado`. |
| CA-11 | Todos los pop-ups respetan el patrón visual existente (colores, formas, botones Actualizar/Cancelar) y muestran `Notificacion2Widget` al concluir con éxito. |

---

## 9. Riesgos y supuestos

**S-01.** El `FutureBuilder<List<UsuariosRow>>` de nivel superior y los FutureBuilder de cada card crean su `future` inline, por lo que `safeSetState` los re-ejecuta y refresca tras escribir. (Verificado en el código actual.)

**S-02.** `selectFiles`/`SelectedFile` y los helpers de Storage funcionan en Flutter Web (el panel corre en web); la subida usa `uploadBinary` con `getPublicUrl`.

**S-03.** Las categorías y servicios mantienen la cadena `servicio.subcategoria_id → subcategoria.categoria_id`; el conjunto "activos" se filtra por `estado == 'activo'`.

**R-01 — Operaciones no atómicas.** El guardado de servicios es delete-all + N inserts (patrón existente). Si falla a mitad, puede quedar inconsistente. **Mitigación:** mostrar error y permitir reintento; (opcional) envolver en RPC transaccional si el negocio lo exige (fuera de alcance inicial).

**R-02 — Archivos huérfanos / borrado de Storage.** Si `deleteSupabaseFileFromPublicUrl` falla pero el `update`/`delete` de BD tiene éxito (o viceversa), puede quedar inconsistencia archivo↔BD. **Mitigación:** ejecutar primero la subida/registro y luego el borrado del anterior; capturar errores y notificar.

**R-03 — `redes_sociales` con menos de 2 posiciones.** Al reconstruir la lista hay que preservar índices [0]=instagram, [1]=facebook aunque uno esté vacío. **Mitigación:** normalizar a lista de 2 elementos.

**R-04 — Volumen de servicios por categoría.** Una categoría con muchos servicios genera muchos inserts. **Mitigación aceptada:** es el comportamiento acordado; el volumen real es bajo.

**R-05 — `cuentas_bancarias` campos NOT NULL.** `entidad_bancaria`, `tipo_cuenta`, `numero_cuenta`, `nombre_titular` son NOT NULL; al insertar deben enviarse (los tres primeros del formulario, `nombre_titular` derivado). Si el formulario los deja vacíos, enviar cadena vacía o bloquear el insert según validación.

---

## 10. Out of scope

- Edición de `disponibilidad` (Activo/Inactivo) y `verificado` (se gestionan en su flujo actual).
- Historial de servicios y "Servicios principales" del encabezado (solo lectura).
- Edición de datos del **cliente final** de una solicitud (esta página es del proveedor).
- Reglas de validación de formato avanzadas (máscaras de teléfono, validación bancaria real).
- Auditoría/registro de cambios y notificaciones al proveedor.
- Transaccionalidad fuerte (RPC) para el reemplazo de servicios (ver R-01).
- Cambios de esquema en Supabase.

---

## 11. Notas de implementación (Fase 2)

1. Añadir, en cada `_sectionTitle`, un trailing `IconButton`/`InkWell` con el lápiz que invoque el diálogo de la sección.
2. Implementar los diálogos reutilizando el helper de campos de `_agregarReferenciaDialog` (extraer un `_formField(...)` común si reduce duplicación, sin alterar el estilo).
3. Documentos: agregar acciones de subir (en el pop-up de sección) y basura (por tarjeta, en `_buildDocumentCard`/certificaciones), con confirmación.
4. Servicios: convertir el pop-up "Ver más" / grupos en uno editable con chips clicables (toggle) + botones Actualizar/Cancelar; al guardar, aplicar delete+insert.
5. Facturación: implementar el upsert (querySingleRow → update|insert) + update de `registro_tributario`.
6. Tras cada acción: `safeSetState(() {})` + `Notificacion2Widget` de éxito; errores con `SnackBar`/notificación.
7. Verificar compilación (`flutter analyze`) y CA-01..CA-11. Actualizar los comentarios `REQ-002 v2.0.x` residuales a la referencia correcta si se tocan esas zonas.
