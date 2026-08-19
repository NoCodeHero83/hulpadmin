import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/ubicacion_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Captura del punto exacto de una solicitud.
///
/// Se monta DEBAJO del campo de direccion, no lo reemplaza: la direccion
/// escrita sigue siendo lo que el proveedor lee, y el punto es para navegar.
///
/// Funciona sin clave de Google Maps. El admin pega el enlace que copia de
/// Maps —o el par de coordenadas— y de ahi se extrae el punto. Cuando la clave
/// exista, `FFDevEnvironmentValues().tieneGoogleMaps` pasa a true y este mismo
/// componente puede montar el mapa interactivo sin tocar a quien lo usa: el
/// contrato hacia afuera es solo `onCambio`.
class SelectorUbicacionWidget extends StatefulWidget {
  const SelectorUbicacionWidget({
    super.key,
    required this.onCambio,
    this.coordenadasIniciales,
    this.direccionActual,
    this.etiqueta = 'Ubicación exacta (opcional)',
  });

  /// Se dispara con el punto validado, o con null cuando se borra o no se
  /// puede leer. Quien lo use debe tratar el null como "sin coordenadas",
  /// nunca como "no cambio nada".
  final ValueChanged<Coordenadas?> onCambio;

  /// Punto ya guardado, para el formulario de edicion.
  final Coordenadas? coordenadasIniciales;

  /// Direccion escrita, solo para el enlace de respaldo cuando no hay punto.
  final String Function()? direccionActual;

  final String etiqueta;

  @override
  State<SelectorUbicacionWidget> createState() =>
      _SelectorUbicacionWidgetState();
}

class _SelectorUbicacionWidgetState extends State<SelectorUbicacionWidget> {
  late final TextEditingController _controlador;
  Coordenadas? _punto;
  String? _error;
  bool _avisoFueraDeColombia = false;

  @override
  void initState() {
    super.initState();
    _punto = widget.coordenadasIniciales;
    _avisoFueraDeColombia = _punto?.pareceFueraDeColombia ?? false;
    // Si ya hay punto guardado se muestra en el campo, para que se vea que
    // esta puesto y se pueda corregir sin tener que borrarlo a ciegas.
    _controlador = TextEditingController(text: _punto?.formateadas ?? '');

    // Se le avisa al padre del punto de partida. Sin esto, en el formulario de
    // edicion abrir y guardar sin tocar la ubicacion la borraria: el padre
    // arrancaria en null y escribiria null. Va en post-frame porque el padre
    // suele estar todavia construyendose.
    if (_punto != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onCambio(_punto);
      });
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _analizar(String valor) {
    final resultado = analizarUbicacion(valor);

    setState(() {
      _punto = resultado.coordenadas;
      _error = resultado.error;
      _avisoFueraDeColombia = resultado.coordenadas?.pareceFueraDeColombia ?? false;
    });

    // El padre se entera tanto del punto como del borrado. Un texto invalido
    // cuenta como "sin punto": mas vale guardar nada que guardar basura.
    widget.onCambio(resultado.coordenadas);
  }

  Future<void> _pegarDelPortapapeles() async {
    final datos = await Clipboard.getData(Clipboard.kTextPlain);
    final texto = datos?.text?.trim() ?? '';
    if (texto.isEmpty) return;
    _controlador.text = texto;
    _analizar(texto);
  }

  void _limpiar() {
    _controlador.clear();
    setState(() {
      _punto = null;
      _error = null;
      _avisoFueraDeColombia = false;
    });
    widget.onCambio(null);
  }

  Future<void> _abrirEnMaps() async {
    final url = urlGoogleMaps(
      latitud: _punto?.latitud,
      longitud: _punto?.longitud,
      direccion: widget.direccionActual?.call(),
    );
    if (url == null) return;
    await launchURL(url);
  }

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final direccion = widget.direccionActual?.call().trim() ?? '';
    final puedeAbrirPorDireccion = _punto == null && direccion.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.etiqueta,
          style: tema.bodyMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.normal),
            fontSize: 16.0,
            letterSpacing: 0.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(height: 8.0),
        TextFormField(
          controller: _controlador,
          onChanged: _analizar,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Pega el enlace de Google Maps o «4.710989, -74.072092»',
            hintStyle: tema.labelMedium.override(
              font: GoogleFonts.inter(),
              color: Color(0xFF8A8A8A),
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
            prefixIcon: Icon(
              Icons.place_outlined,
              size: 20.0,
              color: _punto != null ? tema.primary : Color(0xFF8A8A8A),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Pegar',
                  icon: Icon(Icons.content_paste_rounded, size: 18.0),
                  onPressed: _pegarDelPortapapeles,
                ),
                if (_controlador.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Quitar la ubicación',
                    icon: Icon(Icons.close_rounded, size: 18.0),
                    onPressed: _limpiar,
                  ),
              ],
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: tema.alternate, width: 0.5),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: tema.alternate, width: 0.5),
              borderRadius: BorderRadius.circular(8.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: tema.error, width: 0.5),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: tema.error, width: 0.5),
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Color(0xFFFBFAF9),
          ),
          style: tema.bodyMedium.override(
            font: GoogleFonts.inter(),
            fontSize: 15.0,
            letterSpacing: 0.0,
          ),
          cursorColor: tema.primaryText,
        ),
        SizedBox(height: 6.0),
        if (_error != null)
          _Aviso(
            icono: Icons.error_outline_rounded,
            color: tema.error,
            texto: _error!,
          ),
        if (_punto != null) ...[
          _Aviso(
            icono: Icons.check_circle_outline_rounded,
            color: tema.primary,
            texto: 'Punto guardado: ${_punto!.formateadas}',
            accion: _AccionAviso('Ver en Maps', _abrirEnMaps),
          ),
          if (_avisoFueraDeColombia)
            _Aviso(
              icono: Icons.warning_amber_rounded,
              color: Color(0xFFB26A00),
              texto: 'Ese punto cae fuera de Colombia. Verifica que la '
                  'latitud y la longitud no estén invertidas.',
            ),
        ],
        if (_punto == null && _error == null)
          _Aviso(
            icono: Icons.info_outline_rounded,
            color: Color(0xFF8A8A8A),
            texto: puedeAbrirPorDireccion
                ? 'Sin punto exacto. El proveedor verá la dirección escrita y '
                    'la buscará en Maps como texto.'
                : 'Sin punto exacto. Opcional, pero ayuda al proveedor a llegar.',
            accion: puedeAbrirPorDireccion
                ? _AccionAviso('Buscar la dirección', _abrirEnMaps)
                : null,
          ),
        // Rastro para cuando llegue la clave: aqui va el mapa interactivo.
        if (FFDevEnvironmentValues().tieneGoogleMaps && _punto != null)
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                urlMapaEstatico(
                  latitud: _punto!.latitud,
                  longitud: _punto!.longitud,
                  claveApi: FFDevEnvironmentValues().googleMapsApiKey,
                )!,
                height: 150.0,
                width: double.infinity,
                fit: BoxFit.cover,
                // Una clave mal configurada devuelve una imagen de error de
                // Google; que no rompa el formulario.
                errorBuilder: (_, __, ___) => SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }
}

class _AccionAviso {
  const _AccionAviso(this.texto, this.alPulsar);
  final String texto;
  final Future<void> Function() alPulsar;
}

class _Aviso extends StatelessWidget {
  const _Aviso({
    required this.icono,
    required this.color,
    required this.texto,
    this.accion,
  });

  final IconData icono;
  final Color color;
  final String texto;
  final _AccionAviso? accion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 6.0, 0.0),
            child: Icon(icono, size: 16.0, color: color),
          ),
          Expanded(
            child: Text(
              texto,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: color,
                    fontSize: 13.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          if (accion != null)
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
              child: InkWell(
                onTap: () => accion!.alPulsar(),
                child: Text(
                  accion!.texto,
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        color: FlutterFlowTheme.of(context).primary,
                        fontSize: 13.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
