import 'package:flutter/material.dart';

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void showStatusNotification({
    required String orderNumber,
    required String statusLabel,
    required String statusEmoji,
    required Color color,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        backgroundColor: Colors.white,
        content: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                Center(child: Text(statusEmoji,
                    style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Status Pesanan Diperbarui',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF1B1B1B))),
                Text(
                  'Order #$orderNumber → $statusLabel',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF4A4A4A)),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}