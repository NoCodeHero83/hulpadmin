import '../database.dart';

class VwDashboardMetricasTable extends SupabaseTable<VwDashboardMetricasRow> {
  @override
  String get tableName => 'vw_dashboard_metricas';

  @override
  VwDashboardMetricasRow createRow(Map<String, dynamic> data) =>
      VwDashboardMetricasRow(data);
}

class VwDashboardMetricasRow extends SupabaseDataRow {
  VwDashboardMetricasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwDashboardMetricasTable();

  int? get serviciosPendientes => getField<int>('servicios_pendientes');
  set serviciosPendientes(int? value) =>
      setField<int>('servicios_pendientes', value);

  int? get serviciosActivos => getField<int>('servicios_activos');
  set serviciosActivos(int? value) => setField<int>('servicios_activos', value);

  int? get serviciosEnCurso => getField<int>('servicios_en_curso');
  set serviciosEnCurso(int? value) =>
      setField<int>('servicios_en_curso', value);

  int? get serviciosFinalizados => getField<int>('servicios_finalizados');
  set serviciosFinalizados(int? value) =>
      setField<int>('servicios_finalizados', value);

  int? get totalSolicitudesServicio =>
      getField<int>('total_solicitudes_servicio');
  set totalSolicitudesServicio(int? value) =>
      setField<int>('total_solicitudes_servicio', value);

  int? get totalProveedoresActivos =>
      getField<int>('total_proveedores_activos');
  set totalProveedoresActivos(int? value) =>
      setField<int>('total_proveedores_activos', value);

  int? get solicitudesHoyEntrantes =>
      getField<int>('solicitudes_hoy_entrantes');
  set solicitudesHoyEntrantes(int? value) =>
      setField<int>('solicitudes_hoy_entrantes', value);

  int? get solicitudesHoyActivas => getField<int>('solicitudes_hoy_activas');
  set solicitudesHoyActivas(int? value) =>
      setField<int>('solicitudes_hoy_activas', value);

  int? get solicitudesHoyFinalizadas =>
      getField<int>('solicitudes_hoy_finalizadas');
  set solicitudesHoyFinalizadas(int? value) =>
      setField<int>('solicitudes_hoy_finalizadas', value);

  int? get solicitudesProximasEntrantes =>
      getField<int>('solicitudes_proximas_entrantes');
  set solicitudesProximasEntrantes(int? value) =>
      setField<int>('solicitudes_proximas_entrantes', value);

  int? get solicitudesProximasActivas =>
      getField<int>('solicitudes_proximas_activas');
  set solicitudesProximasActivas(int? value) =>
      setField<int>('solicitudes_proximas_activas', value);

  double? get ingresosTotalesSemanales =>
      getField<double>('ingresos_totales_semanales');
  set ingresosTotalesSemanales(double? value) =>
      setField<double>('ingresos_totales_semanales', value);

  double? get ingresosTotalesMensuales =>
      getField<double>('ingresos_totales_mensuales');
  set ingresosTotalesMensuales(double? value) =>
      setField<double>('ingresos_totales_mensuales', value);

  double? get ingresosTotalesAnuales =>
      getField<double>('ingresos_totales_anuales');
  set ingresosTotalesAnuales(double? value) =>
      setField<double>('ingresos_totales_anuales', value);
}
