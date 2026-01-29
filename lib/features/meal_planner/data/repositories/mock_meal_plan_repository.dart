import '../../../../core/mocks/meal_plan_mocks.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/entities/user_preferencies.dart';
import '../../domain/repositories/meal_plan_repository.dart';

class MockMealPlanRepository implements MealPlanRepository {
  final List<MealPlan> _mockPlans = MealPlanMocks.mockHistory;
  UserPreferences? _preferences;

  @override
  Future<MealPlan> generateMealPlan({
    required String goal,
    int? calories,
    required List<String> restrictions,
    required List<String> allergies,
    required int days,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    return MealPlanMocks.mockMealPlan.copyWith(
      goal: goal,
      targetCalories: calories,
      restrictions: restrictions,
      allergies: allergies,
      days: days,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<MealPlan>> getSavedPlans() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockPlans);
  }

  @override
  Future<void> savePlan(MealPlan plan) async {
    _mockPlans.insert(0, plan);
  }

  @override
  Future<void> deletePlan(String id) async {
    _mockPlans.removeWhere((plan) => plan.id == id);
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    _preferences = preferences;
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<UserPreferences?> getPreferences() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _preferences ?? UserPreferences.defaults();
  }
}