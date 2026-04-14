import '../database.dart';

class PaymentLinksMappingTable extends SupabaseTable<PaymentLinksMappingRow> {
  @override
  String get tableName => 'payment_links_mapping';

  @override
  PaymentLinksMappingRow createRow(Map<String, dynamic> data) =>
      PaymentLinksMappingRow(data);
}

class PaymentLinksMappingRow extends SupabaseDataRow {
  PaymentLinksMappingRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => PaymentLinksMappingTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get paymentLinkId => getField<String>('payment_link_id')!;
  set paymentLinkId(String value) => setField<String>('payment_link_id', value);

  String get solicitudId => getField<String>('solicitud_id')!;
  set solicitudId(String value) => setField<String>('solicitud_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
