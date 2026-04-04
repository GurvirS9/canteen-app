import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/data/models/cart_item.dart';
import 'package:student_app/data/models/order.dart';
import 'package:student_app/data/models/time_slot.dart';
import 'package:student_app/data/services/api_service.dart';
import 'package:student_app/data/services/socket_service.dart';
import 'package:student_app/core/utils/logger.dart';

class OrderState {
  final List<Order> activeOrders;
  final List<Order> orderHistory;
  final bool isPlacingOrder;
  final String? error;

  OrderState({
    required this.activeOrders,
    required this.orderHistory,
    this.isPlacingOrder = false,
    this.error,
  });

  OrderState copyWith({
    List<Order>? activeOrders,
    List<Order>? orderHistory,
    bool? isPlacingOrder,
    String? error,
  }) {
    return OrderState(
      activeOrders: activeOrders ?? this.activeOrders,
      orderHistory: orderHistory ?? this.orderHistory,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      error: error,
    );
  }

  Order? get activeOrder => activeOrders.isNotEmpty ? activeOrders.first : null;
  bool get hasActiveOrder => activeOrders.any((o) => o.status != OrderStatus.collected);
}

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();
  ref.onDispose(() => service.disconnect());
  return service;
});

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(
    ref.read(Provider<ApiService>((ref) => ApiService())),
    ref.read(socketServiceProvider),
  );
});

class OrderNotifier extends StateNotifier<OrderState> {
  static const String _tag = 'OrderNotifier';
  final ApiService _apiService;
  final SocketService _socketService;

  StreamSubscription<Map<String, dynamic>>? _orderUpdatedSub;
  StreamSubscription<Map<String, dynamic>>? _orderCreatedSub;
  Timer? _pollingTimer;

  OrderNotifier(this._apiService, this._socketService) : super(OrderState(
    activeOrders: [],
    orderHistory: [],
  ));

  Future<void> init() async {
    AppLogger.i(_tag, 'init()');
    await _connectSocket();
    await fetchActiveOrders();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchActiveOrders();
    });
  }

  Future<void> initSocket() => init();

  Future<void> _connectSocket() async {
    try {
      await _socketService.connect();
      _listenToSocketEvents();
      AppLogger.i(_tag, 'Socket connected and listeners attached');
    } catch (e, stack) {
      AppLogger.e(_tag, 'Failed to connect socket', e, stack);
    }
  }

  void _listenToSocketEvents() {
    _orderUpdatedSub?.cancel();
    _orderCreatedSub?.cancel();

    _orderUpdatedSub = _socketService.onOrderUpdated.listen((data) {
      _handleOrderUpdated(data);
    });

    _orderCreatedSub = _socketService.onOrderCreated.listen((data) {
      AppLogger.d(_tag, 'orderCreated socket event: ${data['id']}');
    });
  }

  void _handleOrderUpdated(Map<String, dynamic> data) {
    final orderId = (data['id'] ?? data['_id'] ?? '').toString();
    final newStatus = data['status'] as String?;

    if (orderId.isEmpty || newStatus == null) return;

    final idx = state.activeOrders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;

    final parsed = OrderStatus.values.firstWhere(
      (e) => e.name == newStatus,
      orElse: () => OrderStatus.pending,
    );

    final order = state.activeOrders[idx];
    if (order.status == parsed) return;

    AppLogger.i(_tag, 'orderUpdated: $orderId ${order.status.name} → ${parsed.name}');

    final newActive = List<Order>.from(state.activeOrders);
    final newHistory = List<Order>.from(state.orderHistory);

    if (parsed == OrderStatus.collected) {
      final completed = newActive.removeAt(idx).copyWith(status: parsed);
      newHistory.insert(0, completed);
    } else {
      newActive[idx] = order.copyWith(status: parsed);
    }

    state = state.copyWith(activeOrders: newActive, orderHistory: newHistory);
  }

  Future<List<TimeSlot>> getAvailableSlots() async {
    try {
      return await _apiService.getTimeSlots();
    } catch (e, stack) {
      AppLogger.e(_tag, 'getAvailableSlots() FAILED', e, stack);
      return [];
    }
  }

  Future<Order?> placeOrder(List<CartItem> items, {TimeSlot? selectedSlot}) async {
    state = state.copyWith(isPlacingOrder: true, error: null);
    try {
      final serverOrder = await _apiService.postOrder(items, selectedSlot: selectedSlot);

      final total = items.fold<double>(0, (sum, e) => sum + e.total);

      int estimation = 15 + (items.length * 2);
      if (selectedSlot != null) {
        final now = DateTime.now();
        final slotDiff = selectedSlot.startTime.difference(now).inMinutes;
        if (slotDiff > 0 && slotDiff < 60) estimation = slotDiff;
      }

      final newOrder = Order(
        id: serverOrder.id,
        items: items,
        totalAmount: total,
        status: serverOrder.status,
        placedAt: DateTime.now(),
        estimatedMinutes: estimation,
        queuePosition: serverOrder.queuePosition > 0 ? serverOrder.queuePosition : 1,
        selectedSlot: selectedSlot,
      );

      final newActive = List<Order>.from(state.activeOrders)..insert(0, newOrder);
      state = state.copyWith(isPlacingOrder: false, activeOrders: newActive);
      return newOrder;
    } catch (e, stack) {
      state = state.copyWith(
        isPlacingOrder: false,
        error: 'Failed to place order. Please try again.',
      );
      AppLogger.e(_tag, 'placeOrder() FAILED', e, stack);
      return null;
    }
  }

  Future<void> refreshQueue() => fetchActiveOrders();

  Future<void> fetchOrderHistory() async {
    try {
      final orders = await _apiService.getOrders();
      state = state.copyWith(orderHistory: orders);
    } catch (e, stack) {
      AppLogger.e(_tag, 'fetchOrderHistory() FAILED', e, stack);
    }
  }

  Future<void> fetchActiveOrders() async {
    try {
      final active = await _apiService.getActiveOrders();
      if (active.isNotEmpty) {
        state = state.copyWith(activeOrders: active);
      }
    } catch (e, stack) {
      AppLogger.e(_tag, 'fetchActiveOrders() FAILED silently', e, stack);
    }
  }

  void completeOrder([String? orderId]) {
    final idx = orderId != null
        ? state.activeOrders.indexWhere((o) => o.id == orderId)
        : state.activeOrders.isNotEmpty ? 0 : -1;

    if (idx != -1) {
      final newActive = List<Order>.from(state.activeOrders);
      final order = newActive.removeAt(idx);

      final newHistory = List<Order>.from(state.orderHistory);
      newHistory.insert(0, order.copyWith(status: OrderStatus.collected));

      state = state.copyWith(activeOrders: newActive, orderHistory: newHistory);
    }
  }

  void disconnectSocket() {
    _pollingTimer?.cancel();
    _orderUpdatedSub?.cancel();
    _orderCreatedSub?.cancel();
    _socketService.disconnect();
    state = state.copyWith(activeOrders: []);
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _orderUpdatedSub?.cancel();
    _orderCreatedSub?.cancel();
    _socketService.disconnect();
    super.dispose();
  }
}
