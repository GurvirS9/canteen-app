import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/data/models/notification_model.dart';
import 'package:student_app/data/services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.read(notificationServiceProvider));
});

class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationState({
    required this.notifications,
    required this.unreadCount,
  });
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service;

  NotificationNotifier(this._service) : super(NotificationState(
    notifications: _service.notifications,
    unreadCount: _service.unreadCount,
  ));

  void _updateState() {
    state = NotificationState(
      notifications: List.from(_service.notifications),
      unreadCount: _service.unreadCount,
    );
  }

  void markRead(String id) {
    _service.markAsRead(id);
    _updateState();
  }

  void markAllRead() {
    _service.markAllAsRead();
    _updateState();
  }

  void onOrderPlaced(String orderId) {
    _service.addOrderNotification(
      orderId,
      'Your order $orderId has been placed! Estimated time: 12 mins.',
    );
    _updateState();
  }
}
