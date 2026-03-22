import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesSingleton {
  /// [SharedPreferencesSingleton] singleton instance
  static SharedPreferencesSingleton? _instance;

  /// Get the instance or create a new one if one has not been made already
  factory SharedPreferencesSingleton() {
    if (_instance != null) {
      return _instance!;
    }

    return _instance = SharedPreferencesSingleton._();
  }

  SharedPreferencesSingleton._();

  /// [SharedPreferences] instance
  /// This is the instance that is used to store and retrieve data
  /// from the device's SharedPreferences
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get a value from the SharedPreferences
  /// [key] is the key of the value to get
  /// [defaultValue] is the value to return if the key does not exist
  /// [T] is the type of the value to get
  /// [T] must be a type that can be casted to a String
  /// [T] must be a type that can be casted to a bool
  /// [T] must be a type that can be casted to an int
  /// [T] must be a type that can be casted to a double
  /// [T] must be a type that can be casted to a List<String>
  T? get<T>(String key, {T? defaultValue}) {
    final Object? value = _prefs.get(key);
    if (value == null) {
      return defaultValue;
    }
    return value as T;
  }

  List<String> getStringList(String key) {
    if (_prefs.getStringList(key) == null) {
      _prefs.setStringList(key, []);
    }
    return _prefs.getStringList(key)!;
  }

  List<String> addStringList(String key, String value) {
    final List<String> list = getStringList(key);
    list.add(value);
    return list;
  }

  /// Set a value in the SharedPreferences
  /// [key] is the key of the value to set
  /// [value] is the value to set
  /// [T] is the type of the value to set
  /// [T] must be a type that can be casted to a String
  /// [T] must be a type that can be casted to a bool
  /// [T] must be a type that can be casted to an int
  /// [T] must be a type that can be casted to a double
  /// [T] must be a type that can be casted to a List<String>
  Future set<T>(String key, T value) async {
    if (value is String) {
      return _prefs.setString(key, value);
    } else if (value is bool) {
      return _prefs.setBool(key, value);
    } else if (value is int) {
      return _prefs.setInt(key, value);
    } else if (value is double) {
      return _prefs.setDouble(key, value);
    } else if (value is List<String>) {
      return _prefs.setStringList(key, value);
    }
  }

  /// Remove a value from the SharedPreferences
  /// [key] is the key of the value to remove
  Future remove(String key) {
    return _prefs.remove(key);
  }

  /// Clear all values from the SharedPreferences
  /// This will remove all values from the SharedPreferences
  /// and will also remove all keys from the SharedPreferences
  Future clear() {
    return _prefs.clear();
  }

  /// Check if a value exists in the SharedPreferences
  /// [key] is the key of the value to check
  bool contains(String key) {
    return _prefs.containsKey(key);
  }
}
