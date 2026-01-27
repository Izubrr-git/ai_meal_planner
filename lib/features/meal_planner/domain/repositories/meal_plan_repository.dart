import '../entities/meal_plan.dart';
import '../entities/user_preferencies.dart';

abstract class MealPlanRepository {
  Future<MealPlan> generateMealPlan({
    required String goal,
    int? calories,
    required List<String> restrictions,
    required List<String> allergies,
    required int days,
  });

  Future<List<MealPlan>> getSavedPlans();
  Future<void> savePlan(MealPlan plan);
  Future<void> deletePlan(String id);
  Future<void> savePreferences(UserPreferences preferences);
  Future<UserPreferences?> getPreferences();
}