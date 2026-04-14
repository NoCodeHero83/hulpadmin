// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<dynamic> getAcceptanceToken(
  String publicKey,
  bool isProduction,
) async {
  try {
    // Determinar la URL base según el entorno
    final baseUrl = isProduction
        ? 'https://production.wompi.co/v1'
        : 'https://sandbox.wompi.co/v1';

    // Hacer la petición GET para obtener información del merchant
    final response = await http.get(
      Uri.parse('$baseUrl/merchants/$publicKey'),
      headers: {
        'Authorization': 'Bearer $publicKey',
        'Content-Type': 'application/json',
      },
    );

    // Decodificar la respuesta
    final responseData = jsonDecode(response.body);

    // Verificar si la petición fue exitosa
    if (response.statusCode == 200) {
      return {
        'success': true,
        'acceptanceToken': responseData['data']['presigned_acceptance']
            ['acceptance_token'],
        'permalink': responseData['data']['presigned_acceptance']['permalink'],
        'message': 'Token de aceptación obtenido exitosamente'
      };
    } else {
      return {
        'success': false,
        'error': responseData['error']?.toString() ??
            'Error desconocido al obtener acceptance token',
        'statusCode': response.statusCode
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': 'Error de conexión: ${e.toString()}',
      'statusCode': 0
    };
  }
}
