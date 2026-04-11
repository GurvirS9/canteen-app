import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/presentation/providers/menu_provider.dart';
import 'package:student_app/presentation/providers/auth_provider.dart';
import 'package:student_app/presentation/providers/cart_provider.dart';
import 'package:student_app/presentation/providers/shop_provider.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/presentation/widgets/menu_item_card.dart';
import 'package:student_app/presentation/widgets/shimmer_loader.dart';
import 'package:student_app/presentation/widgets/empty_state_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shopState = ref.read(shopProvider);
      if (shopState.selectedShop == null) {
        context.go('/shops');
        return;
      }
      ref.read(menuProvider.notifier).fetchMenu();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuProvider);
    final menuNotifier = ref.read(menuProvider.notifier);
    
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;
    
    final shopState = ref.watch(shopProvider);
    final selectedShop = shopState.selectedShop;
    
    final cartNotifier = ref.watch(cartProvider.notifier);
    // Observe cart to update totals
    ref.watch(cartProvider);
    
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: cartNotifier.itemCount == 0
          ? const SizedBox.shrink()
          : FloatingActionButton.extended(
              onPressed: () => context.push('/cart'),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              label: Text(
                '${cartNotifier.itemCount} items • ₹${cartNotifier.total.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
      body: RefreshIndicator(
        onRefresh: () async => menuNotifier.refresh(),
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 168,
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
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
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
                                  if (selectedShop != null)
                                    GestureDetector(
                                      onTap: () => context.go('/shops'),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.store_rounded,
                                              color: Colors.white70, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            selectedShop.name,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              decoration: TextDecoration.underline,
                                              decorationColor: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.swap_horiz_rounded,
                                              color: Colors.white54, size: 12),
                                        ],
                                      ),
                                    )
                                  else
                                    const Text(
                                      'What are you craving today?',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              CircleAvatar(
                                radius: 22,
                                backgroundImage: user?.avatarUrl != null && user!.avatarUrl.isNotEmpty
                                    ? NetworkImage(user.avatarUrl)
                                    : null,
                                backgroundColor: Colors.white,
                                child: user?.avatarUrl == null || user!.avatarUrl.isEmpty
                                    ? const Icon(Icons.person,
                                        color: AppColors.primary)
                                    : null,
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: menuNotifier.search,
                              decoration: InputDecoration(
                                hintText: 'Search dishes, categories...',
                                prefixIcon: const Icon(Icons.search_rounded,
                                    color: AppColors.primary),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded),
                                        onPressed: () {
                                          _searchController.clear();
                                          menuNotifier.search('');
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                filled: false,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.chipTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: menuState.selectedCategory,
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                          ),
                          isDense: true,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          dropdownColor: theme.cardTheme.color,
                          onChanged: (val) {
                            if (val != null) menuNotifier.selectCategory(val);
                          },
                          items: AppConstants.categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.chipTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<DietaryFilter>(
                          value: menuState.dietaryFilter,
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                          ),
                          isDense: true,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          dropdownColor: theme.cardTheme.color,
                          onChanged: (val) {
                            if (val != null) menuNotifier.setDietaryFilter(val);
                          },
                          items: const [
                            DropdownMenuItem(value: DietaryFilter.all, child: Text('All Diets')),
                            DropdownMenuItem(value: DietaryFilter.veg, child: Text('Veg')),
                            DropdownMenuItem(value: DietaryFilter.egg, child: Text('Egg')),
                            DropdownMenuItem(value: DietaryFilter.nonVeg, child: Text('Non-Veg')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        menuState.selectedCategory == AppConstants.categories.first
                            ? 'All Items'
                            : menuState.selectedCategory,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: theme.chipTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<SortOption>(
                          value: menuState.selectedSort,
                          icon: const Icon(Icons.sort_rounded, size: 16),
                          isDense: true,
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          dropdownColor: theme.cardTheme.color,
                          onChanged: (val) {
                            if (val != null) menuNotifier.setSortOption(val);
                          },
                          items: const [
                            DropdownMenuItem(value: SortOption.bestsellers, child: Text('Top')),
                            DropdownMenuItem(value: SortOption.priceLowToHigh, child: Text('Low-Hi')),
                            DropdownMenuItem(value: SortOption.priceHighToLow, child: Text('Hi-Low')),
                            DropdownMenuItem(value: SortOption.alphabetical, child: Text('A - Z')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!menuState.isLoading)
                      Text(
                        '${menuState.items.length} items',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),

            // Menu items — split into image grid + text-only list
            if (menuState.isLoading)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverToBoxAdapter(child: ShimmerLoader()),
              )
            else if (menuState.error != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    icon: Icons.wifi_off_rounded,
                    title: 'Oops!',
                    subtitle: menuState.error!,
                    actionLabel: 'Retry',
                    onAction: menuNotifier.fetchMenu,
                  ),
                ),
              )
            else if (menuState.items.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                sliver: SliverToBoxAdapter(
                  child: EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No items found',
                    subtitle: 'Try a different search or category.',
                    actionLabel: 'Clear Search',
                    onAction: () {
                      _searchController.clear();
                      menuNotifier.search('');
                      menuNotifier.selectCategory(AppConstants.categories.first);
                    },
                  ),
                ),
              )
            else ...[
              // Items WITH images → 2-column grid
              if (menuState.items.any((i) => i.imageUrl.isNotEmpty))
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final imageItems = menuState.items
                            .where((item) => item.imageUrl.isNotEmpty)
                            .toList();
                        return MenuItemCard(item: imageItems[i]);
                      },
                      childCount: menuState.items
                          .where((i) => i.imageUrl.isNotEmpty)
                          .length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                  ),
                ),

              // Items WITHOUT images → compact horizontal list
              if (menuState.items.any((i) => i.imageUrl.isEmpty))
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final textItems = menuState.items
                            .where((item) => item.imageUrl.isEmpty)
                            .toList();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: MenuItemCard(item: textItems[i]),
                        );
                      },
                      childCount: menuState.items
                          .where((i) => i.imageUrl.isEmpty)
                          .length,
                    ),
                  ),
                )
              else
                // Bottom padding when there are no text-only items
                const SliverPadding(
                  padding: EdgeInsets.only(bottom: 100),
                  sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
