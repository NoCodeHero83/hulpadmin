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

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> createUser(String email, String password) async {
  try {
    print('🔵 Iniciando creación de usuario para: $email');

    // Validar inputs
    if (email.isEmpty || password.isEmpty) {
      print('❌ Error: Email o password vacíos');
      return null;
    }

    // ✅ URL actualizada con TUS credenciales
    final url =
        Uri.parse('https://zexegravzidwloxeimxx.supabase.co/auth/v1/signup');

    print('🔵 Enviando petición a: $url');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpleGVncmF2emlkd2xveGVpbXh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5NTc3MjgsImV4cCI6MjA1NzUzMzcyOH0.KK3zDu42x5q7ehC_jUXtnzIvlHVzz8hAsI-ybE0xZ9E',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpleGVncmF2emlkd2xveGVpbXh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5NTc3MjgsImV4cCI6MjA1NzUzMzcyOH0.KK3zDu42x5q7ehC_jUXtnzIvlHVzz8hAsI-ybE0xZ9E',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('🔵 Status Code: ${response.statusCode}');
    print('🔵 Response Body: ${response.body}');

    // ✅ Verificar respuesta exitosa
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Usuario creado exitosamente');

      try {
        final responseData = jsonDecode(response.body);
        print('🔵 Datos parseados: $responseData');

        // Buscar el UUID en la respuesta
        String? userId;

        // Opción 1: user.id directamente
        if (responseData['user'] != null &&
            responseData['user']['id'] != null) {
          userId = responseData['user']['id'].toString();
          print('✅ UUID encontrado en user.id: $userId');
        }
        // Opción 2: data.user.id
        else if (responseData['data'] != null &&
            responseData['data']['user'] != null &&
            responseData['data']['user']['id'] != null) {
          userId = responseData['data']['user']['id'].toString();
          print('✅ UUID encontrado en data.user.id: $userId');
        }
        // Opción 3: id directamente
        else if (responseData['id'] != null) {
          userId = responseData['id'].toString();
          print('✅ UUID encontrado en id: $userId');
        }

        if (userId != null && userId.isNotEmpty) {
          print('✅ Retornando UUID: $userId');
          return userId;
        } else {
          print('❌ No se encontró UUID en la respuesta');
          print('🔍 Claves disponibles: ${responseData.keys.toList()}');
          // Aún así retornamos algo para indicar que el usuario se creó
          return 'user_created_no_id';
        }
      } catch (jsonError) {
        print('❌ Error al parsear JSON: $jsonError');
        print('🔍 Respuesta raw: ${response.body}');
        // Si se creó pero no pudimos parsear, indicamos éxito parcial
        return 'user_created_parse_error';
      }
    } else {
      print('❌ Error HTTP: ${response.statusCode}');
      print('❌ Response: ${response.body}');

      // Intentar obtener detalles del error
      try {
        final errorData = jsonDecode(response.body);
        print('❌ Error detallado: $errorData');

        if (errorData['error_description'] != null) {
          print('❌ Descripción: ${errorData['error_description']}');
        }
        if (errorData['msg'] != null) {
          print('❌ Mensaje: ${errorData['msg']}');
        }
      } catch (e) {
        print('❌ No se pudo parsear el error');
      }

      return null;
    }
  } catch (e, stackTrace) {
    print('❌ Excepción al crear usuario: $e');
    print('❌ Stack trace: $stackTrace');
    return null;
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
