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

import 'package:supabase_flutter/supabase_flutter.dart';

Future<bool> deleteUserByEmail(String email) async {
  try {
    print('🔵 Iniciando eliminación de usuario: $email');

    // Validar input
    if (email.isEmpty) {
      print('❌ Error: Email vacío');
      return false;
    }

    final supabase = Supabase.instance.client;

    // Llamar a la función RPC
    final response = await supabase.rpc(
      'delete_user_by_email', // 🔥 Nombre de la función RPC en Supabase
      params: {'email_input': email},
    );

    print('🔵 Respuesta de RPC: $response');

    // La función RPC retorna true/false directamente
    if (response == true) {
      print("✅ Usuario eliminado correctamente.");
      return true;
    } else {
      print("❌ No se pudo eliminar el usuario (posiblemente no existe)");
      return false;
    }
  } catch (e) {
    print("❌ Error eliminando usuario: $e");
    return false;
  }
}

// Función alternativa para eliminar el usuario actual (más segura)
Future<bool> deleteCurrentUser() async {
  try {
    print('🔵 Eliminando usuario actual');

    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      print('❌ No hay usuario autenticado');
      return false;
    }

    final email = currentUser.email;
    if (email == null || email.isEmpty) {
      print('❌ Usuario actual no tiene email válido');
      return false;
    }

    print('🔵 Email del usuario actual: $email');

    // Eliminar usando la función RPC
    final response = await supabase.rpc(
      'delete_user_by_email',
      params: {'email_input': email},
    );

    if (response == true) {
      print("✅ Usuario actual eliminado correctamente");
      // Hacer logout automáticamente
      await supabase.auth.signOut();
      return true;
    } else {
      print("❌ No se pudo eliminar el usuario actual");
      return false;
    }
  } catch (e) {
    print("❌ Error eliminando usuario actual: $e");
    return false;
  }
}
