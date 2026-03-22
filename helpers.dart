import 'dart:convert';
import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Helper {
  /// Converts and asserts the [value] as if it was a boolean
  static bool getBool(dynamic value) {
    bool _returnValue = false;

    /// check for null values
    if (value == null) {
      return false;
    }

    /// check for [bool] types
    if (value is bool) {
      return value;
    }

    /// check for [String] types
    if (value is String) {
      switch (value.toLowerCase()) {
        case '1':
        case 'true':
        case 'yes':
          _returnValue = true;
          break;
      }

      return _returnValue;
    }

    /// check for [int] types
    if (value is int) {
      return value >= 1;
    }

    /// check for [double] types
    if (value is double) {
      return value > 0;
    }

    /// return default value if non of the above
    return _returnValue;
  }

  /// Converts [value] to a double, returns 0.0 on failure or unconverteble value.
  static double getDouble(dynamic value) {
    /// check for null values
    if (value == null) {
      return 0.0;
    }

    /// check for [double] types
    if (value is double) {
      return value;
    }

    /// check for [int] types
    if (value is int) {
      return value.toDouble();
    }

    /// check for [String] types
    if (value is String) {
      if (value.isNotEmpty) {
        try {
          return double.parse(value);
        } catch (error) {
          // do nothing, this value is not parse-able.
        }
      }
    }

    return 0.0;
  }

  /// Converts [value] to a double, returns 0.0 on failure or unconverteble value.
  static double? getDoubleOrNull(dynamic value) {
    /// check for null values
    if (value == null) {
      return null;
    }

    /// check for [double] types
    if (value is double) {
      return value;
    }

    /// check for [int] types
    if (value is int) {
      return value.toDouble();
    }

    /// check for [String] types
    if (value is String) {
      if (value.isNotEmpty) {
        try {
          return double.parse(value);
        } catch (error) {
          // do nothing, this value is not parse-able.
        }
      }
    }

    return null;
  }

  /// Converts [value] to an int, returns 0 on failure or unconverteble value.
  static int getInt(dynamic value) {
    /// check for null values
    if (value == null) {
      return 0;
    }

    /// check for [int] types
    if (value is int) {
      return value;
    }

    /// check for [double] types
    if (value is double) {
      return value.toInt();
    }

    /// check for [String] types
    if (value is String) {
      if (value.isNotEmpty) {
        try {
          return int.parse(value);
        } catch (error) {
          // re assume this means the value is actually a double, as a string.
          return getInt(double.parse(value));
        }
      }
    }

    return 0;
  }

  /// Converts [value] to an int, returns 0 on failure or unconverteble value.
  static int? getIntOrNull(dynamic value) {
    /// check for null values
    if (value == null) {
      return null;
    }

    /// check for [int] types
    if (value is int) {
      return value;
    }

    /// check for [double] types
    if (value is double) {
      return value.toInt();
    }

    /// check for [String] types
    if (value is String) {
      if (value.isNotEmpty) {
        try {
          return int.parse(value);
        } catch (error) {
          // re assume this means the value is actually a double, as a string.
          return getIntOrNull(double.parse(value));
        }
      }
    }

    return null;
  }

  /// Parses the [value] as a string. If the value is a Map or List, it will
  /// use the first index, returns '' on failure or error.
  static String getString(dynamic value) {
    /// check for null values
    if (value == null) {
      return '';
    }

    /// check for [String] types
    if (value is String) {
      return value;
    }

    /// check for [int] and [double] types
    if (value is int || value is double) {
      return value.toString();
    }

    /// check for [Map] type
    if (value is Map || value is List) {
      if (value.length == 0) {
        return '';
      }

      return Helper.getString(value[0]);
    }

    return '';
  }

  /// Parses the [value] as a string. If the value is a Map or List, it will
  /// use the first index, returns '' on failure or error.
  static String? getStringOrNull(dynamic value) {
    /// check for null values
    if (value == null) {
      return null;
    }

    /// check for [String] types
    if (value is String) {
      return value;
    }

    /// check for [int] and [double] types
    if (value is int || value is double) {
      return value.toString();
    }

    /// check for [Map] type
    if (value is Map || value is List) {
      if (value.length == 0) {
        return '';
      }

      return Helper.getStringOrNull(value[0]);
    }

    return null;
  }

  static List getList(dynamic value) {
    if (value == null || value is! List) {
      return [];
    }

    return value;
  }

  /// Parses the [value] as a list of string values. If [lowerCase] is true,
  /// the values with be lower cased.
  static List<String> getStringList(dynamic value, {bool lowerCase = false}) {
    /// check for null values
    if (value == null) {
      return <String>[];
    }

    /// check for [Map] type
    if (value is Map || value is List) {
      if (value.length == 0) {
        return <String>[];
      }

      final List<dynamic> listValue = value as List<dynamic>;

      final List<String> _items = [];
      for (final dynamic str in listValue) {
        String newStr = Helper.getString(str);

        if (lowerCase == true) {
          newStr = newStr.toLowerCase();
        }

        _items.add(newStr);
      }

      return _items;
    }

    /// check for [String] types
    if (value is String) {
      String str = Helper.getString(value);

      if (lowerCase == true) {
        str = value.toLowerCase();
      }

      return <String>[str];
    }

    /// check for [int] and [double] types
    if (value is int || value is double) {
      return <String>[value.toString()];
    }

    return <String>[];
  }

  // Make sure we return a map if the input is a list
  static Map<String, dynamic> getMap(dynamic value) {
    if (value is! Map) {
      return {};
    }

    return value as Map<String, dynamic>;
  }

  /// converts an image/file to base64 encoded string
  static Future<String?> uiImageToBase64String(ui.Image image) async {
    final ByteData? imageBytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (imageBytes == null) {
      return null;
    }

    return const Base64Encoder().convert(
      imageBytes.buffer.asUint8List(),
    );
  }

  /// converts a DateTime to dd/mm/yyyy
  static String formatDateTimeToString(DateTime dateTime, [String? format]) {
    final DateFormat formatter = DateFormat(format);
    final String formatted = formatter.format(dateTime);

    return formatted;
  }

  /// takes in a postcode and returns the first part
  static String shortPostcode(String postcode) {
    final List<String> postcodeParts = postcode.split(' ');
    return postcodeParts[0];
  }

  static String toRoundedMiles(int kilometers, {int decimalPlaces = 0}) {
    return (kilometers * 0.6213712).toStringAsFixed(decimalPlaces);
  }

  static String toRoundKilometers(int miles, {int decimalPlaces = 0}) {
    return (miles * 1.60934).toStringAsFixed(decimalPlaces);
  }

  static DateTime formatDateStringToDateTime(String ddmmyy) {
    final List<String> _dateParts = ddmmyy.split('/');
    final DateTime dateTime = DateTime(
      int.parse(_dateParts[2]),
      int.parse(_dateParts[1]),
      int.parse(_dateParts[0]),
    );
    return dateTime;
  }

  static DateTime formatMMYYYYDateStringToDateTime(String mmyyyy) {
    final List<String> _dateParts = mmyyyy.split('/');
    final DateTime dateTime = DateTime(
      int.parse(_dateParts[1]),
      int.parse(_dateParts[0]),
    );
    return dateTime;
  }
}

/// Grade Coin symbol (top-level getter for easy reuse across the app)
String get gradeCoinSymbol => '₲';

void debugLog(dynamic data, [String? title]) {
  if (kReleaseMode) return;
  log(' ================================================== DEBUGGING: $title ================================================== ');
  log(' ');
  log(data.toString());
  log(' ');
  log(' ======================================================================================================================= ');
}

final isWebMobile = kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);
final isWebMobileOrMobile = !kIsWeb || isWebMobile;
