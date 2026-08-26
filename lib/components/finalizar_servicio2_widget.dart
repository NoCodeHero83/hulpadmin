import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'finalizar_servicio2_model.dart';
export 'finalizar_servicio2_model.dart';

class FinalizarServicio2Widget extends StatefulWidget {
  const FinalizarServicio2Widget({
    super.key,
    required this.servicioId,
  });

  final String? servicioId;

  @override
  State<FinalizarServicio2Widget> createState() =>
      _FinalizarServicio2WidgetState();
}

class _FinalizarServicio2WidgetState extends State<FinalizarServicio2Widget> {
  late FinalizarServicio2Model _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FinalizarServicio2Model());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 540.0,
          ),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: 0.0,
                      child: Icon(
                        Icons.arrow_back,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                    ),
                    Text(
                      'Proveedores',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            fontSize: 22.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        color: FlutterFlowTheme.of(context).primaryText,
                        size: 24.0,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                  child: Image.asset(
                    'assets/images/Iconos_de_estado.png',
                    width: 80.0,
                    height: 80.0,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                  child: Text(
                    'Finalizar servicio',
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(10.0, 16.0, 10.0, 0.0),
                    child: Text(
                      'Recuerda que al finalizar el servicio, también estás aceptando los términos y condiciones.\n\nEsta acción es definitiva y no se puede revertir.',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      var _shouldSetState = false;
                      try {
                      _model.validacion =
                          await SolicitudesServicioTable().queryRows(
                        queryFn: (q) => q.eqOrNull(
                          'id',
                          widget!.servicioId,
                        ),
                      );
                      _shouldSetState = true;
                      if (_model.validacion?.firstOrNull?.profesionalId ==
                              null ||
                          _model.validacion?.firstOrNull?.profesionalId == '') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('No se puede finalizar: el servicio no tiene profesional asignado.'),
                            duration: Duration(milliseconds: 4000),
                            backgroundColor: FlutterFlowTheme.of(context).secondary,
                          ),
                        );
                        if (_shouldSetState) safeSetState(() {});
                        return;
                      } else {
                        await SolicitudesServicioTable().update(
                          data: {
                            'profesional_id':
                                _model.validacion?.firstOrNull?.profesionalId,
                          },
                          matchingRows: (rows) => rows.eqOrNull(
                            'id',
                            widget!.servicioId,
                          ),
                        );
                        _model.resultadosUsuarioMetodoPago =
                            await MetodosPagoTable().queryRows(
                          queryFn: (q) => q
                              .eqOrNull(
                                'usuario_id',
                                _model.validacion?.firstOrNull?.usuarioId,
                              )
                              .eqOrNull(
                                'es_predeterminado',
                                true,
                              ),
                        );
                        _shouldSetState = true;
                        if (_model.resultadosUsuarioMetodoPago!.length > 0) {
                          _model.usuarioServicio2 =
                              await UsuariosTable().queryRows(
                            queryFn: (q) => q.eqOrNull(
                              'id',
                              _model.validacion?.firstOrNull?.usuarioId,
                            ),
                          );
                          _shouldSetState = true;
                          _model.aceptaceToken2 =
                              await actions.getAcceptanceToken(
                            FFDevEnvironmentValues().publicKey,
                            FFDevEnvironmentValues().isProduction,
                          );
                          _shouldSetState = true;
                          if (getJsonField(
                            _model.aceptaceToken2,
                            r'''$.success''',
                          )) {
                            _model.pago2 = await actions.createTransaction(
                              FFDevEnvironmentValues().privateKey,
                              FFDevEnvironmentValues().publicKey,
                              functions.stringToIngete(_model
                                  .resultadosUsuarioMetodoPago!
                                  .firstOrNull!
                                  .paymentSourceId
                                  .toString()),
                              getJsonField(
                                _model.aceptaceToken2,
                                r'''$.acceptanceToken''',
                              ).toString(),
                              ((valueOrDefault<double>(
                                            _model.validacion?.firstOrNull
                                                ?.precioBase,
                                            valueOrDefault<double>(
                                              _model.validacion?.firstOrNull
                                                  ?.precio,
                                              0.0,
                                            ),
                                          ) +
                                          valueOrDefault<double>(
                                            _model.validacion?.firstOrNull
                                                ?.precioAdicionales,
                                            0.0,
                                          )) *
                                      100)
                                  .round(),
                              'COP',
                              _model.usuarioServicio2!.firstOrNull!
                                  .correoElectronico!,
                              '${_model.validacion!.firstOrNull!.id}-${DateTime.now().millisecondsSinceEpoch}',
                              FFDevEnvironmentValues().integrityKey,
                              FFDevEnvironmentValues().isProduction,
                            );
                            _shouldSetState = true;
                            if (getJsonField(
                              _model.pago2,
                              r'''$.success''',
                            )) {
                              if ('APPROVED' ==
                                  getJsonField(
                                    _model.pago2,
                                    r'''$.status''',
                                  ).toString()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '¡Servicio finalizado y pago aprobado!',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 2000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).primary,
                                  ),
                                );
                                await SolicitudesServicioTable().update(
                                  data: {
                                    'estado': 'finalizadas',
                                    'profesional_id': _model
                                        .validacion?.firstOrNull?.profesionalId,
                                    'estado_pago': 'pagado',
                                  },
                                  matchingRows: (rows) => rows.eqOrNull(
                                    'id',
                                    widget!.servicioId,
                                  ),
                                );
                                await TransaccionesTable().insert({
                                  'numero_transaccion': getJsonField(
                                    _model.pago2,
                                    r'''$.transactionId''',
                                  )?.toString(),
                                  'referencia_externa': getJsonField(
                                    _model.pago2,
                                    r'''$.reference''',
                                  )?.toString(),
                                  // Lo que Wompi confirmo, no lo que calculo la app.
                                  // Sin esto no hay forma de auditar un cobro.
                                  'datos_pago': getJsonField(
                                    _model.pago2,
                                    r'''$.fullData''',
                                  ),
                                  'solicitud_id':
                                      _model.validacion?.firstOrNull?.id,
                                  'usuario_id':
                                      _model.usuarioServicio2?.firstOrNull?.id,
                                  'monto': valueOrDefault<double>(
                                        _model.validacion?.firstOrNull
                                            ?.precioBase,
                                        valueOrDefault<double>(
                                          _model.validacion?.firstOrNull?.precio,
                                          0.0,
                                        ),
                                      ) +
                                      valueOrDefault<double>(
                                        _model.validacion?.firstOrNull
                                            ?.precioAdicionales,
                                        0.0,
                                      ),
                                  'moneda': 'COP',
                                  'proveedor_pago': 'WOMPI',
                                  'fecha_pago': supaSerialize<DateTime>(
                                      getCurrentTimestamp),
                                  'fecha_registro': supaSerialize<DateTime>(
                                      getCurrentTimestamp),
                                  'metodo_pago':
                                      _model.resultadosUsuarioMetodoPago
                                              ?.firstOrNull?.tipo ??
                                          'Bancolombia',
                                  'numero_transaccion': getJsonField(
                                    _model.pago2,
                                    r'''$.transactionId''',
                                  )?.toString(),
                                  'referencia_externa': getJsonField(
                                    _model.pago2,
                                    r'''$.reference''',
                                  )?.toString(),
                                });
                                Navigator.pop(context);
                                if (_shouldSetState) safeSetState(() {});
                                return;
                              } else if ('DECLINED' ==
                                  getJsonField(
                                    _model.pago2,
                                    r'''$.status''',
                                  ).toString()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'pago rechazado',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                );
                                await SolicitudesServicioTable().update(
                                  data: {
                                    'profesional_id': null,
                                  },
                                  matchingRows: (rows) => rows.eqOrNull(
                                    'id',
                                    widget!.servicioId,
                                  ),
                                );
                                if (_shouldSetState) safeSetState(() {});
                                return;
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'pago no es aprobado',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                );
                                await SolicitudesServicioTable().update(
                                  data: {
                                    'profesional_id': null,
                                  },
                                  matchingRows: (rows) => rows.eqOrNull(
                                    'id',
                                    widget!.servicioId,
                                  ),
                                );
                                if (_shouldSetState) safeSetState(() {});
                                return;
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    getJsonField(
                                      _model.pago2,
                                      r'''$.error''',
                                    ).toString(),
                                    style: TextStyle(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                    ),
                                  ),
                                  duration: Duration(milliseconds: 4000),
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).secondary,
                                ),
                              );
                              await SolicitudesServicioTable().update(
                                data: {
                                  'profesional_id': null,
                                },
                                matchingRows: (rows) => rows.eqOrNull(
                                  'id',
                                  widget!.servicioId,
                                ),
                              );
                              if (_shouldSetState) safeSetState(() {});
                              return;
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error Aceptace Token',
                                  style: TextStyle(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                  ),
                                ),
                                duration: Duration(milliseconds: 4000),
                                backgroundColor:
                                    FlutterFlowTheme.of(context).secondary,
                              ),
                            );
                            await SolicitudesServicioTable().update(
                              data: {
                                'profesional_id': null,
                              },
                              matchingRows: (rows) => rows.eqOrNull(
                                'id',
                                widget!.servicioId,
                              ),
                            );
                            if (_shouldSetState) safeSetState(() {});
                            return;
                          }
                        } else {
                          _model.tarjeta =
                              await TarjetasGuardadasTable().queryRows(
                            queryFn: (q) => q.eqOrNull(
                              'usuario_id',
                              _model.validacion?.firstOrNull?.usuarioId,
                            ),
                          );
                          _shouldSetState = true;
                          if (_model.tarjeta == null || _model.tarjeta!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('El usuario no tiene método de pago ni tarjeta guardada.'),
                                duration: Duration(milliseconds: 4000),
                                backgroundColor: FlutterFlowTheme.of(context).secondary,
                              ),
                            );
                            if (_shouldSetState) safeSetState(() {});
                            return;
                          }
                          _model.usuarioServicio =
                              await UsuariosTable().queryRows(
                            queryFn: (q) => q.eqOrNull(
                              'id',
                              _model.validacion?.firstOrNull?.usuarioId,
                            ),
                          );
                          _shouldSetState = true;
                          _model.aceptaceToken =
                              await actions.getAcceptanceToken(
                            FFDevEnvironmentValues().publicKey,
                            FFDevEnvironmentValues().isProduction,
                          );
                          _shouldSetState = true;
                          if (getJsonField(
                            _model.aceptaceToken,
                            r'''$.success''',
                          )) {
                            _model.pago = await actions.createTransaction(
                              FFDevEnvironmentValues().privateKey,
                              FFDevEnvironmentValues().publicKey,
                              functions.stringToIngete(
                                  _model.tarjeta!.firstOrNull!.paymentSourceId),
                              getJsonField(
                                _model.aceptaceToken,
                                r'''$.acceptanceToken''',
                              ).toString(),
                              ((valueOrDefault<double>(
                                            _model.validacion?.firstOrNull
                                                ?.precioBase,
                                            valueOrDefault<double>(
                                              _model.validacion?.firstOrNull
                                                  ?.precio,
                                              0.0,
                                            ),
                                          ) +
                                          valueOrDefault<double>(
                                            _model.validacion?.firstOrNull
                                                ?.precioAdicionales,
                                            0.0,
                                          )) *
                                      100)
                                  .round(),
                              'COP',
                              _model.usuarioServicio!.firstOrNull!
                                  .correoElectronico!,
                              '${_model.validacion!.firstOrNull!.id}-${DateTime.now().millisecondsSinceEpoch}',
                              FFDevEnvironmentValues().integrityKey,
                              FFDevEnvironmentValues().isProduction,
                            );
                            _shouldSetState = true;
                            if (getJsonField(
                              _model.pago,
                              r'''$.success''',
                            )) {
                              if ('APPROVED' ==
                                  getJsonField(
                                    _model.pago,
                                    r'''$.status''',
                                  ).toString()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '¡Servicio finalizado y pago aprobado!',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 2000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).primary,
                                  ),
                                );
                                await SolicitudesServicioTable().update(
                                  data: {
                                    'estado': 'finalizadas',
                                    'profesional_id': _model
                                        .validacion?.firstOrNull?.profesionalId,
                                    'estado_pago': 'pagado',
                                  },
                                  matchingRows: (rows) => rows.eqOrNull(
                                    'id',
                                    widget!.servicioId,
                                  ),
                                );
                                await TransaccionesTable().insert({
                                  'numero_transaccion': getJsonField(
                                    _model.pago,
                                    r'''$.transactionId''',
                                  )?.toString(),
                                  'referencia_externa': getJsonField(
                                    _model.pago,
                                    r'''$.reference''',
                                  )?.toString(),
                                  // Lo que Wompi confirmo, no lo que calculo la app.
                                  // Sin esto no hay forma de auditar un cobro.
                                  'datos_pago': getJsonField(
                                    _model.pago,
                                    r'''$.fullData''',
                                  ),
                                  'solicitud_id':
                                      _model.validacion?.firstOrNull?.id,
                                  'usuario_id':
                                      _model.usuarioServicio?.firstOrNull?.id,
                                  'monto': valueOrDefault<double>(
                                        _model.validacion?.firstOrNull
                                            ?.precioBase,
                                        valueOrDefault<double>(
                                          _model.validacion?.firstOrNull?.precio,
                                          0.0,
                                        ),
                                      ) +
                                      valueOrDefault<double>(
                                        _model.validacion?.firstOrNull
                                            ?.precioAdicionales,
                                        0.0,
                                      ),
                                  'moneda': 'COP',
                                  'proveedor_pago': 'WOMPI',
                                  'fecha_pago': supaSerialize<DateTime>(
                                      getCurrentTimestamp),
                                  'fecha_registro': supaSerialize<DateTime>(
                                      getCurrentTimestamp),
                                  'metodo_pago': 'Tarjeta',
                                  'numero_transaccion': getJsonField(
                                    _model.pago,
                                    r'''$.transactionId''',
                                  )?.toString(),
                                  'referencia_externa': getJsonField(
                                    _model.pago,
                                    r'''$.reference''',
                                  )?.toString(),
                                });
                                Navigator.pop(context);
                                if (_shouldSetState) safeSetState(() {});
                                return;
                              } else if ('DECLINED' ==
                                  getJsonField(
                                    _model.pago,
                                    r'''$.status''',
                                  ).toString()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'pago rechazado',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                );
                                await SolicitudesServicioTable().update(
                                  data: {
                                    'profesional_id': null,
                                  },
                                  matchingRows: (rows) => rows.eqOrNull(
                                    'id',
                                    widget!.servicioId,
                                  ),
                                );
                                if (_shouldSetState) safeSetState(() {});
                                return;
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'pago no es aprobado',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context)
                                            .primaryText,
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 4000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).secondary,
                                  ),
                                );
                                await SolicitudesServicioTable().update(
                                  data: {
                                    'profesional_id': null,
                                  },
                                  matchingRows: (rows) => rows.eqOrNull(
                                    'id',
                                    widget!.servicioId,
                                  ),
                                );
                                if (_shouldSetState) safeSetState(() {});
                                return;
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    getJsonField(
                                      _model.pago,
                                      r'''$.error''',
                                    ).toString(),
                                    style: TextStyle(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                    ),
                                  ),
                                  duration: Duration(milliseconds: 4000),
                                  backgroundColor:
                                      FlutterFlowTheme.of(context).secondary,
                                ),
                              );
                              await SolicitudesServicioTable().update(
                                data: {
                                  'profesional_id': null,
                                },
                                matchingRows: (rows) => rows.eqOrNull(
                                  'id',
                                  widget!.servicioId,
                                ),
                              );
                              if (_shouldSetState) safeSetState(() {});
                              return;
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Error Aceptace Token',
                                  style: TextStyle(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                  ),
                                ),
                                duration: Duration(milliseconds: 4000),
                                backgroundColor:
                                    FlutterFlowTheme.of(context).secondary,
                              ),
                            );
                            await SolicitudesServicioTable().update(
                              data: {
                                'profesional_id': null,
                              },
                              matchingRows: (rows) => rows.eqOrNull(
                                'id',
                                widget!.servicioId,
                              ),
                            );
                            if (_shouldSetState) safeSetState(() {});
                            return;
                          }
                        }
                      }

                      if (_shouldSetState) safeSetState(() {});
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al finalizar: $e'),
                            duration: Duration(milliseconds: 6000),
                            backgroundColor: FlutterFlowTheme.of(context).secondary,
                          ),
                        );
                        if (_shouldSetState) safeSetState(() {});
                      }
                    },
                    text: 'Finalizar servicio con metodos de pago',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 14.0, 0.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      var _shouldSetState = false;
                      _model.validacion25 =
                          await SolicitudesServicioTable().queryRows(
                        queryFn: (q) => q.eqOrNull(
                          'id',
                          widget!.servicioId,
                        ),
                      );
                      _shouldSetState = true;
                      if (_model.validacion25?.firstOrNull?.profesionalId ==
                              null ||
                          _model.validacion25?.firstOrNull?.profesionalId ==
                              '') {
                        if (_shouldSetState) safeSetState(() {});
                        return;
                      } else {
                        await SolicitudesServicioTable().update(
                          data: {
                            'profesional_id':
                                _model.validacion25?.firstOrNull?.profesionalId,
                          },
                          matchingRows: (rows) => rows.eqOrNull(
                            'id',
                            widget!.servicioId,
                          ),
                        );
                        _model.usuarioServicio33 =
                            await UsuariosTable().queryRows(
                          queryFn: (q) => q.eqOrNull(
                            'id',
                            _model.validacion25?.firstOrNull?.usuarioId,
                          ),
                        );
                        _shouldSetState = true;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'finalizado',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                              ),
                            ),
                            duration: Duration(milliseconds: 2000),
                            backgroundColor:
                                FlutterFlowTheme.of(context).primary,
                          ),
                        );
                        await SolicitudesServicioTable().update(
                          data: {
                            'estado': 'finalizadas',
                            'profesional_id':
                                _model.validacion25?.firstOrNull?.profesionalId,
                            'estado_pago': 'pagado',
                          },
                          matchingRows: (rows) => rows.eqOrNull(
                            'id',
                            widget!.servicioId,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'finalizado 2',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                              ),
                            ),
                            duration: Duration(milliseconds: 2000),
                            backgroundColor:
                                FlutterFlowTheme.of(context).primary,
                          ),
                        );
                        await TransaccionesTable().insert({
                          'solicitud_id': _model.validacion25?.firstOrNull?.id,
                          'usuario_id':
                              _model.usuarioServicio33?.firstOrNull?.id,
                          'monto': valueOrDefault<double>(
                            _model.validacion25?.firstOrNull?.precio,
                            0.0,
                          ),
                          'moneda': 'COP',
                          'proveedor_pago': 'QR',
                          'fecha_pago':
                              supaSerialize<DateTime>(getCurrentTimestamp),
                          'fecha_registro':
                              supaSerialize<DateTime>(getCurrentTimestamp),
                          'metodo_pago': 'QR',
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'finalizado 3',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context)
                                    .primaryBackground,
                              ),
                            ),
                            duration: Duration(milliseconds: 2000),
                            backgroundColor:
                                FlutterFlowTheme.of(context).primary,
                          ),
                        );
                        Navigator.pop(context);
                        if (_shouldSetState) safeSetState(() {});
                        return;
                      }

                      if (_shouldSetState) safeSetState(() {});
                    },
                    text: 'Finalizar servicio sin metodos de pago',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
