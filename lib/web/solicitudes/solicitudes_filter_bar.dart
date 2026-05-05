import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/components/hulp_date_range_picker_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/custom_functions.dart' as functions;

String _normKey(String? s) {
  var t = s?.trim() ?? '';
  if (t.isEmpty) return '';
  t = t.toLowerCase();
  for (final p in const [
    ['á', 'a'],
    ['é', 'e'],
    ['í', 'i'],
    ['ó', 'o'],
    ['ú', 'u'],
    ['ü', 'u'],
    ['ñ', 'n'],
  ]) {
    t = t.replaceAll(p[0], p[1]);
  }
  return t;
}

/// Valor que entiende [DropdownButtonFormField]: debe coincidir con un [DropdownMenuItem.value].
String? _resolveMenuValue(String? selected, List<String> options) {
  if (selected == null || selected.trim().isEmpty) return null;
  if (options.contains(selected)) return selected;
  final key = _normKey(selected);
  for (final o in options) {
    if (_normKey(o) == key) return o;
  }
  return null;
}

class SolicitudesFilterBar extends StatelessWidget {
  const SolicitudesFilterBar({
    super.key,
    required this.estadoOptions,
    required this.categoriaOptions,
    required this.dropDownValue1,
    required this.dropDownValue2,
    required this.dateStart,
    required this.dateEnd,
    required this.resultCount,
    required this.onEstadoChanged,
    required this.onCategoriaChanged,
    required this.onEstadoReset,
    required this.onCategoriaReset,
    required this.onDateRangeSelected,
    required this.onDateReset,
  });

  final List<String> estadoOptions;
  final List<String> categoriaOptions;
  final String? dropDownValue1;
  final String? dropDownValue2;
  final DateTime? dateStart;
  final DateTime? dateEnd;
  final int resultCount;
  final ValueChanged<String?> onEstadoChanged;
  final ValueChanged<String?> onCategoriaChanged;
  final VoidCallback onEstadoReset;
  final VoidCallback onCategoriaReset;
  final void Function(DateTime start, DateTime end) onDateRangeSelected;
  final VoidCallback onDateReset;

  bool get _hasEstado => dropDownValue1 != null && dropDownValue1 != '';
  bool get _hasCategoria => dropDownValue2 != null && dropDownValue2 != '';

  @override
  Widget build(BuildContext context) {
    final bodyStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.inter(),
          fontSize: 16.0,
          letterSpacing: 0.0,
        );

    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0x7C766C4D), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 24.0, 0.0),
              child: Text(
                'Filtrar por:',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: const Color(0xFF4A4A4A),
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            _buildEstadoDropdown(context, bodyStyle),
            if (_hasEstado) _buildResetButton(onEstadoReset),
            _buildCategoriaDropdown(context, bodyStyle),
            if (_hasCategoria) _buildResetButton(onCategoriaReset),
            HulpDateRangePickerWidget(
              dateStart: dateStart,
              dateEnd: dateEnd,
              onDateRangeSelected: onDateRangeSelected,
              onReset: onDateReset,
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional(1.0, 0.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      0.0, 0.0, 12.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Numero de solicitudes:',
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              font: GoogleFonts.inter(),
                              color: const Color(0xFF0B6244),
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        resultCount.toString(),
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              font: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600),
                              color: const Color(0xFF0B6244),
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ].divide(const SizedBox(width: 12.0)),
        ),
      ),
    );
  }

  Widget _buildEstadoDropdown(BuildContext context, TextStyle bodyStyle) {
    final opts = List<String>.from(estadoOptions);
    final labels = functions.getStatus(opts);
    final labelFor = <String, String>{
      for (var i = 0; i < opts.length; i++) opts[i]: labels[i],
    };
    final selected = _resolveMenuValue(dropDownValue1, opts);

    return SizedBox(
      width: 200.0,
      height: 48.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFBFAF9),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0xFFDFDFDF), width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 4.0, 0.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: opts.isEmpty ? null : selected,
              hint: Text('Estado', style: bodyStyle),
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: FlutterFlowTheme.of(context).secondaryText, size: 24.0),
              style: bodyStyle,
              items: opts
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        labelFor[e] ?? e,
                        style: bodyStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: opts.isEmpty ? null : onEstadoChanged,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriaDropdown(BuildContext context, TextStyle bodyStyle) {
    final opts = List<String>.from(categoriaOptions);
    final selected = _resolveMenuValue(dropDownValue2, opts);

    return SizedBox(
      width: 200.0,
      height: 48.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFBFAF9),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0xFFDFDFDF), width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 4.0, 0.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: opts.isEmpty ? null : selected,
              hint: Text('Categoria', style: bodyStyle),
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: FlutterFlowTheme.of(context).secondaryText, size: 24.0),
              style: bodyStyle,
              items: opts
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        e,
                        style: bodyStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: opts.isEmpty ? null : onCategoriaChanged,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton(VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: onTap,
        child: const Icon(Icons.close, color: Color(0xFFE20E0E), size: 24.0),
      ),
    );
  }
}
