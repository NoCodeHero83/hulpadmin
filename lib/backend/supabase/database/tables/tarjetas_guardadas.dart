import '../database.dart';

class TarjetasGuardadasTable extends SupabaseTable<TarjetasGuardadasRow> {
  @override
  String get tableName => 'tarjetas_guardadas';

  @override
  TarjetasGuardadasRow createRow(Map<String, dynamic> data) =>
      TarjetasGuardadasRow(data);
}

class TarjetasGuardadasRow extends SupabaseDataRow {
  TarjetasGuardadasRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => TarjetasGuardadasTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get usuarioId => getField<String>('usuario_id')!;
  set usuarioId(String value) => setField<String>('usuario_id', value);

  String get paymentSourceId => getField<String>('payment_source_id')!;
  set paymentSourceId(String value) =>
      setField<String>('payment_source_id', value);

  String get tokenTarjeta => getField<String>('token_tarjeta')!;
  set tokenTarjeta(String value) => setField<String>('token_tarjeta', value);

  String get ultimosCuatro => getField<String>('ultimos_cuatro')!;
  set ultimosCuatro(String value) => setField<String>('ultimos_cuatro', value);

  String get marca => getField<String>('marca')!;
  set marca(String value) => setField<String>('marca', value);

  String get nombreTitular => getField<String>('nombre_titular')!;
  set nombreTitular(String value) => setField<String>('nombre_titular', value);

  String get mesExpiracion => getField<String>('mes_expiracion')!;
  set mesExpiracion(String value) => setField<String>('mes_expiracion', value);

  String get anioExpiracion => getField<String>('anio_expiracion')!;
  set anioExpiracion(String value) =>
      setField<String>('anio_expiracion', value);

  bool? get activa => getField<bool>('activa');
  set activa(bool? value) => setField<bool>('activa', value);

  bool? get predeterminada => getField<bool>('predeterminada');
  set predeterminada(bool? value) => setField<bool>('predeterminada', value);

  String? get apodo => getField<String>('apodo');
  set apodo(String? value) => setField<String>('apodo', value);

  DateTime? get creadaEn => getField<DateTime>('creada_en');
  set creadaEn(DateTime? value) => setField<DateTime>('creada_en', value);

  DateTime? get actualizadaEn => getField<DateTime>('actualizada_en');
  set actualizadaEn(DateTime? value) =>
      setField<DateTime>('actualizada_en', value);
}
