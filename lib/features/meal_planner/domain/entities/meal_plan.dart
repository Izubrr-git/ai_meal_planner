import 'package:equatable/equatable.dart';

import 'meal.dart';

class MealDay {
  final String day;
  final String date;
  final Map<String, Meal> meals;
  final List<Meal> snacks;
  final int totalCalories;
  final Map<String, int> macros;

  MealDay({
    required this.day,
    required this.date,
    required this.meals,
    required this.snacks,
    required this.totalCalories,
    required this.macros,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date,
      'meals': meals.map((key, value) => MapEntry(key, value.toJson())),
      'snacks': snacks.map((snack) => snack.toJson()).toList(),
      'total_calories': totalCalories,
      'macros': macros,
    };
  }

  factory MealDay.fromJson(Map<String, dynamic> json) {
    final mealsMap = (json['meals'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, Meal.fromJson(value)),
    );

    final snacks = (json['snacks'] as List<dynamic>)
        .map((item) => Meal.fromJson(item))
        .toList();

    return MealDay(
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      meals: mealsMap,
      snacks: snacks,
      totalCalories: json['total_calories'] ?? 0,
      macros: Map<String, int>.from(json['macros'] ?? {}),
    );
  }
}

class MealPlan extends Equatable {
  final String id;
  final DateTime createdAt;
  final String goal;
  final int? targetCalories;
  final List<String> restrictions;
  final List<String> allergies;
  final int days;
  final List<MealDay> mealDays;
  final String summary;
  final List<String> recommendations;

  const MealPlan({
    required this.id,
    required this.createdAt,
    required this.goal,
    this.targetCalories,
    required this.restrictions,
    required this.allergies,
    required this.days,
    required this.mealDays,
    required this.summary,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'goal': goal,
      'target_calories': targetCalories,
      'restrictions': restrictions,
      'allergies': allergies,
      'days': days,
      'meal_days': mealDays.map((day) => day.toJson()).toList(),
      'summary': summary,
      'recommendations': recommendations,
    };
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      goal: json['goal'] ?? '',
      targetCalories: json['target_calories'],
      restrictions: List<String>.from(json['restrictions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      days: json['days'] ?? 0,
      mealDays: (json['meal_days'] as List<dynamic>)
          .map((item) => MealDay.fromJson(item))
          .toList(),
      summary: json['summary'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    goal,
    targetCalories,
    restrictions,
    allergies,
    days,
    mealDays,
    summary,
    recommendations,
  ];
}