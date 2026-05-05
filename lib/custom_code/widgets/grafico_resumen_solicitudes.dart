// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'dart:math' show max, min;

import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:fl_chart/fl_chart.dart';

class GraficoResumenSolicitudes extends StatefulWidget {
  const GraficoResumenSolicitudes({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<GraficoResumenSolicitudes> createState() =>
      _GraficoResumenSolicitudesState();
}

class _GraficoResumenSolicitudesState extends State<GraficoResumenSolicitudes> {
  List<PieChartSectionData> pieSections = [];
  /// Orden de estados en [pieSections] (para mapear índice al hover).
  List<String> pieEstadoKeys = [];
  int _pieTouchedIndex = -1;
  Offset? _pieTooltipOffset;
  bool isLoading = true;
  String error = '';
  int totalSolicitudes = 0;

  Map<String, int> conteoEstados = {
    'finalizadas': 0,
    'canceladas': 0,
    'reagendadas': 0,
  };

  // Mapeo de estados y colores
  final Map<String, String> estadosLabels = {
    'finalizadas': 'Finalizado',
    'canceladas': 'Cancelado',
    'reagendadas': 'Reagendado',
  };

  final Map<String, Color> estadosColores = {
    'finalizadas': Color(0xFF10B981), // Verde
    'canceladas': Color(0xFFF97316), // Naranja
    'reagendadas': Color(0xFF9CA3AF), // Gris
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('=== INICIANDO CARGA RESUMEN SOLICITUDES ===');

      setState(() {
        isLoading = true;
        error = '';
      });

      // Consultar todas las solicitudes
      final response = await SupaFlow.client
          .from('solicitudes_servicio')
          .select('id, estado, creado_en')
          .order('creado_en', ascending: false);

      print('Solicitudes encontradas: ${response.length}');

      // Reiniciar contadores
      Map<String, int> tempConteo = {
        'finalizadas': 0,
        'canceladas': 0,
        'reagendadas': 0,
      };

      int total = 0;

      // Contar solicitudes por estado
      for (var solicitud in response) {
        String estado = solicitud['estado']?.toString().toLowerCase() ?? '';

        if (tempConteo.containsKey(estado)) {
          tempConteo[estado] = tempConteo[estado]! + 1;
          total++;
          print(
              'Solicitud ${solicitud['id']}: $estado - Fecha: ${solicitud['creado_en']}');
        } else {
          print(
              'Estado no reconocido: $estado - Solicitud: ${solicitud['id']}');
        }
      }

      print('\n=== CONTEO POR ESTADOS ===');
      tempConteo.forEach((estado, cantidad) {
        double porcentaje = total > 0 ? (cantidad / total) * 100 : 0;
        print(
            '${estadosLabels[estado]}: $cantidad solicitudes (${porcentaje.toStringAsFixed(1)}%)');
      });

      // Crear secciones del gráfico de torta
      List<PieChartSectionData> sections = [];
      final ordenEstados = <String>[];

      tempConteo.forEach((estado, cantidad) {
        if (cantidad > 0) {
          ordenEstados.add(estado);
          sections.add(
            PieChartSectionData(
              color: estadosColores[estado]!,
              value: cantidad.toDouble(),
              title: '',
              radius: 80,
              titleStyle: const TextStyle(fontSize: 0),
              badgeWidget: null,
            ),
          );
        }
      });

      print('\n=== RESULTADOS FINALES ===');
      print('Total solicitudes procesadas: $total');
      print('Secciones creadas: ${sections.length}');

      setState(() {
        conteoEstados = tempConteo;
        pieSections = sections;
        pieEstadoKeys = ordenEstados;
        _pieTouchedIndex = -1;
        _pieTooltipOffset = null;
        totalSolicitudes = total;
        isLoading = false;
      });

      print('=== CARGA COMPLETADA ===');
    } catch (e) {
      print('ERROR EN _loadData: $e');
      setState(() {
        error = 'Error al cargar datos: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 350,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Resumen de solicitudes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          SizedBox(height: 16),

          // Contenido principal
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF10B981),
                    ),
                  )
                : error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 32, color: Colors.red),
                            SizedBox(height: 8),
                            Text(
                              error,
                              style: TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : totalSolicitudes == 0
                        ? Center(
                            child: Text(
                              'No hay solicitudes disponibles',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final narrow = constraints.maxWidth < 420;
                              final legend = _buildLeyendaEstados();

                              Widget pieOnly() {
                                return LayoutBuilder(
                                  builder: (context, c) {
                                    final side =
                                        min(c.maxWidth, c.maxHeight);
                                    if (side <= 0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Center(
                                      child: SizedBox(
                                        width: side,
                                        height: side,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            PieChart(
                                              PieChartData(
                                                sections: pieSections,
                                                centerSpaceRadius: 0,
                                                sectionsSpace: 2,
                                                startDegreeOffset: -90,
                                                pieTouchData: PieTouchData(
                                                  enabled: true,
                                                  touchCallback:
                                                      (FlTouchEvent event,
                                                          pieTouchResponse) {
                                                    if (event
                                                        is FlPointerExitEvent) {
                                                      if (_pieTouchedIndex !=
                                                              -1 ||
                                                          _pieTooltipOffset !=
                                                              null) {
                                                        setState(() {
                                                          _pieTouchedIndex =
                                                              -1;
                                                          _pieTooltipOffset =
                                                              null;
                                                        });
                                                      }
                                                      return;
                                                    }
                                                    if (!event
                                                        .isInterestedForInteractions) {
                                                      return;
                                                    }
                                                    final touched =
                                                        pieTouchResponse
                                                            ?.touchedSection;
                                                    if (touched == null) {
                                                      setState(() {
                                                        _pieTouchedIndex = -1;
                                                        _pieTooltipOffset =
                                                            null;
                                                      });
                                                      return;
                                                    }
                                                    final pos =
                                                        event.localPosition;
                                                    if (pos == null) return;
                                                    setState(() {
                                                      _pieTouchedIndex =
                                                          touched
                                                              .touchedSectionIndex;
                                                      _pieTooltipOffset = pos;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                            if (_pieTouchedIndex >= 0 &&
                                                _pieTooltipOffset != null &&
                                                _pieTouchedIndex <
                                                    pieEstadoKeys.length)
                                              _pieHoverTooltipEstados(
                                                  side, side),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }

                              if (narrow) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: pieOnly(),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      flex: 2,
                                      child: SingleChildScrollView(
                                        child: legend,
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 2, child: pieOnly()),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 1,
                                    child: SingleChildScrollView(
                                      child: legend,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  static const double _pieTooltipW = 132;
  static const double _pieTooltipH = 46;

  Widget _pieHoverTooltipEstados(double chartW, double chartH) {
    final estado = pieEstadoKeys[_pieTouchedIndex];
    final label = estadosLabels[estado] ?? estado;
    final cant = conteoEstados[estado] ?? 0;
    final pct = totalSolicitudes > 0
        ? (cant / totalSolicitudes) * 100
        : 0.0;
    final offset = _pieTooltipOffset!;
    double left = offset.dx + 10;
    double top = offset.dy + 8;
    if (left + _pieTooltipW > chartW) left = chartW - _pieTooltipW - 4;
    if (top + _pieTooltipH > chartH) {
      top = offset.dy - _pieTooltipH - 8;
    }
    left = left.clamp(0.0, max(0.0, chartW - _pieTooltipW));
    top = top.clamp(0.0, max(0.0, chartH - _pieTooltipH));

    return Positioned(
      left: left,
      top: top,
      child: _pieTooltipShell(label, '${pct.toStringAsFixed(1)}%'),
    );
  }

  Widget _pieTooltipShell(String title, String valueLine) {
    return IgnorePointer(
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFF334155),
        shadowColor: Colors.black38,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valueLine,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeyendaEstados() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: estadosLabels.entries.map((entry) {
        String estado = entry.key;
        String label = entry.value;
        Color color = estadosColores[estado]!;
        int cantidad = conteoEstados[estado] ?? 0;
        double porcentaje = totalSolicitudes > 0
            ? (cantidad / totalSolicitudes) * 100
            : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$label (${porcentaje.toStringAsFixed(1)}%)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
