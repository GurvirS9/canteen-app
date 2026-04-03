import 'cart_item.dart';
import 'time_slot.dart';

enum OrderStatus {
  pending,
  preparing,
  ready,
  collected,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.collected:
        return 'Collected';
    }
  }

  String get emoji {
    switch (this) {
      case OrderStatus.pending:
        return '⏳';
      case OrderStatus.preparing:
        return '👨‍🍳';
      case OrderStatus.ready:
        return '🍽️';
      case OrderStatus.collected:
        return '✔️';
    }
  }
}

OrderStatus _parseOrderStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'pending':
      return OrderStatus.pending;
    case 'preparing':
      return OrderStatus.preparing;
    case 'ready':
      return OrderStatus.ready;
    case 'collected':
      return OrderStatus.collected;
    // Legacy mappings from old 7-status enum
    case 'placed':
    case 'confirmed':
      return OrderStatus.pending;
    case 'completed':
      return OrderStatus.collected;
    default:
      return OrderStatus.pending;
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

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse items array from backend (each has menuItem object or string + quantity)
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemNames = <String>[];
    for (final e in rawItems) {
      if (e is Map) {
        final menuItem = e['menuItem'];
        if (menuItem is Map) {
          final name = menuItem['name']?.toString() ?? '';
          final qty = e['quantity'] ?? 1;
          if (name.isNotEmpty) {
            itemNames.add('${qty}x $name');
          }
        } else if (menuItem is String && menuItem.isNotEmpty) {
          itemNames.add(menuItem);
        }
      }
    }
    // Also handle backend's formatted items string (from getOrders)
    final formattedItems = json['items'];
    String? itemsSummaryStr;
    if (formattedItems is String && formattedItems.isNotEmpty) {
      itemsSummaryStr = formattedItems;
    } else if (itemNames.isNotEmpty) {
      itemsSummaryStr = itemNames.join(', ');
    }

    // Parse totalAmount from items if not provided
    double totalAmount = (json['totalAmount'] as num?)?.toDouble() ?? 0.0;
    if (totalAmount == 0.0 && rawItems.isNotEmpty) {
      for (final e in rawItems) {
        if (e is Map) {
          final menuItem = e['menuItem'];
          final qty = (e['quantity'] as num?)?.toInt() ?? 1;
          if (menuItem is Map) {
            final price = (menuItem['price'] as num?)?.toDouble() ?? 0.0;
            totalAmount += price * qty;
          }
        }
      }
    }

    return Order(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      items: const [], // Full CartItem objects are only available client-side
      totalAmount: totalAmount,
      status: _parseOrderStatus(json['status'] as String?),
      placedAt: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : (json['placedAt'] != null
              ? DateTime.tryParse(json['placedAt'].toString()) ?? DateTime.now()
              : (json['createdAt'] != null
                  ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
                  : DateTime.now())),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 15,
      queuePosition: json['queuePosition'] as int? ?? 0,
      itemsSummary: itemsSummaryStr,
      selectedSlot: json['slot'] != null && json['slot'] is Map
          ? TimeSlot.fromJson(json['slot'] as Map<String, dynamic>)
          : (json['slotId'] != null && json['slotId'] is Map
              ? TimeSlot.fromJson(json['slotId'] as Map<String, dynamic>)
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items
            .map((e) => {
                  'menuItem': e.menuItem.name,
                  'quantity': e.quantity,
                })
            .toList(),
        'totalAmount': totalAmount,
        'status': status.name,
        'placedAt': placedAt.toIso8601String(),
        'estimatedMinutes': estimatedMinutes,
        'queuePosition': queuePosition,
      };
}
