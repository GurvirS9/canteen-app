import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_app/presentation/providers/menu_provider.dart';
import 'package:student_app/presentation/providers/auth_provider.dart';
import 'package:student_app/presentation/providers/cart_provider.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/theme/app_theme.dart';
import 'package:student_app/presentation/widgets/menu_item_card.dart';
import 'package:student_app/presentation/widgets/shimmer_loader.dart';
import 'package:student_app/presentation/widgets/empty_state_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().fetchMenu();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menu = context.watch<MenuProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: Consumer<CartProvider>(
        builder: (ctx, cart, child) {
          if (cart.itemCount == 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, AppConstants.cartRoute),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            label: Text(
              '${cart.itemCount} items • ₹${cart.total.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: menu.refresh,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // App bar with greeting + search (search embedded in gradient)
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
                          // Greeting row
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${auth.user?.name.split(' ').first ?? 'Student'} 👋',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
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
                                backgroundImage: auth.user?.avatarUrl != null
                                    ? NetworkImage(auth.user!.avatarUrl)
                                    : null,
                                backgroundColor: Colors.white,
                                child: auth.user?.avatarUrl == null
                                    ? const Icon(Icons.person,
                                        color: AppColors.primary)
                                    : null,
                              ),
                            ],
                          ),
                          // Search bar — sits inside the gradient, no gap
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
                              onChanged: context.read<MenuProvider>().search,
                              decoration: InputDecoration(
                                hintText: 'Search dishes, categories...',
                                prefixIcon: const Icon(Icons.search_rounded,
                                    color: AppColors.primary),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded),
                                        onPressed: () {
                                          _searchController.clear();
                                          context
                                              .read<MenuProvider>()
                                              .search('');
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

            // Top Controls Row: Category and Diet Preference
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    // Category Dropdown
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
                          value: menu.selectedCategory,
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                          ),
                          isDense: true,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          dropdownColor: theme.cardTheme.color,
                          onChanged: (val) {
                            if (val != null) context.read<MenuProvider>().selectCategory(val);
                          },
                          items: AppConstants.categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Diet Filter Dropdown
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
                          value: menu.dietaryFilter,
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                          ),
                          isDense: true,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          dropdownColor: theme.cardTheme.color,
                          onChanged: (val) {
                            if (val != null) context.read<MenuProvider>().setDietaryFilter(val);
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

            // Section title, Sort Dropdown and Counter
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        menu.selectedCategory == AppConstants.categories.first
                            ? 'All Items'
                            : menu.selectedCategory,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sorting dropdown
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: theme.chipTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<SortOption>(
                          value: menu.selectedSort,
                          icon: const Icon(Icons.sort_rounded, size: 16),
                          isDense: true,
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          dropdownColor: theme.cardTheme.color,
                          onChanged: (val) {
                            if (val != null) context.read<MenuProvider>().setSortOption(val);
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
                    if (!menu.isLoading)
                      Text(
                        '${menu.items.length} items',
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              sliver: menu.isLoading
                  ? const SliverToBoxAdapter(child: ShimmerLoader())
                  : menu.error != null
                      ? SliverToBoxAdapter(
                          child: EmptyStateWidget(
                            icon: Icons.wifi_off_rounded,
                            title: 'Oops!',
                            subtitle: menu.error!,
                            actionLabel: 'Retry',
                            onAction: menu.fetchMenu,
                          ),
                        )
                      : menu.items.isEmpty
                          ? SliverToBoxAdapter(
                              child: EmptyStateWidget(
                                icon: Icons.search_off_rounded,
                                title: 'No items found',
                                subtitle:
                                    'Try a different search or category.',
                                actionLabel: 'Clear Search',
                                onAction: () {
                                  _searchController.clear();
                                  context.read<MenuProvider>().search('');
                                  context
                                      .read<MenuProvider>()
                                      .selectCategory(AppConstants.categories.first);
                                },
                              ),
                            )
                          : SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) => MenuItemCard(item: menu.items[i]),
                                childCount: menu.items.length,
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
          ],
        ),
      ),
    );
  }
}
