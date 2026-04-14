import '../database.dart';

class TransaccionesTable extends SupabaseTable<TransaccionesRow> {
  @override
  String get tableName => 'transacciones';

  @override
  TransaccionesRow createRow(Map<String, dynamic> data) =>
      TransaccionesRow(data);
}

class TransaccionesRow extends SupabaseDataRow {
  TransaccionesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TransaccionesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get solicitudId => getField<String>('solicitud_id')!;
  set solicitudId(String value) => setField<String>('solicitud_id', value);

  String get usuarioId => getField<String>('usuario_id')!;
  set usuarioId(String value) => setField<String>('usuario_id', value);

  String? get numeroTransaccion => getField<String>('numero_transaccion');
  set numeroTransaccion(String? value) =>
      setField<String>('numero_transaccion', value);

  String? get referenciaExterna => getField<String>('referencia_externa');
  set referenciaExterna(String? value) =>
      setField<String>('referencia_externa', value);

  double get monto => getField<double>('monto')!;
  set monto(double value) => setField<double>('monto', value);

  String? get moneda => getField<String>('moneda');
  set moneda(String? value) => setField<String>('moneda', value);

  String get proveedorPago => getField<String>('proveedor_pago')!;
  set proveedorPago(String value) => setField<String>('proveedor_pago', value);

  dynamic? get datosPago => getField<dynamic>('datos_pago');
  set datosPago(dynamic? value) => setField<dynamic>('datos_pago', value);

  DateTime get fechaPago => getField<DateTime>('fecha_pago')!;
  set fechaPago(DateTime value) => setField<DateTime>('fecha_pago', value);

  DateTime? get fechaRegistro => getField<DateTime>('fecha_registro');
  set fechaRegistro(DateTime? value) =>
      setField<DateTime>('fecha_registro', value);

  String? get ipUsuario => getField<String>('ip_usuario');
  set ipUsuario(String? value) => setField<String>('ip_usuario', value);

  String? get metodoPago => getField<String>('metodo_pago');
  set metodoPago(String? value) => setField<String>('metodo_pago', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
