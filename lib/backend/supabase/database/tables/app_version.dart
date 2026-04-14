import '../database.dart';

class AppVersionTable extends SupabaseTable<AppVersionRow> {
  @override
  String get tableName => 'AppVersion';

  @override
  AppVersionRow createRow(Map<String, dynamic> data) => AppVersionRow(data);
}

class AppVersionRow extends SupabaseDataRow {
  AppVersionRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => AppVersionTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get versionUsuarios => getField<String>('version_usuarios')!;
  set versionUsuarios(String value) =>
      setField<String>('version_usuarios', value);

  String? get versionProveedores => getField<String>('version_proveedores');
  set versionProveedores(String? value) =>
      setField<String>('version_proveedores', value);

  String? get urlUsuariosPlayStore => getField<String>('urlUsuariosPlayStore');
  set urlUsuariosPlayStore(String? value) =>
      setField<String>('urlUsuariosPlayStore', value);

  String? get urlUsuariosIOS => getField<String>('urlUsuariosIOS');
  set urlUsuariosIOS(String? value) =>
      setField<String>('urlUsuariosIOS', value);

  String? get urlTalentosPlayStore => getField<String>('urlTalentosPlayStore');
  set urlTalentosPlayStore(String? value) =>
      setField<String>('urlTalentosPlayStore', value);

  String? get urlTalentosIOS => getField<String>('urlTalentosIOS');
  set urlTalentosIOS(String? value) =>
      setField<String>('urlTalentosIOS', value);

  String? get versionUsuariosIos => getField<String>('version_usuarios_ios');
  set versionUsuariosIos(String? value) =>
      setField<String>('version_usuarios_ios', value);

  String? get versionProveedoresIos =>
      getField<String>('version_proveedores_ios');
  set versionProveedoresIos(String? value) =>
      setField<String>('version_proveedores_ios', value);

  String? get versionTestFlight => getField<String>('version_test_flight');
  set versionTestFlight(String? value) =>
      setField<String>('version_test_flight', value);

  bool? get testFlight => getField<bool>('test_flight');
  set testFlight(bool? value) => setField<bool>('test_flight', value);

  int? get meta => getField<int>('Meta');
  set meta(int? value) => setField<int>('Meta', value);

  int? get tiktok => getField<int>('Tiktok');
  set tiktok(int? value) => setField<int>('Tiktok', value);
}
