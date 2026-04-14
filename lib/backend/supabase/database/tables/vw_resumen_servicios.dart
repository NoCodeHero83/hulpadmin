import '../database.dart';

class VwResumenServiciosTable extends SupabaseTable<VwResumenServiciosRow> {
  @override
  String get tableName => 'vw_resumen_servicios';

  @override
  VwResumenServiciosRow createRow(Map<String, dynamic> data) =>
      VwResumenServiciosRow(data);
}

class VwResumenServiciosRow extends SupabaseDataRow {
  VwResumenServiciosRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwResumenServiciosTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get nombre => getField<String>('nombre');
  set nombre(String? value) => setField<String>('nombre', value);

  String? get descripcion => getField<String>('descripcion');
  set descripcion(String? value) => setField<String>('descripcion', value);

  double? get precio => getField<double>('precio');
  set precio(double? value) => setField<double>('precio', value);

  String? get estado => getField<String>('estado');
  set estado(String? value) => setField<String>('estado', value);

  String? get informacionRelevante => getField<String>('informacion_relevante');
  set informacionRelevante(String? value) =>
      setField<String>('informacion_relevante', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);

  String? get subcategoriaId => getField<String>('subcategoria_id');
  set subcategoriaId(String? value) =>
      setField<String>('subcategoria_id', value);

  List<String> get fotos => getListField<String>('fotos');
  set fotos(List<String>? value) => setListField<String>('fotos', value);

  List<String> get items => getListField<String>('items');
  set items(List<String>? value) => setListField<String>('items', value);

  bool? get destacado => getField<bool>('destacado');
  set destacado(bool? value) => setField<bool>('destacado', value);

  int? get totalSolicitudes => getField<int>('total_solicitudes');
  set totalSolicitudes(int? value) => setField<int>('total_solicitudes', value);
}
