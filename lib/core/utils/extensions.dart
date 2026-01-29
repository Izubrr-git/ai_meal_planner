import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  bool get isNullOrEmpty => isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  bool get isNumeric {
    if (isEmpty) return false;
    return double.tryParse(this) != null;
  }

  int? toIntOrNull() => int.tryParse(this);
  double? toDoubleOrNull() => double.tryParse(this);
}

extension NumberExtensions on num {
  String formatCalories() => '${toString()} ккал';
  String formatGrams() => '${toString()}г';

  String formatWithSeparator() {
    final formatter = NumberFormat('#,###', 'ru_RU');
    return formatter.format(this);
  }

  String toPercentage() => '${this}%';

  num clampNum(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

extension DateTimeExtensions on DateTime {
  String formatDate([String pattern = 'dd.MM.yyyy']) {
    return DateFormat(pattern, 'ru_RU').format(this);
  }

  String formatDateTime([String pattern = 'dd.MM.yyyy HH:mm']) {
    return DateFormat(pattern, 'ru_RU').format(this);
  }

  String formatTime([String pattern = 'HH:mm']) {
    return DateFormat(pattern, 'ru_RU').format(this);
  }

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

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
}

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  EdgeInsets get safeAreaInsets => MediaQuery.of(this).viewPadding;

  bool get isTablet => screenWidth >= 600;

  bool get isPortrait => screenHeight > screenWidth;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
  bool get isNullOrEmpty => isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  T? elementAtOrNull(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }

  String joinToString({String separator = ', ', String Function(T)? transform}) {
    if (isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      if (i > 0) buffer.write(separator);
      buffer.write(transform?.call(this[i]) ?? this[i].toString());
    }
    return buffer.toString();
  }

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
  V? getOrNull(K key) => containsKey(key) ? this[key] : null;

  V getOrElse(K key, V defaultValue) => containsKey(key) ? this[key]! : defaultValue;
}