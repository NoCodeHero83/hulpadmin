import '../database.dart';

class VwProfesionalesServiciosTable
    extends SupabaseTable<VwProfesionalesServiciosRow> {
  @override
  String get tableName => 'vw_profesionales_servicios';

  @override
  VwProfesionalesServiciosRow createRow(Map<String, dynamic> data) =>
      VwProfesionalesServiciosRow(data);
}

class VwProfesionalesServiciosRow extends SupabaseDataRow {
  VwProfesionalesServiciosRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwProfesionalesServiciosTable();

  String? get profesionalId => getField<String>('profesional_id');
  set profesionalId(String? value) => setField<String>('profesional_id', value);

  String? get nombres => getField<String>('nombres');
  set nombres(String? value) => setField<String>('nombres', value);

  String? get apellidos => getField<String>('apellidos');
  set apellidos(String? value) => setField<String>('apellidos', value);

  String? get servicioId => getField<String>('servicio_id');
  set servicioId(String? value) => setField<String>('servicio_id', value);

  String? get servicioNombre => getField<String>('servicio_nombre');
  set servicioNombre(String? value) =>
      setField<String>('servicio_nombre', value);

  String? get subcategoriaId => getField<String>('subcategoria_id');
  set subcategoriaId(String? value) =>
      setField<String>('subcategoria_id', value);

  String? get subcategoriaNombre => getField<String>('subcategoria_nombre');
  set subcategoriaNombre(String? value) =>
      setField<String>('subcategoria_nombre', value);

  String? get categoriaId => getField<String>('categoria_id');
  set categoriaId(String? value) => setField<String>('categoria_id', value);

  String? get categoriaNombre => getField<String>('categoria_nombre');
  set categoriaNombre(String? value) =>
      setField<String>('categoria_nombre', value);
}
