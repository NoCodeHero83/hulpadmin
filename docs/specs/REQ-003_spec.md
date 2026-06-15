# REQ-003 · Rediseño sección Documentos — grid 3 columnas

**Fecha:** 2026-06-09 (v2: 2026-06-09 | v3: 2026-06-09 | v4: 2026-06-09)
**Archivos afectados:**
- `lib/components/informacion_proveedor_widget.dart`
- `lib/backend/supabase/database/tables/certificaciones.dart`
- Migración SQL en Supabase (producción y sandbox)

---

## 1. Contexto

La sección de documentos del proveedor necesita:
- Grid siempre de 3 columnas para ambas zonas (desktop).
- Slots vacíos invisibles que mantienen uniformidad del grid.
- Empty states útiles para el administrador en ambas zonas.
- Certificaciones organizadas en filas de 3; la 4ª se ubica en la siguiente fila.
- Fecha de subida en tarjetas de certificaciones.
- **[v4]** Empty state en Zona A cuando ningún documento de registro está cargado.
- **[v4]** Diseño responsivo: 1 columna en móvil (< 600px), 3 columnas en desktop (≥ 600px).

---

## 2. Diseño aprobado

### Desktop (≥ 600px)
```
📄 Documentos
─────────────────────────────────────
Documentos de registro
┌──────────┐  ┌──────────┐  [vacío]
│ Cédula   │  │ Cta Bco  │
│ [thumb]  │  │ [thumb]  │
│ Subido ✓ │  │ Subido ✓ │
│ [Ver]    │  │ [Ver]    │
│ [Descar] │  │ [Descar] │
└──────────┘  └──────────┘

Certificaciones
┌──────────┐  ┌──────────┐  ┌──────────┐
│ Cert 1   │  │ Cert 2   │  │ Cert 3   │
└──────────┘  └──────────┘  └──────────┘
```

### Móvil (< 600px)
```
📄 Documentos
─────────────────────
Documentos de registro
┌────────────────────┐
│ Cédula             │
│ [thumb]            │
│ Subido ✓           │
│ [Ver]  [Descargar] │
└────────────────────┘
┌────────────────────┐
│ Cuenta bancaria    │
│ ...                │
└────────────────────┘

Certificaciones
┌────────────────────┐
│ Cert 1             │
└────────────────────┘
```

---

## 3. Criterios de aceptación (CA)

| ID | Criterio |
|----|----------|
| CA-1 | Header "Documentos" con ícono `Icons.description_outlined` |
| CA-2 | Desktop: Zona A — 3 `Expanded` columnas; slots vacíos son `Expanded(SizedBox())` invisibles |
| CA-3 | Desktop: Zona B — filas de 3 usando `_buildDocRow`; slots faltantes invisibles |
| CA-4 | Zona B empty state: ícono `workspace_premium_outlined` + mensaje descriptivo |
| CA-5 | Solo se renderizan tarjetas de certificación con `documentoUrl` no vacío |
| CA-6 | `_buildDocumentCard` acepta `uploadDate: DateTime?`; muestra "Subido el DD/MM/YYYY" |
| CA-7 | Thumbnails: imagen → `Image.network`; PDF/otro → ícono PDF rojo sobre fondo gris |
| CA-8 | Botones "Ver" y "Descargar" solo cuando `url` no es null/vacío |
| CA-9 | Sin cambios en lógica de `openDocument` / `downloadDocument` / queries |
| CA-10 | `certificaciones.dart` expone `DateTime? get createdAt` mapeado a `created_at` |
| CA-11 | Zona B pasa `uploadDate: cert.createdAt` a cada tarjeta |
| **CA-12** | **[v4]** Zona A muestra empty state cuando los 3 docs (cedula, cuenta, contrato) son null/vacíos. Ícono: `Icons.upload_file_outlined`. Texto: _"Este proveedor aún no tiene documentos de registro cargados"_. Subtexto: _"Los documentos de cédula, cuenta bancaria y contrato aparecerán aquí una vez que el proveedor los cargue."_ |
| **CA-13** | **[v4]** Responsividad con `LayoutBuilder`: ancho < 600px → layout de 1 columna (`Column` de tarjetas ancho completo); ancho ≥ 600px → layout de 3 columnas (`_buildDocRow`) |
| **CA-14** | **[v4]** En móvil, Zona B también muestra 1 tarjeta por fila (ancho completo) |
| **CA-15** | **[v4]** El diseño desktop existente NO se modifica; solo se agrega la rama móvil |

---

## 4. Cambios técnicos

### 4.1 Helper `_buildEmptyColumn` (existente)
```dart
Widget _buildEmptyColumn() => const Expanded(child: SizedBox());
```

### 4.2 Helper `_buildDocRow` (existente)
Filas de 3 con spacers invisibles para slots faltantes.

### 4.3 Responsividad — patrón `LayoutBuilder`
```dart
LayoutBuilder(builder: (context, constraints) {
  final isMobile = constraints.maxWidth < 600;
  return isMobile
      ? _buildMobileLayout(context, ...)
      : _buildDesktopLayout(context, ...);
})
```

### 4.4 Layout móvil Zona A
```dart
Column(
  children: [
    if (cedula != null && cedula.isNotEmpty)
      _buildDocumentCard(context, label: 'Cédula', ...),
    if (cuenta != null && cuenta.isNotEmpty)
      _buildDocumentCard(context, label: 'Cuenta bancaria', ...),
    if (contrato != null && contrato.isNotEmpty)
      _buildDocumentCard(context, label: 'Contrato', ...),
  ].separatedBy(const SizedBox(height: 12)),
)
```

### 4.5 Layout móvil Zona B
```dart
Column(
  children: validCerts.map((cert) =>
    _buildDocumentCard(context, label: cert.entidadCertificadora, ...)
  ).toList().separatedBy(const SizedBox(height: 12)),
)
```

### 4.6 Empty state Zona A (CA-12)
Solo mostrar cuando los 3 documentos son null/vacíos.
```dart
if (loadedA == 0) {
  // mostrar empty state
} else {
  // mostrar LayoutBuilder con grid
}
```

---

## 5. Dependencias
- `intl: 0.20.2`
- `import 'package:intl/intl.dart';`
- `import 'dart:math' show min;`

---

## 6. Archivos a modificar
1. SQL Supabase — columna `created_at` en `certificaciones` ✓ (migración aplicada)
2. `lib/backend/supabase/database/tables/certificaciones.dart` — getter `createdAt` ✓
3. `lib/components/informacion_proveedor_widget.dart` — CA-12, CA-13, CA-14, CA-15
