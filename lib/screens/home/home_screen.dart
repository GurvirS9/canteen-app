import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_theme.dart';
import '../../widgets/menu_item_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/empty_state_widget.dart';

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
                                  color: Colors.black.withOpacity(0.15),
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

            // Category chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final cat = AppConstants.categories[i];
                    final isSelected = menu.selectedCategory == cat;
                    return GestureDetector(
                      onTap: () =>
                          context.read<MenuProvider>().selectCategory(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : theme.chipTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Section title
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text(
                      menu.selectedCategory == AppConstants.categories.first
                          ? 'All Items'
                          : menu.selectedCategory,
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (!menu.isLoading)
                      Text(
                        '${menu.items.length} items',
                        style: theme.textTheme.bodyMedium,
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
