import 'package:student_app/data/models/notification_model.dart';
import 'package:student_app/core/utils/mock_data.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationModel> _notifications = [...MockData.notifications];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) _notifications[idx].isRead = true;
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
  }

  void addOrderNotification(String orderId, String message) {
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: '📋 Order Placed!',
        body: message,
        type: NotificationType.orderUpdate,
        isRead: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void simulateOrderReady(String orderId) {
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_ready_${DateTime.now().millisecondsSinceEpoch}',
        title: '🍽️ Order Ready!',
        body: 'Order $orderId is ready for pickup at Counter 2.',
        type: NotificationType.orderUpdate,
        isRead: false,
        timestamp: DateTime.now(),
      ),
    );
  }
}
