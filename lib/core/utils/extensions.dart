import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  /// Проверяет, является ли строка null или пустой
  bool get isNullOrEmpty => isEmpty;

  /// Проверяет, является ли строка не пустой
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Преобразует строку в формат заголовка (каждое слово с заглавной)
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Обрезает строку до указанной длины и добавляет многоточие
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Проверяет, содержит ли строка только цифры
  bool get isNumeric {
    if (isEmpty) return false;
    return double.tryParse(this) != null;
  }

  /// Преобразует строку в число, возвращает null при ошибке
  int? toIntOrNull() => int.tryParse(this);

  /// Преобразует строку в double, возвращает null при ошибке
  double? toDoubleOrNull() => double.tryParse(this);
}

extension NumberExtensions on num {
  /// Форматирует число как калории
  String formatCalories() => '${toString()} ккал';

  /// Форматирует число как граммы
  String formatGrams() => '${toString()}г';

  /// Форматирует число с разделителями тысяч
  String formatWithSeparator() {
    final formatter = NumberFormat('#,###', 'ru_RU');
    return formatter.format(this);
  }

  /// Преобразует число в проценты
  String toPercentage() => '${this}%';

  /// Ограничивает число в пределах min и max
  num clampNum(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

extension DateTimeExtensions on DateTime {
  /// Форматирует дату в строку
  String formatDate([String pattern = 'dd.MM.yyyy']) {
    return DateFormat(pattern, 'ru_RU').format(this);
  }

  /// Форматирует дату и время
  String formatDateTime([String pattern = 'dd.MM.yyyy HH:mm']) {
    return DateFormat(pattern, 'ru_RU').format(this);
  }

  /// Форматирует время
  String formatTime([String pattern = 'HH:mm']) {
    return DateFormat(pattern, 'ru_RU').format(this);
  }

  /// Возвращает относительное время (например, "2 часа назад")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'только что';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${_pluralize(minutes, 'минуту', 'минуты', 'минут')} назад';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${_pluralize(hours, 'час', 'часа', 'часов')} назад';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${_pluralize(days, 'день', 'дня', 'дней')} назад';
    } else {
      return formatDate();
    }
  }

  String _pluralize(int number, String one, String two, String five) {
    final n = number.abs();
    if (n % 10 == 1 && n % 100 != 11) return one;
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return two;
    return five;
  }

  /// Проверяет, является ли дата сегодняшним днем
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Проверяет, является ли дата вчерашним днем
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}

extension ContextExtensions on BuildContext {
  /// Получает тему из контекста
  ThemeData get theme => Theme.of(this);

  /// Получает цветовую схему
  ColorScheme get colorScheme => theme.colorScheme;

  /// Получает TextTheme
  TextTheme get textTheme => theme.textTheme;

  /// Получает ширину экрана
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Получает высоту экрана
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Получает статус безопасных областей
  EdgeInsets get safeAreaInsets => MediaQuery.of(this).viewPadding;

  /// Проверяет, является ли устройство планшетом
  bool get isTablet => screenWidth >= 600;

  /// Проверяет, находится ли устройство в портретной ориентации
  bool get isPortrait => screenHeight > screenWidth;

  /// Показывает уведомление
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Показывает диалог подтверждения
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = 'Да',
    String cancelText = 'Нет',
  }) async {
    return await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

extension ListExtensions<T> on List<T> {
  /// Проверяет, не является ли список null или пустым
  bool get isNullOrEmpty => isEmpty;

  /// Проверяет, является ли список не пустым
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Возвращает элемент по индексу или null, если индекс вне диапазона
  T? elementAtOrNull(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }

  /// Объединяет элементы в строку с разделителем
  String joinToString({String separator = ', ', String Function(T)? transform}) {
    if (isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      if (i > 0) buffer.write(separator);
      buffer.write(transform?.call(this[i]) ?? this[i].toString());
    }
    return buffer.toString();
  }

  /// Создает список с удаленными дубликатами
  List<T> distinct() {
    final result = <T>[];
    for (final element in this) {
      if (!result.contains(element)) {
        result.add(element);
      }
    }
    return result;
  }
}

extension MapExtensions<K, V> on Map<K, V> {
  /// Получает значение по ключу или null
  V? getOrNull(K key) => containsKey(key) ? this[key] : null;

  /// Получает значение по ключу или значение по умолчанию
  V getOrElse(K key, V defaultValue) => containsKey(key) ? this[key]! : defaultValue;
}