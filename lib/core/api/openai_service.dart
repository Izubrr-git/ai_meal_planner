import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_keys.dart';
import '../constants/app_constants.dart';
import 'api_exceptions.dart';
import 'dio_client.dart';

class OpenAIService {
  final Dio _dio;

  OpenAIService(this._dio);

  Future<String> generateMealPlan({
    required String goal,
    int? calories,
    required List<String> restrictions,
    required List<String> allergies,
    required int days,
  }) async {
    try {
      final apiKey = ApiKeys.openAIKey;
      if (apiKey == null || apiKey.isEmpty) {
        throw ApiException('OpenAI API ключ не настроен. Пожалуйста, настройте его в настройках приложения.');
      }

      final prompt = _buildPrompt(
        goal: goal,
        calories: calories,
        restrictions: restrictions,
        allergies: allergies,
        days: days,
      );

      final response = await _dio.post(
        '/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': AppConstants.openAIModel,
          'messages': [
            {
              'role': 'system',
              'content': 'Ты профессиональный диетолог. Отвечай только на русском языке и строго в формате JSON.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': AppConstants.temperature,
          'max_tokens': AppConstants.maxTokens,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        return content;
      } else {
        throw ApiException('Ошибка API: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiException('Таймаут соединения');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ApiException('Нет подключения к интернету');
      }

      // OpenAI specific errors
      if (e.response?.statusCode == 401) {
        throw ApiException('Неверный API ключ. Проверьте ключ в настройках.');
      } else if (e.response?.statusCode == 429) {
        throw ApiException('Лимит запросов исчерпан. Попробуйте позже.');
      } else if (e.response?.statusCode == 500) {
        throw ApiException('Ошибка сервера OpenAI. Попробуйте позже.');
      }

      throw ApiException('Ошибка сети: ${e.message}');
    } catch (e) {
      throw ApiException('Ошибка: $e');
    }
  }

  String _buildPrompt({
    required String goal,
    int? calories,
    required List<String> restrictions,
    required List<String> allergies,
    required int days,
  }) {
    return '''
Создай детальный план питания на $days ${_getDayWord(days)} для цели: $goal.

Параметры:
- Цель: $goal
- Предполагаемые калории: ${calories ?? 'не указано'}
- Ограничения: ${restrictions.join(', ')}
- Аллергии: ${allergies.join(', ')}

Формат ответа (строго JSON):
{
  "days": [
    {
      "day": "День 1",
      "date": "Понедельник",
      "meals": {
        "breakfast": {"name": "Название", "description": "Описание", "calories": 400, "protein": 20, "carbs": 50, "fat": 15},
        "lunch": {"name": "Название", "description": "Описание", "calories": 600, "protein": 30, "carbs": 70, "fat": 20},
        "dinner": {"name": "Название", "description": "Описание", "calories": 500, "protein": 25, "carbs": 40, "fat": 25},
        "snacks": [
          {"name": "Перекус 1", "description": "Описание", "calories": 200, "protein": 10, "carbs": 25, "fat": 8},
          {"name": "Перекус 2", "description": "Описание", "calories": 150, "protein": 5, "carbs": 20, "fat": 5}
        ]
      },
      "total_calories": 1850,
      "macros": {"protein": 90, "carbs": 205, "fat": 73}
    }
  ],
  "summary": "Краткое описание плана питания",
  "recommendations": ["Рекомендация 1", "Рекомендация 2"]
}

Важно:
1. Используй реальные блюда русской и международной кухни
2. Учитывай диетические ограничения и аллергии
3. Убедись, что макронутриенты сбалансированы
4. Укажи точные значения калорий и БЖУ
5. Добавь полезные рекомендации
''';
  }

  String _getDayWord(int days) {
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }
}

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return OpenAIService(dio);
});