import '../database.dart';

class ChatsSolicitudTable extends SupabaseTable<ChatsSolicitudRow> {
  @override
  String get tableName => 'chats_solicitud';

  @override
  ChatsSolicitudRow createRow(Map<String, dynamic> data) =>
      ChatsSolicitudRow(data);
}

class ChatsSolicitudRow extends SupabaseDataRow {
  ChatsSolicitudRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ChatsSolicitudTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get solicitudId => getField<String>('solicitud_id')!;
  set solicitudId(String value) => setField<String>('solicitud_id', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);

  DateTime? get ultimoMensajeEn => getField<DateTime>('ultimo_mensaje_en');
  set ultimoMensajeEn(DateTime? value) =>
      setField<DateTime>('ultimo_mensaje_en', value);
}
