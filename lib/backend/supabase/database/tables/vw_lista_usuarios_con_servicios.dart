import '../database.dart';

class VwListaUsuariosConServiciosTable
    extends SupabaseTable<VwListaUsuariosConServiciosRow> {
  @override
  String get tableName => 'vw_lista_usuarios_con_servicios';

  @override
  VwListaUsuariosConServiciosRow createRow(Map<String, dynamic> data) =>
      VwListaUsuariosConServiciosRow(data);
}

class VwListaUsuariosConServiciosRow extends SupabaseDataRow {
  VwListaUsuariosConServiciosRow(Map<String, dynamic> data) : super(data);

  @override
  SupabaseTable get table => VwListaUsuariosConServiciosTable();

  String? get id => getField<String>('id');
  set id(String? value) => setField<String>('id', value);

  String? get nombres => getField<String>('nombres');
  set nombres(String? value) => setField<String>('nombres', value);

  String? get apellidos => getField<String>('apellidos');
  set apellidos(String? value) => setField<String>('apellidos', value);

  String? get tipoDocumento => getField<String>('tipo_documento');
  set tipoDocumento(String? value) => setField<String>('tipo_documento', value);

  String? get numeroDocumento => getField<String>('numero_documento');
  set numeroDocumento(String? value) =>
      setField<String>('numero_documento', value);

  String? get pais => getField<String>('pais');
  set pais(String? value) => setField<String>('pais', value);

  String? get codigoPais => getField<String>('codigo_pais');
  set codigoPais(String? value) => setField<String>('codigo_pais', value);

  String? get telefono => getField<String>('telefono');
  set telefono(String? value) => setField<String>('telefono', value);

  String? get correoElectronico => getField<String>('correo_electronico');
  set correoElectronico(String? value) =>
      setField<String>('correo_electronico', value);

  String? get direccion => getField<String>('direccion');
  set direccion(String? value) => setField<String>('direccion', value);

  String? get fotoPerfilUrl => getField<String>('foto_perfil_url');
  set fotoPerfilUrl(String? value) =>
      setField<String>('foto_perfil_url', value);

  String? get rol => getField<String>('rol');
  set rol(String? value) => setField<String>('rol', value);

  DateTime? get fechaRegistro => getField<DateTime>('fecha_registro');
  set fechaRegistro(DateTime? value) =>
      setField<DateTime>('fecha_registro', value);

  int? get aniosExperiencia => getField<int>('anios_experiencia');
  set aniosExperiencia(int? value) => setField<int>('anios_experiencia', value);

  String? get registroTributario => getField<String>('registro_tributario');
  set registroTributario(String? value) =>
      setField<String>('registro_tributario', value);

  String? get verificado => getField<String>('verificado');
  set verificado(String? value) => setField<String>('verificado', value);

  bool? get disponibilidad => getField<bool>('disponibilidad');
  set disponibilidad(bool? value) => setField<bool>('disponibilidad', value);

  int? get idUsuario => getField<int>('id_usuario');
  set idUsuario(int? value) => setField<int>('id_usuario', value);

  String? get cedula => getField<String>('cedula');
  set cedula(String? value) => setField<String>('cedula', value);

  String? get cuentaBancaria => getField<String>('cuenta_bancaria');
  set cuentaBancaria(String? value) =>
      setField<String>('cuenta_bancaria', value);

  String? get contrato => getField<String>('contrato');
  set contrato(String? value) => setField<String>('contrato', value);

  String? get ciudad => getField<String>('ciudad');
  set ciudad(String? value) => setField<String>('ciudad', value);

  String? get suscripcionId => getField<String>('suscripcion_id');
  set suscripcionId(String? value) => setField<String>('suscripcion_id', value);

  List<String> get redesSociales => getListField<String>('redes_sociales');
  set redesSociales(List<String>? value) =>
      setListField<String>('redes_sociales', value);

  int? get totalServicios => getField<int>('total_servicios');
  set totalServicios(int? value) => setField<int>('total_servicios', value);

  int? get totalServiciosFinalizados =>
      getField<int>('total_servicios_finalizados');
  set totalServiciosFinalizados(int? value) =>
      setField<int>('total_servicios_finalizados', value);
}
