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

      print('Solicitudes encontradas: ${response?.length ?? 0}');

      if (response == null) {
        throw Exception('No se pudo consultar la base de datos');
      }

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

      tempConteo.forEach((estado, cantidad) {
        if (cantidad > 0) {
          double porcentaje = total > 0 ? (cantidad / total) * 100 : 0;

          sections.add(
            PieChartSectionData(
              color: estadosColores[estado]!,
              value: cantidad.toDouble(),
              title: '${porcentaje.toStringAsFixed(1)}%',
              radius: 80,
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
          SizedBox(height: 20),

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
                        : Row(
                            children: [
                              // Gráfico de torta
                              Expanded(
                                flex: 2,
                                child: PieChart(
                                  PieChartData(
                                    sections: pieSections,
                                    centerSpaceRadius: 0,
                                    sectionsSpace: 2,
                                    startDegreeOffset: -90,
                                    pieTouchData: PieTouchData(
                                      enabled: true,
                                      touchCallback: (FlTouchEvent event,
                                          pieTouchResponse) {
                                        // Aquí puedes agregar interactividad si lo deseas
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 20),

                              // Leyenda
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: estadosLabels.entries.map((entry) {
                                    String estado = entry.key;
                                    String label = entry.value;
                                    Color color = estadosColores[estado]!;
                                    int cantidad = conteoEstados[estado] ?? 0;
                                    double porcentaje = totalSolicitudes > 0
                                        ? (cantidad / totalSolicitudes) * 100
                                        : 0;

                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  label,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF374151),
                                                  ),
                                                ),
                                                Text(
                                                  '${porcentaje.toStringAsFixed(1)}%',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF9CA3AF),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}
