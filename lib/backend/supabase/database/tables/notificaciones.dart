import '../database.dart';

class NotificacionesTable extends SupabaseTable<NotificacionesRow> {
  @override
  String get tableName => 'notificaciones';

  @override
  NotificacionesRow createRow(Map<String, dynamic> data) =>
      NotificacionesRow(data);
}

class NotificacionesRow extends SupabaseDataRow {
  NotificacionesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => NotificacionesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get usuarioId => getField<String>('usuario_id');
  set usuarioId(String? value) => setField<String>('usuario_id', value);

  String? get proveedorId => getField<String>('proveedor_id');
  set proveedorId(String? value) => setField<String>('proveedor_id', value);

  String get titulo => getField<String>('titulo')!;
  set titulo(String value) => setField<String>('titulo', value);

  String get mensaje => getField<String>('mensaje')!;
  set mensaje(String value) => setField<String>('mensaje', value);

  bool? get leido => getField<bool>('leido');
  set leido(bool? value) => setField<bool>('leido', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);
}
