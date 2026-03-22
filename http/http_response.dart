import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

abstract class APIResponse {
  const APIResponse(this.response);

  /// [Response] instance from the http request.
  @protected
  final Response? response;

  /// The response status code
  @protected
  int get statusCode {
    if (response == null) {
      return 500;
    }

    return response!.statusCode;
  }

  /// The response headers
  @protected
  Map<String, String> get headers {
    if (response == null) {
      return {};
    }

    return response!.headers;
  }

  /// json decodes the [response.body]
  @protected
  dynamic get body {
    try {
      if (response == null) {
        return <String, dynamic>{};
      }

      return jsonDecode(
        response!.body,
      );
    } catch (exception, stackTrace) {
      // Errorhandler.externalFailureError(exception, stackTrace, reportTag: 'Failed to get response body');
      return <String, dynamic>{};
    }
  }

  @protected
  Map<String, dynamic> get dataMap {
    if (body is List) {
      return {};
    }

    return body as Map<String, dynamic>;
  }

  @protected
  List<dynamic> get dataList {
    if (body is Map) {
      return [];
    }

    return body as List<dynamic>;
  }
}
