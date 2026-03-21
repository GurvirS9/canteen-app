import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final bool isGrid;
  final int itemCount;

  const ShimmerLoader({super.key, this.isGrid = true, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE5E7EB);
    final highlightColor =
        isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF9FAFB);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: isGrid
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: itemCount,
              itemBuilder: (_, __) => _shimmerCard(),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => _shimmerListTile(),
            ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(double.infinity, 12),
                  const SizedBox(height: 6),
                  _block(140, 10),
                  const Spacer(),
                  _block(80, 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerListTile() {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _block(double.infinity, 12),
                const SizedBox(height: 6),
                _block(120, 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _block(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
