import 'dart:convert';
import 'package:flutter/services.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFDevEnvironmentValues {
  static const String currentEnvironment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'Production');

  static String get environmentValuesPath =>
      currentEnvironment == 'Test'
          ? 'assets/environment_values/environment_test.json'
          : 'assets/environment_values/environment.json';

  static final FFDevEnvironmentValues _instance =
      FFDevEnvironmentValues._internal();

  factory FFDevEnvironmentValues() {
    return _instance;
  }

  FFDevEnvironmentValues._internal();

  Future<void> initialize() async {
    try {
      final String response =
          await rootBundle.loadString(environmentValuesPath);
      final data = await json.decode(response);
      _privatekey = data['privatekey'];
      _publickey = data['publickey'];
      _isProduction = data['isProduction'] ?? true;
      _supabaseUrl = data['supabaseUrl'];
      _supabaseAnonKey = data['supabaseAnonKey'];
      _integrityKey = data['integrityKey'];
    } catch (e) {
      print('Error loading environment values: $e');
    }
  }

  String _privatekey = '';
  String get privatekey => _privatekey;

  String _publickey = '';
  String get publickey => _publickey;

  bool _isProduction = true;
  bool get isProduction => _isProduction;

  String _supabaseUrl = '';
  String get supabaseUrl => _supabaseUrl;

  String _supabaseAnonKey = '';
  String get supabaseAnonKey => _supabaseAnonKey;

  String _integrityKey = '';
  String get integrityKey => _integrityKey;
}
