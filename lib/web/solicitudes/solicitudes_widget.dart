import '/backend/supabase/supabase.dart';
import '/components/crear_solicitud_widget.dart';
import '/components/detalle_solicitud_widget.dart';
import '/components/dropdown_solicitud_estado_widget.dart';
import '/components/edicion_solicitud_widget.dart';
import '/components/hulp_loading_indicator.dart';
import '/components/notificacion2_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import '/flutter_flow/dialog_helpers.dart';
import '/web/menu/menu_widget.dart';
import '/web/solicitudes/solicitudes_filter_bar.dart';
import '/web/solicitudes/solicitudes_data_table.dart';
import '/index.dart';
import 'dart:async';
import 'package:aligned_dialog/aligned_dialog.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'solicitudes_model.dart';
export 'solicitudes_model.dart';

class SolicitudesWidget extends StatefulWidget {
  const SolicitudesWidget({super.key});

  static String routeName = 'Solicitudes';
  static String routePath = '/solicitudes';

  @override
  State<SolicitudesWidget> createState() => _SolicitudesWidgetState();
}

class _SolicitudesWidgetState extends State<SolicitudesWidget> {
  late SolicitudesModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription<List<Map<String, dynamic>>>? _solicitudesTriggerSub;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SolicitudesModel());
    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();
    _model.textFieldFocusNode!.addListener(() async {
      safeSetState(() => _model.requestCompleter = null);
      await _model.waitForRequestCompleted();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));

    _solicitudesTriggerSub = SupaFlow.client
        .from('solicitudes_servicio')
        .stream(primaryKey: ['id'])
        .listen((_) {
      if (!mounted) return;
      safeSetState(() {
        _model.containerSupabaseStream = null;
        _model.requestCompleter = null;
      });
    });
  }

  @override
  void dispose() {
    _solicitudesTriggerSub?.cancel();
    _model.dispose();
    super.dispose();
  }

  // -- Filter logic -----------------------------------------------------------

  List<VwSolicitudesServiciosCompletaRow> _applyFilters({
    required List<VwSolicitudesServiciosCompletaRow> allData,
    required List<VwSolicitudesServiciosCompletaRow> estadoFiltered,
    required List<VwSolicitudesServiciosCompletaRow> categoriaFiltered,
    required List<VwSolicitudesServiciosCompletaRow> searchFiltered,
  }) {
    final hasText =
        _model.textController.text != null && _model.textController.text != '';
    final hasEstado =
        _model.dropDownValue1 != null && _model.dropDownValue1 != '';
    final hasCategoria =
        _model.dropDownValue2 != null && _model.dropDownValue2 != '';

    // Step 1: base filter
    List<VwSolicitudesServiciosCompletaRow> result;
    if (hasText && hasEstado && hasCategoria) {
      result = searchFiltered
          .where((e) =>
              _model.dropDownValue1 == e.estadoSolicitud &&
              _model.dropDownValue2 == e.categoriaNombre)
          .toList();
    } else if (hasEstado && hasCategoria) {
      result = categoriaFiltered
          .where((e) => _model.dropDownValue1 == e.estadoSolicitud)
          .toList();
    } else if (hasEstado) {
      result = categoriaFiltered;
    } else if (hasCategoria) {
      result = estadoFiltered;
    } else if (hasText) {
      result = searchFiltered;
    } else {
      result = allData;
    }

    // Step 2: date range filter
    if (_model.dateStart != null && _model.dateEnd != null) {
      result = result.where((e) {
        if (e.fecha == null) return false;
        return !e.fecha!.isBefore(_model.dateStart!) &&
            !e.fecha!.isAfter(_model.dateEnd!);
      }).toList();
    }

    // Step 3: sort
    final desc = _model.dropDownOrdenValue == 'Recientes primero';
    return result.sortedList(keyOf: (e) => e.fecha!, desc: desc).toList();
  }

  // -- Action handlers --------------------------------------------------------

  void _onStatusTap(
      BuildContext context, VwSolicitudesServiciosCompletaRow item, int index) {
    showAlignedDialog(
      barrierColor: Colors.transparent,
      context: context,
      isGlobal: false,
      avoidOverflow: false,
      targetAnchor:
          AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
      followerAnchor:
          AlignmentDirectional(0.0, 0.0).resolve(Directionality.of(context)),
      builder: (dialogContext) {
        return Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(dialogContext).unfocus();
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: DropdownSolicitudEstadoWidget(
              estadoActual: item.estadoSolicitud!,
              index: index,
              solicitudId: item.solicitudId!,
              userid: item.clienteIdUsuario?.toString(),
              actionnavegacion: () async {
                if (Navigator.of(context).canPop()) context.pop();
                navigateWithFade(context, SolicitudesWidget.routeName);
              },
            ),
          ),
        );
      },
    );
  }

  void _onDelete(
      BuildContext context, VwSolicitudesServiciosCompletaRow item) {
    showCenteredDialog(
      context,
      Notificacion2Widget(
        titulo: 'Solicitudes',
        texto: 'Estas seguro de eliminar la solicitud?',
        boton: 'Aceptar',
        succes: false,
        action: () async {
          await SolicitudesServicioTable().delete(
            matchingRows: (rows) => rows.eqOrNull('id', item.solicitudId),
          );
          showCenteredDialog(
            context,
            Notificacion2Widget(
              titulo: 'Solicitudes',
              texto: 'Solicitud eliminada exitosamente',
              boton: 'Aceptar',
              succes: true,
              action: () async {
                navigateWithFade(context, SolicitudesWidget.routeName);
              },
            ),
          );
        },
      ),
    );
  }

  void _onViewDetails(
      BuildContext context, VwSolicitudesServiciosCompletaRow item) {
    showCenteredDialog(
      context,
      DetalleSolicitudWidget(solicitudId: item.solicitudId!),
    );
  }

  void _onEdit(
      BuildContext context, VwSolicitudesServiciosCompletaRow item) {
    showCenteredDialog(
      context,
      EdicionSolicitudWidget(solicitudId: item.solicitudId!),
    );
  }

  // -- Build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0.0, -1.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                wrapWithModel(
                  model: _model.menuModel,
                  updateCallback: () => safeSetState(() {}),
                  child: MenuWidget(),
                ),
                Expanded(
                  child: _buildDataPipeline(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Three FutureBuilders (estado, categoria, search) + one StreamBuilder.
  Widget _buildDataPipeline() {
    return FutureBuilder<List<VwSolicitudesServiciosCompletaRow>>(
      future: VwSolicitudesServiciosCompletaTable().queryRows(
        queryFn: (q) => q.like('estado_solicitud', '%${_model.dropDownValue1}%'),
      ),
      builder: (context, estadoSnap) {
        if (!estadoSnap.hasData) return const HulpLoadingIndicator();
        final estadoRows = estadoSnap.data!;

        return FutureBuilder<List<VwSolicitudesServiciosCompletaRow>>(
          future: VwSolicitudesServiciosCompletaTable().queryRows(
            queryFn: (q) =>
                q.like('categoria_nombre', '%${_model.dropDownValue2}%'),
          ),
          builder: (context, catSnap) {
            if (!catSnap.hasData) return const HulpLoadingIndicator();
            final catRows = catSnap.data!;

            return FutureBuilder<List<VwSolicitudesServiciosCompletaRow>>(
              future: (_model.requestCompleter ??=
                      Completer<List<VwSolicitudesServiciosCompletaRow>>()
                        ..complete(
                            VwSolicitudesServiciosCompletaTable().queryRows(
                          queryFn: (q) => q
                              .ilike('cliente_nombre_completo',
                                  '%${_model.textController.text}%')
                              .order('fecha'),
                        )))
                  .future,
              builder: (context, searchSnap) {
                if (!searchSnap.hasData) return const HulpLoadingIndicator();
                final searchRows = searchSnap.data!;

                return StreamBuilder<List<VwSolicitudesServiciosCompletaRow>>(
                  stream: _model.containerSupabaseStream ??= SupaFlow.client
                      .from("vw_solicitudes_servicios_completa")
                      .stream(primaryKey: [
                        'solicitud_id',
                        'subcategoria_id',
                        'categoria_id'
                      ])
                      .order('fecha')
                      .map((list) => list
                          .map((item) =>
                              VwSolicitudesServiciosCompletaRow(item))
                          .toList()),
                  builder: (context, streamSnap) {
                    if (!streamSnap.hasData)
                      return const HulpLoadingIndicator();
                    final allData = streamSnap.data!;

                    return _buildPageContent(
                      context,
                      allData: allData,
                      estadoFiltered: catRows,
                      categoriaFiltered: estadoRows,
                      searchFiltered: searchRows,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPageContent(
    BuildContext context, {
    required List<VwSolicitudesServiciosCompletaRow> allData,
    required List<VwSolicitudesServiciosCompletaRow> estadoFiltered,
    required List<VwSolicitudesServiciosCompletaRow> categoriaFiltered,
    required List<VwSolicitudesServiciosCompletaRow> searchFiltered,
  }) {
    final solicitudesDatos = _applyFilters(
      allData: allData,
      estadoFiltered: estadoFiltered,
      categoriaFiltered: categoriaFiltered,
      searchFiltered: searchFiltered,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildHeaderBar(context),
          Flexible(
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(40.0, 24.0, 40.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildBreadcrumb(context),
                  _buildTitleRow(context),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 24.0, 0.0, 0.0),
                    child: SolicitudesFilterBar(
                      estadoOptions: _getEstadoOptions(allData, estadoFiltered),
                      categoriaOptions:
                          _getCategoriaOptions(allData, categoriaFiltered),
                      dropDownValue1: _model.dropDownValue1,
                      dropDownValue2: _model.dropDownValue2,
                      dropDownValueController1: _model.dropDownValueController1,
                      dropDownValueController2: _model.dropDownValueController2,
                      dateStart: _model.dateStart,
                      dateEnd: _model.dateEnd,
                      resultCount: solicitudesDatos.length,
                      onEstadoChanged: (val) =>
                          safeSetState(() => _model.dropDownValue1 = val),
                      onCategoriaChanged: (val) =>
                          safeSetState(() => _model.dropDownValue2 = val),
                      onEstadoReset: () => safeSetState(() {
                        _model.dropDownValueController1?.reset();
                        _model.dropDownValue1 = null;
                      }),
                      onCategoriaReset: () => safeSetState(() {
                        _model.dropDownValueController2?.reset();
                        _model.dropDownValue2 = null;
                      }),
                      onDateRangeSelected: (start, end) => safeSetState(() {
                        _model.dateStart = start;
                        _model.dateEnd = end;
                        _model.datePicked = start;
                      }),
                      onDateReset: () => safeSetState(() {
                        _model.dateStart = null;
                        _model.dateEnd = null;
                        _model.datePicked = null;
                      }),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 12.0, 0.0, 8.0),
                      child: SolicitudesDataTable(
                        data: solicitudesDatos,
                        controller: _model.paginatedDataTableController,
                        onStatusTap: (item, index) =>
                            _onStatusTap(context, item, index),
                        onDelete: (item) => _onDelete(context, item),
                        onViewDetails: (item) =>
                            _onViewDetails(context, item),
                        onEdit: (item) => _onEdit(context, item),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -- Helper methods ---------------------------------------------------------

  List<String> _getEstadoOptions(
    List<VwSolicitudesServiciosCompletaRow> allData,
    List<VwSolicitudesServiciosCompletaRow> estadoFiltered,
  ) {
    final source = (_model.dropDownValue2 != null && _model.dropDownValue2 != '')
        ? estadoFiltered
        : allData;
    return source
        .unique((e) => e.estadoSolicitud!)
        .map((e) => e.estadoSolicitud)
        .withoutNulls
        .toList();
  }

  List<String> _getCategoriaOptions(
    List<VwSolicitudesServiciosCompletaRow> allData,
    List<VwSolicitudesServiciosCompletaRow> categoriaFiltered,
  ) {
    final source = (_model.dropDownValue1 != null && _model.dropDownValue1 != '')
        ? categoriaFiltered
        : allData;
    return source
        .unique((e) => e.categoriaNombre!)
        .map((e) => e.categoriaNombre)
        .withoutNulls
        .toList();
  }

  // -- Sub-widgets ------------------------------------------------------------

  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: 72.0,
      decoration: BoxDecoration(
        color: const Color(0xFFEEECE8),
        border: Border.all(color: const Color(0xFFD9C19C), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(40.0, 0.0, 0.0, 0.0),
            child: SizedBox(
              width: 394.0,
              child: TextFormField(
                controller: _model.textController,
                focusNode: _model.textFieldFocusNode,
                onChanged: (_) => EasyDebounce.debounce(
                  '_model.textController',
                  const Duration(milliseconds: 2000),
                  () async {
                    safeSetState(() => _model.requestCompleter = null);
                    await _model.waitForRequestCompleted();
                  },
                ),
                autofocus: false,
                obscureText: false,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Buscar solicitud',
                  hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                        font: GoogleFonts.inter(),
                        color: FlutterFlowTheme.of(context).secondary,
                        fontSize: 16.0,
                        letterSpacing: 0.0,
                      ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF8A8A8A), width: 0.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0x00000000), width: 0.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).error, width: 0.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).error, width: 0.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      letterSpacing: 0.0,
                    ),
                cursorColor: FlutterFlowTheme.of(context).primaryText,
                validator:
                    _model.textControllerValidator.asValidator(context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 40.0, 12.0),
            child: Icon(
              Icons.notifications_none,
              color: FlutterFlowTheme.of(context).accent3,
              size: 24.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    final crumbStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.inter(
              fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
          color: const Color(0xFF5E252B),
          fontSize: 16.0,
          letterSpacing: 0.0,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
        );

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          onTap: () => navigateWithFade(context, DashboardWidget.routeName),
          child: Text('Inicio', style: crumbStyle),
        ),
        const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 4.0, 0.0),
          child: Icon(Icons.chevron_right, color: Color(0xFF5E252B), size: 24.0),
        ),
        InkWell(
          splashColor: Colors.transparent,
          onTap: () => navigateWithFade(context, SolicitudesWidget.routeName),
          child: Text('Solicitudes', style: crumbStyle),
        ),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Solicitudes',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  color: FlutterFlowTheme.of(context).primary,
                  fontSize: 28.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              FlutterFlowDropDown<String>(
                controller: _model.dropDownOrdenValueController ??=
                    FormFieldController<String>(
                  _model.dropDownOrdenValue ??= 'Recientes primero',
                ),
                options: ['Recientes primero', 'Antiguos primero'],
                onChanged: (val) =>
                    safeSetState(() => _model.dropDownOrdenValue = val),
                width: 200.0,
                height: 40.0,
                textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      letterSpacing: 0.0,
                    ),
                hintText: 'Ordenar',
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 24.0),
                fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                elevation: 2.0,
                borderColor: Colors.transparent,
                borderWidth: 0.0,
                borderRadius: 8.0,
                margin: const EdgeInsetsDirectional.fromSTEB(
                    12.0, 0.0, 12.0, 0.0),
                hidesUnderline: true,
                isOverButton: false,
                isSearchable: false,
                isMultiSelect: false,
              ),
              Builder(
                builder: (context) => FFButtonWidget(
                  onPressed: () async {
                    await showCenteredDialog(
                        context, CrearSolicitudWidget());
                  },
                  text: 'Nuevo',
                  options: FFButtonOptions(
                    height: 40.0,
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 0.0, 16.0, 0.0),
                    iconPadding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle:
                        FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.interTight(),
                              color: Colors.white,
                              letterSpacing: 0.0,
                            ),
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ].divide(const SizedBox(width: 5.0)),
          ),
        ],
      ),
    );
  }
}
