import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/data/models/cart_item.dart';
import 'package:student_app/data/models/menu_item.dart';
import 'package:student_app/core/utils/logger.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  static const String _tag = 'CartNotifier';

  CartNotifier() : super([]);

  int get itemCount => state.fold(0, (sum, e) => sum + e.quantity);
  double get subtotal => state.fold(0.0, (sum, e) => sum + e.total);
  double get tax => subtotal * 0.05;
  double get total => subtotal + tax;
  bool get isEmpty => state.isEmpty;

  int quantityOf(String menuItemId) {
    try {
      return state.firstWhere((e) => e.menuItem.id == menuItemId).quantity;
    } catch (_) {
      return 0;
    }
  }

  void addItem(MenuItem menuItem) {
    final idx = state.indexWhere((e) => e.menuItem.id == menuItem.id);
    final newState = List<CartItem>.from(state);
    
    if (idx >= 0) {
      newState[idx] = newState[idx].copyWith(quantity: newState[idx].quantity + 1);
      AppLogger.d(_tag, 'addItem() incremented "${menuItem.name}" qty=${newState[idx].quantity}');
    } else {
      newState.add(CartItem(menuItem: menuItem));
      AppLogger.i(_tag, 'addItem() added "${menuItem.name}" to cart');
    }
    
    state = newState;
    AppLogger.d(_tag, 'Cart state: ${state.length} unique items, $itemCount total qty, subtotal=₹${subtotal.toStringAsFixed(2)}');
  }

  void removeItem(MenuItem menuItem) {
    final idx = state.indexWhere((e) => e.menuItem.id == menuItem.id);
    if (idx >= 0) {
      final newState = List<CartItem>.from(state);
      if (newState[idx].quantity > 1) {
        newState[idx] = newState[idx].copyWith(quantity: newState[idx].quantity - 1);
        AppLogger.d(_tag, 'removeItem() decremented "${menuItem.name}" qty=${newState[idx].quantity}');
      } else {
        newState.removeAt(idx);
        AppLogger.i(_tag, 'removeItem() removed "${menuItem.name}" from cart');
      }
      state = newState;
      AppLogger.d(_tag, 'Cart state: ${state.length} unique items, $itemCount total qty, subtotal=₹${subtotal.toStringAsFixed(2)}');
    } else {
      AppLogger.w(_tag, 'removeItem() "${menuItem.name}" not found in cart');
    }
  }

  void removeItemCompletely(String menuItemId) {
    final newState = state.where((e) => e.menuItem.id != menuItemId).toList();
    if (newState.length != state.length) {
      AppLogger.i(_tag, 'removeItemCompletely() removed item from cart');
      state = newState;
    }
  }

  void clearCart() {
    AppLogger.i(_tag, 'clearCart() removed all ${state.length} items');
    state = [];
  }
}
