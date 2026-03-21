import 'package:flutter/material.dart';
import 'package:student_app/data/models/cart_item.dart';
import 'package:student_app/data/models/menu_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal => _items.fold(0.0, (sum, e) => sum + e.total);

  double get tax => subtotal * 0.05;

  double get total => subtotal + tax;

  bool get isEmpty => _items.isEmpty;

  int quantityOf(String menuItemId) {
    try {
      return _items.firstWhere((e) => e.menuItem.id == menuItemId).quantity;
    } catch (_) {
      return 0;
    }
  }

  void addItem(MenuItem menuItem) {
    final idx = _items.indexWhere((e) => e.menuItem.id == menuItem.id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
    } else {
      _items.add(CartItem(menuItem: menuItem));
    }
    notifyListeners();
  }

  void removeItem(MenuItem menuItem) {
    final idx = _items.indexWhere((e) => e.menuItem.id == menuItem.id);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity - 1);
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void removeItemCompletely(String menuItemId) {
    _items.removeWhere((e) => e.menuItem.id == menuItemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
