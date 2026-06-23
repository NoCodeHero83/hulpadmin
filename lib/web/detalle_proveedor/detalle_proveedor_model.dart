import '/flutter_flow/flutter_flow_util.dart';
import '/web/menu/menu_widget.dart';
import 'package:flutter/material.dart';
// REQ-002 v2.0.0 — helpers reutilizados de InformacionProveedorModel (v1.0.0)
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:file_saver/file_saver.dart';
import 'detalle_proveedor_widget.dart' show DetalleProveedorWidget;

class DetalleProveedorModel extends FlutterFlowModel<DetalleProveedorWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Menu component.
  late MenuModel menuModel;

  // REQ-002 v1.0.0: tracks which document is currently downloading
  // (key = downloadPrefix_proveedorId). Lógica idéntica a la versión pop-up.
  Map<String, bool> downloadingDocs = {};

  /// Opens [url] in the external browser / native app. (REQ-002 v1.0.0)
  Future<void> openDocument(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el documento');
    }
  }

  /// Downloads the file at [url] and saves it locally as [fileName].
  /// (REQ-002 v1.0.0)
  Future<void> downloadDocument(String url, String fileName) async {
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('Error al descargar: ${response.statusCode}');
    }
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: response.bodyBytes,
      mimeType: MimeType.other,
    );
  }

  /// REQ-002 v2.0.0: marca un teléfono usando el marcador nativo.
  /// Solo presentación — no toca la base de datos.
  Future<void> llamarTelefono(String telefono) async {
    final uri = Uri(scheme: 'tel', path: telefono.replaceAll(' ', ''));
    if (!await launchUrl(uri)) {
      throw Exception('No se pudo iniciar la llamada');
    }
  }

  @override
  void initState(BuildContext context) {
    menuModel = createModel(context, () => MenuModel());
  }

  @override
  void dispose() {
    menuModel.dispose();
  }
}
