import '/backend/supabase/supabase.dart';
import '/components/mensaje_chat_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'chat_usuario_proveedor_widget.dart' show ChatUsuarioProveedorWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatUsuarioProveedorModel
    extends FlutterFlowModel<ChatUsuarioProveedorWidget> {
  ///  State fields for stateful widgets in this component.

  Stream<List<MensajesChatRow>>? containerSupabaseStream;
  // Models for MensajeChat dynamic component.
  late FlutterFlowDynamicModels<MensajeChatModel> mensajeChatModels;

  @override
  void initState(BuildContext context) {
    mensajeChatModels = FlutterFlowDynamicModels(() => MensajeChatModel());
  }

  @override
  void dispose() {
    mensajeChatModels.dispose();
  }
}
