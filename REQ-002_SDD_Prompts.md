# REQ-002 — Visualización y Descarga de Documentos de Proveedores
## Guía Spec Driven Development (SDD)

---

## ¿Qué es Spec Driven Development?

SDD es una metodología donde **la especificación técnica detallada se escribe ANTES de codificar**. El flujo es:

```
SPEC (especificar) → IMPLEMENT (implementar) → VALIDATE (validar)
```

Cada fase tiene su propio prompt. Se usan en orden: no pasas a la siguiente hasta aprobar la anterior.

---

## Contexto del proyecto (para incluir en cada prompt)

```
Proyecto: hulpadmin — panel administrativo Flutter exportado de FlutterFlow, backend Supabase.

Archivos clave para este requerimiento:
- lib/components/informacion_proveedor_widget.dart  (widget principal, 3149 líneas)
- lib/components/informacion_proveedor_model.dart
- lib/backend/supabase/database/tables/usuarios.dart
- lib/backend/supabase/database/tables/certificaciones.dart

Datos relevantes en Supabase:
- tabla `usuarios`: campos cedula (String?), cuentaBancaria (String?), contrato (String?) — son URLs de Supabase Storage
- tabla `certificaciones`: campos documentoUrl (String), entidadCertificadora (String), usuarioId (String)

Dependencias ya disponibles en pubspec.yaml:
- url_launcher: 6.3.1   → para abrir/previsualizar documentos
- file_saver: 0.2.14    → para descarga de archivos
- http: 1.4.0           → para fetch de bytes antes de guardar

Patrón de roles: el panel ya valida rol == 'administrador' en el login (login_web_widget.dart:556).
Este es un panel exclusivo de administradores, por lo que el acceso ya está implícitamente restringido.
```

---

## FASE 1 — SPEC: Generar la especificación técnica

> **Cuándo usar:** Al inicio, antes de escribir una sola línea de código.
> **Resultado esperado:** Un archivo `SPEC_REQ002.md` con la especificación técnica completa que servirá de contrato para la implementación.

### Prompt Fase 1

```
Eres un arquitecto de software senior. Voy a darte un requerimiento funcional y el contexto
del proyecto. Tu tarea es producir una especificación técnica detallada en formato Markdown
siguiendo la metodología Spec Driven Development (SDD).

NO escribas código todavía. Solo la especificación.

---

## REQUERIMIENTO: REQ-002
Título: Visualización y descarga de documentos de proveedores desde el panel administrativo

Descripción: Permitir que los administradores visualicen y descarguen, desde el panel
administrativo, los documentos que los proveedores adjuntan al registrarse y en su perfil.

Categorías de documentos:
1. Documentos de registro: cédula, cuenta bancaria, contrato (URLs en tabla `usuarios`)
2. Certificaciones: documentos con entidad certificadora (tabla `certificaciones`)

Comportamiento esperado:
- Ver/previsualizar cada documento
- Descargar cada documento
- Mostrar estado vacío cuando no hay documentos
- Solo lectura (sin edición ni eliminación)
- Acceso restringido al rol administrador

---

## CONTEXTO TÉCNICO DEL PROYECTO

Proyecto: hulpadmin — panel administrativo Flutter exportado de FlutterFlow, backend Supabase.

Archivos clave:
- lib/components/informacion_proveedor_widget.dart (3149 líneas — aquí va la nueva sección)
- lib/components/informacion_proveedor_model.dart
- lib/backend/supabase/database/tables/usuarios.dart
- lib/backend/supabase/database/tables/certificaciones.dart

Datos en Supabase:
- tabla `usuarios`: cedula (String?), cuentaBancaria (String?), contrato (String?) — URLs de Storage
- tabla `certificaciones`: documentoUrl (String), entidadCertificadora (String), usuarioId (String)

Dependencias disponibles:
- url_launcher: 6.3.1
- file_saver: 0.2.14
- http: 1.4.0

El widget `InformacionProveedorWidget` ya recibe `proveedorId` como parámetro y ya consulta
`UsuariosTable` y `CertificacionesTable`. El context del proveedor ya está disponible.

---

## ESTRUCTURA REQUERIDA PARA LA ESPECIFICACIÓN

Produce un documento con estas secciones:

1. **Resumen del cambio** — qué se va a construir y dónde
2. **Análisis de impacto** — archivos a modificar / crear, con justificación
3. **Modelo de datos** — campos exactos que se leen, de qué tabla, tipo de dato
4. **Contratos de función / servicio** — firma exacta de helpers o métodos nuevos a crear
5. **Comportamiento por caso** — tabla con caso, entrada, salida esperada, manejo de error
6. **Especificación de UI** — descripción precisa del layout de la nueva sección en el widget,
   estados (cargando, vacío, con documentos), labels exactos
7. **Restricciones y reglas de negocio** — seguridad, rol, validaciones
8. **Criterios de aceptación verificables** — lista de afirmaciones true/false que el código
   debe cumplir, mapeadas a las PA-01..PA-05 del requerimiento original
9. **Riesgos y supuestos** — qué se asume sobre el estado actual, qué podría fallar
10. **Out of scope** — qué NO entra en este requerimiento

Sé preciso y exhaustivo. Esta especificación será el único insumo para la implementación.
```

---

## FASE 2 — IMPLEMENT: Implementar basado en la spec

> **Cuándo usar:** Después de revisar y aprobar el documento SPEC_REQ002.md generado en Fase 1.
> **Resultado esperado:** Código Flutter listo para compilar, sin romper funcionalidad existente.

### Prompt Fase 2

```
Eres un desarrollador Flutter senior. Vas a implementar un requerimiento siguiendo
estrictamente la especificación técnica que te proporciono. No improvises ni agregues
funcionalidad fuera del spec.

---

## SPEC A IMPLEMENTAR

[PEGA AQUÍ EL CONTENIDO COMPLETO DEL ARCHIVO SPEC_REQ002.md GENERADO EN FASE 1]

---

## CONTEXTO DEL PROYECTO

Proyecto: hulpadmin — panel Flutter exportado de FlutterFlow, backend Supabase.

Lee estos archivos antes de escribir código:
1. lib/components/informacion_proveedor_widget.dart
2. lib/components/informacion_proveedor_model.dart
3. lib/backend/supabase/database/tables/usuarios.dart
4. lib/backend/supabase/database/tables/certificaciones.dart

Dependencias disponibles (ya en pubspec.yaml, NO agregar nada):
- url_launcher: 6.3.1
- file_saver: 0.2.14
- http: 1.4.0

Convenciones del proyecto (respétalas):
- Widgets construidos con FlutterFlowTheme.of(context) para colores y tipografía
- Google Fonts (inter) para texto
- FutureBuilder para queries a Supabase
- Padding con EdgeInsetsDirectional.fromSTEB
- Sin setState directo — usar safeSetState cuando aplique

---

## INSTRUCCIONES DE IMPLEMENTACIÓN

1. Lee los 4 archivos listados arriba antes de escribir cualquier código.

2. Crea o modifica SOLO los archivos necesarios según el spec. Para cada archivo modificado,
   muestra el diff o la sección completa cambiada, no el archivo entero a menos que sea nuevo.

3. La nueva sección de documentos debe ir DENTRO de `InformacionProveedorWidget`, después
   de la sección de certificaciones existente (alrededor de la línea 2590), como una nueva
   sección de solo lectura titulada "Documentos".

4. Implementa dos subsecciones separadas visualmente:
   a) "Documentos de registro" — muestra cédula, cuenta bancaria y contrato desde `usuarios`
   b) "Certificaciones" — muestra cada certificación desde tabla `certificaciones` con su entidad

5. Para cada documento implementa:
   - Botón "Ver" → usa url_launcher para abrir la URL en nueva pestaña/app
   - Botón "Descargar" → usa http para obtener bytes + file_saver para guardar localmente
   - Estado vacío si el campo URL es null o vacío → texto claro "Sin documento cargado"

6. El helper de descarga debe ir en un archivo separado:
   lib/utils/document_download_helper.dart
   con la firma:
   Future<void> downloadDocument(String url, String fileName) async

7. Verifica que el widget compila sin errores y que los imports sean correctos.

8. Al terminar, lista todos los archivos modificados/creados con una línea de descripción.
```

---

## FASE 3 — VALIDATE: Validar contra el spec y las pruebas de aceptación

> **Cuándo usar:** Después de que el código de Fase 2 compile y esté en el repositorio.
> **Resultado esperado:** Reporte de validación que confirme cada criterio de aceptación.

### Prompt Fase 3

```
Eres un QA engineer senior. Tu tarea es revisar la implementación de un requerimiento
y verificar que cumple con la especificación técnica y las pruebas de aceptación.

---

## SPEC DE REFERENCIA

[PEGA AQUÍ EL CONTENIDO COMPLETO DEL ARCHIVO SPEC_REQ002.md]

---

## PRUEBAS DE ACEPTACIÓN ORIGINALES

PA-01 — Visualización de documentos de registro
  Pre: proveedor con cédula, cuenta bancaria y contrato cargados; admin autenticado
  Pasos: abrir vista del proveedor → localizar sección documentos de registro → abrir cada uno
  Esperado: cada documento se visualiza correctamente

PA-02 — Visualización de certificaciones
  Pre: proveedor con ≥1 certificación; admin autenticado
  Pasos: abrir vista del proveedor → localizar sección certificaciones → abrir cada una
  Esperado: cada certificación se visualiza correctamente

PA-03 — Descarga de documentos
  Pre: proveedor con documentos; admin autenticado
  Pasos: seleccionar opción descarga en un documento
  Esperado: archivo descargado íntegro y abrible fuera de la app

PA-04 — Proveedor sin documentos
  Pre: proveedor sin documentos; admin autenticado
  Pasos: abrir vista del proveedor
  Esperado: sistema indica ausencia de documentos sin errores

PA-05 — Restricción de acceso por rol
  Pre: usuario no administrador
  Pasos: intentar acceder a documentos del proveedor
  Esperado: acceso denegado según permisos del rol

---

## INSTRUCCIONES DE VALIDACIÓN

Lee estos archivos de la implementación:
1. lib/components/informacion_proveedor_widget.dart (sección nueva de documentos)
2. lib/utils/document_download_helper.dart
3. lib/components/informacion_proveedor_model.dart (si fue modificado)

Para cada prueba de aceptación (PA-01 a PA-05) produce:

| PA | ¿Cubierta? | Evidencia en código (archivo:línea) | Brecha o riesgo |
|----|-----------|--------------------------------------|-----------------|
| PA-01 | ✅/❌ | ... | ... |
| PA-02 | ✅/❌ | ... | ... |
| PA-03 | ✅/❌ | ... | ... |
| PA-04 | ✅/❌ | ... | ... |
| PA-05 | ✅/❌ | ... | ... |

Luego responde estas preguntas de validación estática:

1. ¿La sección de documentos de registro distingue cédula, cuenta bancaria y contrato por separado?
2. ¿Se muestra un estado vacío cuando la URL es null o string vacío?
3. ¿El botón "Ver" abre la URL con url_launcher (launchUrl)?
4. ¿El botón "Descargar" llama a downloadDocument() en document_download_helper.dart?
5. ¿La sección de certificaciones muestra el campo entidadCertificadora junto al documento?
6. ¿No hay ninguna acción de edición o eliminación implementada en la nueva sección?
7. ¿Los imports de url_launcher y file_saver están correctamente declarados?
8. ¿El widget existente (informacion_proveedor_widget.dart) compila sin romper funcionalidad previa?

Termina con: **VEREDICTO FINAL** — APROBADO / APROBADO CON OBSERVACIONES / RECHAZADO
y lista las acciones correctivas si aplica.
```

---

## Resumen del flujo

```
┌─────────────────────────────────────────────────────────────┐
│  FASE 1 — SPEC                                              │
│  Input:  requerimiento REQ-002 + contexto del proyecto      │
│  Output: SPEC_REQ002.md  (revisar y aprobar antes de seguir)│
└─────────────────────┬───────────────────────────────────────┘
                      │ aprobado
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  FASE 2 — IMPLEMENT                                         │
│  Input:  SPEC_REQ002.md + código fuente actual              │
│  Output: informacion_proveedor_widget.dart modificado       │
│          document_download_helper.dart (nuevo)              │
└─────────────────────┬───────────────────────────────────────┘
                      │ código listo
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  FASE 3 — VALIDATE                                          │
│  Input:  SPEC_REQ002.md + código implementado               │
│  Output: reporte PA-01..PA-05 + veredicto APROBADO/RECHAZADO│
└─────────────────────────────────────────────────────────────┘
```

---

## Notas importantes

- **Fase 1 es un checkpoint humano.** Antes de implementar, revisa el spec y corrígelo si
  el AI asumió algo incorrecto sobre el proyecto.
- **El spec es el contrato.** Si en Fase 2 el AI se desvía del spec, recházalo y pídele
  que se ajuste, no que mejore libremente.
- **Fase 3 puede revelar brechas.** Si el veredicto es RECHAZADO, regresa a Fase 2 con
  las brechas identificadas como contexto adicional.
- **No saltees fases.** La tentación de ir directo a "implementa esto" omite la especificación
  y produce código que no cubre todos los casos borde.
