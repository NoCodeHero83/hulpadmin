import '../database.dart';

class CertificacionesTable extends SupabaseTable<CertificacionesRow> {
  @override
  String get tableName => 'certificaciones';

  @override
  CertificacionesRow createRow(Map<String, dynamic> data) =>
      CertificacionesRow(data);
}

class CertificacionesRow extends SupabaseDataRow {
  CertificacionesRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => CertificacionesTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get usuarioId => getField<String>('usuario_id')!;
  set usuarioId(String value) => setField<String>('usuario_id', value);

  String get entidadCertificadora => getField<String>('entidad_certificadora')!;
  set entidadCertificadora(String value) =>
      setField<String>('entidad_certificadora', value);

  String get documentoUrl => getField<String>('documento_url')!;
  set documentoUrl(String value) => setField<String>('documento_url', value);

  // REQ-003 v3: fecha de subida del documento
  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);
}
