import 'package:equatable/equatable.dart';

class Meal extends Equatable {
  final String name;
  final String description;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const Meal({
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Meal copyWith({
    String? name,
    String? description,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return Meal(
      name: name ?? this.name,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      calories: json['calories'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fat: json['fat'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    name,
    description,
    calories,
    protein,
    carbs,
    fat,
  ];
}