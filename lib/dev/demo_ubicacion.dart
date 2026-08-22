// Banco de pruebas del selector de ubicación. NO entra en la app.
//
// Existe porque el selector vive dentro de un diálogo del panel de solicitudes,
// detrás del login: para mirar si el mapa carga había que entrar con una cuenta
// de administrador contra una base real. Aquí se monta solo, sin sesión.
//
//   flutter run -d chrome -t lib/dev/demo_ubicacion.dart
//   flutter build web -t lib/dev/demo_ubicacion.dart
//
// Lo que hay que comprobar: que el mapa se pinte, que el marcador se pueda
// arrastrar, que el buscador sugiera direcciones y que al fijar un punto se
// rellene la dirección de abajo.
import 'package:flutter/material.dart';

import '/components/selector_ubicacion_widget.dart';
import '/environment_values.dart';
import '/flutter_flow/ubicacion_helpers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FFDevEnvironmentValues().initialize();
  runApp(const _DemoApp());
}

class _DemoApp extends StatelessWidget {
  const _DemoApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFEFF3ED),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: 460.0,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const _Formulario(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Formulario extends StatefulWidget {
  const _Formulario();

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  final _direccion = TextEditingController();
  Coordenadas? _punto;

  @override
  void dispose() {
    _direccion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final env = FFDevEnvironmentValues();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Selector de ubicación',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4.0),
        Text(
          'clave: ${env.tieneGoogleMaps ? "sí" : "NO"} · '
          'mapId: ${env.googleMapsMapId ?? "ninguno"}',
          style: const TextStyle(fontSize: 12.0, color: Color(0xFF8A8A8A)),
        ),
        const SizedBox(height: 16.0),
        const Text('Dirección *'),
        const SizedBox(height: 6.0),
        TextField(
          controller: _direccion,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            hintText: 'Digite la dirección',
          ),
        ),
        const SizedBox(height: 16.0),
        SelectorUbicacionWidget(
          direccionActual: () => _direccion.text,
          onCambio: (p) => setState(() => _punto = p),
          onDireccionSugerida: (v) => setState(() => _direccion.text = v),
        ),
        const SizedBox(height: 20.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10.0),
          color: const Color(0xFFF3F3F3),
          child: Text(
            'lo que se guardaría:\n'
            "  ubicacion = '${_direccion.text}'\n"
            '  latitud   = ${_punto?.latitud}\n'
            '  longitud  = ${_punto?.longitud}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12.0),
          ),
        ),
      ],
    );
  }
}
