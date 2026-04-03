import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/data/models/order.dart';
import 'package:student_app/presentation/providers/order_provider.dart';
import 'package:student_app/core/theme/app_theme.dart';

/// A compact floating banner that shows the most recent active order's
/// status and ETA. Tapping it switches to the Queue tab.
///
/// Place this inside a Stack that wraps the main body content,
/// positioned just above the bottom navigation bar.
class ActiveOrderBanner extends ConsumerWidget {
  const ActiveOrderBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);
    final activeOrders = orderState.activeOrders
        .where((o) =>
            o.status != OrderStatus.collected)
        .toList();

    if (activeOrders.isEmpty) return const SizedBox.shrink();

    // Show the most recently placed order (first in list)
    final order = activeOrders.first;
    final orderCount = activeOrders.length;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      offset: Offset.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: GestureDetector(
          onTap: () => context.go('/queue'),
          child: Container(
            decoration: BoxDecoration(
              gradient: _bannerGradient(order.status),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _statusAccent(order.status).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Subtle shimmer overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        // Status emoji with pulsing ring
                        _StatusIcon(status: order.status),
                        const SizedBox(width: 10),

                        // Order info
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      order.status.label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (orderCount > 1) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '+${orderCount - 1} more',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.displaySummary,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // ETA chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${order.estimatedMinutes}m',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 6),

                        // Arrow
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().slideY(begin: 1.0, duration: 400.ms, curve: Curves.easeOutCubic).fadeIn(duration: 300.ms),
    );
  }

  LinearGradient _bannerGradient(OrderStatus status) {
    switch (status) {
      case OrderStatus.ready:
        return const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
        );
      case OrderStatus.preparing:
        return const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFE65100)],
        );
      case OrderStatus.pending:
        return const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  Color _statusAccent(OrderStatus status) {
    switch (status) {
      case OrderStatus.ready:
        return const Color(0xFF2ECC71);
      case OrderStatus.preparing:
        return const Color(0xFFFF6B35);
      case OrderStatus.pending:
        return const Color(0xFF3498DB);
      default:
        return AppColors.primary;
    }
  }
}

class _StatusIcon extends StatefulWidget {
  final OrderStatus status;
  const _StatusIcon({required this.status});

  @override
  State<_StatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<_StatusIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white
                  .withValues(alpha: 0.2 + (_controller.value * 0.2)),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              widget.status.emoji,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        );
      },
    );
  }
}
