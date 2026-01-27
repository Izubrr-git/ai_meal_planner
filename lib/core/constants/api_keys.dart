import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeys {
  static String? _cachedKey;
  static bool _initialized = false;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    if (_initialized && _cachedKey != null) return;

    print('🔧 Initializing ApiKeys...');

    try {
      _prefs = await SharedPreferences.getInstance();

      final storedKey = _prefs?.getString('openai_api_key');
      if (storedKey != null && storedKey.isNotEmpty) {
        print('🔑 Found API key in SharedPreferences');
        _cachedKey = storedKey;
        _initialized = true;
        return;
      }

      print('🔑 No API key found in SharedPreferences');
      _initialized = true;

    } catch (e) {
      print('❌ Error initializing ApiKeys: $e');
      _initialized = true;
    }
  }

  static String? get openAIKey {
    if (!_initialized) {
      print('⚠️ ApiKeys not initialized! Call ApiKeys.init() first');
      return null;
    }
    return _cachedKey;
  }

  static bool get isConfigured {
    if (!_initialized) return false;
    return _cachedKey != null &&
        _cachedKey!.isNotEmpty &&
        _cachedKey!.startsWith('sk-');
  }

  static bool get isTestKey {
    if (!_initialized) return true;
    if (_cachedKey == null) return true;
    return _cachedKey!.isEmpty || !_cachedKey!.startsWith('sk-');
  }

  static Future<void> saveKey(String key) async {
    print('💾 Saving API key: ${key.substring(0, 10)}...');

    try {
      if (_prefs == null) {
        await init();
      }

      await _prefs?.setString('openai_api_key', key);
      _cachedKey = key;
      _initialized = true;

      print('✅ API key saved successfully');
    } catch (e) {
      print('❌ Error saving API key: $e');
      rethrow;
    }
  }

  static Future<void> clearKey() async {
    print('🗑️ Clearing API key...');

    try {
      if (_prefs == null) {
        await init();
      }

      await _prefs?.remove('openai_api_key');
      _cachedKey = null;
      _initialized = true;

      print('✅ API key cleared successfully');
    } catch (e) {
      print('❌ Error clearing API key: $e');
      rethrow;
    }
  }
}

final apiKeyConfiguredProvider = FutureProvider<bool>((ref) async {
  await ApiKeys.init();
  return ApiKeys.isConfigured;
});