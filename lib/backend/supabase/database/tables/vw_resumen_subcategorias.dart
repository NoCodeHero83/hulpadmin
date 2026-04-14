import '../database.dart';

class VwResumenSubcategoriasTable
    extends SupabaseTable<VwResumenSubcategoriasRow> {
  @override
  String get tableName => 'vw_resumen_subcategorias';

  @override
  VwResumenSubcategoriasRow createRow(Map<String, dynamic> data) =>
      VwResumenSubcategoriasRow(data);
}

class VwResumenSubcategoriasRow extends SupabaseDataRow {
  VwResumenSubcategoriasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwResumenSubcategoriasTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get nombre => getField<String>('nombre');
  set nombre(String? value) => setField<String>('nombre', value);

  String? get descripcion => getField<String>('descripcion');
  set descripcion(String? value) => setField<String>('descripcion', value);

  String? get estado => getField<String>('estado');
  set estado(String? value) => setField<String>('estado', value);

  String? get imagenUrl => getField<String>('imagen_url');
  set imagenUrl(String? value) => setField<String>('imagen_url', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);

  String? get categoriaId => getField<String>('categoria_id');
  set categoriaId(String? value) => setField<String>('categoria_id', value);

  int? get totalServicios => getField<int>('total_servicios');
  set totalServicios(int? value) => setField<int>('total_servicios', value);

  int? get totalSolicitudes => getField<int>('total_solicitudes');
  set totalSolicitudes(int? value) => setField<int>('total_solicitudes', value);
}
