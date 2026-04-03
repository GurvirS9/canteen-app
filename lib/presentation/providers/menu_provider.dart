import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app/data/models/menu_item.dart';
import 'package:student_app/data/services/api_service.dart';
import 'package:student_app/core/constants/app_constants.dart';
import 'package:student_app/core/utils/logger.dart';

enum SortOption { bestsellers, priceLowToHigh, priceHighToLow, alphabetical }
enum DietaryFilter { all, veg, egg, nonVeg }

class MenuState {
  final List<MenuItem> items;
  final String selectedCategory;
  final String searchQuery;
  final SortOption selectedSort;
  final DietaryFilter dietaryFilter;
  final bool isLoading;
  final String? error;

  MenuState({
    required this.items,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.selectedSort = SortOption.bestsellers,
    this.dietaryFilter = DietaryFilter.all,
    this.isLoading = false,
    this.error,
  });

  MenuState copyWith({
    List<MenuItem>? items,
    String? selectedCategory,
    String? searchQuery,
    SortOption? selectedSort,
    DietaryFilter? dietaryFilter,
    bool? isLoading,
    String? error,
  }) {
    return MenuState(
      items: items ?? this.items,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSort: selectedSort ?? this.selectedSort,
      dietaryFilter: dietaryFilter ?? this.dietaryFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(ref.read(apiServiceProvider));
});

class MenuNotifier extends StateNotifier<MenuState> {
  static const String _tag = 'MenuNotifier';
  final ApiService _apiService;
  List<MenuItem> _allItems = [];

  MenuNotifier(this._apiService) : super(MenuState(items: []));

  Future<void> fetchMenu() async {
    AppLogger.i(_tag, 'fetchMenu() started');
    state = state.copyWith(isLoading: true, error: null);
    final stopwatch = Stopwatch()..start();
    try {
      _allItems = await _apiService.getMenu();
      stopwatch.stop();
      AppLogger.i(_tag, 'fetchMenu() loaded ${_allItems.length} items in ${stopwatch.elapsedMilliseconds}ms');
      _applyFilters();
    } catch (e, stack) {
      stopwatch.stop();
      state = state.copyWith(isLoading: false, error: 'Failed to load menu. Please try again.');
      AppLogger.e(_tag, 'fetchMenu() FAILED', e, stack);
    }
  }

  void selectCategory(String category) {
    AppLogger.d(_tag, 'selectCategory() → "$category"');
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  void search(String query) {
    AppLogger.d(_tag, 'search() → "$query"');
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    var items = _allItems;

    // Category filter
    if (state.selectedCategory != AppConstants.categories.first) {
      items = items.where((i) => i.category == state.selectedCategory).toList();
    }

    // Search filter
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      items = items.where((i) =>
          i.name.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.category.toLowerCase().contains(q)).toList();
    }

    // Dietary filter
    if (state.dietaryFilter == DietaryFilter.veg) {
      items = items.where((i) => i.isVeg).toList();
    } else if (state.dietaryFilter == DietaryFilter.egg) {
      items = items.where((i) => i.isEgg).toList();
    } else if (state.dietaryFilter == DietaryFilter.nonVeg) {
      items = items.where((i) => !i.isVeg && !i.isEgg).toList();
    }

    // Sort
    switch (state.selectedSort) {
      case SortOption.priceLowToHigh:
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.bestsellers:
        items.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.alphabetical:
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    state = state.copyWith(items: items, isLoading: false);
    AppLogger.d(_tag, '_applyFilters() → ${items.length} items');
  }

  void setSortOption(SortOption option) {
    if (state.selectedSort != option) {
      AppLogger.d(_tag, 'setSortOption() → ${option.name}');
      state = state.copyWith(selectedSort: option);
      _applyFilters();
    }
  }

  void setDietaryFilter(DietaryFilter filter) {
    if (state.dietaryFilter != filter) {
      AppLogger.d(_tag, 'setDietaryFilter() → ${filter.name}');
      state = state.copyWith(dietaryFilter: filter);
      _applyFilters();
    }
  }

  Future<void> refresh() => fetchMenu();
}
