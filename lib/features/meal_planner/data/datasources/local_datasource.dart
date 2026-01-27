import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/meal_plan.dart';
import '../../domain/entities/user_preferencies.dart';
import '../models/meal_plan_model.dart';

class LocalDataSource {
  final SharedPreferences _prefs;

  LocalDataSource(this._prefs);

  static const String _plansKey = 'saved_meal_plans';
  static const String _preferencesKey = 'user_preferences';

  Future<List<MealPlan>> getSavedPlans() async {
    final jsonString = _prefs.getString(_plansKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => MealPlanModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePlan(MealPlan plan) async {
    final plans = await getSavedPlans();
    final updatedPlans = [plan, ...plans];

    final jsonList = updatedPlans.map((plan) => MealPlanModel.fromEntity(plan).toJson()).toList();
    await _prefs.setString(_plansKey, json.encode(jsonList));
  }

  Future<void> deletePlan(String id) async {
    final plans = await getSavedPlans();
    final updatedPlans = plans.where((plan) => plan.id != id).toList();

    final jsonList = updatedPlans.map((plan) => MealPlanModel.fromEntity(plan).toJson()).toList();
    await _prefs.setString(_plansKey, json.encode(jsonList));
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    await _prefs.setString(_preferencesKey, json.encode(preferences.toJson()));
  }

  Future<UserPreferences?> getPreferences() async {
    final jsonString = _prefs.getString(_preferencesKey);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return UserPreferences.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAllData() async {
    try {
      await _prefs.remove(_plansKey);
      await _prefs.remove(_preferencesKey);
    } catch (e) {
      print('Error clearing all data: $e');
      rethrow;
    }
  }
}

final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  return LocalDataSource(ServiceLocator.sharedPreferences);
});