import 'dart:convert';
import 'package:student_app/data/models/shop.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/utils/logger.dart';
import 'package:student_app/data/services/api_service.dart';

class ShopService {
  static const String _tag = 'ShopService';

  final ApiService _api = ApiService();

  /// GET /api/shops — fetch all shops, optionally filtering by location
  Future<List<Shop>> getShops({double? lat, double? lng, double radius = 10}) async {
    AppLogger.i(_tag, 'getShops()');
    String endpoint = AppConstants.shopsEndpoint;
    if (lat != null && lng != null) {
      endpoint += '?lat=$lat&lng=$lng&radius=$radius';
    }
    final response = await _api.getEndpoint(endpoint);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final shops = data.map((e) => Shop.fromJson(e as Map<String, dynamic>)).toList();
      AppLogger.i(_tag, 'getShops() parsed ${shops.length} shops');
      return shops;
    }
    AppLogger.e(_tag, 'getShops() failed with status ${response.statusCode}');
    throw Exception('Failed to load shops (${response.statusCode})');
  }

  /// GET /api/shops/:id
  Future<Shop> getShop(String id) async {
    AppLogger.i(_tag, 'getShop() id=$id');
    final response = await _api.getEndpoint(AppConstants.shopEndpoint(id));
    if (response.statusCode == 200) {
      final shop = Shop.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      AppLogger.i(_tag, 'getShop() loaded ${shop.name}');
      return shop;
    }
    AppLogger.e(_tag, 'getShop() failed with status ${response.statusCode}');
    throw Exception('Failed to load shop (${response.statusCode})');
  }
}
