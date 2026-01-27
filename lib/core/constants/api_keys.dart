// lib/core/constants/api_keys.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeys {
  static String? _cachedKey;
  static bool _initialized = false;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();

      // 1. Из .env файла (для разработки)
      final envKey = dotenv.get('OPENAI_API_KEY', fallback: '');
      if (envKey.isNotEmpty) {
        _cachedKey = envKey;
      }

      // 2. Из SharedPreferences (пользовательский ключ)
      final storedKey = _prefs?.getString('openai_api_key');
      if (storedKey != null && storedKey.isNotEmpty) {
        _cachedKey = storedKey;
      }

      _initialized = true;
    } catch (e) {
      print('Error initializing ApiKeys: $e');
      _initialized = true; // Все равно отмечаем как инициализированное
    }
  }

  static String? get openAIKey => _cachedKey;

  static bool get isConfigured {
    if (!_initialized) return false;
    return _cachedKey != null &&
        _cachedKey!.isNotEmpty &&
        _cachedKey! != 'your_openai_api_key_here';
  }

  static bool get isTestKey {
    if (_cachedKey == null) return true;
    return _cachedKey!.isEmpty ||
        _cachedKey == 'your_openai_api_key_here' ||
        _cachedKey!.startsWith('sk-test-');
  }

  static Future<void> saveKey(String key) async {
    try {
      await _prefs?.setString('openai_api_key', key);
      _cachedKey = key;
      dotenv.env['OPENAI_API_KEY'] = key;
    } catch (e) {
      print('Error saving API key: $e');
    }
  }

  static Future<void> clearKey() async {
    try {
      await _prefs?.remove('openai_api_key');
      _cachedKey = null;
    } catch (e) {
      print('Error clearing API key: $e');
    }
  }
}

final apiKeyConfiguredProvider = FutureProvider<bool>((ref) async {
  await ApiKeys.init();
  return ApiKeys.isConfigured;
});