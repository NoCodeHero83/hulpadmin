import '../database.dart';

class VwResenasCompletaTable extends SupabaseTable<VwResenasCompletaRow> {
  @override
  String get tableName => 'vw_resenas_completa';

  @override
  VwResenasCompletaRow createRow(Map<String, dynamic> data) =>
      VwResenasCompletaRow(data);
}

class VwResenasCompletaRow extends SupabaseDataRow {
  VwResenasCompletaRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwResenasCompletaTable();

  String? get resenaId => getField<String>('resena_id');
  set resenaId(String? value) => setField<String>('resena_id', value);

  String? get solicitudServicioId => getField<String>('solicitud_servicio_id');
  set solicitudServicioId(String? value) =>
      setField<String>('solicitud_servicio_id', value);

  String? get usuarioId => getField<String>('usuario_id');
  set usuarioId(String? value) => setField<String>('usuario_id', value);

  String? get proveedorId => getField<String>('proveedor_id');
  set proveedorId(String? value) => setField<String>('proveedor_id', value);

  int? get calificacion => getField<int>('calificacion');
  set calificacion(int? value) => setField<int>('calificacion', value);

  String? get comentario => getField<String>('comentario');
  set comentario(String? value) => setField<String>('comentario', value);

  DateTime? get resenaCreadaEn => getField<DateTime>('resena_creada_en');
  set resenaCreadaEn(DateTime? value) =>
      setField<DateTime>('resena_creada_en', value);

  String? get usuarioNombres => getField<String>('usuario_nombres');
  set usuarioNombres(String? value) =>
      setField<String>('usuario_nombres', value);

  String? get usuarioApellidos => getField<String>('usuario_apellidos');
  set usuarioApellidos(String? value) =>
      setField<String>('usuario_apellidos', value);

  String? get usuarioNombreCompleto =>
      getField<String>('usuario_nombre_completo');
  set usuarioNombreCompleto(String? value) =>
      setField<String>('usuario_nombre_completo', value);

  String? get usuarioCorreo => getField<String>('usuario_correo');
  set usuarioCorreo(String? value) => setField<String>('usuario_correo', value);

  String? get usuarioFotoPerfil => getField<String>('usuario_foto_perfil');
  set usuarioFotoPerfil(String? value) =>
      setField<String>('usuario_foto_perfil', value);

  String? get proveedorNombres => getField<String>('proveedor_nombres');
  set proveedorNombres(String? value) =>
      setField<String>('proveedor_nombres', value);

  String? get proveedorApellidos => getField<String>('proveedor_apellidos');
  set proveedorApellidos(String? value) =>
      setField<String>('proveedor_apellidos', value);

  String? get proveedorNombreCompleto =>
      getField<String>('proveedor_nombre_completo');
  set proveedorNombreCompleto(String? value) =>
      setField<String>('proveedor_nombre_completo', value);

  String? get proveedorCorreo => getField<String>('proveedor_correo');
  set proveedorCorreo(String? value) =>
      setField<String>('proveedor_correo', value);

  String? get proveedorFotoPerfil => getField<String>('proveedor_foto_perfil');
  set proveedorFotoPerfil(String? value) =>
      setField<String>('proveedor_foto_perfil', value);
}
