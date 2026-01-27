// lib/core/constants/api_keys.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeys {
  static String? _cachedKey;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    // 1. Из .env
    final envKey = dotenv.get('OPENAI_API_KEY', fallback: '');
    if (envKey.isNotEmpty && envKey != 'your_openai_api_key_here') {
      _cachedKey = envKey;
      _initialized = true;
      return;
    }

    // 2. Из SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedKey = prefs.getString('openai_api_key');
      if (storedKey != null && storedKey.isNotEmpty) {
        _cachedKey = storedKey;
        _initialized = true;
        return;
      }
    } catch (e) {
      print('Error reading API key from SharedPreferences: $e');
    }

    _initialized = true;
  }

  static String? get openAIKey {
    if (!_initialized) {
      throw Exception('ApiKeys not initialized. Call ApiKeys.init() first');
    }
    return _cachedKey;
  }

  static Future<bool> get isConfigured async {
    await init();
    return _cachedKey?.isNotEmpty == true &&
        _cachedKey != 'your_openai_api_key_here';
  }

  static Future<void> saveKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('openai_api_key', key);
      _cachedKey = key;

      // Обновляем в памяти для dotenv
      dotenv.env['OPENAI_API_KEY'] = key;
    } catch (e) {
      print('Error saving API key: $e');
      rethrow;
    }
  }

  static Future<void> clearKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('openai_api_key');
      _cachedKey = null;
      dotenv.env.remove('OPENAI_API_KEY');
    } catch (e) {
      print('Error clearing API key: $e');
    }
  }
}

// Добавить в lib/core/constants/api_keys.dart
final apiKeyConfiguredProvider = FutureProvider<bool>((ref) async {
  await ApiKeys.init();
  return ApiKeys.isConfigured;
});