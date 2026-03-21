import 'cart_item.dart';
import 'time_slot.dart';

enum OrderStatus {
  placed,
  confirmed,
  preparing,
  ready,
  completed,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get emoji {
    switch (this) {
      case OrderStatus.placed:
        return '📋';
      case OrderStatus.confirmed:
        return '✅';
      case OrderStatus.preparing:
        return '👨‍🍳';
      case OrderStatus.ready:
        return '🍽️';
      case OrderStatus.completed:
        return '✔️';
      case OrderStatus.cancelled:
        return '❌';
    }
  }
}

class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime placedAt;
  final int estimatedMinutes;
  final int queuePosition;
  final String? itemsSummary; // For history display without full items
  final TimeSlot? selectedSlot;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.placedAt,
    required this.estimatedMinutes,
    required this.queuePosition,
    this.itemsSummary,
    this.selectedSlot,
  });

  Order copyWith({
    OrderStatus? status,
    int? queuePosition,
    int? estimatedMinutes,
  }) =>
      Order(
        id: id,
        items: items,
        totalAmount: totalAmount,
        status: status ?? this.status,
        placedAt: placedAt,
        estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
        queuePosition: queuePosition ?? this.queuePosition,
        itemsSummary: itemsSummary,
        selectedSlot: selectedSlot,
      );

  String get displaySummary {
    if (itemsSummary != null) return itemsSummary!;
    if (items.isEmpty) return 'No items';
    return items.map((e) => e.menuItem.name).join(', ');
  }
}
