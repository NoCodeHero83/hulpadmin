import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'seleccionar_sub_categoria_widget.dart'
    show SeleccionarSubCategoriaWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SeleccionarSubCategoriaModel
    extends FlutterFlowModel<SeleccionarSubCategoriaWidget> {
  ///  State fields for stateful widgets in this component.

  Stream<List<SubcategoriasRow>>? listViewSupabaseStream;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
