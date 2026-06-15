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

---

## Índice de requerimientos

- [REQ-002](REQ-002_spec.md) — Visualización y descarga de documentos de proveedores. (Guía SDD: [REQ-002_guia-sdd.md](REQ-002_guia-sdd.md))
- [REQ-003](REQ-003_spec.md) — Rediseño sección Documentos, grid 3 columnas.
- [REQ-004](REQ-004_spec.md) — Selección de ambiente de ejecución (Test / Sandbox / Production).
