import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/data/models/order.dart';
import 'package:student_app/presentation/providers/order_provider.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/presentation/widgets/empty_state_widget.dart';
import 'package:go_router/go_router.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);
    final orderNotifier = ref.read(orderProvider.notifier);
    final activeOrders = orderState.activeOrders
        .where((o) => o.status != OrderStatus.collected)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          activeOrders.length > 1
              ? 'Order Queue (${activeOrders.length})'
              : 'Order Queue',
        ),
        actions: [
          if (activeOrders.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: orderNotifier.refreshQueue,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: orderNotifier.refreshQueue,
        color: AppColors.primary,
        child: activeOrders.isEmpty
            ? ListView(
                children: [
                  EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Active Orders',
                    subtitle: 'Place an order to track it here.',
                    actionLabel: 'Browse Menu',
                    onAction: () => context.go('/home'),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: activeOrders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final order = activeOrders[index];
                  return _OrderCard(
                    order: order,
                    index: index,
                  );
                },
              ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final Order order;
  final int index;

  const _OrderCard({
    required this.order,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _orderHeader(context, order),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              children: [
                _statusStepper(context, order),
                const SizedBox(height: 16),
                _infoCards(context, order),
                const SizedBox(height: 16),
                _itemsSummary(context, order),
                if (order.status == OrderStatus.ready) ...[
                  const SizedBox(height: 16),
                  _readyBanner(context, ref, order),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.15);
  }

  Widget _orderHeader(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          const Text('🧾', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.shortId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.status.emoji} ${order.status.label}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusStepper(BuildContext context, Order order) {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.collected,
    ];
    final currentStep = statuses.indexOf(order.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const double dotSize = 28;
            final double totalWidth = constraints.maxWidth;
            final double inset = 16.0; // Inset to leave room for text
            final double trackWidth = totalWidth - (inset * 2);
            final double spacing = (trackWidth - dotSize) / (statuses.length - 1);

            return Column(
              children: [
                SizedBox(
                  height: dotSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (int i = 0; i < statuses.length - 1; i++)
                        Positioned(
                          left: inset + (i * spacing) + dotSize,
                          top: dotSize / 2 - 1,
                          width: spacing - dotSize,
                          height: 2,
                          child: Container(
                            color: i < currentStep
                                ? AppColors.primary
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                      for (int i = 0; i < statuses.length; i++)
                        Positioned(
                          left: inset + (i * spacing),
                          top: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                              color: i <= currentStep
                                  ? AppColors.primary
                                  : const Color(0xFFE5E7EB),
                              shape: BoxShape.circle,
                              boxShadow: i == currentStep
                                  ? [
                                      const BoxShadow(
                                        color: Color(0x50FF6B35),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: i <= currentStep
                                  ? Text(statuses[i].emoji,
                                      style: const TextStyle(fontSize: 12))
                                  : Text('${i + 1}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 24,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (int i = 0; i < statuses.length; i++)
                        Positioned(
                          left: inset + (i * spacing) + (dotSize / 2) - 30,
                          top: 0,
                          width: 60,
                          child: Text(
                            statuses[i].label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: i == currentStep
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: i <= currentStep
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _infoCards(BuildContext context, Order order) {
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            context,
            icon: '⏱️',
            label: 'Est. Time',
            value: '${order.estimatedMinutes} min',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoCard(
            context,
            icon: '🔢',
            label: 'Queue',
            value: '#${order.queuePosition}',
          ),
        ),
      ],
    );
  }

  Widget _infoCard(BuildContext context,
      {required String icon, required String label, required String value}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: AppColors.primary, fontSize: 18)),
          Text(label,
              style:
                  theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _itemsSummary(BuildContext context, Order order) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              order.displaySummary,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${order.totalAmount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _readyBanner(BuildContext context, WidgetRef ref, Order order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 30)),
          const SizedBox(height: 6),
          const Text(
            'Your order is ready!',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.success),
          ),
          const SizedBox(height: 4),
          Text('Please collect at ${AppConstants.canteenName}',
              style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ref.read(orderProvider.notifier).completeOrder(order.id),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success),
              child: const Text('Mark as Collected ✓'),
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
  }
}
