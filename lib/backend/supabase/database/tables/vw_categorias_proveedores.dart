import '../database.dart';

class VwCategoriasProveedoresTable
    extends SupabaseTable<VwCategoriasProveedoresRow> {
  @override
  String get tableName => 'vw_categorias_proveedores';

  @override
  VwCategoriasProveedoresRow createRow(Map<String, dynamic> data) =>
      VwCategoriasProveedoresRow(data);
}

class VwCategoriasProveedoresRow extends SupabaseDataRow {
  VwCategoriasProveedoresRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwCategoriasProveedoresTable();

  String? get categoriaId => getField<String>('categoria_id');
  set categoriaId(String? value) => setField<String>('categoria_id', value);

  String? get categoriaNombre => getField<String>('categoria_nombre');
  set categoriaNombre(String? value) =>
      setField<String>('categoria_nombre', value);

  int? get proveedoresActivos => getField<int>('proveedores_activos');
  set proveedoresActivos(int? value) =>
      setField<int>('proveedores_activos', value);

  int? get proveedoresTotales => getField<int>('proveedores_totales');
  set proveedoresTotales(int? value) =>
      setField<int>('proveedores_totales', value);
}
