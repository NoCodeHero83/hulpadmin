import '/backend/supabase/supabase.dart';
import '/components/mensaje_chat_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'chat_usuario_proveedor_model.dart';
export 'chat_usuario_proveedor_model.dart';

class ChatUsuarioProveedorWidget extends StatefulWidget {
  const ChatUsuarioProveedorWidget({
    super.key,
    required this.solicitud,
  });

  final VwSolicitudesServiciosCompletaRow? solicitud;

  @override
  State<ChatUsuarioProveedorWidget> createState() =>
      _ChatUsuarioProveedorWidgetState();
}

class _ChatUsuarioProveedorWidgetState
    extends State<ChatUsuarioProveedorWidget> {
  late ChatUsuarioProveedorModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatUsuarioProveedorModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChatsSolicitudRow>>(
      future: ChatsSolicitudTable().querySingleRow(
        queryFn: (q) => q.eqOrNull(
          'solicitud_id',
          widget!.solicitud?.solicitudId,
        ),
      ),
      builder: (context, snapshot) {
        // Customize what your widget looks like when it's loading.
        if (!snapshot.hasData) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  FlutterFlowTheme.of(context).primary,
                ),
              ),
            ),
          );
        }
        List<ChatsSolicitudRow> containerChatsSolicitudRowList = snapshot.data!;

        final containerChatsSolicitudRow =
            containerChatsSolicitudRowList.isNotEmpty
                ? containerChatsSolicitudRowList.first
                : null;

        return Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
          ),
          child: StreamBuilder<List<MensajesChatRow>>(
            stream: _model.containerSupabaseStream ??= SupaFlow.client
                .from("mensajes_chat")
                .stream(primaryKey: ['id'])
                .eqOrNull(
                  'chat_id',
                  containerChatsSolicitudRow?.id,
                )
                .order('enviado_en', ascending: true)
                .map((list) =>
                    list.map((item) => MensajesChatRow(item)).toList()),
            builder: (context, snapshot) {
              // Customize what your widget looks like when it's loading.
              if (!snapshot.hasData) {
                return Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                );
              }
              List<MensajesChatRow> containerMensajesChatRowList =
                  snapshot.data!;

              return Container(
                decoration: BoxDecoration(),
                child: Builder(
                  builder: (context) {
                    final conversaciones =
                        containerMensajesChatRowList.toList();

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: List.generate(conversaciones.length,
                            (conversacionesIndex) {
                          final conversacionesItem =
                              conversaciones[conversacionesIndex];
                          return wrapWithModel(
                            model: _model.mensajeChatModels.getModel(
                              conversacionesIndex.toString(),
                              conversacionesIndex,
                            ),
                            updateCallback: () => safeSetState(() {}),
                            child: MensajeChatWidget(
                              key: Key(
                                'Keywh2_${conversacionesIndex.toString()}',
                              ),
                              rolRemitente: valueOrDefault<String>(
                                conversacionesItem.rolRemitente,
                                'Sin rol',
                              ),
                              tipoMensaje: valueOrDefault<String>(
                                conversacionesItem.tipoMensaje,
                                'Sin tipo',
                              ),
                              urlArchivo: valueOrDefault<String>(
                                conversacionesItem.archivoUrl,
                                'Url Archivo',
                              ),
                              mensaje: valueOrDefault<String>(
                                conversacionesItem.contenido,
                                'Sin contenido',
                              ),
                              reciboID: valueOrDefault<String>(
                                conversacionesItem.reciboId,
                                'Sin recibo',
                              ),
                              urlImagen: valueOrDefault<String>(
                                conversacionesItem.archivoUrl,
                                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                              ),
                              fotoRemitente: () {
                                if (conversacionesItem.remitenteId ==
                                    widget!.solicitud?.usuarioId) {
                                  return valueOrDefault<String>(
                                    widget!.solicitud?.clienteFotoPerfil,
                                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                                  );
                                } else if (conversacionesItem.remitenteId ==
                                    widget!.solicitud?.profesionalId) {
                                  return valueOrDefault<String>(
                                    widget!.solicitud?.proveedorFotoPerfil,
                                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                                  );
                                } else {
                                  return 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
                                }
                              }(),
                              urlVideo: valueOrDefault<String>(
                                conversacionesItem.archivoUrl,
                                'https://assets.mixkit.co/videos/529/529-720.mp4',
                              ),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
