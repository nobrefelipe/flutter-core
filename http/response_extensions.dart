import 'dart:async';

import 'package:http/http.dart';

import '../global_atoms.dart';
import '../helpers.dart';
import '../atomic_state/auth_state.dart';
import '../atomic_state/result.dart';
import 'http_response.dart';

extension ResponseExtention on Response {
  Future<Result<T>> toResult<T extends Object>(FutureOr<T> Function(dynamic data) adapter) async {
    try {
      return await ResponseInterceptor<T>(this).parseWith(adapter);
    } catch (e, s) {
      return Result.failure(e.toString());
    }
  }
}

class ResponseInterceptor<T extends Object> extends APIResponse {
  ResponseInterceptor(super.response);

  Result<T> parseWith(Function(dynamic data) adapter) {
    try {
      if (dataMap.isEmpty) {
        return Result.failure('Failed parsing the response.');
      }
      if (dataMap.containsKey('message')) {
        final errorMessage = Helper.getString(body['message']);
        if (errorMessage.toLowerCase().contains("unauthenticated")) {
          if (authState.value is! Unauthenticated) {
            authState.emit(Unauthenticated());
          }
        }
        return Result<T>.failure(body['message']);
      }

      if (dataMap.containsKey('error')) {
        final errorMessage = Helper.getString(body['error']);

        if (errorMessage.toLowerCase().contains("unauthenticated")) {
          if (authState.value is! Unauthenticated) {
            authState.emit(Unauthenticated());
          }
        }
        return Result<T>.failure(body['error']);
      }

      if (!dataMap.containsKey('data')) {
        return Result.failure('No data returned from the API.');
      }

      if (dataMap.containsKey('result')) {
        return Result<T>.success(adapter(dataMap['result']));
      }

      if (dataMap.containsKey('data')) {
        return Result<T>.success(adapter(dataMap['data']));
      }

      return Result.failure('Something went wrong');
    } catch (exception, stackTrace) {
      print(exception);
      print(stackTrace);
      return Result.failure("Error trying to parse $T \n$exception");
      // Errorhandler.externalFailureError(exception, stackTrace, reportTag: 'Generic Response Error');
    }
  }
}
