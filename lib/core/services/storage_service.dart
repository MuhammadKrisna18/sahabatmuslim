import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }


  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }


  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }


  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }


  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }


  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }


  Future<bool> clear() async {
    return await _prefs.clear();
  }
}
