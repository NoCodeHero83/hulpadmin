import '../database.dart';

class RecibosTable extends SupabaseTable<RecibosRow> {
  @override
  String get tableName => 'recibos';

  @override
  RecibosRow createRow(Map<String, dynamic> data) => RecibosRow(data);
}

class RecibosRow extends SupabaseDataRow {
  RecibosRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => RecibosTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get solicitudId => getField<String>('solicitud_id')!;
  set solicitudId(String value) => setField<String>('solicitud_id', value);

  String get proveedorId => getField<String>('proveedor_id')!;
  set proveedorId(String value) => setField<String>('proveedor_id', value);

  String get titulo => getField<String>('titulo')!;
  set titulo(String value) => setField<String>('titulo', value);

  double get total => getField<double>('total')!;
  set total(double value) => setField<double>('total', value);

  String get estado => getField<String>('estado')!;
  set estado(String value) => setField<String>('estado', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);

  DateTime? get respondidoEn => getField<DateTime>('respondido_en');
  set respondidoEn(DateTime? value) =>
      setField<DateTime>('respondido_en', value);

  String? get motivoRechazo => getField<String>('motivo_rechazo');
  set motivoRechazo(String? value) => setField<String>('motivo_rechazo', value);

  String? get mensajeId => getField<String>('mensaje_id');
  set mensajeId(String? value) => setField<String>('mensaje_id', value);
}
