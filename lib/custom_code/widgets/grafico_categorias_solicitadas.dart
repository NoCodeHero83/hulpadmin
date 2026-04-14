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

class GraficoCategoriasSolicitadas extends StatefulWidget {
  const GraficoCategoriasSolicitadas({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<GraficoCategoriasSolicitadas> createState() =>
      _GraficoCategoriasSolicitadasState();
}

class _GraficoCategoriasSolicitadasState
    extends State<GraficoCategoriasSolicitadas> {
  List<PieChartSectionData> pieSections = [];
  bool isLoading = true;
  String error = '';
  int totalSolicitudes = 0;

  Map<String, int> conteoCategorias = {};
  List<String> nombresCategorias = [];

  // Colores predefinidos para las categorías
  final List<Color> coloresDisponibles = [
    Color(0xFF9CA3AF), // Gris
    Color(0xFFF3E8D0), // Beige/Crema
    Color(0xFF10B981), // Verde
    Color(0xFFEF4444), // Rojo
    Color(0xFF3B82F6), // Azul
    Color(0xFF8B5CF6), // Morado
    Color(0xFFF59E0B), // Amarillo
    Color(0xFF06B6D4), // Cian
    Color(0xFFEC4899), // Rosa
    Color(0xFF84CC16), // Lima
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('=== INICIANDO CARGA CATEGORÍAS SOLICITADAS ===');

      setState(() {
        isLoading = true;
        error = '';
      });

      // Consultar solicitudes con JOIN a categorías
      final response =
          await SupaFlow.client.from('solicitudes_servicio').select('''
            id,
            servicio_id,
            creado_en,
            servicios!inner(
              id,
              nombre,
              subcategoria_id,
              subcategorias!inner(
                id,
                nombre,
                categoria_id,
                categorias!inner(
                  id,
                  nombre
                )
              )
            )
          ''').order('creado_en', ascending: false);

      print('Solicitudes con categorías encontradas: ${response?.length ?? 0}');

      if (response == null) {
        throw Exception('No se pudo consultar la base de datos');
      }

      // Contar solicitudes por categoría
      Map<String, int> tempConteo = {};
      int total = 0;

      for (var solicitud in response) {
        try {
          // Extraer nombre de categoría desde el JOIN
          var servicios = solicitud['servicios'];
          if (servicios != null) {
            var subcategorias = servicios['subcategorias'];
            if (subcategorias != null) {
              var categorias = subcategorias['categorias'];
              if (categorias != null) {
                String nombreCategoria =
                    categorias['nombre']?.toString() ?? 'Sin categoría';

                tempConteo[nombreCategoria] =
                    (tempConteo[nombreCategoria] ?? 0) + 1;
                total++;

                print(
                    'Solicitud ${solicitud['id']}: Categoría "$nombreCategoria" - Servicio: ${servicios['nombre']} - Fecha: ${solicitud['creado_en']}');
              }
            }
          }
        } catch (e) {
          print('Error procesando solicitud ${solicitud['id']}: $e');
        }
      }

      print('\n=== CONTEO POR CATEGORÍAS ===');

      // Ordenar categorías por cantidad (mayor a menor)
      var categoriasOrdenadas = tempConteo.entries.toList();
      categoriasOrdenadas.sort((a, b) => b.value.compareTo(a.value));

      List<String> nombresOrdenados = [];
      categoriasOrdenadas.forEach((entry) {
        String nombreCategoria = entry.key;
        int cantidad = entry.value;
        double porcentaje = total > 0 ? (cantidad / total) * 100 : 0;

        nombresOrdenados.add(nombreCategoria);
        print(
            '$nombreCategoria: $cantidad solicitudes (${porcentaje.toStringAsFixed(1)}%)');
      });

      // Crear secciones del gráfico de torta
      List<PieChartSectionData> sections = [];

      for (int i = 0; i < categoriasOrdenadas.length; i++) {
        var entry = categoriasOrdenadas[i];
        String nombreCategoria = entry.key;
        int cantidad = entry.value;

        if (cantidad > 0) {
          double porcentaje = total > 0 ? (cantidad / total) * 100 : 0;
          Color color = coloresDisponibles[i % coloresDisponibles.length];

          sections.add(
            PieChartSectionData(
              color: color,
              value: cantidad.toDouble(),
              title: '${porcentaje.toStringAsFixed(0)}%',
              radius: 80,
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: porcentaje > 15 ? Colors.white : Colors.black,
              ),
              badgeWidget: null,
            ),
          );
        }
      }

      print('\n=== RESULTADOS FINALES ===');
      print('Total solicitudes procesadas: $total');
      print('Categorías encontradas: ${tempConteo.length}');
      print('Secciones creadas: ${sections.length}');

      setState(() {
        conteoCategorias = tempConteo;
        nombresCategorias = nombresOrdenados;
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
            'Categorías más solicitadas',
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
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: nombresCategorias
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      String nombreCategoria = entry.value;
                                      Color color = coloresDisponibles[
                                          index % coloresDisponibles.length];
                                      int cantidad =
                                          conteoCategorias[nombreCategoria] ??
                                              0;
                                      double porcentaje = totalSolicitudes > 0
                                          ? (cantidad / totalSolicitudes) * 100
                                          : 0;

                                      return Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 6),
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
                                                    nombreCategoria,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xFF374151),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    '${porcentaje.toStringAsFixed(0)}%',
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
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}
