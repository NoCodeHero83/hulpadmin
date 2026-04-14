import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'meta_model.dart';
export 'meta_model.dart';

class MetaWidget extends StatefulWidget {
  const MetaWidget({super.key});

  static String routeName = 'Meta';
  static String routePath = '/meta';

  @override
  State<MetaWidget> createState() => _MetaWidgetState();
}

class _MetaWidgetState extends State<MetaWidget> {
  late MetaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MetaModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.appVersions = await AppVersionTable().queryRows(
        queryFn: (q) => q,
      );
      await AppVersionTable().update(
        data: {
          'Meta': (_model.appVersions!.firstOrNull!.meta!) + 1,
        },
        matchingRows: (rows) => rows.eqOrNull(
          'id',
          _model.appVersions?.firstOrNull?.id,
        ),
      );
      if (isiOS == true) {
        await launchURL(_model.appVersions!.firstOrNull!.urlUsuariosIOS!);
      } else {
        await launchURL(_model.appVersions!.firstOrNull!.urlUsuariosPlayStore!);
      }
    });

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
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 54.0,
            icon: FaIcon(
              FontAwesomeIcons.angleLeft,
              color: Color(0xFF7C766C),
              size: 24.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          actions: [],
          centerTitle: true,
          elevation: 0.1,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [],
          ),
        ),
      ),
    );
  }
}
