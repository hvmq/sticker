import 'package:flutter/material.dart';
import '../../models/collection.dart';
import '../../services/collection_api.dart';

class CollectionProvider with ChangeNotifier {
  final int userId;

  CollectionProvider({required this.userId});

  List<Collection> _collections = [];

  List<Collection> get collections => _collections;

  /// 🔄 Fetch collections + các sticker trong từng collection
  Future<void> fetchCollectionsByUser() async {
    debugPrint('[CollectionProvider] 🔄 Fetching collections for user $userId...');
    try {
      final fetched = await CollectionApi.getCollectionsByUser(userId);
      _collections = [...fetched];
      debugPrint('[CollectionProvider] ✅ Loaded ${_collections.length} collections');
    } catch (e, stack) {
      debugPrint('[CollectionProvider] ❌ Error fetching collections: $e');
      debugPrint('[CollectionProvider] 🪵 Stack trace: $stack');
    } finally {
      notifyListeners();
    }
  }

  /// ➕ Tạo collection mới
  Future<void> createNewCollection(String name) async {
    debugPrint('[CollectionProvider] ➕ Creating collection "$name" for user $userId');
    try {
      final newCollection = await CollectionApi.createCollection(userId: userId, name: name);
      _collections.add(newCollection);
      debugPrint('[CollectionProvider] ✅ Added new collection with id ${newCollection.id}');
    } catch (e) {
      debugPrint('[CollectionProvider] ❌ Error creating collection "$name": $e');
    } finally {
      notifyListeners();
    }
  }

  /// 🗑️ Xóa collection theo id
  Future<void> deleteCollection(int id) async {
    debugPrint('[CollectionProvider] 🗑️ Deleting collection $id');
    try {
      await CollectionApi.deleteCollection(id);
      _collections.removeWhere((c) => c.id == id);
      debugPrint('[CollectionProvider] ✅ Deleted collection $id');
    } catch (e) {
      debugPrint('[CollectionProvider] ❌ Error deleting collection $id: $e');
    } finally {
      notifyListeners();
    }
  }

  /// ➕ Thêm sticker vào collection
  Future<void> addStickerToCollection(int collectionId, String stickerId) async {
    debugPrint('[CollectionProvider] ➕ Adding sticker $stickerId to collection $collectionId');
    try {
      await CollectionApi.addStickerToCollection(
        collectionId: collectionId,
        userId: userId,
        stickerId: stickerId,
      );
      debugPrint('[CollectionProvider] ✅ Added sticker $stickerId to collection $collectionId');
      await fetchCollectionsByUser();
    } catch (e) {
      debugPrint('[CollectionProvider] ❌ Error adding sticker: $e');
    }
  }

  /// 🔁 Cập nhật sticker trong collection
  Future<void> updateStickerInCollection(
    int collectionId,
    String newStickerId,
    String oldStickerId,
  ) async {
    debugPrint('[CollectionProvider] 🔁 Updating sticker in collection $collectionId: $oldStickerId → $newStickerId');
    try {
      await CollectionApi.updateStickerInCollection(
        collectionId: collectionId,
        userId: userId,
        newStickerId: newStickerId,
        oldStickerId: oldStickerId,
      );
      debugPrint('[CollectionProvider] ✅ Updated sticker in collection $collectionId');
    } catch (e) {
      debugPrint('[CollectionProvider] ❌ Error updating sticker: $e');
    }
  }

  /// ✏️ Cập nhật tên collection
  Future<void> updateCollection({
    required int collectionId,
    required String name,
  }) async {
    debugPrint('[CollectionProvider] ✏️ Updating collection $collectionId name to "$name"');
    try {
      await CollectionApi.updateCollection(
        collectionId: collectionId,
        userId: userId,
        name: name,
      );

      final index = _collections.indexWhere((c) => c.id == collectionId);
      if (index != -1) {
        _collections[index] = _collections[index].copyWith(name: name);
        debugPrint('[CollectionProvider] ✅ Updated collection name');
      } else {
        debugPrint('[CollectionProvider] ⚠️ Collection $collectionId not found');
      }
    } catch (e) {
      debugPrint('[CollectionProvider] ❌ Error updating collection: $e');
    } finally {
      notifyListeners();
    }
  }

  /// 🔍 Kiểm tra sticker có nằm trong collection nào không
  bool isStickerInCollection({
    required int collectionId,
    required String stickerId,
  }) {
    final collection = _collections.firstWhere(
      (c) => c.id == collectionId,
      orElse: () {
        debugPrint('[CollectionProvider] ⚠️ Không tìm thấy collection với id $collectionId');
        return Collection.empty();
      },
    );

    final exists = collection.stickers.any((s) => s.id == stickerId);
    debugPrint('[CollectionProvider] 🔍 Sticker $stickerId in collection $collectionId: $exists');
    return exists;
  }

  /// ❌ Xóa sticker khỏi 1 collection
  Future<void> removeStickerFromCollection({
    required int collectionId,
    required String stickerId,
  }) async {
    debugPrint('[CollectionProvider] ❌ Removing sticker $stickerId from collection $collectionId');
    try {
      await CollectionApi.removeStickerFromCollection(
        collectionId: collectionId,
        userId: userId,
        stickerId: stickerId,
      );
      debugPrint('[CollectionProvider] ✅ Removed sticker $stickerId from collection $collectionId');
    } catch (e) {
      debugPrint('[CollectionProvider] ❌ Error removing sticker: $e');
    } finally {
      notifyListeners();
    }
  }

  /// 📋 Trả về danh sách collection có chứa sticker
  List<Collection> getCollectionsContainingSticker(String stickerId) {
    final result = _collections.where((collection) => collection.stickers.any((s) => s.id == stickerId)).toList();

    debugPrint('[CollectionProvider] 📋 Found ${result.length} collections containing sticker $stickerId');
    return result;
  }
}
