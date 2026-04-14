import '/backend/supabase/supabase.dart';
import '/components/notificacion2_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'editar_proveedor_widget.dart' show EditarProveedorWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class EditarProveedorModel extends FlutterFlowModel<EditarProveedorWidget> {
  ///  Local state fields for this component.

  List<String> serviciosids = [];
  void addToServiciosids(String item) => serviciosids.add(item);
  void removeFromServiciosids(String item) => serviciosids.remove(item);
  void removeAtIndexFromServiciosids(int index) => serviciosids.removeAt(index);
  void insertAtIndexInServiciosids(int index, String item) =>
      serviciosids.insert(index, item);
  void updateServiciosidsAtIndex(int index, Function(String) updateFn) =>
      serviciosids[index] = updateFn(serviciosids[index]);

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for nombre widget.
  FocusNode? nombreFocusNode;
  TextEditingController? nombreTextController;
  String? Function(BuildContext, String?)? nombreTextControllerValidator;
  // State field(s) for apellido widget.
  FocusNode? apellidoFocusNode;
  TextEditingController? apellidoTextController;
  String? Function(BuildContext, String?)? apellidoTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    nombreFocusNode?.dispose();
    nombreTextController?.dispose();

    apellidoFocusNode?.dispose();
    apellidoTextController?.dispose();
  }
}
