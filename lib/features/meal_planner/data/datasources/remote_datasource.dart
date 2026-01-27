import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/openai_service.dart';
import '../../domain/entities/meal_plan.dart';
import '../models/api_response.dart';

class RemoteDataSource {
  final OpenAIService _openAIService;

  RemoteDataSource(this._openAIService);

  Future<MealPlan> generateMealPlan({
    required String goal,
    int? calories,
    required List<String> restrictions,
    required List<String> allergies,
    required int days,
  }) async {
    try {
      final response = await _openAIService.generateMealPlan(
        goal: goal,
        calories: calories,
        restrictions: restrictions,
        allergies: allergies,
        days: days,
      );

      final apiResponse = ApiResponse.fromJson(response);
      return apiResponse.toMealPlan(
        goal: goal,
        calories: calories,
        restrictions: restrictions,
        allergies: allergies,
        daysCount: days,
      );
    } catch (e) {
      rethrow;
    }
  }
}

final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  return RemoteDataSource(ref.watch(openAIServiceProvider));
});