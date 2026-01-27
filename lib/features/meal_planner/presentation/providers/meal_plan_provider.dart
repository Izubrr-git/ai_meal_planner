import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/meal_plan_repository_impl.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/entities/user_preferencies.dart';
import '../../domain/repositories/meal_plan_repository.dart';

class MealPlanNotifier extends StateNotifier<MealPlanState> {
  final MealPlanRepository _repository;

  MealPlanNotifier(this._repository) : super(const MealPlanState());

  Future<void> generateMealPlan({
    required String goal,
    int? calories,
    required List<String> restrictions,
    required List<String> allergies,
    required int days,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final mealPlan = await _repository.generateMealPlan(
        goal: goal,
        calories: calories,
        restrictions: restrictions,
        allergies: allergies,
        days: days,
      );

      state = state.copyWith(
        isLoading: false,
        currentPlan: mealPlan,
        savedPlans: [mealPlan, ...state.savedPlans],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadSavedPlans() async {
    state = state.copyWith(isLoading: true);

    try {
      final plans = await _repository.getSavedPlans();
      state = state.copyWith(
        isLoading: false,
        savedPlans: plans,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    await _repository.savePreferences(preferences);
  }

  Future<UserPreferences?> loadPreferences() async {
    return await _repository.getPreferences();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> deletePlan(String id) async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.deletePlan(id);
      final updatedPlans = state.savedPlans.where((plan) => plan.id != id).toList();

      state = state.copyWith(
        isLoading: false,
        savedPlans: updatedPlans,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка удаления плана: $e',
      );
    }
  }

  Future<void> clearAllPlans() async {
    state = state.copyWith(isLoading: true);

    try {
      final plans = state.savedPlans;
      for (final plan in plans) {
        await _repository.deletePlan(plan.id);
      }

      state = state.copyWith(
        isLoading: false,
        savedPlans: [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка очистки истории: $e',
      );
    }
  }

  Future<void> clearAllData() async {
    state = state.copyWith(isLoading: true);

    try {
      // Очищаем все планы
      final plans = state.savedPlans;
      for (final plan in plans) {
        await _repository.deletePlan(plan.id);
      }

      // Сбрасываем текущий план
      state = state.copyWith(
        isLoading: false,
        savedPlans: [],
        currentPlan: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка очистки всех данных: $e',
      );
    }
  }
}

class MealPlanState {
  final MealPlan? currentPlan;
  final List<MealPlan> savedPlans;
  final bool isLoading;
  final String? error;

  const MealPlanState({
    this.currentPlan,
    this.savedPlans = const [],
    this.isLoading = false,
    this.error,
  });

  MealPlanState copyWith({
    MealPlan? currentPlan,
    List<MealPlan>? savedPlans,
    bool? isLoading,
    String? error,
  }) {
    return MealPlanState(
      currentPlan: currentPlan ?? this.currentPlan,
      savedPlans: savedPlans ?? this.savedPlans,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final mealPlanProvider = StateNotifierProvider<MealPlanNotifier, MealPlanState>(
      (ref) => MealPlanNotifier(ref.watch(mealPlanRepositoryProvider)),
);