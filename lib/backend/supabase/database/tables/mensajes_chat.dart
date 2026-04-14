import '../database.dart';

class MensajesChatTable extends SupabaseTable<MensajesChatRow> {
  @override
  String get tableName => 'mensajes_chat';

  @override
  MensajesChatRow createRow(Map<String, dynamic> data) => MensajesChatRow(data);
}

class MensajesChatRow extends SupabaseDataRow {
  MensajesChatRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MensajesChatTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get chatId => getField<String>('chat_id')!;
  set chatId(String value) => setField<String>('chat_id', value);

  String get remitenteId => getField<String>('remitente_id')!;
  set remitenteId(String value) => setField<String>('remitente_id', value);

  String get rolRemitente => getField<String>('rol_remitente')!;
  set rolRemitente(String value) => setField<String>('rol_remitente', value);

  String get tipoMensaje => getField<String>('tipo_mensaje')!;
  set tipoMensaje(String value) => setField<String>('tipo_mensaje', value);

  String? get contenido => getField<String>('contenido');
  set contenido(String? value) => setField<String>('contenido', value);

  String? get archivoUrl => getField<String>('archivo_url');
  set archivoUrl(String? value) => setField<String>('archivo_url', value);

  DateTime? get enviadoEn => getField<DateTime>('enviado_en');
  set enviadoEn(DateTime? value) => setField<DateTime>('enviado_en', value);

  String? get reciboId => getField<String>('recibo_id');
  set reciboId(String? value) => setField<String>('recibo_id', value);

  bool get leido => getField<bool>('leido')!;
  set leido(bool value) => setField<bool>('leido', value);
}
