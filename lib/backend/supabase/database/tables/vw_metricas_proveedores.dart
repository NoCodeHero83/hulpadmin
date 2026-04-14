import '../database.dart';

class VwMetricasProveedoresTable
    extends SupabaseTable<VwMetricasProveedoresRow> {
  @override
  String get tableName => 'vw_metricas_proveedores';

  @override
  VwMetricasProveedoresRow createRow(Map<String, dynamic> data) =>
      VwMetricasProveedoresRow(data);
}

class VwMetricasProveedoresRow extends SupabaseDataRow {
  VwMetricasProveedoresRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwMetricasProveedoresTable();

  String? get proveedorId => getField<String>('proveedor_id');
  set proveedorId(String? value) => setField<String>('proveedor_id', value);

  String? get nombreProveedor => getField<String>('nombre_proveedor');
  set nombreProveedor(String? value) =>
      setField<String>('nombre_proveedor', value);

  String? get correoElectronico => getField<String>('correo_electronico');
  set correoElectronico(String? value) =>
      setField<String>('correo_electronico', value);

  String? get telefono => getField<String>('telefono');
  set telefono(String? value) => setField<String>('telefono', value);

  double? get ingresosSemanales => getField<double>('ingresos_semanales');
  set ingresosSemanales(double? value) =>
      setField<double>('ingresos_semanales', value);

  double? get porcentajeVsSemanaAnterior =>
      getField<double>('porcentaje_vs_semana_anterior');
  set porcentajeVsSemanaAnterior(double? value) =>
      setField<double>('porcentaje_vs_semana_anterior', value);

  int? get serviciosRealizados => getField<int>('servicios_realizados');
  set serviciosRealizados(int? value) =>
      setField<int>('servicios_realizados', value);

  double? get porcentajeServiciosVsTrimestreAnterior =>
      getField<double>('porcentaje_servicios_vs_trimestre_anterior');
  set porcentajeServiciosVsTrimestreAnterior(double? value) =>
      setField<double>('porcentaje_servicios_vs_trimestre_anterior', value);

  double? get ingresosSemanaAnterior =>
      getField<double>('ingresos_semana_anterior');
  set ingresosSemanaAnterior(double? value) =>
      setField<double>('ingresos_semana_anterior', value);

  double? get serviciosTrimestreActual =>
      getField<double>('servicios_trimestre_actual');
  set serviciosTrimestreActual(double? value) =>
      setField<double>('servicios_trimestre_actual', value);

  double? get serviciosTrimestreAnterior =>
      getField<double>('servicios_trimestre_anterior');
  set serviciosTrimestreAnterior(double? value) =>
      setField<double>('servicios_trimestre_anterior', value);

  double? get serviciosSemanaActual =>
      getField<double>('servicios_semana_actual');
  set serviciosSemanaActual(double? value) =>
      setField<double>('servicios_semana_actual', value);

  DateTime? get fechaActualizacion => getField<DateTime>('fecha_actualizacion');
  set fechaActualizacion(DateTime? value) =>
      setField<DateTime>('fecha_actualizacion', value);
}
