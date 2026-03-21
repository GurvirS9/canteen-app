import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_app/data/models/menu_item.dart';
import 'package:student_app/presentation/providers/cart_provider.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'veg_nonveg_badge.dart';
import 'quantity_control.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const MenuItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = context.watch<CartProvider>();
    final qty = cart.quantityOf(item.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.light
                  ? const Color(0x0C000000)
                  : const Color(0x40000000),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(Icons.fastfood_rounded,
                              size: 40, color: Color(0xFFCBD5E1)),
                        ),
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: const Color(0xFFF1F5F9),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Veg badge top-left
                Positioned(
                  top: 8,
                  left: 8,
                  child: VegNonVegBadge(isVeg: item.isVeg),
                ),
                // Unavailable overlay
                if (!item.isAvailable)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Text('Unavailable',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 2),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Prep time
                      Text(
                        '${item.preparationTime} min',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontSize: 11),
                      ),
                      const Spacer(),
                      // Price
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Cart control
                  Center(
                    child: qty == 0
                        ? SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: item.isAvailable
                                  ? () => context
                                      .read<CartProvider>()
                                      .addItem(item)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                minimumSize: const Size(0, 34),
                                textStyle: const TextStyle(fontSize: 13),
                              ),
                              child: const Text('ADD'),
                            ),
                          )
                        : QuantityControl(
                            quantity: qty,
                            onIncrement: () =>
                                context.read<CartProvider>().addItem(item),
                            onDecrement: () =>
                                context.read<CartProvider>().removeItem(item),
                          ),
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
