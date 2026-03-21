import 'package:flutter/material.dart';
import 'package:student_app/core/theme/app_theme.dart';

class QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool compact;

  const QuantityControl({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 28.0 : 32.0;
    return Container(
      height: compact ? 32 : 36,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove_rounded, onDecrement, size),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: TextStyle(
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          _btn(Icons.add_rounded, onIncrement, size),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap, double size) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}
