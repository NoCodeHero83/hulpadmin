import '../database.dart';

class FavoritosTable extends SupabaseTable<FavoritosRow> {
  @override
  String get tableName => 'favoritos';

  @override
  FavoritosRow createRow(Map<String, dynamic> data) => FavoritosRow(data);
}

class FavoritosRow extends SupabaseDataRow {
  FavoritosRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => FavoritosTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get usuarioId => getField<String>('usuario_id')!;
  set usuarioId(String value) => setField<String>('usuario_id', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);

  String get profesionalServicioId =>
      getField<String>('profesional_servicio_id')!;
  set profesionalServicioId(String value) =>
      setField<String>('profesional_servicio_id', value);
}
