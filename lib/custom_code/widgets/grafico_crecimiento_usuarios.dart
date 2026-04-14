// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:fl_chart/fl_chart.dart';

class GraficoCrecimientoUsuarios extends StatefulWidget {
  const GraficoCrecimientoUsuarios({
    super.key,
    this.width,
    this.height,
    required this.rol,
    required this.tiempo,
  });

  final double? width;
  final double? height;
  final String rol; // "usuario" o "proveedor"
  final String tiempo; // "semanal" o "mensual"

  @override
  State<GraficoCrecimientoUsuarios> createState() =>
      _GraficoCrecimientoUsuariosState();

  // Agregar clave única para cada instancia del widget
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GraficoCrecimientoUsuarios(rol: $rol, tiempo: $tiempo)';
  }
}

class _GraficoCrecimientoUsuariosState
    extends State<GraficoCrecimientoUsuarios> {
  List<FlSpot> spots = [];
  List<String> labels = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      String widgetId = '${widget.rol}_${widget.tiempo}';
      print('=== INICIANDO CARGA DE DATOS ($widgetId) ===');
      print('Rol: ${widget.rol}');
      print('Tiempo: ${widget.tiempo}');

      setState(() {
        isLoading = true;
        error = '';
      });

      final now = DateTime.now();
      print('Fecha actual: ${now.toIso8601String()}');

      List<DateTime> dates = [];
      List<String> labelsList = [];

      // Configurar fechas según el tipo de tiempo
      if (widget.tiempo == 'semanal') {
        print('Configurando vista DIARIA (últimos 7 días)');
        // Últimos 7 días
        for (int i = 6; i >= 0; i--) {
          final dayDate = now.subtract(Duration(days: i));
          dates.add(dayDate);
          final dayLabel = _getDayLabel(dayDate);
          labelsList.add(dayLabel);
          print(
              'Día ${6 - i}: ${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')} - Etiqueta: $dayLabel');
        }
      } else {
        print('Configurando vista MENSUAL (últimos 7 meses)');
        // Últimos 7 meses
        for (int i = 6; i >= 0; i--) {
          final monthDate = DateTime(now.year, now.month - i, 1);
          dates.add(monthDate);
          final monthLabel = _getMonthLabel(monthDate);
          labelsList.add(monthLabel);
          print(
              'Mes ${6 - i}: ${monthDate.toIso8601String()} - Etiqueta: $monthLabel');
        }
      }

      List<FlSpot> spotsList = [];
      print('=== INICIANDO CONSULTAS ($widgetId) ===');

      for (int i = 0; i < dates.length; i++) {
        print('\n--- Consulta ${i + 1} de ${dates.length} ($widgetId) ---');
        final count = await _getUserCount(dates[i], i == dates.length - 1);
        spotsList.add(FlSpot(i.toDouble(), count.toDouble()));
        print('Resultado: ${count} usuarios para índice $i ($widgetId)');
      }

      print('\n=== RESULTADOS FINALES ($widgetId) ===');
      print('Total de puntos: ${spotsList.length}');
      for (int i = 0; i < spotsList.length && i < labelsList.length; i++) {
        print(
            'Punto $i: ${labelsList[i]} = ${spotsList[i].y.toInt()} usuarios ($widgetId)');
      }

      setState(() {
        spots = spotsList;
        labels = labelsList;
        isLoading = false;
      });

      print('=== CARGA COMPLETADA ($widgetId) ===');
    } catch (e) {
      print('ERROR EN _loadData: $e');
      setState(() {
        error = 'Error al cargar datos: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<int> _getUserCount(DateTime date, bool isLast) async {
    try {
      print('CONSULTA para fecha: ${date.day}/${date.month}/${date.year}');

      if (widget.tiempo == 'semanal') {
        // Para días: buscar usuarios registrados en ese día específico
        String fechaBuscada =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        print('  Buscando usuarios registrados el: $fechaBuscada');
        print('  Filtro rol: ${widget.rol}');

        // NUEVA ESTRATEGIA: Usar cast a date para comparación exacta
        final response = await SupaFlow.client
            .from('usuarios')
            .select('id, fecha_registro, rol, nombres, apellidos')
            .eq('rol', widget.rol)
            .gte('fecha_registro', '${fechaBuscada}T00:00:00')
            .lt('fecha_registro', '${fechaBuscada}T23:59:59');

        print(
            '  Query: fecha_registro >= \'${fechaBuscada}T00:00:00\' AND fecha_registro < \'${fechaBuscada}T23:59:59\'');
        print('  Usuarios encontrados: ${response?.length ?? 0}');

        if (response != null && response.isNotEmpty) {
          print('  Detalles de usuarios encontrados:');
          for (var user in response) {
            String fechaRegistro = user['fecha_registro'] ?? '';
            String fechaExtracta = fechaRegistro.contains('T')
                ? fechaRegistro.split('T')[0]
                : fechaRegistro.split(' ')[0];
            print(
                '    - ${user['nombres']} ${user['apellidos']} (${user['rol']}) - $fechaRegistro');
            print(
                '      -> Fecha extraída: $fechaExtracta (¿coincide con $fechaBuscada?)');
          }
        } else {
          print('  No se encontraron usuarios en este día');

          // DEBUG: Buscar TODOS los usuarios para ver qué fechas tenemos
          print(
              '  --- DEBUG: Consultando TODOS los usuarios con rol ${widget.rol} ---');
          final allUsers = await SupaFlow.client
              .from('usuarios')
              .select('id, fecha_registro, nombres, apellidos')
              .eq('rol', widget.rol);

          if (allUsers != null && allUsers.isNotEmpty) {
            print('  Todos los usuarios encontrados:');
            for (var user in allUsers) {
              String fechaRegistro = user['fecha_registro'] ?? '';
              String fechaExtracta = fechaRegistro.contains('T')
                  ? fechaRegistro.split('T')[0]
                  : fechaRegistro.split(' ')[0];
              print(
                  '    - ${user['nombres']} ${user['apellidos']} - $fechaRegistro (fecha: $fechaExtracta)');
            }
          }
          print('  --- FIN DEBUG ---');
        }

        return response?.length ?? 0;
      } else {
        // Para meses: contar usuarios registrados en todo el mes
        DateTime startDate = DateTime(date.year, date.month, 1, 0, 0, 0);
        // CORRECCIÓN: Usar siempre el mes completo, no DateTime.now()
        DateTime endDate =
            DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);

        print('  CONSULTA MENSUAL: ${date.month}/${date.year}');
        print(
            '  Rango completo del mes: ${startDate.toIso8601String()} hasta ${endDate.toIso8601String()}');
        print('  Filtro rol: ${widget.rol}');

        final response = await SupaFlow.client
            .from('usuarios')
            .select('id, fecha_registro, rol, nombres, apellidos')
            .eq('rol', widget.rol)
            .gte('fecha_registro', startDate.toIso8601String())
            .lte('fecha_registro', endDate.toIso8601String());

        print('  Usuarios encontrados: ${response?.length ?? 0}');

        if (response != null && response.isNotEmpty) {
          print('  Detalles de usuarios encontrados:');
          for (var user in response) {
            print(
                '    - ${user['nombres']} ${user['apellidos']} (${user['rol']}) - ${user['fecha_registro']}');
          }
        } else {
          print('  No se encontraron usuarios en este mes');
        }

        return response?.length ?? 0;
      }
    } catch (e) {
      print('ERROR EN _getUserCount: $e');
      return 0;
    }
  }

  String _getDayLabel(DateTime date) {
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    // date.weekday devuelve 1=Monday, 2=Tuesday, etc., hasta 7=Sunday
    return days[date.weekday - 1];
  }

  String _getMonthLabel(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return months[date.month - 1];
  }

  String get _title {
    String tipoUsuario = widget.rol == 'usuario' ? 'usuarios' : 'proveedores';
    String periodo = widget.tiempo == 'semanal' ? 'diario' : 'mensual';
    return 'Crecimiento $periodo de $tipoUsuario';
  }

  double _calculateInterval() {
    if (spots.isEmpty) return 1;
    double maxValue = 0;
    for (var spot in spots) {
      if (spot.y > maxValue) maxValue = spot.y;
    }
    if (maxValue <= 10) return 2;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    if (maxValue <= 500) return 100;
    return (maxValue / 5).ceil().toDouble();
  }

  double _getMaxY() {
    if (spots.isEmpty) return 100;
    double maxValue = 0;
    for (var spot in spots) {
      if (spot.y > maxValue) maxValue = spot.y;
    }
    return (maxValue * 1.2);
  }

  @override
  Widget build(BuildContext context) {
    // Generar una clave única para este widget específico basada en timestamp
    final uniqueKey =
        '${widget.rol}_${widget.tiempo}_${DateTime.now().millisecondsSinceEpoch}';

    return Container(
      key: ValueKey(uniqueKey), // Clave única para evitar conflictos
      width: widget.width ?? double.infinity,
      height: widget.height ?? 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
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
        key: ValueKey('column_$uniqueKey'), // Clave única para la columna
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _title,
            style: FlutterFlowTheme.of(context).headlineSmall.override(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0B6244),
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
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
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
                    : spots.isEmpty
                        ? Center(
                            child: Text(
                              'No hay datos disponibles',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 14,
                              ),
                            ),
                          )
                        : LineChart(
                            key: ValueKey(
                                'chart_$uniqueKey'), // Clave única para el gráfico
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                drawHorizontalLine: true,
                                horizontalInterval: _calculateInterval(),
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Color(0xFFE2E8F0),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval:
                                        1, // CORRECCIÓN: Evita ticks fraccionarios
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      // Filtrar solo enteros para evitar duplicados
                                      if (value % 1 != 0)
                                        return SizedBox.shrink();

                                      final index = value.toInt();
                                      if (index >= 0 && index < labels.length) {
                                        return Padding(
                                          padding: EdgeInsets.only(top: 8),
                                          child: Text(
                                            labels[index],
                                            style: TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        );
                                      }
                                      return SizedBox.shrink();
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: _calculateInterval(),
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              minX: 0,
                              maxX: (labels.length - 1).toDouble(),
                              minY: 0,
                              maxY: _getMaxY(),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: Color(0xFF0B6244),
                                  barWidth: 2,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 3,
                                        color: Color(0xFF0B6244),
                                        strokeWidth: 0,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Color(0xFF0B6244).withOpacity(0.1),
                                  ),
                                ),
                              ],
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((touchedSpot) {
                                      final index = touchedSpot.spotIndex;
                                      final value = touchedSpot.y.toInt();
                                      final label = index < labels.length
                                          ? labels[index]
                                          : '';

                                      return LineTooltipItem(
                                        '$label\n$value ${widget.rol}s',
                                        TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
