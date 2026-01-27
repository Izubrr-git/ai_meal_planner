import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class UserPreferences extends Equatable {
  final String goal;
  final int? targetCalories;
  final List<String> restrictions;
  final List<String> allergies;
  final String? gender;
  final int? age;
  final double? weight;
  final double? height;
  final String activityLevel;
  final bool notificationsEnabled;
  final bool darkMode;
  final String language;

  const UserPreferences({
    required this.goal,
    this.targetCalories,
    required this.restrictions,
    required this.allergies,
    this.gender,
    this.age,
    this.weight,
    this.height,
    this.activityLevel = 'Средняя',
    this.notificationsEnabled = true,
    this.darkMode = false,
    this.language = 'ru',
  });

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'target_calories': targetCalories,
      'restrictions': restrictions,
      'allergies': allergies,
      'gender': gender,
      'age': age,
      'weight': weight,
      'height': height,
      'activity_level': activityLevel,
      'notifications_enabled': notificationsEnabled,
      'dark_mode': darkMode,
      'language': language,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      goal: json['goal'] ?? '',
      targetCalories: json['target_calories'],
      restrictions: List<String>.from(json['restrictions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      gender: json['gender'],
      age: json['age'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      activityLevel: json['activity_level'] ?? 'Средняя',
      notificationsEnabled: json['notifications_enabled'] ?? true,
      darkMode: json['dark_mode'] ?? false,
      language: json['language'] ?? 'ru',
    );
  }

  UserPreferences copyWith({
    String? goal,
    int? targetCalories,
    List<String>? restrictions,
    List<String>? allergies,
    String? gender,
    int? age,
    double? weight,
    double? height,
    String? activityLevel,
    bool? notificationsEnabled,
    bool? darkMode,
    String? language,
  }) {
    return UserPreferences(
      goal: goal ?? this.goal,
      targetCalories: targetCalories ?? this.targetCalories,
      restrictions: restrictions ?? this.restrictions,
      allergies: allergies ?? this.allergies,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      activityLevel: activityLevel ?? this.activityLevel,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
    );
  }

  static UserPreferences defaults() {
    return const UserPreferences(
      goal: 'Поддержание веса',
      targetCalories: 2000,
      restrictions: ['Без ограничений'],
      allergies: ['Нет'],
      activityLevel: 'Средняя',
      notificationsEnabled: true,
      darkMode: false,
      language: 'ru',
    );
  }

  int calculateRecommendedCalories() {
    if (weight == null || height == null || age == null || gender == null) {
      return 2000;
    }

    double bmr;
    if (gender == 'Мужской') {
      bmr = 10 * weight! + 6.25 * height! - 5 * age! + 5;
    } else {
      bmr = 10 * weight! + 6.25 * height! - 5 * age! - 161;
    }

    final activityMultiplier = _getActivityMultiplier(activityLevel);
    var calories = (bmr * activityMultiplier).round();

    switch (goal) {
      case 'Похудение':
        calories -= 500;
        break;
      case 'Набор мышечной массы':
        calories += 500;
        break;
      case 'Поддержание веса':
        break;
    }

    return _clamp(calories, 1200, 4000);
  }

  double _getActivityMultiplier(String level) {
    switch (level) {
      case 'Минимальная':
        return 1.2;
      case 'Низкая':
        return 1.375;
      case 'Средняя':
        return 1.55;
      case 'Высокая':
        return 1.725;
      case 'Очень высокая':
        return 1.9;
      default:
        return 1.55;
    }
  }

  int _clamp(int value, int min, int max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  @override
  List<Object?> get props => [
    goal,
    targetCalories,
    restrictions,
    allergies,
    gender,
    age,
    weight,
    height,
    activityLevel,
    notificationsEnabled,
    darkMode,
    language,
  ];
}