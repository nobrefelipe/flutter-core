import 'dart:convert';

import 'shared_preferences_singleton.dart';

abstract class ICache {
  Future init();
  Map<String, dynamic> loadJson(String key, {Map<String, dynamic>? defaultValue});
  Future saveJson(String key, Map<String, dynamic> value);
  Future<void> clearCache();
  bool contains(String key);
  Future save(String key, dynamic value);
  dynamic load(String key, {dynamic defaultValue});

  Future clear(String key);

  //Token
  Future saveToken(String value);
  String? getToken();
  Future<void> clearToken();

  // Student
  Future setUser(Map<String, dynamic> value);
  Future getUser();
  Future clearUser();

  // PIN and Biometric Setup
  Future setPinHash(String value);
  String? getPinHash();
  Future clearPinHash();
  Future setBiometricEnabled(bool value);
  bool getBiometricEnabled();
  Future setSecuritySetupComplete(bool value);
  bool getSecuritySetupComplete();
  Future setLocale(String value);
  String? getLocale();
}

class AppCache extends ICache {
  AppCache._internal();
  static final AppCache _singleton = AppCache._internal();
  factory AppCache() => _singleton;
  bool _initialised = false;

  @override
  Future init() async {
    if (_initialised) return;
    await SharedPreferencesSingleton().init();
    _initialised = true;
  }

  @override
  Map<String, dynamic> loadJson(String key, {Map<String, dynamic>? defaultValue}) {
    String? value = SharedPreferencesSingleton().get(key, defaultValue: json.encode(defaultValue));
    return value != null ? json.decode(value) : defaultValue;
  }

  @override
  Future saveJson(String key, Map<String, dynamic> value) async {
    return SharedPreferencesSingleton().set(key, json.encode(value));
  }

  @override
  Future<void> clearCache() async {
    return SharedPreferencesSingleton().clear();
  }

  @override
  bool contains(String key) {
    return SharedPreferencesSingleton().contains(key);
  }

  @override
  Future save(String key, dynamic value) async {
    return SharedPreferencesSingleton().set(key, value);
  }

  @override
  dynamic load(String key, {dynamic defaultValue}) {
    return SharedPreferencesSingleton().get(key, defaultValue: defaultValue);
  }

  @override
  Future<void> saveToken(String value) async {
    return SharedPreferencesSingleton().set('authToken', value);
  }

  @override
  String? getToken() {
    return SharedPreferencesSingleton().get('authToken');
  }

  @override
  Future<void> clearToken() async {
    return SharedPreferencesSingleton().remove('authToken');
  }

  @override
  Future clear(String key) {
    return SharedPreferencesSingleton().remove(key);
  }

  @override
  Future setSchool(Map<String, dynamic> value) async {
    await saveJson('school', value);
  }

  @override
  Map<String, dynamic> getSchool() {
    try {
      return loadJson('school');
    } catch (e) {
      return {};
    }
  }

  @override
  Future setPinHash(String value) {
    return SharedPreferencesSingleton().set('pin_hash', value);
  }

  @override
  String? getPinHash() {
    return SharedPreferencesSingleton().get('pin_hash');
  }

  @override
  Future clearPinHash() {
    return SharedPreferencesSingleton().remove('pin_hash');
  }

  @override
  Future setBiometricEnabled(bool value) {
    return SharedPreferencesSingleton().set('biometric_enabled', value);
  }

  @override
  bool getBiometricEnabled() {
    return SharedPreferencesSingleton().get('biometric_enabled', defaultValue: false) ?? false;
  }

  @override
  Future setSecuritySetupComplete(bool value) {
    return SharedPreferencesSingleton().set('security_setup_complete', value);
  }

  @override
  bool getSecuritySetupComplete() {
    return SharedPreferencesSingleton().get('security_setup_complete', defaultValue: false) ?? false;
  }

  @override
  Future clearUser() {
    return SharedPreferencesSingleton().remove('user');
  }

  @override
  Future setUser(Map<String, dynamic> value) {
    return SharedPreferencesSingleton().set('user', value);
  }

  @override
  Future getUser() {
    return SharedPreferencesSingleton().get('user');
  }

  @override
  String? getLocale() {
    return SharedPreferencesSingleton().get('locale');
  }

  @override
  Future setLocale(String value) {
    return SharedPreferencesSingleton().set('locale', value);
  }
}
