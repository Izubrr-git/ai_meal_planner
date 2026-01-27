import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  static String get openAIKey => dotenv.get('OPENAI_API_KEY');

  static bool get isConfigured => openAIKey.isNotEmpty;
}