import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'finalizar_servicio2_widget.dart' show FinalizarServicio2Widget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FinalizarServicio2Model
    extends FlutterFlowModel<FinalizarServicio2Widget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<SolicitudesServicioRow>? validacion;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<MetodosPagoRow>? resultadosUsuarioMetodoPago;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UsuariosRow>? usuarioServicio2;
  // Stores action output result for [Custom Action - getAcceptanceToken] action in Button widget.
  dynamic? aceptaceToken2;
  // Stores action output result for [Custom Action - createTransaction] action in Button widget.
  dynamic? pago2;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<TarjetasGuardadasRow>? tarjeta;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UsuariosRow>? usuarioServicio;
  // Stores action output result for [Custom Action - getAcceptanceToken] action in Button widget.
  dynamic? aceptaceToken;
  // Stores action output result for [Custom Action - createTransaction] action in Button widget.
  dynamic? pago;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<SolicitudesServicioRow>? validacion25;
  // Stores action output result for [Backend Call - Query Rows] action in Button widget.
  List<UsuariosRow>? usuarioServicio33;

  /// Profesional con el que se cierra la solicitud.
  ///
  /// Sale del que ya tenia asignado o, si no tenia, de lo que el
  /// administrador elija en el selector. Nulo significa que se finaliza sin
  /// profesional, que es una opcion valida y no un error.
  String? profesionalResuelto;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
