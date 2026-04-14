import '../database.dart';

class VwMensajesChatCompletoTable
    extends SupabaseTable<VwMensajesChatCompletoRow> {
  @override
  String get tableName => 'vw_mensajes_chat_completo';

  @override
  VwMensajesChatCompletoRow createRow(Map<String, dynamic> data) =>
      VwMensajesChatCompletoRow(data);
}

class VwMensajesChatCompletoRow extends SupabaseDataRow {
  VwMensajesChatCompletoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwMensajesChatCompletoTable();

  String? get mensajeId => getField<String>('mensaje_id');
  set mensajeId(String? value) => setField<String>('mensaje_id', value);

  String? get chatId => getField<String>('chat_id');
  set chatId(String? value) => setField<String>('chat_id', value);

  String? get tipoMensaje => getField<String>('tipo_mensaje');
  set tipoMensaje(String? value) => setField<String>('tipo_mensaje', value);

  String? get contenido => getField<String>('contenido');
  set contenido(String? value) => setField<String>('contenido', value);

  String? get archivoUrl => getField<String>('archivo_url');
  set archivoUrl(String? value) => setField<String>('archivo_url', value);

  String? get reciboId => getField<String>('recibo_id');
  set reciboId(String? value) => setField<String>('recibo_id', value);

  DateTime? get enviadoEn => getField<DateTime>('enviado_en');
  set enviadoEn(DateTime? value) => setField<DateTime>('enviado_en', value);

  String? get rolRemitente => getField<String>('rol_remitente');
  set rolRemitente(String? value) => setField<String>('rol_remitente', value);

  String? get remitenteNombres => getField<String>('remitente_nombres');
  set remitenteNombres(String? value) =>
      setField<String>('remitente_nombres', value);

  String? get remitenteApellidos => getField<String>('remitente_apellidos');
  set remitenteApellidos(String? value) =>
      setField<String>('remitente_apellidos', value);

  String? get remitenteFoto => getField<String>('remitente_foto');
  set remitenteFoto(String? value) => setField<String>('remitente_foto', value);

  String? get solicitudId => getField<String>('solicitud_id');
  set solicitudId(String? value) => setField<String>('solicitud_id', value);

  int? get ticket => getField<int>('ticket');
  set ticket(int? value) => setField<int>('ticket', value);

  String? get servicioNombre => getField<String>('servicio_nombre');
  set servicioNombre(String? value) =>
      setField<String>('servicio_nombre', value);

  String? get reciboTitulo => getField<String>('recibo_titulo');
  set reciboTitulo(String? value) => setField<String>('recibo_titulo', value);

  double? get reciboTotal => getField<double>('recibo_total');
  set reciboTotal(double? value) => setField<double>('recibo_total', value);

  String? get reciboEstado => getField<String>('recibo_estado');
  set reciboEstado(String? value) => setField<String>('recibo_estado', value);
}
