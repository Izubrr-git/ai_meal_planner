import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeys {
  static Future<String> get openAIKey async {
    // First check memory
    final envKey = dotenv.get('OPENAI_API_KEY', fallback: '');
    if (envKey.isNotEmpty && envKey != 'your_openai_api_key_here') {
      return envKey;
    }

    // Check SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedKey = prefs.getString('openai_api_key');
      if (storedKey != null && storedKey.isNotEmpty) {
        return storedKey;
      }
    } catch (e) {
      // Ignore
    }

    return '';
  }

  static Future<bool> get isConfigured async {
    final key = await openAIKey;
    return key.isNotEmpty && key != 'your_openai_api_key_here';
  }
}

// Создадим провайдер для проверки API ключа
final apiKeyConfiguredProvider = FutureProvider<bool>((ref) async {
  return await ApiKeys.isConfigured;
});