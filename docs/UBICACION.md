# Ubicación de las solicitudes

Estado a 2026-08-22. Cubre los puntos 2 y 3 del backlog. El punto 4 (captura
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

## Con clave de Google Maps

Cuando `googleMapsApiKey` esta presente en el `environment.json`, el selector
anade dos cosas encima del campo de pegar, que **no desaparece**: sigue ahi,
plegado, porque es la salida cuando la clave caduca, se agota la cuota o el
mapa no carga.

- **Buscador de direcciones** (Places API New). Sesgado a Colombia. Al elegir
  una sugerencia se fijan el punto y la direccion a la vez.
- **Mapa interactivo**. Un clic fija el punto; el marcador se puede arrastrar
  para afinar. En ambos casos se consulta la direccion de ese punto y se
  rellena el campo de arriba, para que el texto no contradiga al punto.

Se hizo con interoperabilidad directa contra la API de JavaScript
(`lib/flutter_flow/google_maps_web.dart`) en vez de `google_maps_flutter_web`,
para controlar el Map ID y no anadir dependencias pesadas.

### Detalles que costaron un rato

- **Places API (New), no la antigua.** La antigua **no manda cabeceras CORS** y
  el navegador la bloquea. Geocoding si las manda, por eso ese va por REST
  tambien y no hace falta interoperabilidad para la geocodificacion inversa.
- **No vale el primer resultado de la geocodificacion inversa.** Google ordena
  por precision geometrica, no por utilidad: para muchos puntos el primero es
  un *plus code* (`67P7PVQJ+X2`) y el segundo una calle con numero. Se prefiere
  lo que tenga portal. Ver `elegirMejorDireccion`.
- **Las direcciones vienen con niveles repetidos** («Bogota, D.C., Bogota,
  Bogota, D.C., Colombia»): cada uno viene de un nivel administrativo distinto.
  `limpiarDireccion` conserva la primera aparicion de cada tramo.
- **El mapa se importa condicionalmente.** `flutter test` corre en la VM, donde
  `package:web` y `dart:ui_web` no existen; importar la implementacion real
  desde el selector reventaba toda la bateria con errores de un paquete de
  terceros. `mapa_punto_widget.dart` elige entre la real y un sustituto.
- **El SDK minimo subio a 3.3** (`extension type`). El `>=3.0.0` que traia
  FlutterFlow ya no reflejaba la realidad.
- **Token de sesion en el autocompletado.** Google cobra por sesion, no por
  pulsacion, siempre que todas las peticiones lleven el mismo token y se cierre
  con un detalle de lugar. Sin eso, cada tecla se factura aparte.

### Banco de pruebas

El selector vive dentro de un dialogo detras del login, asi que para mirarlo
habia que entrar con una cuenta de administrador contra una base real. Hay un
punto de entrada suelto:

```
flutter run -d chrome -t lib/dev/demo_ubicacion.dart --dart-define=ENVIRONMENT=Test
```

## Poner la clave

Falta una clave propia de Google Cloud con facturacion activa y estas APIs:
**Maps JavaScript**, **Places (New)**, **Geocoding** y **Maps Static**.

1. Anadir `"googleMapsApiKey"` y `"googleMapsMapId"` a
   `assets/environment_values/environment.json`.
2. Restringirla en Google Cloud por **referente HTTP** a `hulpweb.com` y al
   dominio de pruebas. El JavaScript de una app web es publico por definicion:
   lo que protege la clave es la restriccion, no el secreto.
3. Poner tope de cuota diaria por API y una alerta de presupuesto.

⚠️ **Todo lo que este en `assets/environment_values/` viaja en el bundle**,
incluido `environment_test.json`, que ni se carga en produccion. Cualquiera
puede descargarlo desde el dominio. No meter ahi nada que no pueda ser publico.

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
