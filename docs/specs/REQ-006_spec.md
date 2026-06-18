# Especificación Técnica — REQ-006
**Título:** Columna "Ciudad" en el listado de Solicitudes
**Fecha:** 2026-06-18
**Estado:** Especificado (pendiente de implementación)
**Metodología:** Spec Driven Development (SDD)

---

## Control de versiones

| Versión | Fecha | Autor | Cambios |
|---|---|---|---|
| v1.0.0 | 2026-06-18 | Equipo Hulp | Versión inicial. Agregar la columna "Ciudad" al listado de Solicitudes, ubicada **antes** de "Direccion". El valor proviene de la relación `solicitudes_servicio.ciudad_id → ciudades.nombre`, expuesta a través de la vista `vw_solicitudes_servicios_completa`. |

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
