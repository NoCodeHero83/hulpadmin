import '/components/finalizar_servicio2_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'finalizar_servicio_widget.dart' show FinalizarServicioWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FinalizarServicioModel extends FlutterFlowModel<FinalizarServicioWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for FinalizarServicio2 component.
  late FinalizarServicio2Model finalizarServicio2Model;

  @override
  void initState(BuildContext context) {
    finalizarServicio2Model =
        createModel(context, () => FinalizarServicio2Model());
  }

  @override
  void dispose() {
    finalizarServicio2Model.dispose();
  }
}
