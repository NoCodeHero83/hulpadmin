# spec.md · hulpadmin

> Documento de especificación raíz (Spec-Driven Development).
> El código se implementa **única y exclusivamente** a partir de lo aquí definido.

---

## Control de versiones

| Versión | Fecha | Cambio | Motivo |
|---------|-------|--------|--------|
| v1.0.0 | 2026-06-15 | Versión inicial del spec raíz. | Formalizar SDD. |
| v1.1.0 | 2026-06-15 | Soporte de tres ambientes (`Test` / `Sandbox` / `Production`) en la carga de configuración. | Habilitar un entorno Sandbox real seleccionable por `--dart-define=ENVIRONMENT`, sin romper compilación ni la lógica de pagos/Supabase existente. |

---

## REQ-ENV · Selección de ambiente de ejecución (v1.1.0)

### 1. Contexto / problema

Antes de v1.1.0, `lib/environment_values.dart` solo distinguía `Test` vs.
"todo lo demás". El valor `--dart-define=ENVIRONMENT=Sandbox` **no tenía efecto**:
caía al archivo `environment.json` (producción/default). El que se pegara a
Wompi sandbox o producción dependía únicamente del campo `isProduction` dentro
del JSON, no del flag.

### 2. Comportamiento aprobado

`FFDevEnvironmentValues.currentEnvironment` resuelve a uno de tres valores:

- `--dart-define=ENVIRONMENT=Test` → `Test`
- `--dart-define=ENVIRONMENT=Sandbox` → `Sandbox`
- `--dart-define=ENVIRONMENT=Production` → `Production`
- Sin flag: `kDebugMode` → `Test`; release → `Production`

Mapa de archivo de configuración (`environmentValuesPath`):

| Ambiente | Archivo |
|----------|---------|
| `Test` | `assets/environment_values/environment_test.json` |
| `Sandbox` | `assets/environment_values/environment_sandbox.json` |
| `Production` | `assets/environment_values/environment.json` |

### 3. Estructura del JSON de configuración

Cada archivo de ambiente debe contener estas claves (camelCase):

```json
{
  "privateKey": "prv_...",
  "publicKey": "pub_...",
  "isProduction": false,
  "supabaseUrl": "https://....supabase.co",
  "supabaseAnonKey": "...",
  "integrityKey": "...",
  "n8nWebhookUrl": "https://..."
}
```

> **Nota de robustez (decisión "sin dañar nada"):** `initialize()` aplica
> valores por defecto (`?? ''` para strings, `?? false` para `isProduction`)
> de modo que un JSON al que le falte alguna clave **no rompa** la carga ni
> deje toda la configuración vacía.

### 4. Restricciones

- No se altera la lógica de negocio de pagos Wompi: la URL base sigue
  decidiéndose por `isProduction` dentro de cada JSON.
- Getters expuestos por `FFDevEnvironmentValues` pasan a camelCase
  (`privateKey`, `publicKey`) y se agrega `n8nWebhookUrl`. Todos los
  consumidores deben usar los nuevos nombres.
- Los archivos `environment*.json` contienen secretos: permanecen en
  `.gitignore` (incluido el nuevo `environment_sandbox.json`).

### 5. Archivos afectados

- `lib/environment_values.dart` (reemplazo)
- `lib/components/finalizar_servicio2_widget.dart` (6 referencias a getters)
- `.github/workflows/deploy.yml` (generador JSON producción)
- `build_vercel.sh` (generador JSON producción)
- `.gitignore` (ignorar `environment_sandbox.json`)
- `assets/environment_values/environment_sandbox.json` (plantilla nueva, local)

### 6. Pendiente del usuario (valores no asumibles)

- Completar `environment_sandbox.json` con las credenciales reales de Sandbox.
- Agregar la clave `n8nWebhookUrl` a los `environment.json` /
  `environment_test.json` locales y al secreto de CI si se desea usarla.
