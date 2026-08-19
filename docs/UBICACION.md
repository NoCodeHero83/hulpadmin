# Ubicación de las solicitudes

Estado a 2026-08-19. Cubre los puntos 2 y 3 del backlog. El punto 4 (captura
desde la app de clientes) queda pendiente y reutilizará lo mismo.

## Qué hay hoy

Una solicitud guarda **dos cosas distintas** que no compiten entre sí:

| Campo | Tipo | Para qué |
|---|---|---|
| `ubicacion` | `text`, obligatorio | La dirección que el proveedor **lee** |
| `latitud` / `longitud` | `numeric(10,7)`, opcionales | El punto al que **navega** |

La dirección en texto sigue siendo obligatoria. Las coordenadas son un extra:
si no están, todo funciona igual, solo que el enlace a Maps busca la dirección
como texto en vez de abrir un punto exacto.

Tres restricciones protegen el dato en la base (`REQ-008_coordenadas_solicitud.sql`):
rango válido de latitud, rango válido de longitud, y **o van las dos o no va
ninguna**. Media coordenada no ubica nada y rompería a quien asuma que si hay
latitud hay punto.

## Cómo se captura, sin clave de Google

El admin abre *Nueva solicitud* o *Editar*, y bajo el campo de dirección
encuentra **Ubicación exacta (opcional)**. Ahí pega lo que tenga:

- El enlace completo que copia de la barra del navegador en Google Maps.
- Un par de coordenadas: `4.710989, -74.072092`.
- Un enlace antiguo con `?q=` o `&ll=`, o un `geo:` de Android.

De un enlace de lugar se extrae el punto **real** del sitio, no el centro de la
vista del mapa, que puede estar desplazado decenas de metros.

**Los enlaces cortos (`maps.app.goo.gl`) no sirven.** Son un redirect que solo
se resuelve con una petición HTTP, y el navegador la bloquea por CORS. Es
justo lo que copia el botón *Compartir* del móvil, así que el campo lo detecta
y lo dice, en vez de fallar sin explicar nada. La salida es abrir ese enlace en
el navegador y copiar la dirección larga.

El campo avisa además cuando el punto cae fuera de Colombia, que casi siempre
significa que el par está invertido.

## Qué ve el proveedor

En la tarjeta del servicio, bajo la dirección:

- **Servicios entrantes** → *Buscar la dirección en Google Maps* / ver el sitio.
  Solo mostrar, no navegar: todavía no lo aceptó.
- **Servicios aceptados** → *Cómo llegar*, con indicaciones paso a paso.

Sin coordenadas el botón sigue apareciendo y busca la dirección escrita. Como
ninguna solicitud anterior a REQ-008 tiene punto, hoy ese es el único camino
que se ejecuta — no es un caso raro de respaldo.

El enlace es el universal de Google Maps, que **no lleva clave** y abre la app
nativa si está instalada.

## Cuando llegue la clave de Google Maps

Falta una clave de Google Cloud con facturación activa y estas APIs:
**Maps JavaScript**, **Places** y **Geocoding**.

Con ella se enciende el mapa interactivo y el autocompletado de direcciones.
Pasos:

1. Añadir `"googleMapsApiKey": "..."` a `assets/environment_values/environment.json`
   y a `environment_test.json`. `FFDevEnvironmentValues().tieneGoogleMaps` pasa
   a `true` solo.
2. Restringir la clave en Google Cloud por **referente HTTP** a `hulpweb.com` y
   al dominio de pruebas. Sin eso la clave es de quien mire el bundle: el
   JavaScript de una app web es público por definición.
3. `SelectorUbicacionWidget` ya trae el hueco: con clave pinta el mapa estático
   del punto. Sustituir esa imagen por el mapa arrastrable y añadir el campo de
   autocompletado. **El contrato hacia afuera no cambia** — quien lo usa solo
   conoce `onCambio`, así que `crear_solicitud` y `edicion_solicitud` no se
   tocan.

## Punto 4 — clientes

`hulp-usuarios` necesitará además `geolocator` y el permiso de ubicación con su
justificación (iOS ya declara `NSLocationWhenInUseUsageDescription`), más un
botón *usar mi ubicación actual*. Va **después** del mapa interactivo, no en
paralelo: el selector se diseña una vez y se reutiliza.

## Detalles que conviene no olvidar

- `lib/pages/solicitudes_copy/` en `talento-hulp` muestra la misma tarjeta pero
  **nadie navega ahí**. No se tocó. Si alguna vez se reactiva, le falta el
  enlace.
- El manifiesto de Android de `talento-hulp` necesitaba un bloque `<queries>`
  para poder entregarle el enlace a Google Maps. Con `targetSdk 36` y sin él,
  el botón no abre nada.
- La rama de test de Supabase (`ptafsiwlhxomgqmdmidf`) está **muy** desfasada:
  no tiene ni `ciudad_id`. La migración se ensayó contra producción dentro de
  una transacción con `rollback`, porque en test ni siquiera compila.
- El analizador de coordenadas tiene pruebas en
  `test/ubicacion_helpers_test.dart`. Si se toca, correrlas.
