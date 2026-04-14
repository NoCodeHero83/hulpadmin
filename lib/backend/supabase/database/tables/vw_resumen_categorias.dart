import '../database.dart';

class VwResumenCategoriasTable extends SupabaseTable<VwResumenCategoriasRow> {
  @override
  String get tableName => 'vw_resumen_categorias';

  @override
  VwResumenCategoriasRow createRow(Map<String, dynamic> data) =>
      VwResumenCategoriasRow(data);
}

class VwResumenCategoriasRow extends SupabaseDataRow {
  VwResumenCategoriasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwResumenCategoriasTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get nombre => getField<String>('nombre');
  set nombre(String? value) => setField<String>('nombre', value);

  String? get estado => getField<String>('estado');
  set estado(String? value) => setField<String>('estado', value);

  String? get imagenUrl => getField<String>('imagen_url');
  set imagenUrl(String? value) => setField<String>('imagen_url', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);

  int? get totalSubcategorias => getField<int>('total_subcategorias');
  set totalSubcategorias(int? value) =>
      setField<int>('total_subcategorias', value);

  int? get totalSolicitudes => getField<int>('total_solicitudes');
  set totalSolicitudes(int? value) => setField<int>('total_solicitudes', value);
}
