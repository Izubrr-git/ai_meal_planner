import '../../features/meal_planner/domain/entities/meal.dart';
import '../../features/meal_planner/domain/entities/meal_plan.dart';

class MealPlanMocks {
  static MealPlan get mockMealPlan {
    return MealPlan(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      goal: 'Поддержание веса',
      targetCalories: 2000,
      restrictions: const ['Без ограничений'],
      allergies: const ['Нет'],
      days: 3,
      mealDays: [
        _mockDay('День 1', 'Понедельник'),
        _mockDay('День 2', 'Вторник'),
        _mockDay('День 3', 'Среда'),
      ],
      summary: 'Это тестовый план питания с сбалансированным рационом для поддержания веса.',
      recommendations: const [
        'Пейте достаточное количество воды',
        'Соблюдайте режим питания',
        'Добавьте физическую активность',
      ],
    );
  }

  static MealDay _mockDay(String day, String date) {
    return MealDay(
      day: day,
      date: date,
      meals: {
        'breakfast': const Meal(
          name: 'Овсянка с фруктами',
          description: 'Овсяные хлопья с бананом и медом',
          calories: 350,
          protein: 12,
          carbs: 60,
          fat: 8,
        ),
        'lunch': const Meal(
          name: 'Куриная грудка с овощами',
          description: 'Запеченная куриная грудка с брокколи и морковью',
          calories: 450,
          protein: 35,
          carbs: 30,
          fat: 15,
        ),
        'dinner': const Meal(
          name: 'Рыба на пару с рисом',
          description: 'Филе трески с бурым рисом',
          calories: 400,
          protein: 30,
          carbs: 50,
          fat: 10,
        ),
      },
      snacks: [
        const Meal(
          name: 'Йогурт',
          description: 'Греческий йогурт',
          calories: 150,
          protein: 10,
          carbs: 8,
          fat: 5,
        ),
        const Meal(
          name: 'Орехи',
          description: 'Горсть миндаля',
          calories: 200,
          protein: 8,
          carbs: 6,
          fat: 18,
        ),
      ],
      totalCalories: 1550,
      macros: {'protein': 95, 'carbs': 154, 'fat': 56},
    );
  }

  static List<MealPlan> get mockHistory {
    return [
      mockMealPlan,
      MealPlan(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch - 1000000}',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        goal: 'Похудение',
        targetCalories: 1500,
        restrictions: const ['Низкоуглеводная'],
        allergies: const ['Нет'],
        days: 5,
        mealDays: List.generate(5, (index) => _mockDay('День ${index + 1}', '')),
        summary: 'План для похудения с дефицитом калорий',
        recommendations: const [
          'Соблюдайте дефицит калорий',
          'Избегайте сладкого',
          'Тренируйтесь 3 раза в неделю',
        ],
      ),
    ];
  }
}