import '../database.dart';

class ReferenciasLaboralesTable extends SupabaseTable<ReferenciasLaboralesRow> {
  @override
  String get tableName => 'referencias_laborales';

  @override
  ReferenciasLaboralesRow createRow(Map<String, dynamic> data) =>
      ReferenciasLaboralesRow(data);
}

class ReferenciasLaboralesRow extends SupabaseDataRow {
  ReferenciasLaboralesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReferenciasLaboralesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get usuarioId => getField<String>('usuario_id')!;
  set usuarioId(String value) => setField<String>('usuario_id', value);

  String get nombreReferencia => getField<String>('nombre_referencia')!;
  set nombreReferencia(String value) =>
      setField<String>('nombre_referencia', value);

  String get telefonoReferencia => getField<String>('telefono_referencia')!;
  set telefonoReferencia(String value) =>
      setField<String>('telefono_referencia', value);

  String get relacionLaboral => getField<String>('relacion_laboral')!;
  set relacionLaboral(String value) =>
      setField<String>('relacion_laboral', value);
}
