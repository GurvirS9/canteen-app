import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/data/models/menu_item.dart';
import 'package:student_app/presentation/providers/cart_provider.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'menu_item_image.dart';
import 'veg_nonveg_badge.dart';
import 'quantity_control.dart';

class MenuItemCard extends ConsumerWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const MenuItemCard({super.key, required this.item, this.onTap});

  bool get _hasImage => item.imageUrl.isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_hasImage) {
      return _ImageCard(item: item, onTap: onTap);
    } else {
      return _CompactCard(item: item, onTap: onTap);
    }
  }
}

// ── Image Card (original vertical grid layout) ─────────────────────────────

class _ImageCard extends ConsumerWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const _ImageCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartNotifier = ref.watch(cartProvider.notifier);
    ref.watch(cartProvider);
    final qty = cartNotifier.quantityOf(item.id);

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
            // Image with placeholder fallback
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: MenuItemImage(
                    imageUrl: item.imageUrl,
                    itemName: item.name,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
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
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
                                  ? () => cartNotifier.addItem(item)
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
                                cartNotifier.addItem(item),
                            onDecrement: () =>
                                cartNotifier.removeItem(item),
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

// ── Compact Card (horizontal row for text-only items) ───────────────────────

class _CompactCard extends ConsumerWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const _CompactCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cartNotifier = ref.watch(cartProvider.notifier);
    ref.watch(cartProvider);
    final qty = cartNotifier.quantityOf(item.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? const Color(0x30000000) : const Color(0x08000000),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Veg/Non-veg badge
            VegNonVegBadge(isVeg: item.isVeg),
            const SizedBox(width: 12),

            // Name + description + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 10, color: Colors.white),
                            const SizedBox(width: 2),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.schedule_rounded,
                          size: 12,
                          color: isDark ? Colors.white38 : Colors.grey.shade400),
                      const SizedBox(width: 2),
                      Text(
                        '${item.preparationTime} min',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Unavailable label or cart controls
            if (!item.isAvailable)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Unavailable',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
            else if (qty == 0)
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () => cartNotifier.addItem(item),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    minimumSize: const Size(0, 34),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('ADD'),
                ),
              )
            else
              QuantityControl(
                quantity: qty,
                onIncrement: () => cartNotifier.addItem(item),
                onDecrement: () => cartNotifier.removeItem(item),
              ),
          ],
        ),
      ),
    );
  }
}
