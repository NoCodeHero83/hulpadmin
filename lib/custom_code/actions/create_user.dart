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

// Crea un usuario en Supabase Auth vía REST signup.
// Se usa HTTP directo (no SupaFlow.client.auth.signUp) para NO alterar
// la sesión del admin actual: signUp del SDK inicia sesión como el
// nuevo usuario y deslogea al admin.
//
// Devuelve el UUID del usuario creado o null si hubo error.
Future<String?> createUser(String email, String password) async {
  try {
    if (email.isEmpty || password.isEmpty) {
      print('❌ createUser: email o password vacíos');
      return null;
    }

    final supaUrl = FFDevEnvironmentValues().supabaseUrl;
    final supaKey = FFDevEnvironmentValues().supabaseAnonKey;
    final url = Uri.parse('$supaUrl/auth/v1/signup');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': supaKey,
        'Authorization': 'Bearer $supaKey',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('❌ createUser HTTP ${response.statusCode}: ${response.body}');
      return null;
    }

    final data = jsonDecode(response.body);
    final userId = _extractUserId(data);
    if (userId == null || userId.isEmpty) {
      print('❌ createUser: no se pudo extraer UUID de: $data');
      return null;
    }
    return userId;
  } catch (e, st) {
    print('❌ createUser excepción: $e\n$st');
    return null;
  }
}

String? _extractUserId(dynamic data) {
  if (data is! Map) return null;
  if (data['id'] is String) return data['id'] as String;
  final user = data['user'];
  if (user is Map && user['id'] is String) return user['id'] as String;
  final inner = data['data'];
  if (inner is Map) {
    final u = inner['user'];
    if (u is Map && u['id'] is String) return u['id'] as String;
  }
  return null;
}
