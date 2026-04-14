import '../database.dart';

class MetodosPagoTable extends SupabaseTable<MetodosPagoRow> {
  @override
  String get tableName => 'metodos_pago';

  @override
  MetodosPagoRow createRow(Map<String, dynamic> data) => MetodosPagoRow(data);
}

class MetodosPagoRow extends SupabaseDataRow {
  MetodosPagoRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => MetodosPagoTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get usuarioId => getField<String>('usuario_id')!;
  set usuarioId(String value) => setField<String>('usuario_id', value);

  int get paymentSourceId => getField<int>('payment_source_id')!;
  set paymentSourceId(int value) => setField<int>('payment_source_id', value);

  String get tipo => getField<String>('tipo')!;
  set tipo(String value) => setField<String>('tipo', value);

  String get estado => getField<String>('estado')!;
  set estado(String value) => setField<String>('estado', value);

  String get emailCliente => getField<String>('email_cliente')!;
  set emailCliente(String value) => setField<String>('email_cliente', value);

  String? get tipoCuenta => getField<String>('tipo_cuenta');
  set tipoCuenta(String? value) => setField<String>('tipo_cuenta', value);

  String? get ultimosCuatro => getField<String>('ultimos_cuatro');
  set ultimosCuatro(String? value) => setField<String>('ultimos_cuatro', value);

  String? get numeroTelefono => getField<String>('numero_telefono');
  set numeroTelefono(String? value) =>
      setField<String>('numero_telefono', value);

  String? get tipoDocumento => getField<String>('tipo_documento');
  set tipoDocumento(String? value) => setField<String>('tipo_documento', value);

  String? get numeroDocumento => getField<String>('numero_documento');
  set numeroDocumento(String? value) =>
      setField<String>('numero_documento', value);

  String? get numeroProducto => getField<String>('numero_producto');
  set numeroProducto(String? value) =>
      setField<String>('numero_producto', value);

  bool? get esPredeterminado => getField<bool>('es_predeterminado');
  set esPredeterminado(bool? value) =>
      setField<bool>('es_predeterminado', value);

  String? get apodo => getField<String>('apodo');
  set apodo(String? value) => setField<String>('apodo', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);

  DateTime? get actualizadoEn => getField<DateTime>('actualizado_en');
  set actualizadoEn(DateTime? value) =>
      setField<DateTime>('actualizado_en', value);

  DateTime? get usadoPorUltimaVez => getField<DateTime>('usado_por_ultima_vez');
  set usadoPorUltimaVez(DateTime? value) =>
      setField<DateTime>('usado_por_ultima_vez', value);

  int? get vecesUsado => getField<int>('veces_usado');
  set vecesUsado(int? value) => setField<int>('veces_usado', value);
}
