# REQ-004 · Selección de ambiente de ejecución (Test / Sandbox / Production)

**Fecha:** 2026-06-15 (v1.0.0)
**Versión:** v1.1.0 del comportamiento de carga de configuración (ver tabla en `spec.md` maestro)
**Archivos afectados:**
- `lib/environment_values.dart` (reemplazo)
- `lib/components/finalizar_servicio2_widget.dart` (6 referencias a getters)
- `.github/workflows/deploy.yml` (generador JSON producción)
- `build_vercel.sh` (generador JSON producción)
- `.gitignore` (ignorar `environment_sandbox.json`)
- `assets/environment_values/environment_sandbox.json` (plantilla nueva, local)

---

## 1. Contexto / problema

Antes de este cambio, `lib/environment_values.dart` solo distinguía `Test` vs.
"todo lo demás". El valor `--dart-define=ENVIRONMENT=Sandbox` **no tenía efecto**:
caía al archivo `environment.json` (producción/default). Que se pegara a Wompi
sandbox o producción dependía únicamente del campo `isProduction` dentro del
JSON, no del flag de ambiente.

## 2. Comportamiento aprobado

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

## 3. Modelo de datos — estructura del JSON de configuración

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

`initialize()` aplica valores por defecto (`?? ''` para strings, `?? false`
para `isProduction`) de modo que un JSON al que le falte una clave **no rompa**
la carga ni deje toda la configuración vacía.

## 4. Contratos — getters expuestos por `FFDevEnvironmentValues`

| Getter | Tipo | Fuente JSON |
|--------|------|-------------|
| `privateKey` | String | `privateKey` |
| `publicKey` | String | `publicKey` |
| `isProduction` | bool | `isProduction` |
| `supabaseUrl` | String | `supabaseUrl` |
| `supabaseAnonKey` | String | `supabaseAnonKey` |
| `integrityKey` | String | `integrityKey` |
| `n8nWebhookUrl` | String | `n8nWebhookUrl` |

> Cambio incompatible: los getters `privatekey`/`publickey` (minúscula) pasan a
> `privateKey`/`publicKey`. Todos los consumidores deben usar los nuevos nombres.

## 5. Comportamiento por caso

| Caso | Entrada | Resultado esperado |
|------|---------|--------------------|
| Debug sin flag | `flutter run --debug` | Carga `environment_test.json` |
| Sandbox explícito | `--dart-define=ENVIRONMENT=Sandbox` | Carga `environment_sandbox.json` |
| Producción explícita | `--dart-define=ENVIRONMENT=Production` | Carga `environment.json` |
| Release sin flag | `flutter build --release` | Carga `environment.json` |
| JSON sin `n8nWebhookUrl` u otra clave | cualquier ambiente | No crashea; campo queda `''` / `false` |

## 6. Restricciones y reglas de negocio

- No se altera la lógica de pagos Wompi: la URL base (`production.wompi.co` vs.
  `sandbox.wompi.co`) sigue decidiéndose por `isProduction` dentro de cada JSON
  (`get_acceptance_token.dart`, `create_transaction.dart`).
- Los archivos `environment*.json` contienen secretos: permanecen en
  `.gitignore`, incluido el nuevo `environment_sandbox.json`.
- Se respeta el patrón FlutterFlow: solo se renombran getters y referencias; no
  se introduce nueva arquitectura.

## 7. Criterios de aceptación

- CA-01 — `ENVIRONMENT=Sandbox` carga `environment_sandbox.json`. ✅
- CA-02 — `ENVIRONMENT=Production` carga `environment.json`. ✅
- CA-03 — Sin flag en debug carga `environment_test.json`. ✅
- CA-04 — El proyecto compila tras renombrar getters (6 referencias ajustadas). ✅
- CA-05 — Un JSON sin alguna clave no provoca configuración vacía (fallbacks). ✅
- CA-06 — Generadores CI emiten claves camelCase + `n8nWebhookUrl`. ✅

## 8. Riesgos y supuestos

- Los `environment.json` / `environment_test.json` **locales** del desarrollador
  aún usan claves en minúscula y carecen de `n8nWebhookUrl`. Gracias a los
  fallbacks no crashean, pero `privateKey`/`publicKey` quedarán vacíos hasta que
  se regeneren con claves camelCase.
- Existía `assets/environment_values/environment.sandbox.json` (con punto) sin
  uso por el código; sus valores reales de Supabase sandbox se migraron al nuevo
  `environment_sandbox.json`. El archivo con punto queda obsoleto.

## 9. Pendiente del usuario (valores no asumibles)

- Completar `environment_sandbox.json` con las llaves Wompi de sandbox y el
  `n8nWebhookUrl`.
- Definir el secreto `N8N_WEBHOOK_URL` en CI si se usará en producción.
- Decidir si se elimina el obsoleto `environment.sandbox.json`.

## 10. Out of scope

- Migración de los `environment.json` / `environment_test.json` locales (los
  gestiona el desarrollador / CI fuera del repo).
- Cambios en la lógica de negocio de Wompi o Supabase.
