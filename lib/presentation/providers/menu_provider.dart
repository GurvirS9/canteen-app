import 'package:flutter/material.dart';
import 'package:student_app/data/models/menu_item.dart';
import 'package:student_app/data/services/api_service.dart';
import 'package:student_app/core/constants/app_constants.dart';

enum SortOption { bestsellers, priceLowToHigh, priceHighToLow, alphabetical }
enum DietaryFilter { all, veg, egg, nonVeg }

class MenuProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<MenuItem> _allItems = [];
  List<MenuItem> _filteredItems = [];
  String _selectedCategory = AppConstants.categories.first;
  String _searchQuery = '';
  SortOption _selectedSort = SortOption.bestsellers;
  DietaryFilter _dietaryFilter = DietaryFilter.all;
  bool _isLoading = false;
  String? _error;

  List<MenuItem> get items => _filteredItems;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  SortOption get selectedSort => _selectedSort;
  DietaryFilter get dietaryFilter => _dietaryFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMenu() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _allItems = await _apiService.getMenu();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load menu. Please try again.';
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var items = _allItems;

    // Category filter
    if (_selectedCategory != AppConstants.categories.first) {
      items = items.where((i) => i.category == _selectedCategory).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((i) =>
          i.name.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.category.toLowerCase().contains(q)).toList();
    }

    // Dietary filter
    if (_dietaryFilter == DietaryFilter.veg) {
      items = items.where((i) => i.isVeg).toList();
    } else if (_dietaryFilter == DietaryFilter.egg) {
      items = items.where((i) => i.isEgg).toList();
    } else if (_dietaryFilter == DietaryFilter.nonVeg) {
      // Non-veg usually means meat (not strictly veg and not strictly egg)
      // We can define it as items where both isVeg and isEgg are false.
      items = items.where((i) => !i.isVeg && !i.isEgg).toList();
    }

    // Sort
    switch (_selectedSort) {
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

    _filteredItems = items;
  }

  void setSortOption(SortOption option) {
    if (_selectedSort != option) {
      _selectedSort = option;
      _applyFilters();
      notifyListeners();
    }
  }

  void setDietaryFilter(DietaryFilter filter) {
    if (_dietaryFilter != filter) {
      _dietaryFilter = filter;
      _applyFilters();
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchMenu();
}
