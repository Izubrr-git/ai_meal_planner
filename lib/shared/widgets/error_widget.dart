import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? retryButtonText;

  const AppErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.retryButtonText = 'Попробовать снова',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          Text(
            error,
            style: TextStyle(color: Colors.red[700]),
          ),

          const SizedBox(height: 12),

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
            ],
          ),
        ],
      ),
    );
  }
}