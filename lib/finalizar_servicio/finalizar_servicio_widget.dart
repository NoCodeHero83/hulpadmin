import '/components/finalizar_servicio2_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'finalizar_servicio_model.dart';
export 'finalizar_servicio_model.dart';

class FinalizarServicioWidget extends StatefulWidget {
  const FinalizarServicioWidget({
    super.key,
    required this.idservicio,
  });

  final String? idservicio;

  static String routeName = 'FinalizarServicio';
  static String routePath = '/finalizarServicio';

  @override
  State<FinalizarServicioWidget> createState() =>
      _FinalizarServicioWidgetState();
}

class _FinalizarServicioWidgetState extends State<FinalizarServicioWidget> {
  late FinalizarServicioModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FinalizarServicioModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: wrapWithModel(
              model: _model.finalizarServicio2Model,
              updateCallback: () => safeSetState(() {}),
              child: FinalizarServicio2Widget(
                servicioId: widget!.idservicio!,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
