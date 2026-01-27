import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareMealPlan({
    required String goal,
    required int days,
    required int totalCalories,
    required String summary,
  }) async {
    final text = '''
🥗 План питания от AI Meal Planner

🎯 Цель: $goal
📅 Период: $days дней
🔥 Калории в день: $totalCalories ккал

📋 Описание:
$summary

Создано в приложении AI Meal Planner 🍽️
''';

    await Share.share(
      text,
      subject: 'Мой план питания на $days дней',
    );
  }

  static Future<void> shareDayPlan({
    required String day,
    required String date,
    required int calories,
    required Map<String, int> macros,
    required Map<String, String> meals,
  }) async {
    final text = '''
📅 $day ($date)

🍽️ План питания:

Завтрак: ${meals['breakfast']}
Обед: ${meals['lunch']}
Ужин: ${meals['dinner']}

📊 Показатели:
• Калории: $calories ккал
• Белки: ${macros['protein']}г
• Углеводы: ${macros['carbs']}г
• Жиры: ${macros['fat']}г

Создано в приложении AI Meal Planner 🍽️
''';

    await Share.share(
      text,
      subject: 'План питания на $day',
    );
  }
}