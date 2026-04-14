import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'dropdown_soporte_widget.dart' show DropdownSoporteWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DropdownSoporteModel extends FlutterFlowModel<DropdownSoporteWidget> {
  ///  Local state fields for this component.

  List<String> opciones = [
    'completado',
    'escalado',
    'pendiente',
    'rechazado',
    'en proceso'
  ];
  void addToOpciones(String item) => opciones.add(item);
  void removeFromOpciones(String item) => opciones.remove(item);
  void removeAtIndexFromOpciones(int index) => opciones.removeAt(index);
  void insertAtIndexInOpciones(int index, String item) =>
      opciones.insert(index, item);
  void updateOpcionesAtIndex(int index, Function(String) updateFn) =>
      opciones[index] = updateFn(opciones[index]);

  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - Update Row(s)] action in Row widget.
  List<SoporteRow>? isSuccesUpdate;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
