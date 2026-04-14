import '../database.dart';

class SubcategoriasTable extends SupabaseTable<SubcategoriasRow> {
  @override
  String get tableName => 'subcategorias';

  @override
  SubcategoriasRow createRow(Map<String, dynamic> data) =>
      SubcategoriasRow(data);
}

class SubcategoriasRow extends SupabaseDataRow {
  SubcategoriasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => SubcategoriasTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get categoriaId => getField<String>('categoria_id')!;
  set categoriaId(String value) => setField<String>('categoria_id', value);

  String get nombre => getField<String>('nombre')!;
  set nombre(String value) => setField<String>('nombre', value);

  String? get descripcion => getField<String>('descripcion');
  set descripcion(String? value) => setField<String>('descripcion', value);

  String get estado => getField<String>('estado')!;
  set estado(String value) => setField<String>('estado', value);

  String? get imagenUrl => getField<String>('imagen_url');
  set imagenUrl(String? value) => setField<String>('imagen_url', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);
}
