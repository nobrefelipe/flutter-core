import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../cache/local_cache.dart';
import 'response_extensions.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../atomic_state/result.dart';
import '../env.dart';
import '../helpers.dart';

abstract class APIRequest {
  final _log = Logger('APIRequest');

  bool includeAuthToken = false;

  // ─── Authenticated shorthand methods ────────────────────────────────────────

  /// Authenticated GET — returns Result<T> directly.
  /// Usage: authGet('/api/rewards', RewardModel.fromJsonToList)
  Future<Result<T>> authGet<T extends Object>(
    String path,
    T Function(dynamic) adapter,
  ) async {
    includeAuthToken = true;
    final response = await get(path);
    return response.toResult<T>(adapter);
  }

  /// Authenticated POST — returns Result<T> directly.
  /// Usage: authPost('/api/rewards', RewardModel.fromJson, body: {...})
  Future<Result<T>> authPost<T extends Object>(
    String path,
    T Function(dynamic) adapter, {
    Map<String, dynamic>? body,
  }) async {
    includeAuthToken = true;
    final response = await post(path, body: body);
    return response.toResult<T>(adapter);
  }

  /// Authenticated PATCH — returns Result<T> directly.
  Future<Result<T>> authPatch<T extends Object>(
    String path,
    T Function(dynamic) adapter, {
    Map<String, dynamic>? body,
  }) async {
    includeAuthToken = true;
    final response = await patch(path, body: body);
    return response?.toResult<T>(adapter) ?? Failure('No response from the API.');
  }

  /// Authenticated PUT — returns Result<T> directly.
  Future<Result<T>> authPut<T extends Object>(
    String path,
    T Function(dynamic) adapter, {
    Map<String, dynamic>? body,
  }) async {
    includeAuthToken = true;
    final response = await put(path, body: body);
    return response?.toResult<T>(adapter) ?? Failure('No response from the API.');
  }

  /// Authenticated DELETE — returns Result<T> directly.
  /// Handles nullable response internally.
  Future<Result<T>> authDelete<T extends Object>(
    String path,
    T Function(dynamic) adapter, {
    Map<String, dynamic>? body,
  }) async {
    includeAuthToken = true;
    final response = await delete(path, body: body);
    if (response == null) return Failure('No response from the API.');
    return response.toResult<T>(adapter);
  }

  // ─── Raw HTTP methods ────────────────────────────────────────────────────────

  @protected
  Future<http.Response> post(
    String endpoint, {
    Map? body,
    Map<String, String>? headers,
    String? url,
  }) async {
    return _call('POST', endpoint, body: body, headers: headers, url: url);
  }

  @protected
  Future<http.Response?> postUrl(String url, {Map? body, Map<String, String>? headers}) {
    return _call('POST', '', body: body, headers: headers, url: url);
  }

  @protected
  Future<http.Response?> patch(String endpoint, {Map? body, Map<String, String>? headers, String? url}) {
    return _call('PATCH', endpoint, body: body, headers: headers, url: url);
  }

  @protected
  Future<http.Response?> patchUrl(String url, {Map? body, Map<String, String>? headers}) {
    return _call('PATCH', '', body: body, headers: headers, url: url);
  }

  @protected
  Future<http.Response?> put(String endpoint, {Map? body, Map<String, String>? headers, String? url}) {
    return _call('PUT', endpoint, body: body, headers: headers, url: url);
  }

  @protected
  Future<http.Response?> putUrl(String url, {Map? body, Map<String, String>? headers}) {
    return _call('PUT', '', body: body, headers: headers, url: url);
  }

  @protected
  Future<http.Response> get(String endpoint, {Map<String, String>? headers, String? url}) {
    return _call('GET', endpoint, headers: headers, url: url);
  }

  @protected
  Future<http.Response?> getUrl(String url, {Map<String, String>? headers}) {
    return _call('GET', '', headers: headers, url: url);
  }

  @protected
  Future<http.Response?> delete(String endpoint, {Map<String, String>? headers, String? url, Map? body}) {
    return _call('DELETE', endpoint, headers: headers, url: url, body: body);
  }

  @protected
  Future<http.Response?> deleteUrl(String url, {Map<String, String>? headers}) {
    return _call('DELETE', '', headers: headers, url: url);
  }

  @protected
  Future<http.Response?> multipart(
    String endpoint, {
    Map? body,
    Map<String, File>? files,
    Map<String, String>? headers,
    String? url,
  }) {
    return _call('multipart', endpoint, headers: headers, url: url, body: body, files: files);
  }

  @protected
  Future<http.Response?> multipartUrl(String url, {Map? body, Map<String, File>? files, Map<String, String>? headers}) {
    return _call('multipart', '', headers: headers, url: url, body: body, files: files);
  }

  // ─── Internal ────────────────────────────────────────────────────────────────

  Future<http.Response> _call(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Map? body,
    Map<String, File>? files,
    String? url,
  }) async {
    try {
      String requestEndpoint = endpoint;
      String? requestBody;
      http.Response? response;

      if (!Env.apiBaseUrl.endsWith('/') && !requestEndpoint.startsWith('/')) {
        requestEndpoint = '/$endpoint';
      }

      final DateTime now = DateTime.now();
      final String requestUrl = url ?? '${Env.apiBaseUrl}$requestEndpoint';
      final Map<String, String> requestHeaders = {
        "timezone_name": DateTime.now().timeZoneName,
        "timezone_offset": DateTime.now().timeZoneOffset.toString(),
        "accept": 'application/json',
      };

      if (headers != null) requestHeaders.addAll(headers);

      if (includeAuthToken) {
        final String? authToken = AppCache().getToken();
        if (authToken != null && authToken.isNotEmpty) {
          requestHeaders['Authorization'] = 'Bearer $authToken';
        }
      }

      if (!requestHeaders.containsKey('content-type') && body != null && body.isNotEmpty) {
        requestHeaders['content-type'] = 'application/json';
        requestHeaders['accept'] = 'application/json';
      }

      if (body != null) requestBody = json.encode(body);

      if (!Env.suppressApiLogging) {
        _log.log(Level.INFO, '''
  --------- API REQUEST ---------
  Fingerprint: ${now.millisecondsSinceEpoch}
  Method: $method
  URL: $requestUrl
  Headers: $requestHeaders
  Body: $requestBody
  --------------------------------''');
      }

      switch (method.toLowerCase()) {
        case 'get':
          response = await http.get(Uri.parse(requestUrl), headers: requestHeaders);
        case 'post':
          response = await http.post(Uri.parse(requestUrl), headers: requestHeaders, body: requestBody);
        case 'patch':
          response = await http.patch(Uri.parse(requestUrl), headers: requestHeaders, body: requestBody);
        case 'put':
          response = await http.put(Uri.parse(requestUrl), headers: requestHeaders, body: requestBody);
        case 'delete':
          response = await http.delete(Uri.parse(requestUrl), headers: requestHeaders, body: requestBody);
        case 'multipart':
          final request = http.MultipartRequest('POST', Uri.parse(requestUrl));
          request.headers.addAll(requestHeaders);
          if (body != null) {
            body.forEach((key, value) => request.fields[key as String] = Helper.getString(value));
          }
          if (files != null) {
            for (final String fieldName in files.keys) {
              request.files.add(await http.MultipartFile.fromPath(fieldName, files[fieldName]!.path));
            }
          }
          response = await http.Response.fromStream(await request.send());
      }

      if (response != null && !Env.suppressApiLogging) {
        _log.log(Level.INFO, '''
  --------- API RESPONSE ---------
  Fingerprint: ${now.millisecondsSinceEpoch}
  Status: ${response.statusCode}
  Body: ${response.body}
  --------------------------------''');
      }

      if (response != null) return response;
      throw Exception('No response from server');
    } catch (error, stacktrace) {
      debugLog("Error: $error, Stacktrace: $stacktrace", 'API Request Error');
    }
    return http.Response('{error: "API Request Error: Something went wrong"}', 500);
  }
}
