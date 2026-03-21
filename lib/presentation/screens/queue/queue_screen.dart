import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:student_app/data/models/order.dart';
import 'package:student_app/presentation/providers/order_provider.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/presentation/widgets/empty_state_widget.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final order = orderProvider.activeOrder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Queue'),
        actions: [
          if (orderProvider.hasActiveOrder)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: orderProvider.refreshQueue,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: orderProvider.refreshQueue,
        color: AppColors.primary,
        child: !orderProvider.hasActiveOrder
            ? ListView(
                children: [
                  EmptyStateWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Active Order',
                    subtitle: 'Place an order to track it here.',
                    actionLabel: 'Browse Menu',
                    onAction: () =>
                        DefaultTabController.of(context).animateTo(0),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Order ID header
                  _orderHeader(context, order!),
                  const SizedBox(height: 24),
                  // Status stepper
                  _statusStepper(context, order),
                  const SizedBox(height: 24),
                  // ETA + Queue position cards
                  _infoCards(context, order),
                  const SizedBox(height: 24),
                  // Items summary
                  _itemsSummary(context, order),

                  if (order.status == OrderStatus.ready) ...[
                    const SizedBox(height: 24),
                    _readyBanner(context, orderProvider),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _orderHeader(BuildContext context, Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Text('🧾', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ${order.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                '${order.status.emoji} ${order.status.label}',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _statusStepper(BuildContext context, Order order) {
    final statuses = [
      OrderStatus.placed,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
    ];
    final currentStep = statuses.indexOf(order.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Status',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...List.generate(statuses.length, (i) {
            final isCompleted = i <= currentStep;
            final isCurrent = i == currentStep;
            final isLast = i == statuses.length - 1;
            return _stepItem(
                context, statuses[i], isCompleted, isCurrent, isLast, i);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2);
  }

  Widget _stepItem(BuildContext context, OrderStatus status, bool isCompleted,
      bool isCurrent, bool isLast, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [
                        const BoxShadow(
                          color: Color(0x50FF6B35),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: isCompleted
                    ? Text(status.emoji, style: const TextStyle(fontSize: 14))
                    : Text('${index + 1}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600)),
              ),
            ),
            if (!isLast)
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 2,
                height: 32,
                color:
                    isCompleted ? AppColors.primary : const Color(0xFFE5E7EB),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.label,
                style: TextStyle(
                  fontWeight:
                      isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCompleted
                      ? AppColors.primary
                      : const Color(0xFFADB5BD),
                  fontSize: 14,
                ),
              ),
              if (!isLast) const SizedBox(height: 20),
            ],
          ),
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
        const SizedBox(width: 12),
        Expanded(
          child: _infoCard(
            context,
            icon: '🔢',
            label: 'Queue Position',
            value: '#${order.queuePosition}',
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _infoCard(BuildContext context,
      {required String icon, required String label, required String value}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: AppColors.primary, fontSize: 22)),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _itemsSummary(BuildContext context, Order order) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Items', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            order.displaySummary,
            style: theme.textTheme.bodyLarge,
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: theme.textTheme.titleMedium),
              Text(
                '₹${order.totalAmount.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _readyBanner(BuildContext context, OrderProvider orderProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          const Text(
            'Your order is ready!',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.success),
          ),
          const SizedBox(height: 4),
          const Text('Please collect at Counter 2',
              style: TextStyle(fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: orderProvider.completeOrder,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success),
            child: const Text('Mark as Collected ✓'),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
  }
}
