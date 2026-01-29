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
      print('🔑 Checking API key...');

      final apiKey = ApiKeys.openAIKey;
      print('🔑 API Key: ${apiKey?.substring(0, 10)}...');

      if (apiKey == null ||
          apiKey.isEmpty ||
          apiKey == 'your_openai_api_key_here' ||
          !apiKey.startsWith('sk-')) {
        print('✅ Using mock data - test mode activated');
        return _generateMockResponse(
          goal: goal,
          calories: calories,
          restrictions: restrictions,
          allergies: allergies,
          days: days,
        );
      }

      print('🚀 Making real API call with OpenAI');

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
        print('✅ API call successful');
        return content;
      } else {
        throw ApiException('Ошибка API: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiException('Таймаут соединения');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ApiException('Нет подключения к интернету');
      }

      if (e.response?.statusCode == 401) {
        throw ApiException('Неверный API ключ. Проверьте ключ в настройках.');
      } else if (e.response?.statusCode == 429) {
        throw ApiException('Лимит запросов исчерпан. Попробуйте позже.');
      } else if (e.response?.statusCode == 500) {
        throw ApiException('Ошибка сервера OpenAI. Попробуйте позже.');
      }

      print('🔄 Falling back to mock data due to error');
      return _generateMockResponse(
        goal: goal,
        calories: calories,
        restrictions: restrictions,
        allergies: allergies,
        days: days,
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      return _generateMockResponse(
        goal: goal,
        calories: calories,
        restrictions: restrictions,
        allergies: allergies,
        days: days,
      );
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

  String _generateMockResponse({
    required String goal,
    int? calories,
    required List<String> restrictions,
    required List<String> allergies,
    required int days,
  }) {
    final mockDays = List.generate(days, (index) {
      final dayNum = index + 1;
      final totalCalories = 1400 + (index * 100);

      return '''
    {
      "day": "День $dayNum",
      "date": "${_getWeekday(dayNum)}",
      "meals": {
        "breakfast": {
          "name": "${_getMealName('breakfast', dayNum)}",
          "description": "${_getMealDescription('breakfast')}",
          "calories": ${300 + (dayNum * 10)},
          "protein": ${12 + dayNum},
          "carbs": ${40 + (dayNum * 2)},
          "fat": ${8 + dayNum}
        },
        "lunch": {
          "name": "${_getMealName('lunch', dayNum)}",
          "description": "${_getMealDescription('lunch')}",
          "calories": ${500 + (dayNum * 15)},
          "protein": ${25 + dayNum},
          "carbs": ${50 + (dayNum * 3)},
          "fat": ${15 + dayNum}
        },
        "dinner": {
          "name": "${_getMealName('dinner', dayNum)}",
          "description": "${_getMealDescription('dinner')}",
          "calories": ${400 + (dayNum * 12)},
          "protein": ${20 + dayNum},
          "carbs": ${30 + (dayNum * 2)},
          "fat": ${12 + dayNum}
        }
      },
      "snacks": [
        {
          "name": "${_getMealName('snack', dayNum)}",
          "description": "Полезный перекус",
          "calories": ${150 + (dayNum * 5)},
          "protein": ${8 + dayNum},
          "carbs": ${15 + dayNum},
          "fat": ${5 + dayNum}
        }
      ],
      "total_calories": $totalCalories,
      "macros": {
        "protein": ${70 + (dayNum * 5)},
        "carbs": ${120 + (dayNum * 10)},
        "fat": ${40 + dayNum}
      }
    }''';
    }).join(',');

    return '''
  {
    "days": [$mockDays],
    "summary": "План питания для цели '$goal'. ${calories != null ? 'Целевые калории: $calories.' : ''} Учтены ограничения: ${restrictions.join(', ')}. Аллергии: ${allergies.join(', ')}. Это демо-режим, для реальных данных настройте API ключ.",
    "recommendations": [
      "Пейте 2-2.5 литра воды в день",
      "Соблюдайте режим питания",
      "Комбинируйте белковые и углеводные приемы пищи",
      "Избегайте поздних ужинов",
      "Добавьте физическую активность"
    ]
  }
  ''';
  }

  String _getWeekday(int dayOffset) {
    final weekdays = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    final today = DateTime.now().weekday - 1; // 0-based
    return weekdays[(today + dayOffset - 1) % 7];
  }

  String _getMealName(String type, int dayNum) {
    final meals = {
      'breakfast': [
        'Овсянка с фруктами',
        'Яичница с овощами',
        'Творог с ягодами',
        'Сырники с медом',
        'Гречка с молоком'
      ],
      'lunch': [
        'Куриная грудка с рисом',
        'Рыба на пару с овощами',
        'Говядина с гречкой',
        'Суп куриный',
        'Индейка с картофелем'
      ],
      'dinner': [
        'Рыба на гриле с салатом',
        'Куриные котлеты с овощами',
        'Творожная запеканка',
        'Омлет с зеленью',
        'Отварная говядина с салатом'
      ],
      'snack': [
        'Йогурт греческий',
        'Орехи',
        'Яблоко',
        'Протеиновый батончик',
        'Творог'
      ]
    };

    final list = meals[type] ?? meals['snack']!;
    final index = (dayNum - 1) % list.length;
    return list[index];
  }

  String _getMealDescription(String type) {
    final descriptions = {
      'breakfast': 'Полезный завтрак для хорошего начала дня',
      'lunch': 'Сбалансированный обед для поддержания энергии',
      'dinner': 'Легкий ужин для хорошего сна',
      'snack': 'Полезный перекус между основными приемами пищи'
    };

    return descriptions[type] ?? 'Вкусное и полезное блюдо';
  }
}

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  final dio = ref.watch(dioClientProvider);
  return OpenAIService(dio);
});