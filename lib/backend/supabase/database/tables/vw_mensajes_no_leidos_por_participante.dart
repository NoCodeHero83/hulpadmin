import '../database.dart';

class VwMensajesNoLeidosPorParticipanteTable
    extends SupabaseTable<VwMensajesNoLeidosPorParticipanteRow> {
  @override
  String get tableName => 'vw_mensajes_no_leidos_por_participante';

  @override
  VwMensajesNoLeidosPorParticipanteRow createRow(Map<String, dynamic> data) =>
      VwMensajesNoLeidosPorParticipanteRow(data);
}

class VwMensajesNoLeidosPorParticipanteRow extends SupabaseDataRow {
  VwMensajesNoLeidosPorParticipanteRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwMensajesNoLeidosPorParticipanteTable();

  String? get chatId => getField<String>('chat_id');
  set chatId(String? value) => setField<String>('chat_id', value);

  String? get solicitudId => getField<String>('solicitud_id');
  set solicitudId(String? value) => setField<String>('solicitud_id', value);

  DateTime? get ultimoMensajeEn => getField<DateTime>('ultimo_mensaje_en');
  set ultimoMensajeEn(DateTime? value) =>
      setField<DateTime>('ultimo_mensaje_en', value);

  String? get usuarioId => getField<String>('usuario_id');
  set usuarioId(String? value) => setField<String>('usuario_id', value);

  int? get cantidadNoLeidos => getField<int>('cantidad_no_leidos');
  set cantidadNoLeidos(int? value) =>
      setField<int>('cantidad_no_leidos', value);
}
