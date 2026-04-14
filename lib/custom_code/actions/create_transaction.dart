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

import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

Future<dynamic> createTransaction(
  String privateKey,
  String publicKey, // ← NUEVO: Para consultar estado
  int paymentSourceId,
  String acceptanceToken,
  int amountInCents,
  String currency,
  String customerEmail,
  String referenceId,
  String integrityKey,
  bool isProduction,
) async {
  try {
    // Validaciones básicas
    if (privateKey.trim().isEmpty || !privateKey.startsWith('prv_')) {
      return {
        'success': false,
        'error': 'Private key inválida. Debe empezar con "prv_"',
        'field': 'privateKey'
      };
    }

    if (publicKey.trim().isEmpty || !publicKey.startsWith('pub_')) {
      return {
        'success': false,
        'error': 'Public key inválida. Debe empezar con "pub_"',
        'field': 'publicKey'
      };
    }

    if (paymentSourceId <= 0) {
      return {
        'success': false,
        'error': 'Payment Source ID debe ser mayor a 0',
        'field': 'paymentSourceId'
      };
    }

    if (acceptanceToken.trim().isEmpty) {
      return {
        'success': false,
        'error': 'Acceptance token requerido',
        'field': 'acceptanceToken'
      };
    }

    if (amountInCents <= 0) {
      return {
        'success': false,
        'error': 'El monto debe ser mayor a 0',
        'field': 'amountInCents'
      };
    }

    if (currency.trim().isEmpty) {
      return {
        'success': false,
        'error': 'Moneda requerida (ej: COP, USD)',
        'field': 'currency'
      };
    }

    if (customerEmail.trim().isEmpty || !customerEmail.contains('@')) {
      return {
        'success': false,
        'error': 'Email válido requerido',
        'field': 'customerEmail'
      };
    }

    if (referenceId.trim().isEmpty) {
      return {
        'success': false,
        'error': 'Referencia requerida y debe ser única',
        'field': 'referenceId'
      };
    }

    if (integrityKey.trim().isEmpty) {
      return {
        'success': false,
        'error': 'Llave de integridad requerida para signature',
        'field': 'integrityKey'
      };
    }

    final baseUrl = isProduction
        ? 'https://production.wompi.co/v1'
        : 'https://sandbox.wompi.co/v1';

    print('=== INICIANDO TRANSACCIÓN CON POLLING AUTOMÁTICO ===');
    print('Payment Source ID: $paymentSourceId');
    print('Amount: $amountInCents centavos');
    print('Reference: ${referenceId.trim()}');
    print('================================================');

    // PASO 1: CREAR LA TRANSACCIÓN
    final signatureString =
        '${referenceId.trim()}${amountInCents}${currency.toUpperCase()}${integrityKey.trim()}';
    final bytes = utf8.encode(signatureString);
    final digest = sha256.convert(bytes);
    final signature = digest.toString();

    final requestBody = {
      'amount_in_cents': amountInCents,
      'currency': currency.toUpperCase(),
      'customer_email': customerEmail.trim().toLowerCase(),
      'payment_method': {
        'installments': 1,
      },
      'reference': referenceId.trim(),
      'payment_source_id': paymentSourceId,
      'acceptance_token': acceptanceToken.trim(),
      'signature': signature,
    };

    print('=== CREANDO TRANSACCIÓN ===');
    print('Signature: $signature');
    print('===========================');

    final createResponse = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Authorization': 'Bearer $privateKey',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print('=== RESPUESTA CREACIÓN ===');
    print('Status: ${createResponse.statusCode}');
    print('Body: ${createResponse.body}');
    print('==========================');

    if (createResponse.statusCode != 200 && createResponse.statusCode != 201) {
      final errorData = jsonDecode(createResponse.body);
      return {
        'success': false,
        'error': errorData['error']?.toString() ?? 'Error al crear transacción',
        'statusCode': createResponse.statusCode,
        'details': errorData,
        'phase': 'CREATION'
      };
    }

    final createData = jsonDecode(createResponse.body);
    final transactionId = createData['data']['id'];
    final initialStatus = createData['data']['status'];

    print('=== TRANSACCIÓN CREADA ===');
    print('ID: $transactionId');
    print('Estado inicial: $initialStatus');
    print('==========================');

    // Si ya es final, retornarlo inmediatamente
    if (['APPROVED', 'DECLINED', 'VOIDED', 'ERROR'].contains(initialStatus)) {
      print('=== ESTADO FINAL INMEDIATO ===');
      print('Estado: $initialStatus');
      print('No necesita polling');
      print('==============================');

      return {
        'success': true,
        'transactionId': transactionId,
        'status': initialStatus,
        'statusMessage': createData['data']['status_message'] ?? '',
        'amount': createData['data']['amount_in_cents'],
        'currency': createData['data']['currency'],
        'customerEmail': createData['data']['customer_email'],
        'reference': createData['data']['reference'],
        'createdAt': createData['data']['created_at'],
        'finalizedAt': createData['data']['finalized_at'],
        'paymentMethod': createData['data']['payment_method'],
        'paymentSourceId': createData['data']['payment_source_id'],
        'attempts': 0,
        'totalTime': '0 segundos',
        'message': 'Transacción finalizada inmediatamente: $initialStatus',
        'fullData': createData['data']
      };
    }

    // PASO 2: POLLING AUTOMÁTICO HASTA OBTENER RESULTADO FINAL
    print('=== INICIANDO POLLING AUTOMÁTICO ===');
    print('Estado inicial: $initialStatus (PENDING)');
    print('Max intentos: 20 (60 segundos total)');
    print('Intervalo: 3 segundos');
    print('====================================');

    final startTime = DateTime.now();

    for (int attempt = 1; attempt <= 20; attempt++) {
      print('🔍 Polling intento $attempt/20...');

      await Future.delayed(Duration(seconds: 3));

      try {
        final statusResponse = await http.get(
          Uri.parse('$baseUrl/transactions/$transactionId'),
          headers: {
            'Authorization': 'Bearer $publicKey',
            'Content-Type': 'application/json',
          },
        );

        if (statusResponse.statusCode == 200) {
          final statusData = jsonDecode(statusResponse.body);
          final currentStatus = statusData['data']['status'];
          final elapsedTime = DateTime.now().difference(startTime).inSeconds;

          print(
              '📊 Estado actual: $currentStatus (${elapsedTime}s transcurridos)');

          // ¡RESULTADO FINAL ENCONTRADO!
          if (['APPROVED', 'DECLINED', 'VOIDED', 'ERROR']
              .contains(currentStatus)) {
            print('🎉 === RESULTADO FINAL OBTENIDO ===');
            print('✅ Estado: $currentStatus');
            print('⏱️  Intentos: $attempt');
            print('🕐 Tiempo total: ${elapsedTime} segundos');
            print('==================================');

            return {
              'success': true,
              'transactionId': transactionId,
              'status': currentStatus,
              'statusMessage': statusData['data']['status_message'] ?? '',
              'amount': statusData['data']['amount_in_cents'],
              'currency': statusData['data']['currency'],
              'customerEmail': statusData['data']['customer_email'],
              'reference': statusData['data']['reference'],
              'createdAt': statusData['data']['created_at'],
              'finalizedAt': statusData['data']['finalized_at'],
              'paymentMethod': statusData['data']['payment_method'],
              'paymentSourceId': statusData['data']['payment_source_id'],
              'attempts': attempt,
              'totalTime': '${elapsedTime} segundos',
              'message': 'Transacción finalizada: $currentStatus',
              'fullData': statusData['data']
            };
          }

          print('⏳ Aún en $currentStatus, continuando polling...');
        } else {
          print(
              '❌ Error HTTP ${statusResponse.statusCode} en intento $attempt');
        }
      } catch (e) {
        print('❌ Error en polling intento $attempt: ${e.toString()}');
      }
    }

    // Si llegamos aquí, se agotó el tiempo
    final totalTime = DateTime.now().difference(startTime).inSeconds;
    print('⏰ === TIMEOUT DESPUÉS DE 20 INTENTOS ===');
    print('❌ Tiempo total: ${totalTime} segundos');
    print('⚠️  Estado: Probablemente aún PENDING');
    print('=======================================');

    return {
      'success': false,
      'error':
          'TIMEOUT: La transacción sigue procesándose después de 60 segundos',
      'transactionId': transactionId,
      'status': 'TIMEOUT',
      'attempts': 20,
      'totalTime': '${totalTime} segundos',
      'message':
          'Timeout después de 60 segundos. La transacción puede completarse más tarde.',
      'phase': 'POLLING'
    };
  } catch (e) {
    print('💥 === ERROR GENERAL ===');
    print('Error: ${e.toString()}');
    print('=======================');

    return {
      'success': false,
      'error': 'Error general: ${e.toString()}',
      'statusCode': 0,
      'phase': 'GENERAL'
    };
  }
}
