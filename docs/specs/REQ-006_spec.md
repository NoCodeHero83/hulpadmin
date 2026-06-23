# Especificación Técnica — REQ-006
**Título:** Listado de Solicitudes — columna «Ciudad» y opción «Pendientes» en el filtro de Estado
**Fecha:** 2026-06-18
**Estado:** Especificado (pendiente de implementación)
**Metodología:** Spec Driven Development (SDD)

> **Alcance:** este REQ agrupa dos cambios en la sección **Solicitudes** (`lib/web/solicitudes/`):
> - **Parte A (§1–§11):** nueva columna "Ciudad" en el listado (antes de "Direccion").
> - **Parte B (§12):** mostrar el estado `entrantes` en el filtro de Estado con la etiqueta "Pendientes".

---

## Control de versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0.0 | 2026-06-18 | Equipo Hulp | Versión inicial. Agregar la columna "Ciudad" al listado de Solicitudes, ubicada **antes** de "Direccion". El valor proviene de la relación `solicitudes_servicio.ciudad_id → ciudades.nombre`, expuesta a través de la vista `vw_solicitudes_servicios_completa`. |
| **v1.1.0** | **2026-06-18** | **Equipo Hulp** | **Agregar la opción "Pendientes" al filtro de Estado del listado de Solicitudes. Surface el estado cuyo valor de BD es `entrantes` (hoy oculto a propósito vía la lista `ocultosEnFiltro`) y muestra su etiqueta como "Pendientes" en el desplegable. El valor en BD y el de filtrado siguen siendo `entrantes`; el badge de estado de las filas no cambia. Ver §12.** |

---

## 1. Resumen del cambio

En la sección **Solicitudes** (`lib/web/solicitudes/`), el listado de solicitudes se muestra en una tabla paginada (`SolicitudesDataTable`) cuyas filas provienen de la vista de Supabase `vw_solicitudes_servicios_completa`.

Se agrega una nueva columna **"Ciudad"**, ubicada entre "Usu. Solicitante" y "Direccion", que muestra el nombre de la ciudad asociada a la solicitud.

**Fuente del dato (decidida con el usuario):** la ciudad sale de la relación
`solicitudes_servicio.ciudad_id → ciudades.id` (FK creada en la migración `0001 — paises/provincias/ciudades`), tomando `ciudades.nombre`. **No** se usa el texto concatenado de la columna `Direccion` (`ubicacion`) ni el campo `usuarios.ciudad`.

Como el listado consume una **vista**, el dato debe exponerse primero en la vista (`solicitud_ciudad`); luego se agrega el getter Dart correspondiente y, por último, la columna en la UI.

> **Limitación conocida y aceptada:** la columna `solicitudes_servicio.ciudad_id` se agregó como `NULL` y la migración 0001 **no rellena** las solicitudes existentes. Por lo tanto, mientras `ciudad_id` no se pueble, la columna "Ciudad" mostrará el estado vacío "Sin ciudad" para esas filas. El backfill / la asignación de `ciudad_id` queda **fuera del alcance** de este REQ (ver §9 y §10).

---

## 2. Análisis de impacto

| Archivo / objeto | Acción | Justificación |
|---|---|---|
| Vista SQL `vw_solicitudes_servicios_completa` (Supabase, sandbox y producción) | **Modificar** | `LEFT JOIN ciudades` por `solicitudes_servicio.ciudad_id` y exponer `ciudades.nombre AS solicitud_ciudad`. Es el único punto donde el listado puede obtener la ciudad sin nuevas consultas en Flutter. |
| `lib/backend/supabase/database/tables/vw_solicitudes_servicios_completa.dart` | **Modificar** | Agregar el getter `String? get solicitudCiudad => getField<String>('solicitud_ciudad')` (+ setter). |
| `lib/web/solicitudes/solicitudes_data_table.dart` | **Modificar** | Agregar la `DataColumn2` "Ciudad" en `_buildColumns` y la `DataCell` correspondiente en `_buildRow`, ambas **antes** de "Direccion". |
| Migración SQL nueva (opcional) `docs/sql/` | **Crear (opcional)** | Versionar el `CREATE OR REPLACE VIEW` actualizado para trazabilidad, en paralelo a `migrations countries provinces cities.sql`. |

**Archivos / objetos que NO se tocan:**
- `lib/web/solicitudes/solicitudes_widget.dart` y `solicitudes_model.dart` — la query (`queryRows` + `.stream()` sobre la vista) trae todas las columnas de la vista; el nuevo campo aparece automáticamente en el `Map` de cada fila. **Sin cambios.**
- `solicitudes_servicio.dart` — no se requiere el getter `ciudadId` para este REQ (el join se resuelve en la vista). Se documenta como nota (§7, RN-04).
- `lib/web/solicitudes_rechazadas/*` — no usa `SolicitudesDataTable` ni esta tabla de columnas. **Fuera de alcance.**
- El buscador y los filtros existentes (estado, categoría, fecha, orden) — **sin cambios** (ver §10).

---

## 3. Modelo de datos

### 3.1 Cadena de relación

```
vw_solicitudes_servicios_completa
        │  (se construye desde) solicitudes_servicio  s
        │
        └── s.ciudad_id ──FK──> ciudades.id
                                 └── ciudades.nombre   →  expuesto como  solicitud_ciudad
```

### 3.2 Tablas involucradas (esquema real)

`solicitudes_servicio` (FK agregada en migración 0001):

| Columna | Tipo | Nullable | Nota |
|---|---|---|---|
| `ciudad_id` | `uuid` | Sí | `REFERENCES ciudades(id) ON DELETE SET NULL`. NULL en las filas existentes hasta que se pueble. |

`ciudades` (creada en migración 0001):

| Columna | Tipo | Nullable | Nota |
|---|---|---|---|
| `id` | `uuid` | No | PK |
| `provincia_id` | `uuid` | No | FK → `provincias.id` |
| `nombre` | `text` | No | Nombre de la ciudad (ej. "Cali", "Medellín") |
| `activo` | `boolean` | No | — |

### 3.3 Campo nuevo expuesto por la vista

| Campo Dart (nuevo) | Columna de la vista | Tipo | Nullable | Descripción |
|---|---|---|---|---|
| `solicitudCiudad` | `solicitud_ciudad` | `String?` | Sí | `ciudades.nombre` de la ciudad de la solicitud; `null` si `ciudad_id` es `NULL` o la ciudad no existe. |

---

## 4. Cambio en la vista SQL (contrato)

La definición exacta vigente de `vw_solicitudes_servicios_completa` no está versionada en el repo; vive en Supabase. La modificación debe:

1. Mantener **todas** las columnas y nombres actuales (la app depende de ellos; ver el modelo Dart de la vista).
2. Agregar un `LEFT JOIN` a `ciudades` por `solicitudes_servicio.ciudad_id`.
3. Proyectar `ciudades.nombre AS solicitud_ciudad`.

Patrón esperado (a integrar dentro del `SELECT` existente, sin alterar el resto):

```sql
CREATE OR REPLACE VIEW vw_solicitudes_servicios_completa AS
SELECT
  ...,                              -- TODAS las columnas actuales, intactas
  c.nombre AS solicitud_ciudad      -- NUEVO
FROM solicitudes_servicio s
  ...                               -- joins actuales, intactos
  LEFT JOIN ciudades c ON c.id = s.ciudad_id;   -- NUEVO
```

**Reglas del cambio de vista:**
- **`LEFT JOIN`** (no `INNER`): una solicitud con `ciudad_id = NULL` debe seguir apareciendo en el listado, con `solicitud_ciudad = NULL`.
- No se renombra, elimina ni reordena ninguna columna existente.
- Se aplica primero en **sandbox**, se valida, y luego en **producción** (mismo criterio que la migración 0001).
- El `primaryKey` del `.stream()` (`solicitud_id`, `subcategoria_id`, `categoria_id`) no cambia.

---

## 5. Comportamiento por caso

| # | Caso | Entrada | Salida esperada |
|---|---|---|---|
| C-01 | Solicitud con `ciudad_id` válido | `ciudad_id` apunta a una ciudad existente | La celda "Ciudad" muestra `ciudades.nombre` (ej. "Cali"). |
| C-02 | Solicitud sin ciudad asignada | `ciudad_id = NULL` (caso de las filas existentes) | La celda muestra el texto vacío **"Sin ciudad"**. |
| C-03 | `ciudad_id` apunta a una ciudad inexistente/inactiva | el `LEFT JOIN` no encuentra fila | `solicitud_ciudad = NULL` → celda "Sin ciudad". |
| C-04 | Carga del listado | stream de la vista | La columna "Ciudad" aparece entre "Usu. Solicitante" y "Direccion", alineada con el resto. |
| C-05 | Búsqueda/filtros activos | texto, estado, categoría, fecha | El comportamiento de filtrado no cambia; la columna "Ciudad" se muestra en las filas resultantes. |

---

## 6. Especificación de UI

**Ubicación de la columna:** en `SolicitudesDataTable._buildColumns`, insertar "Ciudad" **entre** "Usu. Solicitante" y "Direccion". Orden resultante de columnas:

```
Ticket · Estado · Fecha y hora · Usu. Solicitante · [Ciudad] · Direccion · Categoria · Precio · ID Proveedor · Acciones
```

**Encabezado:** se crea con el mismo helper `_col('Ciudad', headerStyle)` (misma tipografía Inter w600, 16px que el resto). Sin `fixedWidth` (igual que las demás columnas flexibles).

**Celda (en `_buildRow`, en la misma posición que la columna):**

```dart
// Ciudad
DataCell(Text(
  valueOrDefault<String>(item.solicitudCiudad, 'Sin ciudad'),
  style: bodyStyle,
)),
```

- Usa el `bodyStyle` ya definido en `_buildRow` (Inter, color por defecto del tema).
- Estado vacío: literal **"Sin ciudad"** (consistente con los placeholders existentes: "Sin usuario", "Sin direccion", "Sin datos").
- No es interactiva (a diferencia de "Direccion", que copia al portapapeles). Solo texto.

**Consistencia de conteo:** `DataColumn2` y `DataCell` deben quedar en el **mismo índice**. Al insertar la columna, se inserta también la celda en la misma posición para que el número de columnas y celdas siga coincidiendo (9 → 10).

---

## 7. Restricciones y reglas de negocio

**RN-01 — Fuente única del dato.** El valor de "Ciudad" proviene exclusivamente de `solicitudes_servicio.ciudad_id → ciudades.nombre`. No se deriva del string `ubicacion` (Direccion) ni de `usuarios.ciudad`.

**RN-02 — Solo lectura.** La columna es de presentación; no se agrega edición ni asignación de ciudad desde el listado.

**RN-03 — No romper la vista.** El `CREATE OR REPLACE VIEW` preserva todas las columnas y el orden de las existentes; solo añade `solicitud_ciudad`. Cualquier renombrado rompería el modelo Dart generado y la app.

**RN-04 — Modelo Dart de `solicitudes_servicio` sin re-sync obligatorio.** Como el join se resuelve en la vista, no es necesario que FlutterFlow regenere `solicitudes_servicio.dart` con el getter `ciudadId` para este REQ. (Si en el futuro se asigna `ciudad_id` desde la app, ahí sí se requerirá el getter.)

**RN-05 — Aplicar en sandbox antes que producción.** El cambio de vista sigue el mismo flujo de despliegue de la migración 0001.

---

## 8. Criterios de aceptación verificables

| ID | Afirmación |
|---|---|
| CA-01 | La vista `vw_solicitudes_servicios_completa` expone un campo `solicitud_ciudad` igual a `ciudades.nombre` para la `ciudad_id` de la solicitud, vía `LEFT JOIN`. |
| CA-02 | Una solicitud con `ciudad_id = NULL` sigue apareciendo en el listado (el `LEFT JOIN` no la excluye). |
| CA-03 | `vw_solicitudes_servicios_completa.dart` expone `String? get solicitudCiudad => getField<String>('solicitud_ciudad')`. |
| CA-04 | El listado muestra una columna "Ciudad" ubicada inmediatamente antes de "Direccion". |
| CA-05 | Para una solicitud con ciudad asignada, la celda muestra el nombre de la ciudad (ej. "Cali"). |
| CA-06 | Para una solicitud sin ciudad (`ciudad_id` NULL), la celda muestra "Sin ciudad" sin errores. |
| CA-07 | El número de columnas (`DataColumn2`) coincide con el de celdas (`DataCell`) por fila (10 y 10). |
| CA-08 | El resto de columnas, la paginación, el buscador y los filtros mantienen su comportamiento previo (sin regresiones). |
| CA-09 | El proyecto compila sin errores y sin warnings nuevos por la adición del getter y la columna. |

---

## 9. Riesgos y supuestos

**S-01.** La vista actual se construye a partir de `solicitudes_servicio` con un alias accesible (p. ej. `s`) sobre el cual está disponible `ciudad_id`. Si la vista no parte directamente de esa tabla, el `LEFT JOIN` debe anclarse al alias correcto que represente la solicitud.

**S-02.** El `.stream()` de Supabase sobre la vista sigue funcionando tras `CREATE OR REPLACE VIEW`; agregar una columna no invalida el stream ni el `primaryKey`.

**R-01 — Columna vacía hasta poblar `ciudad_id`.** Las 147 solicitudes existentes (y cualquier nueva que no asigne `ciudad_id`) mostrarán "Sin ciudad". **Mitigación / decisión pendiente del usuario:** definir si se hace un backfill de `ciudad_id` (p. ej. derivándolo de la ciudad del cliente `usuarios.ciudad` mapeada a `ciudades`, o por parsing de `ubicacion`) y si la app de origen empieza a setear `ciudad_id` al crear solicitudes. Ambos quedan **fuera del alcance** de este REQ.

**R-02 — Desfase del modelo Dart de la vista.** Si se regenera la vista en Supabase pero no se agrega manualmente el getter en `vw_solicitudes_servicios_completa.dart`, la columna mostrará siempre "Sin ciudad" aunque el dato exista. **Mitigación:** los dos cambios (vista + getter) se entregan juntos.

**R-03 — Orden de columnas.** Insertar la `DataColumn2` sin insertar la `DataCell` en la misma posición (o viceversa) desalinea toda la fila. **Mitigación:** CA-07 verifica el conteo y la posición.

---

## 10. Out of scope

- **Backfill / asignación de `ciudad_id`** en solicitudes existentes o nuevas.
- **Hacer "Ciudad" buscable o filtrable** (el buscador hace `ilike` solo sobre `cliente_nombre_completo`; los filtros son estado/categoría/fecha/orden). Si se desea, será otro REQ.
- **Parsear la ciudad desde `ubicacion`/Direccion** (descartado como fuente, RN-01).
- **Usar `usuarios.ciudad`** del cliente como fuente (alternativa evaluada y descartada en favor de la FK).
- **Sección `solicitudes_rechazadas`** y cualquier otro listado que no use `SolicitudesDataTable`.
- **Edición de la ciudad** desde el panel.
- **Regenerar `solicitudes_servicio.dart`** con el getter `ciudadId` (no requerido aquí, RN-04).

---

## 11. Notas de implementación (resumen para Fase 2)

1. **SQL (Supabase, sandbox → prod):** `CREATE OR REPLACE VIEW vw_solicitudes_servicios_completa` agregando `LEFT JOIN ciudades c ON c.id = <alias_solicitud>.ciudad_id` y `c.nombre AS solicitud_ciudad`. Versionar el SQL en `docs/sql/` (opcional pero recomendado).
2. **Dart (modelo de la vista):** agregar getter/setter `solicitudCiudad` ↔ `'solicitud_ciudad'` en `vw_solicitudes_servicios_completa.dart`.
3. **Dart (UI):** en `solicitudes_data_table.dart`, insertar `_col('Ciudad', headerStyle)` y la `DataCell` de `item.solicitudCiudad` **antes** de "Direccion", en ambos métodos (`_buildColumns` y `_buildRow`).
4. Verificar compilación y CA-01..CA-09.

---

# Parte B — Opción «Pendientes» en el filtro de Estado (v1.1.0)

## 12.1 Resumen del cambio

En el listado de Solicitudes, el filtro **"Filtrar por: Estado"** (un `DropdownButton` en `SolicitudesFilterBar`) no ofrece actualmente la opción para el estado cuyo valor de BD es `entrantes`. Este requerimiento la **agrega**, mostrándola con la etiqueta **"Pendientes"**.

- **Etiqueta visible en el filtro:** "Pendientes".
- **Valor en base de datos y valor de filtrado:** `entrantes` (sin cambios; la app sigue filtrando por `estado_solicitud == 'entrantes'`).
- **Badge de estado en las filas:** **sin cambios** (sigue mostrando "Pendiente" vía `solicitudStatusLabel`). El usuario confirmó que "en el badge ya existe".

## 12.2 Causa raíz (estado actual del código)

Dos puntos explican por qué hoy no aparece y dónde se ajusta:

1. **Exclusión deliberada** — `lib/web/solicitudes/solicitudes_widget.dart`, método `_getEstadoOptions`:
   ```dart
   // Estados ... por decisión de producto NO se ofrecen como opción de filtro
   const ocultosEnFiltro = ['entrantes', 'pendiente'];
   ```
   El estado `entrantes` se filtra fuera de las opciones del dropdown. Las opciones se derivan de los estados **presentes en los datos** (`allData`), excluyendo los de `ocultosEnFiltro`.

2. **Etiqueta del filtro** — `lib/flutter_flow/custom_functions.dart`, función `getStatus`:
   ```dart
   case 'entrantes': return 'Pendiente';   // singular
   ```
   `getStatus` se usa **únicamente** en `solicitudes_filter_bar.dart` (verificado); por eso cambiar este mapeo afecta **solo al filtro** y no al badge.

## 12.3 Análisis de impacto

| Archivo / objeto | Acción | Justificación |
|---|---|---|
| `lib/web/solicitudes/solicitudes_widget.dart` (`_getEstadoOptions`) | **Modificar** | Quitar `'entrantes'` de `ocultosEnFiltro` para que el estado aparezca como opción del filtro cuando exista en los datos. |
| `lib/flutter_flow/custom_functions.dart` (`getStatus`) | **Modificar** | Cambiar el `case 'entrantes'` para devolver `'Pendientes'` (etiqueta del desplegable). |
| `lib/flutter_flow/solicitud_status_helpers.dart` (`solicitudStatusLabel`) | **Sin cambios** | Es el mapeo del **badge** de las filas; debe seguir mostrando "Pendiente". |
| `lib/web/solicitudes/solicitudes_filter_bar.dart` | **Sin cambios** | Ya renderiza `value = e` (valor crudo `entrantes`) y `label = getStatus(e)`. El filtrado por `entrantes` ya funciona. |

> **Nota sobre `'pendiente'`:** la lista `ocultosEnFiltro` también contiene el valor crudo `'pendiente'` (variante heredada). Este requerimiento **solo** desoculta `'entrantes'`; `'pendiente'` se mantiene oculto para no duplicar la opción. Si se requiere también surfacearlo, será un ajuste aparte.

## 12.4 Comportamiento por caso

| # | Caso | Entrada | Salida esperada |
|---|---|---|---|
| CB-01 | Existen solicitudes en estado `entrantes` | `allData` contiene filas con `estado_solicitud == 'entrantes'` | El dropdown de Estado incluye la opción **"Pendientes"**. |
| CB-02 | El usuario selecciona "Pendientes" | click en la opción | `dropDownValue1 = 'entrantes'`; el listado se filtra a las solicitudes con `estado_solicitud == 'entrantes'`. |
| CB-03 | Badge en las filas | una fila con estado `entrantes` | La pastilla de Estado sigue mostrando **"Pendiente"** (sin cambios). |
| CB-04 | No hay solicitudes `entrantes` en los datos | `allData` sin filas `entrantes` | La opción "Pendientes" no aparece (comportamiento data-derived, idéntico al resto de estados). Ver §12.7 R-B2. |

## 12.5 Especificación de UI

- En el desplegable "Estado", la nueva opción se muestra con el texto **"Pendientes"** (Inter, mismo `bodyStyle` que las demás opciones).
- Posición: el listado de opciones se **ordena alfabéticamente** por clave normalizada (`list.sort(...)` en `_getEstadoOptions`), por lo que "Pendientes" se ubicará según ese orden, sin posición fija.
- El valor seleccionado interno sigue siendo `entrantes`; el usuario solo ve "Pendientes".

## 12.6 Criterios de aceptación verificables

| ID | Afirmación |
|---|---|
| CB-CA-01 | Con al menos una solicitud en estado `entrantes`, el filtro de Estado muestra la opción "Pendientes". |
| CB-CA-02 | Al seleccionar "Pendientes", el listado se filtra exactamente a las solicitudes con `estado_solicitud == 'entrantes'`. |
| CB-CA-03 | El valor enviado al filtrado y el almacenado en BD permanece como `entrantes` (no se introduce el literal "Pendientes" como valor). |
| CB-CA-04 | El badge de estado de las filas sigue mostrando "Pendiente" (no se altera `solicitudStatusLabel`). |
| CB-CA-05 | `getStatus('entrantes')` devuelve "Pendientes"; ningún otro consumidor de `getStatus` se ve afectado (es exclusivo del filtro). |
| CB-CA-06 | El proyecto compila sin errores ni warnings nuevos. |

## 12.7 Riesgos y supuestos

- **S-B1.** En los datos existen (o existirán) solicitudes con `estado_solicitud == 'entrantes'`; el comentario actual del código confirma que esos estados se estaban ocultando, no que no existan.
- **R-B1 — Consistencia filtro vs. badge.** El filtro dirá "Pendientes" (plural) y el badge "Pendiente" (singular). Es la decisión explícita del usuario (etiqueta nueva solo en el filtro). No es un defecto.
- **R-B2 — Opción data-derived.** Como las opciones se derivan de `allData`, "Pendientes" solo aparece si hay filas `entrantes` cargadas. Si se desea que la opción esté **siempre** visible (aun sin datos), habría que inyectarla explícitamente en `_getEstadoOptions`; queda como ajuste opcional fuera de este alcance salvo que se indique lo contrario.

## 12.8 Out of scope (Parte B)

- Cambiar la etiqueta del **badge** de las filas (sigue "Pendiente").
- Surfacear el valor crudo `'pendiente'` (solo se desoculta `'entrantes'`).
- Renombrar el valor en base de datos (permanece `entrantes`).
- Forzar que la opción "Pendientes" aparezca siempre, incluso sin solicitudes en ese estado (ver R-B2).
- Cualquier cambio en otros filtros (categoría, fecha, orden) o en el buscador.
