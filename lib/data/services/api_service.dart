import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:student_app/data/models/cart_item.dart';
import 'package:student_app/data/models/menu_item.dart';
import 'package:student_app/data/models/order.dart';
import 'package:student_app/data/models/time_slot.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/utils/logger.dart';

class ApiService {
  static const String _tag = 'ApiService';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    AppLogger.lifecycle(_tag, 'Singleton instance created');
  }

  /// Custom HTTP client that trusts self-signed certs (dev only)
  http.Client get _client {
    final ioClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    return IOClient(ioClient);
  }

  Uri _uri(String endpoint) =>
      Uri.parse('${AppConstants.baseUrl}$endpoint');

  /// Build headers with Content-Type and Firebase Auth token.
  /// Tries a force-refreshed Firebase ID token first; falls back to the
  /// backend's dev-bypass key if no user is signed in.
  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    try {
      final user = firebase.FirebaseAuth.instance.currentUser;
      if (user != null) {
        // forceRefresh: true ensures we never send an expired token
        final token = await user.getIdToken(true);
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          AppLogger.d(_tag, '_headers() Firebase token attached (force-refreshed)');
          return headers;
        }
      }
    } catch (e) {
      AppLogger.w(_tag, '_headers() Firebase token failed: $e — falling back to dev key');
    }
    // Fallback: use the backend's Swagger dev-key bypass (dev/test only)
    headers['Authorization'] = 'Bearer ${AppConstants.devAuthKey}';
    AppLogger.w(_tag, '_headers() Using dev auth key fallback');
    return headers;
  }

  /// Shared GET helper
  Future<http.Response> _get(String endpoint) async {
    final url = _uri(endpoint).toString();
    AppLogger.network('GET', url);
    final stopwatch = Stopwatch()..start();
    final client = _client;
    final headers = await _headers();

    try {
      final response = await client
          .get(_uri(endpoint), headers: headers)
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      stopwatch.stop();
      AppLogger.network('GET', url,
          statusCode: response.statusCode, body: response.body);
      AppLogger.perf(_tag, 'GET $endpoint', stopwatch.elapsed);
      return response;
    } on TimeoutException {
      stopwatch.stop();
      AppLogger.e(_tag, 'GET $endpoint TIMED OUT after ${AppConstants.apiTimeout}s');
      rethrow;
    } on SocketException catch (e) {
      stopwatch.stop();
      AppLogger.e(_tag, 'GET $endpoint SOCKET ERROR: $e');
      rethrow;
    } catch (e, stack) {
      stopwatch.stop();
      AppLogger.e(_tag, 'GET $endpoint FAILED', e, stack);
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Shared POST helper
  Future<http.Response> _post(String endpoint,
      {Map<String, dynamic>? body}) async {
    final url = _uri(endpoint).toString();
    AppLogger.network('POST', url, body: body != null ? json.encode(body) : null);
    final stopwatch = Stopwatch()..start();
    final client = _client;
    final headers = await _headers();

    try {
      final response = await client
          .post(
            _uri(endpoint),
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      stopwatch.stop();
      AppLogger.network('POST', url,
          statusCode: response.statusCode, body: response.body);
      AppLogger.perf(_tag, 'POST $endpoint', stopwatch.elapsed);
      return response;
    } on TimeoutException {
      stopwatch.stop();
      AppLogger.e(_tag, 'POST $endpoint TIMED OUT after ${AppConstants.apiTimeout}s');
      rethrow;
    } on SocketException catch (e) {
      stopwatch.stop();
      AppLogger.e(_tag, 'POST $endpoint SOCKET ERROR: $e');
      rethrow;
    } catch (e, stack) {
      stopwatch.stop();
      AppLogger.e(_tag, 'POST $endpoint FAILED', e, stack);
      rethrow;
    } finally {
      client.close();
    }
  }

  // ─── Menu ──────────────────────────────────────────────────────────

  /// GET /menu – Get all menu items
  Future<List<MenuItem>> getMenu() async {
    AppLogger.i(_tag, 'getMenu()');
    final response = await _get(AppConstants.menuEndpoint);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final items = data
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getMenu() parsed ${items.length} items from API');
      final noImage = items.where((i) => i.imageUrl.isEmpty).toList();
      if (noImage.isNotEmpty) {
        AppLogger.w(_tag,
            '${noImage.length} menu items have no image: ${noImage.map((i) => i.name).join(', ')}');
      }
      return items;
    }
    AppLogger.e(_tag, 'getMenu() failed with status ${response.statusCode}');
    throw Exception('Failed to load menu (${response.statusCode})');
  }

  // ─── Slots ─────────────────────────────────────────────────────────

  /// GET /slots – Get all time slots
  Future<List<TimeSlot>> getTimeSlots() async {
    AppLogger.i(_tag, 'getTimeSlots()');
    final response = await _get(AppConstants.slotsEndpoint);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final slots = data
          .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getTimeSlots() parsed ${slots.length} slots');
      return slots;
    }
    AppLogger.e(_tag, 'getTimeSlots() failed with status ${response.statusCode}');
    throw Exception('Failed to load time slots (${response.statusCode})');
  }

  /// POST /slots/check – Check capacity for a specific slot
  Future<Map<String, dynamic>> checkSlotCapacity(String slotId) async {
    AppLogger.i(_tag, 'checkSlotCapacity() slotId=$slotId');
    final response = await _post(
      AppConstants.slotsCheckEndpoint,
      body: {'slotId': slotId},
    );
    if (response.statusCode == 200) {
      final result = json.decode(response.body) as Map<String, dynamic>;
      AppLogger.i(_tag, 'checkSlotCapacity() result: $result');
      return result;
    }
    AppLogger.e(_tag, 'checkSlotCapacity() failed with status ${response.statusCode}');
    throw Exception('Failed to check slot capacity (${response.statusCode})');
  }

  // ─── Orders ────────────────────────────────────────────────────────

  /// GET /orders – Get all orders (history)
  Future<List<Order>> getOrders() async {
    AppLogger.i(_tag, 'getOrders()');
    final response = await _get(AppConstants.ordersEndpoint);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final orders = data
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getOrders() parsed ${orders.length} orders');
      return orders;
    }
    AppLogger.e(_tag, 'getOrders() failed with status ${response.statusCode}');
    throw Exception('Failed to load orders (${response.statusCode})');
  }

  /// GET /orders/active?userId=[uid] – Get active orders for current user
  Future<List<Order>> getActiveOrders() async {
    AppLogger.i(_tag, 'getActiveOrders()');
    final uid = firebase.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      AppLogger.w(_tag, 'getActiveOrders() no Firebase user, returning empty');
      return [];
    }
    final response = await _get('${AppConstants.activeOrdersEndpoint}?userId=$uid');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final orders = data
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
      AppLogger.i(_tag, 'getActiveOrders() parsed ${orders.length} active orders');
      return orders;
    }
    AppLogger.e(_tag, 'getActiveOrders() failed with status ${response.statusCode}');
    throw Exception('Failed to load active orders (${response.statusCode})');
  }

  /// POST /orders – Create a new order
  Future<Order> postOrder(
    List<CartItem> items, {
    TimeSlot? selectedSlot,
    String? userId,
  }) async {
    AppLogger.i(_tag,
        'postOrder() ${items.length} items | slot=${selectedSlot?.id ?? 'none'}');
    final firebaseUid = userId ?? firebase.FirebaseAuth.instance.currentUser?.uid;
    final body = {
      if (firebaseUid != null) 'userId': firebaseUid,
      'items': items
          .map((e) => ({
                'menuItem': e.menuItem.id,
                'quantity': e.quantity,
              }))
          .toList(),
      'slotId': selectedSlot?.id ?? '',
      'status': 'pending',
    };
    AppLogger.d(_tag, 'postOrder() REQUEST BODY: ${json.encode(body)}');
    final response = await _post(AppConstants.ordersEndpoint, body: body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      final order = Order.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
      AppLogger.i(_tag, 'postOrder() order created: ${order.id}');
      return order;
    }
    AppLogger.e(_tag,
        'postOrder() failed with status ${response.statusCode} | body: ${response.body}');
    throw Exception('Failed to create order (${response.statusCode})');
  }

  /// GET /orders/{id}/status – Get status of an order
  Future<Map<String, dynamic>> getOrderStatus(String orderId) async {
    AppLogger.i(_tag, 'getOrderStatus() orderId=$orderId');
    final response = await _get(AppConstants.orderStatusEndpoint(orderId));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      AppLogger.i(_tag, 'getOrderStatus() status=${data['status']} for $orderId');
      return data;
    }
    AppLogger.e(_tag, 'getOrderStatus() failed with status ${response.statusCode}');
    throw Exception('Failed to get order status (${response.statusCode})');
  }
}
