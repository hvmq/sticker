import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_sticker/presentation/pages/sticker_page.dart';
import 'package:star_sticker/presentation/provider/category_provider.dart';
import 'package:star_sticker/presentation/provider/collection_provider.dart';
import 'package:star_sticker/presentation/provider/sticker_provider.dart';

class StickerSDK {
  static StickerSDK? _instance;

  static StickerSDK get instance => _instance ??= StickerSDK._();

  StickerSDK._();

  static StickerProvider? _stickerProvider;
  static CategoryProvider? _categoryProvider;
  static CollectionProvider? _collectionProvider;

  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static late int _userId;

  static int get userId => _userId;

  static Future<void> init({required int userId}) async {
    if (_isInitialized) return;

    _userId = userId;
    debugPrint("_userId: $_userId");

    try {
      _stickerProvider = StickerProvider(userId: _userId);
      _categoryProvider = CategoryProvider();
      _collectionProvider = CollectionProvider(userId: _userId);

      await _stickerProvider!.loadRecentFromLocal();
      // await _collectionProvider!.fetchCollectionsByUser();
      await _categoryProvider!.loadCategories();
      _isInitialized = true;

      debugPrint('Sticker SDK initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Sticker SDK: $e');
      rethrow;
    }
  }

  static Future<void> show(
    BuildContext context, {
    Function(String stickerUrl)? onStickerSelected,
  }) async {
    if (!_isInitialized) {
      debugPrint('Sticker SDK not initialized. Call Sticker.init() first.');
      return;
    }

    FocusScope.of(context).unfocus();
    if (_stickerProvider!.recentsStickerList.isEmpty) {
      if (_categoryProvider!.categories.isNotEmpty) {
        _categoryProvider!
            .setCurrentCategory(_categoryProvider!.categories[0].id);
        _stickerProvider!
            .fetchStickersByCategory(_categoryProvider!.categories[0].name);
      }
    } else {
      _categoryProvider!.setCurrentCategory('Recents');
      _stickerProvider!.loadRecentsStickers();
    }

    await showModalBottomSheet(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        side: BorderSide(width: 0.5),
      ),
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext modalContext) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _stickerProvider!),
            ChangeNotifierProvider.value(value: _categoryProvider!),
            ChangeNotifierProvider.value(value: _collectionProvider!),
          ],
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            ),
            child: StatefulBuilder(
              builder: (BuildContext ctx, StateSetter modalSetState) {
                return DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  maxChildSize: 0.8,
                  minChildSize: 0.2,
                  expand: false,
                  builder: (context, scrollController) {
                    final width = MediaQuery.of(context).size.width;
                    return ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.trackpad,
                        },
                        scrollbars:
                            defaultTargetPlatform == TargetPlatform.macOS,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                        child: StickerPage(
                          onStickerSelected: onStickerSelected,
                          scrollController: scrollController,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
