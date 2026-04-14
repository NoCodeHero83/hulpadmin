import '../database.dart';

class CalificacionesTable extends SupabaseTable<CalificacionesRow> {
  @override
  String get tableName => 'calificaciones';

  @override
  CalificacionesRow createRow(Map<String, dynamic> data) =>
      CalificacionesRow(data);
}

class CalificacionesRow extends SupabaseDataRow {
  CalificacionesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CalificacionesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get solicitudId => getField<String>('solicitud_id')!;
  set solicitudId(String value) => setField<String>('solicitud_id', value);

  String get usuarioId => getField<String>('usuario_id')!;
  set usuarioId(String value) => setField<String>('usuario_id', value);

  String get proveedorId => getField<String>('proveedor_id')!;
  set proveedorId(String value) => setField<String>('proveedor_id', value);

  int get puntaje => getField<int>('puntaje')!;
  set puntaje(int value) => setField<int>('puntaje', value);

  String? get comentario => getField<String>('comentario');
  set comentario(String? value) => setField<String>('comentario', value);

  DateTime? get fecha => getField<DateTime>('fecha');
  set fecha(DateTime? value) => setField<DateTime>('fecha', value);
}
