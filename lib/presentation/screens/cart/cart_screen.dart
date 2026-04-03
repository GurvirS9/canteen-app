import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/data/models/time_slot.dart';
import 'package:student_app/presentation/providers/cart_provider.dart';
import 'package:student_app/presentation/providers/order_provider.dart';
import 'package:student_app/presentation/providers/notification_provider.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/presentation/widgets/cart_item_tile.dart';
import 'package:student_app/presentation/widgets/empty_state_widget.dart';

class CartScreen extends ConsumerWidget {
  final bool showBackButton;
  const CartScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.watch(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        title: const Text('My Cart'),
        actions: [
          if (cartNotifier.itemCount > 0)
            TextButton.icon(
              onPressed: () => _clearCart(context, ref),
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
            ),
        ],
      ),
      body: cartNotifier.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add some delicious items from the menu!',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    itemCount: cartState.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) => CartItemTile(
                      cartItem: cartState[i],
                    ).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.1),
                  ),
                ),
                const _PriceSummaryPanel(),
              ],
            ),
    );
  }

  void _clearCart(BuildContext context, WidgetRef ref) {
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
              ref.read(cartProvider.notifier).clearCart();
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

class _PriceSummaryPanel extends ConsumerStatefulWidget {
  const _PriceSummaryPanel();

  @override
  ConsumerState<_PriceSummaryPanel> createState() => _PriceSummaryPanelState();
}

class _PriceSummaryPanelState extends ConsumerState<_PriceSummaryPanel> {
  bool _isFetchingSlots = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartNotifier = ref.watch(cartProvider.notifier);
    // Since Subtotal/Tax/Total change when cart contents change, we need to observe the cartState
    ref.watch(cartProvider);
    final isPlacingOrder = ref.watch(orderProvider).isPlacingOrder;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _priceRow(context, 'Subtotal', '₹${cartNotifier.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 6),
          _priceRow(context, 'GST (5%)', '₹${cartNotifier.tax.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          _priceRow(context, 'Total Amount', '₹${cartNotifier.total.toStringAsFixed(2)}',
              isBold: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (isPlacingOrder || _isFetchingSlots) ? null : () => _showSlotSelection(),
              icon: (isPlacingOrder || _isFetchingSlots)
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.restaurant_rounded, size: 20),
              label: Text(isPlacingOrder
                  ? 'Placing Order...'
                  : _isFetchingSlots
                      ? 'Loading Slots...'
                      : 'Place Order • ₹${cartNotifier.total.toStringAsFixed(2)}'),
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

  Future<void> _showSlotSelection() async {
    setState(() {
      _isFetchingSlots = true;
    });

    final orderNotifier = ref.read(orderProvider.notifier);
    final slots = await orderNotifier.getAvailableSlots();
    
    if (!mounted) return;
    setState(() {
      _isFetchingSlots = false;
    });

    if (slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No time slots available at the moment.')),
      );
      return;
    }

    final TimeSlot? selectedSlot = await showModalBottomSheet<TimeSlot>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SlotSelectionSheet(slots: slots),
    );

    if (selectedSlot != null && mounted) {
      _placeOrder(selectedSlot);
    }
  }

  Future<void> _placeOrder(TimeSlot selectedSlot) async {
    final cartItems = ref.read(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final orderNotifier = ref.read(orderProvider.notifier);
    final notifNotifier = ref.read(notificationProvider.notifier);

    final items = List.of(cartItems);
    final order = await orderNotifier.placeOrder(items, selectedSlot: selectedSlot);
    if (!mounted) return;

    if (order != null) {
      notifNotifier.onOrderPlaced(order.id);
      cartNotifier.clearCart();
      context.push('/order-success', extra: order);
    } else {
      final errorMsg = ref.read(orderProvider).error ?? 'Order failed. Try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SlotSelectionSheet extends StatefulWidget {
  final List<TimeSlot> slots;
  const _SlotSelectionSheet({required this.slots});

  @override
  State<_SlotSelectionSheet> createState() => _SlotSelectionSheetState();
}

class _SlotSelectionSheetState extends State<_SlotSelectionSheet> {
  TimeSlot? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Select Pickup Time', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.slots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final slot = widget.slots[i];
                final isSelected = _selectedSlot == slot;
                return ListTile(
                  title: Text(slot.label, style: theme.textTheme.titleMedium),
                  subtitle: Text(
                    slot.occupancy.label,
                    style: TextStyle(
                      color: slot.occupancy.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  tileColor: slot.isAvailable ? theme.cardTheme.color : theme.disabledColor.withValues(alpha: 0.05),
                  enabled: slot.isAvailable,
                  onTap: () {
                    if (slot.isAvailable) {
                      setState(() => _selectedSlot = slot);
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSlot == null
                    ? null
                    : () => Navigator.pop(context, _selectedSlot),
                child: const Text('Confirm Time & Place Order'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
