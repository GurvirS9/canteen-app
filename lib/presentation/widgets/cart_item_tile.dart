import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/data/models/cart_item.dart';
import 'package:student_app/presentation/providers/cart_provider.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'menu_item_image.dart';
import 'veg_nonveg_badge.dart';
import 'quantity_control.dart';

class CartItemTile extends ConsumerWidget {
  final CartItem cartItem;

  const CartItemTile({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Dismissible(
      key: Key(cartItem.menuItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Remove',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      onDismissed: (_) => cartNotifier.removeItemCompletely(cartItem.menuItem.id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.light
                  ? const Color(0x08000000)
                  : const Color(0x30000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image with placeholder fallback
            SizedBox(
              width: 72,
              height: 72,
              child: MenuItemImage(
                imageUrl: cartItem.menuItem.imageUrl,
                itemName: cartItem.menuItem.name,
                width: 72,
                height: 72,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      VegNonVegBadge(isVeg: cartItem.menuItem.isVeg, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cartItem.menuItem.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${cartItem.menuItem.price.toStringAsFixed(0)} each',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      QuantityControl(
                        quantity: cartItem.quantity,
                        compact: true,
                        onIncrement: () => cartNotifier.addItem(cartItem.menuItem),
                        onDecrement: () => cartNotifier.removeItem(cartItem.menuItem),
                      ),
                      const Spacer(),
                      Text(
                        '₹${cartItem.total.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
