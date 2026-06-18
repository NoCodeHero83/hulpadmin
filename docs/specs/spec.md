# spec.md · hulpadmin

> Documento de especificación maestro (Spec-Driven Development).
> El detalle de cada requerimiento vive en su propio `REQ-XXX_spec.md` dentro de
> `docs/specs/`. Este archivo solo lleva el control de versiones e índice.

---

## Control de versiones

| Versión | Fecha | Cambio | Spec | Motivo |
|---------|-------|--------|------|--------|
| v1.0.0 | 2026-06-15 | Versión inicial del spec maestro. | — | Formalizar SDD. |
| v1.1.0 | 2026-06-15 | Soporte de tres ambientes (`Test` / `Sandbox` / `Production`) en la carga de configuración. | [REQ-004](REQ-004_spec.md) | Habilitar un entorno Sandbox real seleccionable por `--dart-define=ENVIRONMENT`, sin romper compilación ni la lógica de pagos/Supabase. |
| v1.2.0 | 2026-06-18 | Reorganización documental: el antiguo REQ-003 (rediseño de la sección Documentos) se fusiona dentro de [REQ-002](REQ-002_spec.md) v1.1.0; la migración de pop-up a página dedicada `DetalleProveedor` (antes Adenda §11 de REQ-002) se extrae a [REQ-005](REQ-005_spec.md). | [REQ-002](REQ-002_spec.md), [REQ-005](REQ-005_spec.md) | Separar requerimientos solapados: un spec por feature (documentos) y otro por el rediseño de UI (página), eliminando duplicidad. Sin cambios de código. |
| v1.3.0 | 2026-06-18 | Nuevo requerimiento: columna "Ciudad" en el listado de Solicitudes (antes de "Direccion"), con fuente `solicitudes_servicio.ciudad_id → ciudades.nombre` vía la vista `vw_solicitudes_servicios_completa`. | [REQ-006](REQ-006_spec.md) | Mostrar la ciudad de la solicitud sin consultar la BD manualmente ni parsear la dirección. |

---

## Índice de requerimientos

- [REQ-002](REQ-002_spec.md) — Visualización y descarga de documentos de proveedores (incluye el rediseño de la sección Documentos, antes REQ-003). (Guía SDD: [REQ-002_guia-sdd.md](REQ-002_guia-sdd.md))
- [REQ-004](REQ-004_spec.md) — Selección de ambiente de ejecución (Test / Sandbox / Production).
- [REQ-005](REQ-005_spec.md) — Rediseño: migración de pop-up a página dedicada `DetalleProveedor`.
- [REQ-006](REQ-006_spec.md) — Columna "Ciudad" en el listado de Solicitudes.

> **Nota:** REQ-003 fue retirado; su contenido se fusionó en REQ-002 (v1.2.0 del spec maestro).
