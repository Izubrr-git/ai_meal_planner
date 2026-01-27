import 'package:shared_preferences/shared_preferences.dart';

class ServiceLocator {
  static SharedPreferences? _sharedPreferences;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  static SharedPreferences get sharedPreferences {
    if (_sharedPreferences == null) {
      throw Exception('SharedPreferences не инициализирован');
    }
    return _sharedPreferences!;
  }
}