import 'package:flutter/material.dart';
import 'package:star_sticker/models/category.dart';
import 'package:star_sticker/services/category_api.dart';

class CategoryProvider with ChangeNotifier {
  CategoryProvider() : super();

  List<Category> _categories = [];

  List<Category> get categories => _categories;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _error;

  String? get error => _error;

  String _currentCategory = 'Recents';

  String get currentCategory => _currentCategory;

  int currentPage = 1;
  bool hasMore = true;

  void setCurrentCategory(String category) {
    _currentCategory = category;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    if (_isLoading) return;
    if (!hasMore) return;
    debugPrint('[Provider] Start loading categories...');
    _isLoading = true;
    notifyListeners();

    try {
      final categories = await CategoryApi.fetchCategories(page: currentPage);
      debugPrint('[Provider] Categories loaded: ${categories.length} items');
      _categories = [..._categories, ...categories];
      hasMore = categories.length == 20;
      currentPage++;
    } catch (e) {
      debugPrint('[Provider] Error loading categories: $e');
      _error = e.toString();
    }
    debugPrint('[Provider] Categories : ${categories.length} items');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomCategory(String name) async {
    debugPrint('[Provider] Adding custom category: $name');
    _isLoading = true;
    notifyListeners();

    try {
      final newCategory = Category(id: '', name: name, imagePath: '', price: 0);
      final created = await CategoryApi.createCategory(newCategory);
      debugPrint(
          '[Provider] Created category: ${created.name} (${created.id})');

      _categories = [..._categories, created];
    } catch (e) {
      debugPrint('[Provider] Error creating category: $e');
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
