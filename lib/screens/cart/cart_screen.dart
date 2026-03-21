import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_theme.dart';
import '../../widgets/cart_item_tile.dart';
import '../../widgets/empty_state_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          if (cart.itemCount > 0)
            TextButton.icon(
              onPressed: () => _clearCart(context),
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
            ),
        ],
      ),
      body: cart.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add some delicious items from the menu!',
            )
          : Column(
              children: [
                // Item list
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => CartItemTile(
                      cartItem: cart.items[i],
                    ).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.1),
                  ),
                ),
                // Price summary + CTA
                _PriceSummaryPanel(cart: cart),
              ],
            ),
    );
  }

  void _clearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cart?'),
        content: const Text('All items will be removed from your cart.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _PriceSummaryPanel extends StatelessWidget {
  final CartProvider cart;

  const _PriceSummaryPanel({required this.cart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Price Details', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _priceRow(context, 'Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _priceRow(context, 'GST (5%)', '₹${cart.tax.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          _priceRow(context, 'Total Amount', '₹${cart.total.toStringAsFixed(2)}',
              isBold: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _placeOrder(context),
              icon: const Icon(Icons.restaurant_rounded, size: 20),
              label: Text(
                  'Place Order • ₹${cart.total.toStringAsFixed(2)}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(BuildContext context, String label, String value,
      {bool isBold = false}) {
    return Row(
      children: [
        Text(
          label,
          style: isBold
              ? Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)
              : Theme.of(context).textTheme.bodyLarge,
        ),
        const Spacer(),
        Text(
          value,
          style: isBold
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 17,
                  )
              : Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();
    final notifProvider = context.read<NotificationProvider>();

    final items = List.of(cart.items);
    final order = await orderProvider.placeOrder(items);
    if (!context.mounted) return;

    if (order != null) {
      notifProvider.onOrderPlaced(order.id);
      cart.clearCart();
      Navigator.of(context).pushNamed(AppConstants.orderSuccessRoute,
          arguments: order);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Order failed. Try again.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
