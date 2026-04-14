import '../database.dart';

class ConversacionesTable extends SupabaseTable<ConversacionesRow> {
  @override
  String get tableName => 'conversaciones';

  @override
  ConversacionesRow createRow(Map<String, dynamic> data) =>
      ConversacionesRow(data);
}

class ConversacionesRow extends SupabaseDataRow {
  ConversacionesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ConversacionesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get usuarioId => getField<String>('usuario_id')!;
  set usuarioId(String value) => setField<String>('usuario_id', value);

  String get mensaje => getField<String>('mensaje')!;
  set mensaje(String value) => setField<String>('mensaje', value);

  String get tipo => getField<String>('tipo')!;
  set tipo(String value) => setField<String>('tipo', value);

  dynamic? get metadata => getField<dynamic>('metadata');
  set metadata(dynamic? value) => setField<dynamic>('metadata', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);

  String? get tipoMensaje => getField<String>('tipoMensaje');
  set tipoMensaje(String? value) => setField<String>('tipoMensaje', value);
}
