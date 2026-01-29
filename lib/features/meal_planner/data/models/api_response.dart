import 'dart:convert';

import '../../domain/entities/meal_plan.dart';

class ApiResponse {
  final List<MealDay> days;
  final String summary;
  final List<String> recommendations;

  ApiResponse({
    required this.days,
    required this.summary,
    required this.recommendations,
  });

  factory ApiResponse.fromJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString);

      final days = (json['days'] as List<dynamic>)
          .map((dayJson) => MealDay.fromJson(dayJson))
          .toList();

      return ApiResponse(
        days: days,
        summary: json['summary'] ?? '',
        recommendations: List<String>.from(json['recommendations'] ?? []),
      );
    } catch (e) {
      throw Exception('Ошибка парсинга ответа AI: $e');
    }
  }

  MealPlan toMealPlan({
    required String goal,
    int? calories,
    required List<String> restrictions,
    required List<String> allergies,
    required int daysCount,
  }) {
    return MealPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      goal: goal,
      targetCalories: calories,
      restrictions: restrictions,
      allergies: allergies,
      days: daysCount,
      mealDays: days,
      summary: summary,
      recommendations: recommendations,
    );
  }
}