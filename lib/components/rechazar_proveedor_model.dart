import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'rechazar_proveedor_widget.dart' show RechazarProveedorWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class RechazarProveedorModel extends FlutterFlowModel<RechazarProveedorWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for descripcion widget.
  FocusNode? descripcionFocusNode;
  TextEditingController? descripcionTextController;
  String? Function(BuildContext, String?)? descripcionTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    descripcionFocusNode?.dispose();
    descripcionTextController?.dispose();
  }
}
