import '../database.dart';

class ReciboItemsTable extends SupabaseTable<ReciboItemsRow> {
  @override
  String get tableName => 'recibo_items';

  @override
  ReciboItemsRow createRow(Map<String, dynamic> data) => ReciboItemsRow(data);
}

class ReciboItemsRow extends SupabaseDataRow {
  ReciboItemsRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => ReciboItemsTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get reciboId => getField<String>('recibo_id')!;
  set reciboId(String value) => setField<String>('recibo_id', value);

  String get tipoItem => getField<String>('tipo_item')!;
  set tipoItem(String value) => setField<String>('tipo_item', value);

  String? get descripcion => getField<String>('descripcion');
  set descripcion(String? value) => setField<String>('descripcion', value);

  double get cantidad => getField<double>('cantidad')!;
  set cantidad(double value) => setField<double>('cantidad', value);

  double get precioUnitario => getField<double>('precio_unitario')!;
  set precioUnitario(double value) =>
      setField<double>('precio_unitario', value);

  double? get total => getField<double>('total');
  set total(double? value) => setField<double>('total', value);

  DateTime? get creadoEn => getField<DateTime>('creado_en');
  set creadoEn(DateTime? value) => setField<DateTime>('creado_en', value);
}
