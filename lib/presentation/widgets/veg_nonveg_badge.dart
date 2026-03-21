import 'package:flutter/material.dart';
import 'package:student_app/core/theme/app_theme.dart';

class VegNonVegBadge extends StatelessWidget {
  final bool isVeg;
  final double size;

  const VegNonVegBadge({super.key, required this.isVeg, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isVeg ? AppColors.veg : AppColors.nonVeg,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.45,
          height: size * 0.45,
          decoration: BoxDecoration(
            color: isVeg ? AppColors.veg : AppColors.nonVeg,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
