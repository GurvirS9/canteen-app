import 'dart:async';
import 'package:flutter/material.dart';
import 'package:student_app/data/models/cart_item.dart';
import 'package:student_app/data/models/order.dart';
import 'package:student_app/data/models/time_slot.dart';
import 'package:student_app/data/services/api_service.dart';
import 'package:student_app/core/utils/mock_data.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Order? _activeOrder;
  final List<Order> _orderHistory = List<Order>.from(MockData.orderHistory);
  bool _isPlacingOrder = false;
  String? _error;
  Timer? _simulationTimer;

  Order? get activeOrder => _activeOrder;
  List<Order> get orderHistory => _orderHistory;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get error => _error;
  bool get hasActiveOrder => _activeOrder != null &&
      _activeOrder!.status != OrderStatus.completed &&
      _activeOrder!.status != OrderStatus.cancelled;

  Future<List<TimeSlot>> getAvailableSlots() async {
    try {
      return await _apiService.getTimeSlots();
    } catch (e) {
      return [];
    }
  }

  Future<Order?> placeOrder(List<CartItem> items, {TimeSlot? selectedSlot}) async {
    _isPlacingOrder = true;
    _error = null;
    notifyListeners();
    try {
      var order = await _apiService.postOrder(items, selectedSlot: selectedSlot);
      if (selectedSlot != null) {
        final now = DateTime.now();
        final diff = selectedSlot.startTime.difference(now).inMinutes;
        final estimation = diff > 0 ? diff : 15;
        order = order.copyWith(estimatedMinutes: estimation);
      }
      _activeOrder = order;
      _isPlacingOrder = false;
      notifyListeners();
      _startOrderSimulation();
      return order;
    } catch (e) {
      _error = 'Failed to place order. Please try again.';
      _isPlacingOrder = false;
      notifyListeners();
      return null;
    }
  }

  void _startOrderSimulation() {
    _simulationTimer?.cancel();
    int step = 0;
    final statuses = [
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
    ];
    _simulationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (step < statuses.length && _activeOrder != null) {
        final newEta = _activeOrder!.estimatedMinutes - ((step + 1) * 3);
        final newQueue = (_activeOrder!.queuePosition - (step + 1)).clamp(0, 99);
        _activeOrder = _activeOrder!.copyWith(
          status: statuses[step],
          estimatedMinutes: newEta.clamp(0, 60),
          queuePosition: newQueue,
        );
        step++;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> refreshQueue() async {
    // In demo mode just notify — real impl would re-fetch
    notifyListeners();
  }

  void completeOrder() {
    if (_activeOrder != null) {
      _orderHistory.insert(0, _activeOrder!.copyWith(status: OrderStatus.completed));
      _activeOrder = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
