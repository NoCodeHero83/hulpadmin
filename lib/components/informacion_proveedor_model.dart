import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import 'informacion_proveedor_widget.dart' show InformacionProveedorWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// REQ-002
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:file_saver/file_saver.dart';

class InformacionProveedorModel
    extends FlutterFlowModel<InformacionProveedorWidget> {
  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();

  // REQ-002: tracks which document is currently downloading (key = downloadPrefix_proveedorId)
  Map<String, bool> downloadingDocs = {};

  /// Opens [url] in the external browser / native app.
  Future<void> openDocument(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el documento');
    }
  }

  /// Downloads the file at [url] and saves it locally as [fileName].
  Future<void> downloadDocument(String url, String fileName) async {
    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('Error al descargar: ${response.statusCode}');
    }
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: response.bodyBytes,
      mimeType: MimeType.other,
    );
  }

  // State field(s) for tipoDocumento widget.
  String? tipoDocumentoValue;
  FormFieldController<String>? tipoDocumentoValueController;
  // State field(s) for nroDocumento widget.
  FocusNode? nroDocumentoFocusNode;
  TextEditingController? nroDocumentoTextController;
  String? Function(BuildContext, String?)? nroDocumentoTextControllerValidator;
  String? _nroDocumentoTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Ingresa la dirección';
    }

    return null;
  }

  // State field(s) for pais widget.
  String? paisValue;
  FormFieldController<String>? paisValueController;
  // State field(s) for telefono widget.
  FocusNode? telefonoFocusNode;
  TextEditingController? telefonoTextController;
  String? Function(BuildContext, String?)? telefonoTextControllerValidator;
  String? _telefonoTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Ingresa el teléfono';
    }

    return null;
  }

  // State field(s) for nombre widget.
  FocusNode? nombreFocusNode1;
  TextEditingController? nombreTextController1;
  String? Function(BuildContext, String?)? nombreTextController1Validator;
  String? _nombreTextController1Validator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Ingresa el nombre';
    }

    return null;
  }

  // State field(s) for nombre widget.
  FocusNode? nombreFocusNode2;
  TextEditingController? nombreTextController2;
  String? Function(BuildContext, String?)? nombreTextController2Validator;
  // State field(s) for entidad widget.
  String? entidadValue;
  FormFieldController<String>? entidadValueController;
  // State field(s) for tipocuenta widget.
  String? tipocuentaValue;
  FormFieldController<String>? tipocuentaValueController;
  // State field(s) for numerocuenta widget.
  FocusNode? numerocuentaFocusNode;
  TextEditingController? numerocuentaTextController;
  String? Function(BuildContext, String?)? numerocuentaTextControllerValidator;
  String? _numerocuentaTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Ingresa el número de cuenta';
    }

    return null;
  }

  // State field(s) for rutnit widget.
  FocusNode? rutnitFocusNode;
  TextEditingController? rutnitTextController;
  String? Function(BuildContext, String?)? rutnitTextControllerValidator;
  String? _rutnitTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Ingresa el RUT / NIT';
    }

    return null;
  }

  @override
  void initState(BuildContext context) {
    nroDocumentoTextControllerValidator = _nroDocumentoTextControllerValidator;
    telefonoTextControllerValidator = _telefonoTextControllerValidator;
    nombreTextController1Validator = _nombreTextController1Validator;
    numerocuentaTextControllerValidator = _numerocuentaTextControllerValidator;
    rutnitTextControllerValidator = _rutnitTextControllerValidator;
  }

  @override
  void dispose() {
    nroDocumentoFocusNode?.dispose();
    nroDocumentoTextController?.dispose();

    telefonoFocusNode?.dispose();
    telefonoTextController?.dispose();

    nombreFocusNode1?.dispose();
    nombreTextController1?.dispose();

    nombreFocusNode2?.dispose();
    nombreTextController2?.dispose();

    numerocuentaFocusNode?.dispose();
    numerocuentaTextController?.dispose();

    rutnitFocusNode?.dispose();
    rutnitTextController?.dispose();
  }
}
