import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import '/components/solicitud_status_badge_widget.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SolicitudesDataTable extends StatelessWidget {
  const SolicitudesDataTable({
    super.key,
    required this.data,
    required this.controller,
    required this.onStatusTap,
    required this.onDelete,
    required this.onViewDetails,
    required this.onEdit,
  });

  final List<VwSolicitudesServiciosCompletaRow> data;
  final FlutterFlowDataTableController<VwSolicitudesServiciosCompletaRow>
      controller;
  final void Function(VwSolicitudesServiciosCompletaRow item, int index)
      onStatusTap;
  final void Function(VwSolicitudesServiciosCompletaRow item) onDelete;
  final void Function(VwSolicitudesServiciosCompletaRow item) onViewDetails;
  final void Function(VwSolicitudesServiciosCompletaRow item) onEdit;

  @override
  Widget build(BuildContext context) {
    return FlutterFlowDataTable<VwSolicitudesServiciosCompletaRow>(
      controller: controller,
      data: data,
      columnsBuilder: (onSortChanged) => _buildColumns(context),
      dataRowBuilder: (item, index, selected, onSelectChanged) =>
          _buildRow(context, item, index),
      paginated: true,
      selectable: false,
      hidePaginator: false,
      showFirstLastButtons: true,
      width: MediaQuery.sizeOf(context).width * 1.0,
      height: MediaQuery.sizeOf(context).height * 1.0,
      headingRowHeight: 56.0,
      dataRowHeight: 60.0,
      columnSpacing: 20.0,
      headingRowColor: const Color(0xFFFBFAF9),
      borderRadius: BorderRadius.circular(20.0),
      addHorizontalDivider: false,
      addTopAndBottomDivider: false,
      hideDefaultHorizontalDivider: true,
      addVerticalDivider: false,
    );
  }

  List<DataColumn2> _buildColumns(BuildContext context) {
    final headerStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.inter(fontWeight: FontWeight.w600),
          fontSize: 16.0,
          letterSpacing: 0.0,
          fontWeight: FontWeight.w600,
        );

    return [
      _col('Ticket', headerStyle),
      _col('Estado', headerStyle, fixedWidth: 160.0),
      _col('Fecha y hora', headerStyle),
      _col('Usu. Solicitante', headerStyle),
      _col('Direccion', headerStyle),
      _col('Categoria', headerStyle),
      _col('Precio', headerStyle),
      _col('ID Proveedor', headerStyle),
      _col('Acciones', headerStyle),
    ];
  }

  DataColumn2 _col(String label, TextStyle style, {double? fixedWidth}) {
    return DataColumn2(
      label: DefaultTextStyle.merge(
        softWrap: true,
        child: Text(label, style: style),
      ),
      fixedWidth: fixedWidth,
    );
  }

  DataRow _buildRow(
    BuildContext context,
    VwSolicitudesServiciosCompletaRow item,
    int index,
  ) {
    final bodyStyle = FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.inter(),
          letterSpacing: 0.0,
        );

    return DataRow(
      color: WidgetStateProperty.all(
        FlutterFlowTheme.of(context).secondaryBackground,
      ),
      cells: [
        // Ticket
        DataCell(Text(
          '#${valueOrDefault<String>(item.ticket?.toString(), '0000')}',
          style: bodyStyle.override(
            font: GoogleFonts.inter(),
            color: const Color(0xFF4A4A4A),
            fontSize: 16.0,
          ),
        )),
        // Estado
        DataCell(SolicitudStatusBadgeWidget(
          estado: item.estadoSolicitud ?? '',
          showArrow: true,
          onTap: () => onStatusTap(item, index),
        )),
        // Fecha y hora
        DataCell(Text(
          valueOrDefault<String>(
            '${dateTimeFormat("jm", item.hora?.time)} -  ${dateTimeFormat("d/M/y", item.fecha)}',
            'sin fecha',
          ),
          style: bodyStyle,
        )),
        // Usuario solicitante
        DataCell(Text(
          valueOrDefault<String>(
            '${item.clienteNombres} ${item.clienteApellidos}',
            'Sin usuario',
          ),
          style: bodyStyle,
        )),
        // Direccion
        DataCell(InkWell(
          splashColor: Colors.transparent,
          onTap: () async {
            await Clipboard.setData(
                ClipboardData(text: item.ubicacion ?? ''));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Copiado al portapapeles',
                  style: TextStyle(
                      color: FlutterFlowTheme.of(context)
                          .secondaryBackground,
                      fontSize: 14.0)),
              duration: const Duration(milliseconds: 4000),
              backgroundColor: FlutterFlowTheme.of(context).success,
            ));
          },
          child: Text(
            valueOrDefault<String>(item.ubicacion, 'Sin direccion'),
            style: bodyStyle,
          ),
        )),
        // Categoria
        DataCell(Text(
          valueOrDefault<String>(item.categoriaNombre, 'Sin datos'),
          style: bodyStyle,
        )),
        // Precio
        DataCell(Text(
          valueOrDefault<String>(
            '\$ ${valueOrDefault<String>(item.precioTotal?.toString(), '0')}',
            'Sin datos',
          ),
          style: bodyStyle.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w500),
            color: const Color(0xFF0D70E7),
            fontWeight: FontWeight.w500,
          ),
        )),
        // ID Proveedor
        DataCell(Text(
          valueOrDefault<String>(
              item.proveedorIdUsuario?.toString(), 'Sin datos'),
          style: bodyStyle,
        )),
        // Acciones
        DataCell(Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            FlutterFlowIconButton(
              borderRadius: 10.0,
              buttonSize: 35.0,
              fillColor: const Color(0xFFB81C2C),
              icon: Icon(Icons.close,
                  color: FlutterFlowTheme.of(context).info, size: 18.0),
              onPressed: () => onDelete(item),
            ),
            FlutterFlowIconButton(
              borderRadius: 10.0,
              buttonSize: 34.0,
              fillColor: const Color(0xFF606060),
              icon: Icon(Icons.search_rounded,
                  color: FlutterFlowTheme.of(context).info, size: 18.0),
              onPressed: () => onViewDetails(item),
            ),
            FlutterFlowIconButton(
              borderRadius: 10.0,
              buttonSize: 34.0,
              fillColor: FlutterFlowTheme.of(context).warning,
              icon: Icon(Icons.edit,
                  color: FlutterFlowTheme.of(context).info, size: 18.0),
              onPressed: () => onEdit(item),
            ),
          ].divide(const SizedBox(width: 3.0)),
        )),
      ],
    );
  }
}
