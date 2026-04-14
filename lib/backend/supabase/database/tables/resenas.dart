import '../database.dart';

class ResenasTable extends SupabaseTable<ResenasRow> {
  @override
  String get tableName => 'resenas';

  @override
  ResenasRow createRow(Map<String, dynamic> data) => ResenasRow(data);
}

class ResenasRow extends SupabaseDataRow {
  ResenasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ResenasTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get solicitudServicioId => getField<String>('solicitud_servicio_id')!;
  set solicitudServicioId(String value) =>
      setField<String>('solicitud_servicio_id', value);

  String get usuarioId => getField<String>('usuario_id')!;
  set usuarioId(String value) => setField<String>('usuario_id', value);

  String get proveedorId => getField<String>('proveedor_id')!;
  set proveedorId(String value) => setField<String>('proveedor_id', value);

  int get calificacion => getField<int>('calificacion')!;
  set calificacion(int value) => setField<int>('calificacion', value);

  String? get comentario => getField<String>('comentario');
  set comentario(String? value) => setField<String>('comentario', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);
}
