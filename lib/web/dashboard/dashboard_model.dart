import '/backend/supabase/supabase.dart';
import '/components/dropdown_proveedor_estado_widget.dart';
import '/components/dropdown_solicitud_estado_widget.dart';
import '/components/dropdown_soporte_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/web/menu/menu_widget.dart';
import 'dart:ui';
import '/index.dart';
import 'dashboard_widget.dart' show DashboardWidget;
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardModel extends FlutterFlowModel<DashboardWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for Menu component.
  late MenuModel menuModel;
  Stream<List<VwSolicitudesServiciosCompletaRow>>? containerSupabaseStream1;
  Stream<List<VwProfesionalesCompletoRow>>? containerSupabaseStream2;
  // Models for dropdownProveedorEstado dynamic component.
  late FlutterFlowDynamicModels<DropdownProveedorEstadoModel>
      dropdownProveedorEstadoModels;
  Stream<List<SoporteRow>>? containerSupabaseStream3;

  @override
  void initState(BuildContext context) {
    menuModel = createModel(context, () => MenuModel());
    dropdownProveedorEstadoModels =
        FlutterFlowDynamicModels(() => DropdownProveedorEstadoModel());
  }

  @override
  void dispose() {
    menuModel.dispose();
    dropdownProveedorEstadoModels.dispose();
  }
}
