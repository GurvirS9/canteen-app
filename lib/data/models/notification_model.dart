enum NotificationType { orderUpdate, offer, general }

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  bool isRead;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.timestamp,
  });
}
