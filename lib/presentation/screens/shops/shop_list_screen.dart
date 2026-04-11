import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/data/models/shop.dart';
import 'package:student_app/presentation/providers/shop_provider.dart';
import 'package:student_app/presentation/providers/cart_provider.dart';
import 'package:student_app/presentation/providers/auth_provider.dart';
import 'package:student_app/presentation/widgets/shop_card.dart';
import 'package:student_app/presentation/widgets/shimmer_loader.dart';

class ShopListScreen extends ConsumerStatefulWidget {
  const ShopListScreen({super.key});

  @override
  ConsumerState<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends ConsumerState<ShopListScreen> {
  _SortMode _sortMode = _SortMode.none;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shopProvider.notifier).fetchShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    final theme = Theme.of(context);

    List<Shop> shops = List.from(shopState.shops);
    if (_sortMode == _SortMode.rating) {
      shops.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortMode == _SortMode.queue) {
      shops.sort((a, b) => a.currentQueue.compareTo(b.currentQueue));
    }

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(shopProvider.notifier).fetchShops(),
        child: CustomScrollView(
          slivers: [
            // Hero gradient header
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${user?.name.split(' ').first ?? 'Student'} 👋',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded,
                                          color: Colors.white70, size: 14),
                                      const SizedBox(width: 3),
                                      const Text(
                                        'Campus, India',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: user?.avatarUrl != null &&
                                        user!.avatarUrl.isNotEmpty
                                    ? NetworkImage(user.avatarUrl)
                                    : null,
                                backgroundColor: Colors.white,
                                child: user?.avatarUrl == null ||
                                        user!.avatarUrl.isEmpty
                                    ? const Icon(Icons.person,
                                        color: AppColors.primary)
                                    : null,
                              ),
                            ],
                          ),
                          // Promo banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Text('🎉', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Fresh meals from multiple canteens!',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Sort chips row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Choose a Canteen',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    _SortChip(
                      label: 'Rating',
                      icon: Icons.star_rounded,
                      active: _sortMode == _SortMode.rating,
                      onTap: () => setState(() {
                        _sortMode = _sortMode == _SortMode.rating
                            ? _SortMode.none
                            : _SortMode.rating;
                      }),
                    ),
                    const SizedBox(width: 8),
                    _SortChip(
                      label: 'Queue',
                      icon: Icons.people_outline,
                      active: _sortMode == _SortMode.queue,
                      onTap: () => setState(() {
                        _sortMode = _sortMode == _SortMode.queue
                            ? _SortMode.none
                            : _SortMode.queue;
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            if (shopState.isLoading)
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(child: ShimmerLoader()),
              )
            else if (shopState.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('Failed to load shops',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(shopProvider.notifier).fetchShops(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (shops.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text('No canteens available',
                          style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => ShopCard(
                    shop: shops[i],
                    onTap: () => _selectShop(shops[i]),
                  ),
                  childCount: shops.length,
                ),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  void _selectShop(Shop shop) {
    final cart = ref.read(cartProvider);
    // Check if cart belongs to a different shop
    if (cart.shopId != null && cart.shopId != shop.id && cart.items.isNotEmpty) {
      _showSwitchShopDialog(shop);
      return;
    }
    _commitSelectShop(shop);
  }

  void _showSwitchShopDialog(Shop newShop) {
    final currentShopState = ref.read(shopProvider);
    final currentShopName =
        currentShopState.selectedShop?.name ?? 'current shop';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Switch Canteen?'),
        content: Text(
          'Your cart has items from "$currentShopName". Switching to "${newShop.name}" will clear your cart.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Cart')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(cartProvider.notifier).switchShop(newShop.id);
              _commitSelectShop(newShop);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
  }

  void _commitSelectShop(Shop shop) {
    ref.read(shopProvider.notifier).selectShop(shop);
    context.go('/home');
  }
}

enum _SortMode { none, rating, queue }

class _SortChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.15)
              : Theme.of(context).chipTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 14,
                color: active ? AppColors.primary : Theme.of(context).hintColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color:
                    active ? AppColors.primary : Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
