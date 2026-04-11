import 'package:flutter/material.dart';
import 'package:student_app/data/models/shop.dart';
import 'package:student_app/core/theme/app_theme.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;

  const ShopCard({super.key, required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner image gradient overlay
              Stack(
                children: [
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _shopGradient(shop.name),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.store_rounded,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  // Open/Closed chip
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _OpenStatusChip(isOpen: shop.isCurrentlyOpen),
                  ),
                  // Rating pill
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            shop.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 13, color: theme.hintColor),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            shop.address,
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _QueueBadge(level: shop.queueLevel, emoji: shop.queueEmoji, count: shop.currentQueue),
                        const SizedBox(width: 10),
                        Icon(Icons.people_outline, size: 13, color: theme.hintColor),
                        const SizedBox(width: 4),
                        Text(
                          '${shop.seatingCapacity} seats',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                        ),
                        const Spacer(),
                        Text(
                          '${shop.openingTime} – ${shop.closingTime}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                            fontFeatures: const [],
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
      ),
    );
  }

  List<Color> _shopGradient(String name) {
    final colors = [
      [const Color(0xFFFF6B35), const Color(0xFFFF8C42)],
      [const Color(0xFF6C63FF), const Color(0xFF9C88FF)],
      [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      [const Color(0xFFFC5C7D), const Color(0xFF6A82FB)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    ];
    final idx = name.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[idx];
  }
}

class _OpenStatusChip extends StatelessWidget {
  final bool isOpen;
  const _OpenStatusChip({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green : Colors.red.shade600,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOpen ? Colors.green : Colors.red).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueBadge extends StatelessWidget {
  final String level;
  final String emoji;
  final int count;

  const _QueueBadge({required this.level, required this.emoji, required this.count});

  @override
  Widget build(BuildContext context) {
    Color bg;
    switch (level.toLowerCase()) {
      case 'high':
        bg = AppColors.error.withValues(alpha: 0.15);
        break;
      case 'medium':
        bg = Colors.orange.withValues(alpha: 0.15);
        break;
      default:
        bg = Colors.green.withValues(alpha: 0.15);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$emoji Queue: $count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: level.toLowerCase() == 'high'
              ? AppColors.error
              : level.toLowerCase() == 'medium'
                  ? Colors.orange
                  : Colors.green,
        ),
      ),
    );
  }
}
