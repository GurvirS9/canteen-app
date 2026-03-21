import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/order.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_theme.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as Order?;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Success animation
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) => Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.05),
                  child: child,
                ),
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 60)),
                  ),
                ),
              ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 32),

              Text(
                'Order Placed!',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 30),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
              const SizedBox(height: 8),
              Text(
                'Your food is on its way to the kitchen 🍳',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 32),

              // Order details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _detailRow(context, '🧾 Order ID', order?.id ?? '-'),
                    const Divider(height: 20),
                    _detailRow(context, '⏱️ Est. Time',
                        '${order?.estimatedMinutes ?? 12} minutes'),
                    const Divider(height: 20),
                    _detailRow(context, '🔢 Queue',
                        '#${order?.queuePosition ?? 5}'),
                    const Divider(height: 20),
                    _detailRow(context, '💳 Total',
                        '₹${order?.totalAmount.toStringAsFixed(2) ?? '0.00'}',
                        valueColor: AppColors.primary),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

              const Spacer(),

              // CTA buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppConstants.homeRoute),
                      icon: const Icon(Icons.queue_rounded),
                      label: const Text('Track Order'),
                    ),
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppConstants.homeRoute),
                      icon: const Icon(Icons.restaurant_menu_rounded),
                      label: const Text('Back to Menu'),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value,
      {Color? valueColor}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13)),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
