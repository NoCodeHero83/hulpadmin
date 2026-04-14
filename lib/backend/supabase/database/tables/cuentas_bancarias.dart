import '../database.dart';

class CuentasBancariasTable extends SupabaseTable<CuentasBancariasRow> {
  @override
  String get tableName => 'cuentas_bancarias';

  @override
  CuentasBancariasRow createRow(Map<String, dynamic> data) =>
      CuentasBancariasRow(data);
}

class CuentasBancariasRow extends SupabaseDataRow {
  CuentasBancariasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CuentasBancariasTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get usuarioId => getField<String>('usuario_id')!;
  set usuarioId(String value) => setField<String>('usuario_id', value);

  String get entidadBancaria => getField<String>('entidad_bancaria')!;
  set entidadBancaria(String value) =>
      setField<String>('entidad_bancaria', value);

  String get tipoCuenta => getField<String>('tipo_cuenta')!;
  set tipoCuenta(String value) => setField<String>('tipo_cuenta', value);

  String get numeroCuenta => getField<String>('numero_cuenta')!;
  set numeroCuenta(String value) => setField<String>('numero_cuenta', value);

  String get nombreTitular => getField<String>('nombre_titular')!;
  set nombreTitular(String value) => setField<String>('nombre_titular', value);
}
