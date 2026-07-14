// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ItemsReciboStruct extends BaseStruct {
  ItemsReciboStruct({
    String? tipoItem,
    String? descripcion,
    double? cantidad,
    double? precioUnitario,
    double? total,
  })  : _tipoItem = tipoItem,
        _descripcion = descripcion,
        _cantidad = cantidad,
        _precioUnitario = precioUnitario,
        _total = total;

  // "tipoItem" field.
  String? _tipoItem;
  String get tipoItem => _tipoItem ?? '';
  set tipoItem(String? val) => _tipoItem = val;

  bool hasTipoItem() => _tipoItem != null;

  // "descripcion" field.
  String? _descripcion;
  String get descripcion => _descripcion ?? '';
  set descripcion(String? val) => _descripcion = val;

  bool hasDescripcion() => _descripcion != null;

  // "cantidad" field.
  double? _cantidad;
  double get cantidad => _cantidad ?? 0.0;
  set cantidad(double? val) => _cantidad = val;

  void incrementCantidad(double amount) => cantidad = cantidad + amount;

  bool hasCantidad() => _cantidad != null;

  // "precioUnitario" field.
  double? _precioUnitario;
  double get precioUnitario => _precioUnitario ?? 0.0;
  set precioUnitario(double? val) => _precioUnitario = val;

  void incrementPrecioUnitario(double amount) =>
      precioUnitario = precioUnitario + amount;

  bool hasPrecioUnitario() => _precioUnitario != null;

  // "total" field.
  double? _total;
  double get total => _total ?? 0.0;
  set total(double? val) => _total = val;

  void incrementTotal(double amount) => total = total + amount;

  bool hasTotal() => _total != null;

  static ItemsReciboStruct fromMap(Map<String, dynamic> data) =>
      ItemsReciboStruct(
        tipoItem: data['tipoItem'] as String?,
        descripcion: data['descripcion'] as String?,
        cantidad: castToType<double>(data['cantidad']),
        precioUnitario: castToType<double>(data['precioUnitario']),
        total: castToType<double>(data['total']),
      );

  static ItemsReciboStruct? maybeFromMap(dynamic data) => data is Map
      ? ItemsReciboStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'tipoItem': _tipoItem,
        'descripcion': _descripcion,
        'cantidad': _cantidad,
        'precioUnitario': _precioUnitario,
        'total': _total,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'tipoItem': serializeParam(
          _tipoItem,
          ParamType.String,
        ),
        'descripcion': serializeParam(
          _descripcion,
          ParamType.String,
        ),
        'cantidad': serializeParam(
          _cantidad,
          ParamType.double,
        ),
        'precioUnitario': serializeParam(
          _precioUnitario,
          ParamType.double,
        ),
        'total': serializeParam(
          _total,
          ParamType.double,
        ),
      }.withoutNulls;

  static ItemsReciboStruct fromSerializableMap(Map<String, dynamic> data) =>
      ItemsReciboStruct(
        tipoItem: deserializeParam(
          data['tipoItem'],
          ParamType.String,
          false,
        ),
        descripcion: deserializeParam(
          data['descripcion'],
          ParamType.String,
          false,
        ),
        cantidad: deserializeParam(
          data['cantidad'],
          ParamType.double,
          false,
        ),
        precioUnitario: deserializeParam(
          data['precioUnitario'],
          ParamType.double,
          false,
        ),
        total: deserializeParam(
          data['total'],
          ParamType.double,
          false,
        ),
      );

  @override
  String toString() => 'ItemsReciboStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ItemsReciboStruct &&
        tipoItem == other.tipoItem &&
        descripcion == other.descripcion &&
        cantidad == other.cantidad &&
        precioUnitario == other.precioUnitario &&
        total == other.total;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([tipoItem, descripcion, cantidad, precioUnitario, total]);
}

ItemsReciboStruct createItemsReciboStruct({
  String? tipoItem,
  String? descripcion,
  double? cantidad,
  double? precioUnitario,
  double? total,
}) =>
    ItemsReciboStruct(
      tipoItem: tipoItem,
      descripcion: descripcion,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      total: total,
    );
