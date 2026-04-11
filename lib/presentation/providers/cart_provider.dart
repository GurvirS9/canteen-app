import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/data/models/cart_item.dart';
import 'package:student_app/data/models/menu_item.dart';
import 'package:student_app/core/utils/logger.dart';

class CartState {
  final List<CartItem> items;
  final String? shopId; // Scoped to a single shop

  const CartState({this.items = const [], this.shopId});

  CartState copyWith({List<CartItem>? items, String? shopId, bool clearShopId = false}) {
    return CartState(
      items: items ?? this.items,
      shopId: clearShopId ? null : (shopId ?? this.shopId),
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<CartState> {
  static const String _tag = 'CartNotifier';

  CartNotifier() : super(const CartState());

  List<CartItem> get cartItems => state.items;
  String? get shopId => state.shopId;

  int get itemCount => state.items.fold(0, (sum, e) => sum + e.quantity);
  double get subtotal => state.items.fold(0.0, (sum, e) => sum + e.total);
  double get tax => subtotal * 0.05;
  double get total => subtotal + tax;
  bool get isEmpty => state.items.isEmpty;

  int quantityOf(String menuItemId) {
    try {
      return state.items.firstWhere((e) => e.menuItem.id == menuItemId).quantity;
    } catch (_) {
      return 0;
    }
  }

  /// Returns true if the item was added; returns false if it belongs to a
  /// different shop (caller should show a confirmation dialog first).
  bool addItem(MenuItem menuItem, {String? shopId}) {
    // Cross-shop guard
    if (state.shopId != null && shopId != null && state.shopId != shopId && state.items.isNotEmpty) {
      AppLogger.w(_tag, 'addItem() cross-shop attempt blocked — cart is for shop ${state.shopId}, tried $shopId');
      return false;
    }

    final idx = state.items.indexWhere((e) => e.menuItem.id == menuItem.id);
    final newItems = List<CartItem>.from(state.items);

    if (idx >= 0) {
      newItems[idx] = newItems[idx].copyWith(quantity: newItems[idx].quantity + 1);
      AppLogger.d(_tag, 'addItem() incremented "${menuItem.name}" qty=${newItems[idx].quantity}');
    } else {
      newItems.add(CartItem(menuItem: menuItem));
      AppLogger.i(_tag, 'addItem() added "${menuItem.name}" to cart');
    }

    state = state.copyWith(items: newItems, shopId: shopId ?? state.shopId);
    AppLogger.d(_tag, 'Cart state: ${state.items.length} unique items, $itemCount total qty, subtotal=₹${subtotal.toStringAsFixed(2)}');
    return true;
  }

  void removeItem(MenuItem menuItem) {
    final idx = state.items.indexWhere((e) => e.menuItem.id == menuItem.id);
    if (idx >= 0) {
      final newItems = List<CartItem>.from(state.items);
      if (newItems[idx].quantity > 1) {
        newItems[idx] = newItems[idx].copyWith(quantity: newItems[idx].quantity - 1);
        AppLogger.d(_tag, 'removeItem() decremented "${menuItem.name}" qty=${newItems[idx].quantity}');
      } else {
        newItems.removeAt(idx);
        AppLogger.i(_tag, 'removeItem() removed "${menuItem.name}" from cart');
      }
      final newShopId = newItems.isEmpty ? null : state.shopId;
      state = state.copyWith(items: newItems, shopId: newShopId, clearShopId: newItems.isEmpty);
      AppLogger.d(_tag, 'Cart state: ${state.items.length} unique items, $itemCount total qty, subtotal=₹${subtotal.toStringAsFixed(2)}');
    } else {
      AppLogger.w(_tag, 'removeItem() "${menuItem.name}" not found in cart');
    }
  }

  void removeItemCompletely(String menuItemId) {
    final newItems = state.items.where((e) => e.menuItem.id != menuItemId).toList();
    if (newItems.length != state.items.length) {
      AppLogger.i(_tag, 'removeItemCompletely() removed item from cart');
      final newShopId = newItems.isEmpty ? null : state.shopId;
      state = state.copyWith(items: newItems, shopId: newShopId, clearShopId: newItems.isEmpty);
    }
  }

  void clearCart() {
    AppLogger.i(_tag, 'clearCart() removed all ${state.items.length} items');
    state = const CartState();
  }

  /// Force switch shops — clears cart and sets new shopId
  void switchShop(String newShopId) {
    AppLogger.i(_tag, 'switchShop() clearing cart and switching to $newShopId');
    state = CartState(items: const [], shopId: newShopId);
  }
}
