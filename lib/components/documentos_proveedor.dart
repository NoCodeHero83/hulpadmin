import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '/backend/supabase/storage/storage.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Todo lo que las dos pantallas de documentos necesitan compartir.
///
/// El detalle del proveedor y el pop-up de registro enseñan lo mismo con dos
/// copias del mismo código. Ya salió caro una vez: cuando las cédulas y las
/// cuentas bancarias pasaron al bucket privado, hubo que parchear las dos por
/// separado, y su propio commit lo dejó escrito. Aquí vive una sola versión.
///
/// Nota sobre las URL: los documentos de identidad y bancarios se guardan como
/// **ruta** del bucket privado, no como URL. Hay que firmarlos antes de
/// abrirlos. Las certificaciones y los registros antiguos siguen siendo URLs
/// públicas. `isPrivateStoragePath` distingue los dos casos, así que quien
/// llame no necesita saber cuál es cuál.

/// Firma la ruta si es privada; si ya es una URL pública, la devuelve tal cual.
/// Devuelve null cuando no se puede acceder, para que quien llame lo trate
/// como documento ausente en vez de romper.
Future<String?> resolverUrlDocumento(String? valor) async {
  if (valor == null || valor.isEmpty) return null;
  if (!isPrivateStoragePath(valor)) return valor;
  try {
    return await signedUrlForPrivatePath(valor);
  } catch (_) {
    // Sin permiso o ruta inexistente: se trata como documento ausente.
    return null;
  }
}

/// El nombre del archivo, sin la ruta ni los parámetros de la URL firmada.
String nombreArchivoDocumento(String? url) {
  if (url == null || url.isEmpty) return 'Sin archivo';
  try {
    final segs = Uri.parse(url).pathSegments;
    return segs.isNotEmpty ? segs.last : 'Sin archivo';
  } catch (_) {
    return 'Sin archivo';
  }
}

/// Si el archivo se puede pintar. Los PDF y ofimáticos, no.
bool esImagenDocumento(String url) {
  final ext = url.toLowerCase().split('?').first.split('.').last;
  return const ['jpg', 'jpeg', 'png', 'webp'].contains(ext);
}

Widget placeholderPdf() => Container(
      color: const Color(0xFFEAEAEA),
      child: const Center(
        child: Icon(Icons.picture_as_pdf_outlined,
            size: 40, color: Color(0xFFD32F2F)),
      ),
    );

Widget placeholderVacio(BuildContext context) => Container(
      color: const Color(0xFFEAEAEA),
      child: Center(
        child: Icon(Icons.insert_drive_file_outlined,
            size: 40, color: FlutterFlowTheme.of(context).secondaryText),
      ),
    );

/// Fila de tarjetas de documento, rellenando los huecos del final con
/// espaciadores invisibles para que no se estiren las que sí hay.
Widget filaDocumentos(List<Widget> tarjetas) {
  final hijos = <Widget>[];
  for (var i = 0; i < tarjetas.length; i++) {
    hijos.add(Expanded(child: tarjetas[i]));
    if (i < tarjetas.length - 1) hijos.add(const SizedBox(width: 12));
  }
  return Row(crossAxisAlignment: CrossAxisAlignment.start, children: hijos);
}

Future<void> abrirDocumento(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('No se pudo abrir el documento');
  }
}

Future<void> descargarDocumento(String url, String nombreArchivo) async {
  final respuesta =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
  if (respuesta.statusCode != 200) {
    throw Exception('Error al descargar: ${respuesta.statusCode}');
  }
  await FileSaver.instance.saveFile(
    name: nombreArchivo,
    bytes: respuesta.bodyBytes,
    mimeType: MimeType.other,
  );
}

/// Tarjeta de un documento: vista previa, nombre, estado y las acciones.
///
/// Gestiona ella misma el «descargando…», que antes vivía en el modelo de cada
/// pantalla. Así se puede usar desde cualquier sitio sin arrastrar estado.
class TarjetaDocumento extends StatefulWidget {
  const TarjetaDocumento({
    super.key,
    required this.label,
    required this.url,
    required this.prefijoDescarga,
    this.proveedorId,
    this.fechaSubida,
  });

  final String label;
  final String? url;

  /// Con qué nombre se guarda al descargar: `cedula_<id>.jpg`.
  final String prefijoDescarga;
  final String? proveedorId;
  final DateTime? fechaSubida;

  @override
  State<TarjetaDocumento> createState() => _TarjetaDocumentoState();
}

class _TarjetaDocumentoState extends State<TarjetaDocumento> {
  bool _descargando = false;

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    final url = widget.url;
    final hayUrl = url != null && url.isNotEmpty;
    final archivo = nombreArchivoDocumento(url);

    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      decoration: BoxDecoration(
        color: tema.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tema.tertiary),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: tema.bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                fontSize: 14,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: tema.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: !hayUrl
                  ? placeholderVacio(context)
                  : !esImagenDocumento(url)
                      ? placeholderPdf()
                      : FutureBuilder<String?>(
                          future: resolverUrlDocumento(url),
                          builder: (context, snap) {
                            if (snap.connectionState != ConnectionState.done) {
                              return placeholderVacio(context);
                            }
                            final resuelta = snap.data;
                            if (resuelta == null) return placeholderPdf();
                            return Image.network(resuelta,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => placeholderPdf());
                          },
                        ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  archivo,
                  overflow: TextOverflow.ellipsis,
                  style: tema.bodySmall.override(
                    font: GoogleFonts.inter(),
                    fontSize: 11,
                    letterSpacing: 0,
                    color: tema.secondaryText,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (hayUrl)
                const Icon(Icons.check_circle,
                    size: 16, color: Color(0xFF43A047))
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'No cargado',
                    style: tema.bodySmall.override(
                      font: GoogleFonts.inter(),
                      fontSize: 11,
                      letterSpacing: 0,
                      color: tema.secondaryText,
                    ),
                  ),
                ),
            ],
          ),
          if (widget.fechaSubida != null) ...[
            const SizedBox(height: 4),
            Text(
              'Subido el ${DateFormat('dd/MM/yyyy').format(widget.fechaSubida!)}',
              style: tema.bodySmall.override(
                font: GoogleFonts.inter(),
                fontSize: 11,
                letterSpacing: 0,
                color: tema.secondaryText,
              ),
            ),
          ],
          if (hayUrl) ...[
            const SizedBox(height: 8),
            _boton(
              context,
              icono: const Icon(Icons.remove_red_eye_outlined, size: 16),
              texto: 'Ver documento',
              onTap: () async {
                try {
                  // Con el bucket privado la ruta no se puede abrir
                  // directamente: hay que firmarla antes.
                  final resuelta = await resolverUrlDocumento(url);
                  if (resuelta == null) {
                    throw 'No se pudo acceder al documento';
                  }
                  await abrirDocumento(resuelta);
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('No se pudo abrir el documento'),
                    ));
                  }
                }
              },
            ),
            const SizedBox(height: 6),
            _boton(
              context,
              icono: _descargando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined, size: 16),
              texto: _descargando ? 'Descargando...' : 'Descargar',
              onTap: _descargando ? null : () => _descargar(archivo),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _descargar(String archivo) async {
    final ext = archivo.contains('.') ? archivo.split('.').last : 'bin';
    final nombre =
        '${widget.prefijoDescarga}_${widget.proveedorId ?? 'doc'}.$ext';
    setState(() => _descargando = true);
    try {
      final resuelta = await resolverUrlDocumento(widget.url);
      if (resuelta == null) throw 'No se pudo acceder al documento';
      await descargarDocumento(resuelta, nombre);
    } catch (e) {
      if (mounted) {
        final msg = e.toString().toLowerCase().contains('timeout')
            ? 'La descarga tardó demasiado. Intente nuevamente.'
            : 'Error al descargar el documento';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _descargando = false);
    }
  }

  Widget _boton(BuildContext context,
      {required Widget icono,
      required String texto,
      required VoidCallback? onTap}) {
    final tema = FlutterFlowTheme.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: icono,
        label: Text(texto),
        style: OutlinedButton.styleFrom(
          foregroundColor: tema.primary,
          side: BorderSide(color: tema.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 8),
          textStyle: GoogleFonts.inter(fontSize: 13),
        ),
        onPressed: onTap,
      ),
    );
  }
}

/// Estado vacío de una sección de documentos: icono, qué falta y cuándo
/// aparecerá. Se usa igual en las dos pantallas para que digan lo mismo.
class SeccionVacia extends StatelessWidget {
  const SeccionVacia({
    super.key,
    required this.icono,
    required this.titulo,
    required this.detalle,
  });

  final IconData icono;
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final tema = FlutterFlowTheme.of(context);
    // Ancho completo: sin esto la caja se encoge hasta el texto más largo, y
    // si el padre la alinea a la izquierda el contenido queda centrado
    // respecto a la caja y no respecto a la sección. Se notaba: «Referencias»
    // salía desplazado frente a las otras dos secciones.
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(icono, size: 40, color: tema.secondaryText),
            const SizedBox(height: 10),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: tema.bodyMedium.override(
                font: GoogleFonts.inter(fontWeight: FontWeight.w600),
                fontSize: 14,
                letterSpacing: 0,
                color: tema.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detalle,
              textAlign: TextAlign.center,
              style: tema.bodySmall.override(
                font: GoogleFonts.inter(),
                fontSize: 12,
                letterSpacing: 0,
                color: tema.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
