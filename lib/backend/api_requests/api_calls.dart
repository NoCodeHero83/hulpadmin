import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class SendNotificationUserCall {
  static Future<ApiCallResponse> call({
    String? userIdSupabase = '',
    String? title = '',
    String? message = '',
  }) async {
    final ffApiRequestBody = '''
{
  "app_id": "fba1928f-8b58-4431-9ece-808ee8059532",
  "filters": [
    {
      "field": "tag",
      "key": "notifications_enabled",
      "relation": "!=",
      "value": "false"
    },
    {
      "operator": "AND"
    },
    {
      "field": "tag",
      "key": "user_id_supabase",
      "relation": "=",
      "value": "${escapeStringForJson(userIdSupabase)}"
    }
  ],
  "headings": {
    "en": "${escapeStringForJson(title)}"
  },
  "contents": {
    "en": "${escapeStringForJson(message)}"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'sendNotificationUser',
      apiUrl: 'https://onesignal.com/api/v1/notifications',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'os_v2_app_7oqzfd4llbcddhwoqchoqbmvgl2xat2kudzex357vgril6dwpbyerhohvv7asuzcaqudk7pl5pfwe2siwwqh63c2euvlw6gyawo43rq',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class SenNotificationUserHulpCall {
  static Future<ApiCallResponse> call({
    String? userIdSupabase = '',
    String? title = '',
    String? message = '',
  }) async {
    final ffApiRequestBody = '''
{
  "app_id": "1822544c-cbc3-482c-9246-ae0c8f070d1c",
  "filters": [
    {
      "field": "tag",
      "key": "notifications_enabled",
      "relation": "!=",
      "value": "false"
    },
    {
      "operator": "AND"
    },
    {
      "field": "tag",
      "key": "user_id_supabase",
      "relation": "=",
      "value": "${escapeStringForJson(userIdSupabase)}"
    }
  ],
  "headings": {
    "en": "${escapeStringForJson(title)}"
  },
  "contents": {
    "en": "${escapeStringForJson(message)}"
  }
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'senNotificationUserHulp',
      apiUrl: 'https://onesignal.com/api/v1/notifications',
      callType: ApiCallType.POST,
      headers: {
        'Authorization':
            'os_v2_app_darfitglyneczesgvygi6byndr7eriwmnolujkuvutfcucvnessox4s7m55l3wjcefutdmwrem4uaura3xs66bkq5jqgm6jfp7je6ha',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CreateUserCall {
  static Future<ApiCallResponse> call({
    String? email = '',
    String? password = '',
  }) async {
    final ffApiRequestBody = '''
{
  "email": "${escapeStringForJson(email)}",
  "password": "${escapeStringForJson(password)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'createUser',
      apiUrl: 'https://hulp-api.vercel.app/create-user',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
