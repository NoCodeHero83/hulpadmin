import '/backend/supabase/supabase.dart';
import '/components/notificacioneliminar_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'historial_servicios_widget.dart' show HistorialServiciosWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HistorialServiciosModel
    extends FlutterFlowModel<HistorialServiciosWidget> {
  ///  Local state fields for this component.

  List<VwSolicitudesServiciosCompletaRow> listaHistorial = [];
  void addToListaHistorial(VwSolicitudesServiciosCompletaRow item) =>
      listaHistorial.add(item);
  void removeFromListaHistorial(VwSolicitudesServiciosCompletaRow item) =>
      listaHistorial.remove(item);
  void removeAtIndexFromListaHistorial(int index) =>
      listaHistorial.removeAt(index);
  void insertAtIndexInListaHistorial(
          int index, VwSolicitudesServiciosCompletaRow item) =>
      listaHistorial.insert(index, item);
  void updateListaHistorialAtIndex(
          int index, Function(VwSolicitudesServiciosCompletaRow) updateFn) =>
      listaHistorial[index] = updateFn(listaHistorial[index]);

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Backend Call - Query Rows] action in HistorialServicios widget.
  List<VwSolicitudesServiciosCompletaRow>? listaProveedores;
  // Stores action output result for [Backend Call - Query Rows] action in HistorialServicios widget.
  List<VwSolicitudesServiciosCompletaRow>? listaUsuarios;
  // State field(s) for PaginatedDataTable widget.
  final paginatedDataTableController =
      FlutterFlowDataTableController<VwSolicitudesServiciosCompletaRow>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    paginatedDataTableController.dispose();
  }
}
