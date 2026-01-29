import '../../domain/entities/meal_plan.dart';

class MealPlanModel {
  final String id;
  final String createdAt;
  final String goal;
  final int? targetCalories;
  final List<String> restrictions;
  final List<String> allergies;
  final int days;
  final List<Map<String, dynamic>> mealDays;
  final String summary;
  final List<String> recommendations;

  MealPlanModel({
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
      'created_at': createdAt,
      'goal': goal,
      'target_calories': targetCalories,
      'restrictions': restrictions,
      'allergies': allergies,
      'days': days,
      'meal_days': mealDays,
      'summary': summary,
      'recommendations': recommendations,
    };
  }

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      goal: json['goal'] ?? '',
      targetCalories: json['target_calories'],
      restrictions: List<String>.from(json['restrictions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      days: json['days'] ?? 0,
      mealDays: List<Map<String, dynamic>>.from(json['meal_days'] ?? []),
      summary: json['summary'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  factory MealPlanModel.fromEntity(MealPlan entity) {
    return MealPlanModel(
      id: entity.id,
      createdAt: entity.createdAt.toIso8601String(),
      goal: entity.goal,
      targetCalories: entity.targetCalories,
      restrictions: entity.restrictions,
      allergies: entity.allergies,
      days: entity.days,
      mealDays: entity.mealDays.map((day) => day.toJson()).toList(),
      summary: entity.summary,
      recommendations: entity.recommendations,
    );
  }

  MealPlan toEntity() {
    return MealPlan(
      id: id,
      createdAt: DateTime.parse(createdAt),
      goal: goal,
      targetCalories: targetCalories,
      restrictions: restrictions,
      allergies: allergies,
      days: days,
      mealDays: mealDays.map((json) => MealDay.fromJson(json)).toList(),
      summary: summary,
      recommendations: recommendations,
    );
  }
}