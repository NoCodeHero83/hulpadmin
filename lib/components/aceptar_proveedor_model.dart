import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';
import 'dart:ui';
import '/index.dart';
import 'aceptar_proveedor_widget.dart' show AceptarProveedorWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AceptarProveedorModel extends FlutterFlowModel<AceptarProveedorWidget> {
  ///  Local state fields for this component.

  List<String> items = [];
  void addToItems(String item) => items.add(item);
  void removeFromItems(String item) => items.remove(item);
  void removeAtIndexFromItems(int index) => items.removeAt(index);
  void insertAtIndexInItems(int index, String item) =>
      items.insert(index, item);
  void updateItemsAtIndex(int index, Function(String) updateFn) =>
      items[index] = updateFn(items[index]);

  String? foto1;

  String? foto2;

  String? foto3;

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for Checkbox widget.
  bool? checkboxValue1;
  // State field(s) for Checkbox widget.
  bool? checkboxValue2;
  // State field(s) for Checkbox widget.
  bool? checkboxValue3;
  // State field(s) for Checkbox widget.
  bool? checkboxValue4;
  bool isDataUploading_uploadDataCedula = false;
  FFUploadedFile uploadedLocalFile_uploadDataCedula =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataCedula = '';

  bool isDataUploading_uploadDataCuentaBancaria = false;
  FFUploadedFile uploadedLocalFile_uploadDataCuentaBancaria =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataCuentaBancaria = '';

  bool isDataUploading_uploadDataContrato = false;
  FFUploadedFile uploadedLocalFile_uploadDataContrato =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataContrato = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
