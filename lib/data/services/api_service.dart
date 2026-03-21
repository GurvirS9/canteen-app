import 'dart:async';
import 'package:student_app/data/models/cart_item.dart';
import 'package:student_app/data/models/menu_item.dart';
import 'package:student_app/data/models/order.dart';
import 'package:student_app/data/models/time_slot.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/utils/mock_data.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final bool _demoMode = AppConstants.demoMode;

  /// Simulated delay for demo mode to mimic network latency
  Future<void> _fakeDelay() =>
      Future.delayed(const Duration(milliseconds: AppConstants.demoDelay));

  /// GET /menu
  Future<List<MenuItem>> getMenu() async {
    if (_demoMode) {
      await _fakeDelay();
      return MockData.menuItems;
    }
    // Real implementation placeholder:
    // final response = await http.get(Uri.parse('${AppConstants.baseUrl}${AppConstants.menuEndpoint}'));
    // if (response.statusCode == 200) {
    //   final List<dynamic> data = json.decode(response.body);
    //   return data.map((e) => MenuItem.fromJson(e)).toList();
    // }
    throw UnimplementedError('Real API not connected yet.');
  }

  /// GET /slots -> Now strongly typed
  Future<List<TimeSlot>> getTimeSlots() async {
    if (_demoMode) {
      await _fakeDelay();
      return MockData.timeSlots;
    }
    throw UnimplementedError('Real API not connected yet.');
  }

  /// POST /order
  Future<Order> postOrder(List<CartItem> items, {TimeSlot? selectedSlot}) async {
    if (_demoMode) {
      await _fakeDelay();
      final total = items.fold<double>(0, (sum, e) => sum + e.total);
      final taxed = total + (total * 0.05); // 5% tax
      return Order(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch % 10000}',
        items: items,
        totalAmount: taxed,
        status: OrderStatus.placed,
        placedAt: DateTime.now(),
        estimatedMinutes: 12 + (items.length * 2),
        queuePosition: 5,
        selectedSlot: selectedSlot,
      );
    }
    throw UnimplementedError('Real API not connected yet.');
  }
}
