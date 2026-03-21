import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';

class MenuProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<MenuItem> _allItems = [];
  List<MenuItem> _filteredItems = [];
  String _selectedCategory = AppConstants.categories.first;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  List<MenuItem> get items => _filteredItems;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
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

    _filteredItems = items;
  }

  Future<void> refresh() => fetchMenu();
}
