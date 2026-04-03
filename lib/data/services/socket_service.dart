import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/utils/logger.dart';

/// Singleton Socket.IO client for real-time order status updates.
class SocketService {
  static const String _tag = 'SocketService';

  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // ── Streams for order events ─────────────────────────────────
  final _orderUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _orderCreatedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onOrderUpdated =>
      _orderUpdatedController.stream;
  Stream<Map<String, dynamic>> get onOrderCreated =>
      _orderCreatedController.stream;

  /// Connect to the backend Socket.IO server.
  /// Should be called after Firebase Auth login.
  Future<void> connect() async {
    if (_socket != null && _isConnected) {
      AppLogger.d(_tag, 'Already connected, skipping');
      return;
    }

    String? token;
    try {
      token = await firebase.FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (e) {
      AppLogger.w(_tag, 'Could not get Firebase token for socket: $e');
    }

    final socketUrl = AppConstants.socketUrl;
    AppLogger.i(_tag, 'Connecting to $socketUrl');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setAuth({'token': token ?? ''})
          .setQuery({'userId': firebase.FirebaseAuth.instance.currentUser?.uid ?? ''})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      AppLogger.i(_tag, 'Connected (id: ${_socket!.id})');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      AppLogger.w(_tag, 'Disconnected');
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      AppLogger.e(_tag, 'Connection error: $err');
    });

    _socket!.on('orderUpdated', (data) {
      AppLogger.d(_tag, 'orderUpdated event: $data');
      if (data is Map<String, dynamic>) {
        _orderUpdatedController.add(data);
      } else if (data is Map) {
        _orderUpdatedController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('orderCreated', (data) {
      AppLogger.d(_tag, 'orderCreated event: $data');
      if (data is Map<String, dynamic>) {
        _orderCreatedController.add(data);
      } else if (data is Map) {
        _orderCreatedController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.connect();
  }

  /// Disconnect from the server (e.g. on logout).
  void disconnect() {
    AppLogger.i(_tag, 'Disconnecting');
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  /// Dispose all resources.
  void dispose() {
    disconnect();
    _orderUpdatedController.close();
    _orderCreatedController.close();
  }
}
