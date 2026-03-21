import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationModel> get notifications => _service.notifications;
  int get unreadCount => _service.unreadCount;

  void markRead(String id) {
    _service.markAsRead(id);
    notifyListeners();
  }

  void markAllRead() {
    _service.markAllAsRead();
    notifyListeners();
  }

  void onOrderPlaced(String orderId) {
    _service.addOrderNotification(
      orderId,
      'Your order $orderId has been placed! Estimated time: 12 mins.',
    );
    notifyListeners();
  }
}
