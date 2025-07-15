import 'dart:io';

import 'package:flutter/material.dart';
import 'package:star_sticker/models/sticker.dart';
import 'package:star_sticker/services/sticker_api.dart';

import '../../services/recent_sticker_service.dart';

class StickerProvider with ChangeNotifier {
  final int userId;

  StickerProvider({required this.userId});

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _error;

  String? get error => _error;

  bool get hasError => _error != null;

  bool get hasData => _allSticker.isNotEmpty;

  final Map<String, List<Sticker>> _allSticker = {};

  Map<String, List<Sticker>> get allSticker => _allSticker;

  List<Sticker> _filteredStickers = [];

  List<Sticker> get filteredStickers => _filteredStickers;

  final Map<String, List<Sticker>> _premiumSticker = {};

  Map<String, List<Sticker>> get premiumSticker => _premiumSticker;

  final List<Sticker> _thumb = [];

  List<Sticker> get thumb => _thumb;

  final List<Sticker> _favoriteStickers = [];

  List<Sticker> get favoriteStickers => _favoriteStickers;

  List<Sticker> _recentsStickerList = [];

  List<Sticker> get recentsStickerList => _recentsStickerList;

  final List<Sticker> _collectionStickers = [];

  List<Sticker> get collectionStickers => _collectionStickers;

  final Map<String, List<Sticker>> _searchSticker = {};

  Map<String, List<Sticker>> get searchSticker => _allSticker;

  bool _isSearching = false;

  bool get isSearching => _isSearching;

  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  // Lazy loading properties
  final Map<String, int> _currentPages = {};
  final Map<String, bool> _hasMorePages = {};
  bool _isLoadingMore = false;

  bool get isLoadingMore => _isLoadingMore;

  bool hasMoreForCategory(String categoryName) {
    return _hasMorePages[categoryName] ?? true;
  }

  void setIsSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }

  /// Search stickers by category name
  Future<void> searchStickersByCategory(String query) async {
    debugPrint('[StickerProvider] 🔍 Searching stickers by category: "$query"');

    if (query.trim().isEmpty) {
      _searchSticker.clear();
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);

      // Search through all cached categories
      _searchSticker.clear();

      for (String categoryName in _allSticker.keys) {
        if (categoryName.toLowerCase().contains(query.toLowerCase())) {
          _searchSticker
              .addEntries([MapEntry(categoryName, _allSticker[categoryName]!)]);
        }
      }
    } catch (e) {
      debugPrint('[StickerProvider] ❌ Error searching stickers: $e');
      _error = 'Failed to search stickers: $e';
      _searchSticker.clear();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Clear search results
  void clearSearch() {
    _searchQuery = '';
    _filteredStickers = [];
    _isSearching = false;
    notifyListeners();
  }

  /// Load initial stickers for a category with pagination
  Future<void> fetchStickersByCategory(String categoryName) async {
    debugPrint(
        '[StickerProvider] 🔄 Loading stickers for category: $categoryName');

    try {
      _setLoading(true);
      _currentPages[categoryName] = 1;
      _hasMorePages[categoryName] = true;

      final stickers =
          await StickerApi.fetchStickersByCategory(categoryName, 1);

      _allSticker[categoryName] = stickers;
      _filteredStickers = stickers;

      // Check if we have more pages (assuming 10 items per page)
      _hasMorePages[categoryName] = stickers.length >= 10;

      debugPrint(
          '[StickerProvider] ✅ Loaded ${stickers.length} stickers for $categoryName');
      notifyListeners();
    } catch (e) {
      debugPrint('[StickerProvider] ❌ Error loading stickers: $e');
      _error = 'Failed to load stickers: $e';
      _filteredStickers = [];
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Load more stickers for a category (lazy loading)
  Future<void> loadMoreStickers(String categoryName) async {
    if (_isLoadingMore || !(_hasMorePages[categoryName] ?? false)) {
      return;
    }

    debugPrint(
        '[StickerProvider] 🔄 Loading more stickers for category: $categoryName');

    try {
      _isLoadingMore = true;
      notifyListeners();

      final currentPage = _currentPages[categoryName] ?? 1;
      final nextPage = currentPage + 1;

      final newStickers =
          await StickerApi.fetchStickersByCategory(categoryName, nextPage);

      if (newStickers.isNotEmpty) {
        _allSticker[categoryName] = [
          ...(_allSticker[categoryName] ?? []),
          ...newStickers
        ];
        _filteredStickers = _allSticker[categoryName]!;
        _currentPages[categoryName] = nextPage;

        // Check if we have more pages (assuming 30 items per page)
        _hasMorePages[categoryName] = newStickers.length >= 10;

        debugPrint(
            '[StickerProvider] ✅ Loaded ${newStickers.length} more stickers for $categoryName');
      } else {
        _hasMorePages[categoryName] = false;
        debugPrint('[StickerProvider] 🏁 No more stickers for $categoryName');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('[StickerProvider] ❌ Error loading more stickers: $e');
      _error = 'Failed to load more stickers: $e';
      notifyListeners();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentsStickers() async {
    _setLoading(true);
    _error = null;
    debugPrint('[StickerProvider] 🔄 Bắt đầu loadRecentsStickers...');
    try {
      _filteredStickers = _recentsStickerList.toList();
      debugPrint(
          '[StickerProvider] ❤️ Đã load ${_recentsStickerList.length} recent stickers');
      notifyListeners();
    } catch (e) {
      debugPrint('[StickerProvider] ❌ Lỗi loadRecentsStickers: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadFavoriteStickers() async {
    _setLoading(true);
    _error = null;
    debugPrint('[StickerProvider] 🔄 Bắt đầu loadFavoriteStickers...');

    try {
      _filteredStickers = await StickerApi.fetchFavorites();
      debugPrint(
          '[StickerProvider] ❤️ Đã load ${_favoriteStickers.length} favorite stickers');
    } catch (e, stack) {
      _error = 'PROVIDER - Failed to load favorite stickers: $e';
      debugPrint('[StickerProvider] ❌ Lỗi loadFavoriteStickers: $e');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Stack trace: $stack');
    } finally {
      _setLoading(false);
      debugPrint('[StickerProvider] 🔚 Kết thúc loadFavoriteStickers');
    }
  }

  Future<void> toggleFavorite({required String stickerId}) async {
    debugPrint('[StickerProvider] 🔃 toggleFavorite $stickerId');

    try {
      final isFavorite =
          await StickerApi.toggleFavoriteSticker(stickerId: stickerId);
      debugPrint('[StickerProvider] ✅ API trả về isFavorite = $isFavorite');

      final allStickersFlat =
          _allSticker.values.expand((list) => list).toList();
      final sticker = allStickersFlat.firstWhere(
        (s) => s.id == stickerId,
        orElse: () {
          debugPrint(
              '[StickerProvider] ⚠️ Không tìm thấy sticker $stickerId trong allSticker');
          return Sticker.empty();
        },
      );

      if (sticker.id.isEmpty) return;

      if (isFavorite) {
        if (!_favoriteStickers.any((s) => s.id == stickerId)) {
          _favoriteStickers.add(sticker);
          debugPrint(
              '[StickerProvider] ➕ Đã thêm sticker $stickerId vào favorite');
        }
      } else {
        _favoriteStickers.removeWhere((s) => s.id == stickerId);
        debugPrint(
            '[StickerProvider] ➖ Đã xóa sticker $stickerId khỏi favorite');
      }
    } catch (e) {
      _error = 'PROVIDER - Failed to toggle favorite: $e';
      debugPrint('[StickerProvider] ❌ Lỗi toggleFavorite: $e');
    } finally {
      notifyListeners();
      debugPrint('[StickerProvider] 🔚 Kết thúc toggleFavorite');
    }
  }

  bool isFavorite(String stickerId) {
    final result = _favoriteStickers.any((sticker) => sticker.id == stickerId);
    debugPrint('[StickerProvider] 🔍 isFavorite($stickerId) => $result');
    return result;
  }

  Future<bool> uploadUserSticker({
    required File imageFile,
  }) async {
    final success = await StickerApi.uploadUserSticker(
      createdBy: userId,
      imageFile: imageFile,
    );

    if (success) {
      debugPrint('[StickerProvider] Upload user sticker thành công');
    } else {
      debugPrint('[StickerProvider] Upload user sticker thất bại');
    }

    return success;
  }

  Future<void> loadRecentFromLocal() async {
    _recentsStickerList = await RecentStickerService.getRecentList();
    notifyListeners();
  }

  Future<void> saveToRecentAndReload(Sticker sticker) async {
    await RecentStickerService.saveToRecent([sticker]);
    await loadRecentFromLocal();
  }

  bool isStickerPremium(String categoryId, Sticker sticker) {
    final premiumList = _premiumSticker[categoryId];
    if (premiumList == null || premiumList.isEmpty) return false;
    return premiumList.any((s) => s.id == sticker.id);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
