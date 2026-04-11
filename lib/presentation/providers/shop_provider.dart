import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/data/models/shop.dart';
import 'package:student_app/data/services/shop_service.dart';
import 'package:student_app/core/utils/logger.dart';

class ShopState {
  final List<Shop> shops;
  final Shop? selectedShop;
  final bool isLoading;
  final String? error;

  const ShopState({
    this.shops = const [],
    this.selectedShop,
    this.isLoading = false,
    this.error,
  });

  ShopState copyWith({
    List<Shop>? shops,
    Shop? selectedShop,
    bool clearSelectedShop = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ShopState(
      shops: shops ?? this.shops,
      selectedShop: clearSelectedShop ? null : (selectedShop ?? this.selectedShop),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final shopServiceProvider = Provider<ShopService>((ref) => ShopService());

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier(ref.read(shopServiceProvider));
});

class ShopNotifier extends StateNotifier<ShopState> {
  static const String _tag = 'ShopNotifier';
  static const _selectedShopKey = 'selected_shop_id';

  final ShopService _service;

  ShopNotifier(this._service) : super(const ShopState()) {
    _restoreSelectedShop();
  }

  Future<void> _restoreSelectedShop() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_selectedShopKey);
      if (savedId != null && savedId.isNotEmpty) {
        AppLogger.d(_tag, 'Restoring previously selected shop: $savedId');
        // We'll load shops and find it, or fetch by id when shops load
        state = state.copyWith(isLoading: true);
        final shops = await _service.getShops();
        final found = shops.where((s) => s.id == savedId).firstOrNull;
        state = state.copyWith(
          shops: shops,
          selectedShop: found,
          isLoading: false,
        );
      }
    } catch (e) {
      AppLogger.w(_tag, '_restoreSelectedShop() failed: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchShops({double? lat, double? lng}) async {
    AppLogger.i(_tag, 'fetchShops()');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final shops = await _service.getShops(lat: lat, lng: lng);
      state = state.copyWith(shops: shops, isLoading: false);
      AppLogger.i(_tag, 'fetchShops() loaded ${shops.length} shops');
    } catch (e, st) {
      AppLogger.e(_tag, 'fetchShops() failed', e, st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectShop(Shop shop) {
    AppLogger.i(_tag, 'selectShop() ${shop.name}');
    state = state.copyWith(selectedShop: shop);
    _persistSelectedShop(shop.id);
  }

  void clearSelectedShop() {
    AppLogger.i(_tag, 'clearSelectedShop()');
    state = state.copyWith(clearSelectedShop: true);
    _persistSelectedShop('');
  }

  Future<void> _persistSelectedShop(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (id.isEmpty) {
        await prefs.remove(_selectedShopKey);
      } else {
        await prefs.setString(_selectedShopKey, id);
      }
    } catch (e) {
      AppLogger.w(_tag, '_persistSelectedShop() failed: $e');
    }
  }
}
