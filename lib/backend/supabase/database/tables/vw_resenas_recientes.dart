import '../database.dart';

class VwResenasRecientesTable extends SupabaseTable<VwResenasRecientesRow> {
  @override
  String get tableName => 'vw_resenas_recientes';

  @override
  VwResenasRecientesRow createRow(Map<String, dynamic> data) =>
      VwResenasRecientesRow(data);
}

class VwResenasRecientesRow extends SupabaseDataRow {
  VwResenasRecientesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwResenasRecientesTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get solicitudServicioId => getField<String>('solicitud_servicio_id');
  set solicitudServicioId(String? value) =>
      setField<String>('solicitud_servicio_id', value);

  String? get usuarioId => getField<String>('usuario_id');
  set usuarioId(String? value) => setField<String>('usuario_id', value);

  String? get proveedorId => getField<String>('proveedor_id');
  set proveedorId(String? value) => setField<String>('proveedor_id', value);

  int? get calificacion => getField<int>('calificacion');
  set calificacion(int? value) => setField<int>('calificacion', value);

  String? get comentario => getField<String>('comentario');
  set comentario(String? value) => setField<String>('comentario', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);

  String? get nombreUsuario => getField<String>('nombre_usuario');
  set nombreUsuario(String? value) => setField<String>('nombre_usuario', value);
}
