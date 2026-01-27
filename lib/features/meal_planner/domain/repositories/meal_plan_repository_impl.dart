import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_datasource.dart';
import '../../data/datasources/remote_datasource.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../entities/user_preferencies.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  MealPlanRepositoryImpl({
    required RemoteDataSource remoteDataSource,
    required LocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<MealPlan> generateMealPlan({
    required String goal,
    int? calories,
    required List<String> restrictions,
    required List<String> allergies,
    required int days,
  }) async {
    try {
      final mealPlan = await _remoteDataSource.generateMealPlan(
        goal: goal,
        calories: calories,
        restrictions: restrictions,
        allergies: allergies,
        days: days,
      );

      await savePlan(mealPlan);
      return mealPlan;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<MealPlan>> getSavedPlans() async {
    return await _localDataSource.getSavedPlans();
  }

  @override
  Future<void> savePlan(MealPlan plan) async {
    await _localDataSource.savePlan(plan);
  }

  @override
  Future<void> deletePlan(String id) async {
    await _localDataSource.deletePlan(id);
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    await _localDataSource.savePreferences(preferences);
  }

  @override
  Future<UserPreferences?> getPreferences() async {
    return await _localDataSource.getPreferences();
  }
}

final mealPlanRepositoryProvider = Provider<MealPlanRepository>((ref) {
  return MealPlanRepositoryImpl(
    remoteDataSource: ref.watch(remoteDataSourceProvider),
    localDataSource: ref.watch(localDataSourceProvider),
  );
});