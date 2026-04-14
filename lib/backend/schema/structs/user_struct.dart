// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserStruct extends BaseStruct {
  UserStruct({
    String? nombres,
    String? fotoUrl,
  })  : _nombres = nombres,
        _fotoUrl = fotoUrl;

  // "nombres" field.
  String? _nombres;
  String get nombres => _nombres ?? '';
  set nombres(String? val) => _nombres = val;

  bool hasNombres() => _nombres != null;

  // "fotoUrl" field.
  String? _fotoUrl;
  String get fotoUrl => _fotoUrl ?? '';
  set fotoUrl(String? val) => _fotoUrl = val;

  bool hasFotoUrl() => _fotoUrl != null;

  static UserStruct fromMap(Map<String, dynamic> data) => UserStruct(
        nombres: data['nombres'] as String?,
        fotoUrl: data['fotoUrl'] as String?,
      );

  static UserStruct? maybeFromMap(dynamic data) =>
      data is Map ? UserStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'nombres': _nombres,
        'fotoUrl': _fotoUrl,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'nombres': serializeParam(
          _nombres,
          ParamType.String,
        ),
        'fotoUrl': serializeParam(
          _fotoUrl,
          ParamType.String,
        ),
      }.withoutNulls;

  static UserStruct fromSerializableMap(Map<String, dynamic> data) =>
      UserStruct(
        nombres: deserializeParam(
          data['nombres'],
          ParamType.String,
          false,
        ),
        fotoUrl: deserializeParam(
          data['fotoUrl'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'UserStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is UserStruct &&
        nombres == other.nombres &&
        fotoUrl == other.fotoUrl;
  }

  @override
  int get hashCode => const ListEquality().hash([nombres, fotoUrl]);
}

UserStruct createUserStruct({
  String? nombres,
  String? fotoUrl,
}) =>
    UserStruct(
      nombres: nombres,
      fotoUrl: fotoUrl,
    );
