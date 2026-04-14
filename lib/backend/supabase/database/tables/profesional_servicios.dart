import '../database.dart';

class ProfesionalServiciosTable extends SupabaseTable<ProfesionalServiciosRow> {
  @override
  String get tableName => 'profesional_servicios';

  @override
  ProfesionalServiciosRow createRow(Map<String, dynamic> data) =>
      ProfesionalServiciosRow(data);
}

class ProfesionalServiciosRow extends SupabaseDataRow {
  ProfesionalServiciosRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ProfesionalServiciosTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get usuarioId => getField<String>('usuario_id')!;
  set usuarioId(String value) => setField<String>('usuario_id', value);

  String get servicioId => getField<String>('servicio_id')!;
  set servicioId(String value) => setField<String>('servicio_id', value);

  DateTime? get publicadoEn => getField<DateTime>('publicado_en');
  set publicadoEn(DateTime? value) => setField<DateTime>('publicado_en', value);
}
