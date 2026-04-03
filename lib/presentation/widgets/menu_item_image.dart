import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/core/utils/logger.dart';

/// Reusable widget for displaying a menu-item image with:
///   • Loading shimmer
///   • Placeholder when the URL is empty / null
///   • Error fallback when the network image fails to load
///
/// Accepts both full URLs (https://...) and relative backend paths (/uploads/...)
class MenuItemImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String itemName; // for logging context

  const MenuItemImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.itemName = '',
  });

  /// Resolve a potentially relative path to a full URL.
  /// Backend stores images as `/uploads/<filename>` — prepend the host.
  String get _resolvedUrl {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    // Relative path like /uploads/xyz.jpg
    return '${AppConstants.imageBaseUrl}$imageUrl';
  }

  bool get _hasValidUrl => _resolvedUrl.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;

    // If URL is blank, skip the network call entirely
    if (!_hasValidUrl) {
      AppLogger.d('MenuItemImage', 'No image URL for "$itemName" — showing placeholder');
      return ClipRRect(
        borderRadius: radius,
        child: _PlaceholderWidget(width: width, height: height),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: _resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _LoadingWidget(width: width, height: height),
        errorWidget: (context, url, error) {
          AppLogger.w('MenuItemImage',
              'Failed to load image for "$itemName" from $url — $error');
          return _PlaceholderWidget(width: width, height: height);
        },
      ),
    );
  }
}

// ── Placeholder (no image available) ──────────────────────────────────

class _PlaceholderWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const _PlaceholderWidget({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2A2A3E), const Color(0xFF1E1E2E)]
              : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            size: (height ?? 80) * 0.35,
            color: isDark ? const Color(0xFF6366F1) : AppColors.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            'No image',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading shimmer ───────────────────────────────────────────────────

class _LoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const _LoadingWidget({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      color: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF1F5F9),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}
