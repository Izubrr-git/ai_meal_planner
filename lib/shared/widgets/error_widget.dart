import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? retryButtonText;
  final String? dismissButtonText;

  const AppErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.retryButtonText = 'Повторить',
    this.dismissButtonText = 'Скрыть',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с кнопкой закрытия
          Row(
            children: [
              Icon(Icons.error, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ошибка',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red[700], size: 20),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Текст ошибки
          Text(
            error,
            style: TextStyle(color: Colors.red[700]),
          ),

          const SizedBox(height: 12),

          // Кнопки действий
          Row(
            children: [
              if (onRetry != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                    ),
                    child: Text(retryButtonText!),
                  ),
                ),

              if (onRetry != null && onDismiss != null)
                const SizedBox(width: 8),

              if (onDismiss != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[700]!),
                      foregroundColor: Colors.red[700],
                    ),
                    child: Text(dismissButtonText!),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}