import '../database.dart';

class CleanupProgramadoTable extends SupabaseTable<CleanupProgramadoRow> {
  @override
  String get tableName => 'cleanup_programado';

  @override
  CleanupProgramadoRow createRow(Map<String, dynamic> data) =>
      CleanupProgramadoRow(data);
}

class CleanupProgramadoRow extends SupabaseDataRow {
  CleanupProgramadoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CleanupProgramadoTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get usuarioId => getField<String>('usuario_id')!;
  set usuarioId(String value) => setField<String>('usuario_id', value);

  String get solicitudId => getField<String>('solicitud_id')!;
  set solicitudId(String value) => setField<String>('solicitud_id', value);

  DateTime get programadoEn => getField<DateTime>('programado_en')!;
  set programadoEn(DateTime value) =>
      setField<DateTime>('programado_en', value);

  DateTime get ejecutarEn => getField<DateTime>('ejecutar_en')!;
  set ejecutarEn(DateTime value) => setField<DateTime>('ejecutar_en', value);

  bool? get ejecutado => getField<bool>('ejecutado');
  set ejecutado(bool? value) => setField<bool>('ejecutado', value);

  DateTime? get ejecutadoEn => getField<DateTime>('ejecutado_en');
  set ejecutadoEn(DateTime? value) => setField<DateTime>('ejecutado_en', value);

  int? get conversacionesEliminadas =>
      getField<int>('conversaciones_eliminadas');
  set conversacionesEliminadas(int? value) =>
      setField<int>('conversaciones_eliminadas', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
