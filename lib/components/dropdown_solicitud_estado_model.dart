import '/backend/api_requests/api_calls.dart';
import '/backend/supabase/supabase.dart';
import '/components/finalizar_servicio2_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dropdown_solicitud_estado_widget.dart'
    show DropdownSolicitudEstadoWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DropdownSolicitudEstadoModel
    extends FlutterFlowModel<DropdownSolicitudEstadoWidget> {
  ///  Local state fields for this component.

  List<String> opciones = [
    'entrantes',
    'aceptadas',
    'iniciadas',
    'en camino',
    'en proceso',
    'finalizadas',
    'canceladas',
    'reagendadas'
  ];
  void addToOpciones(String item) => opciones.add(item);
  void removeFromOpciones(String item) => opciones.remove(item);
  void removeAtIndexFromOpciones(int index) => opciones.removeAt(index);
  void insertAtIndexInOpciones(int index, String item) =>
      opciones.insert(index, item);
  void updateOpcionesAtIndex(int index, Function(String) updateFn) =>
      opciones[index] = updateFn(opciones[index]);

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
