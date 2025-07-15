import 'dart:developer';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_sticker/models/category.dart';
import 'package:star_sticker/models/sticker.dart';
import 'package:star_sticker/presentation/provider/collection_provider.dart';
import 'package:star_sticker/presentation/widgets/category_widget.dart';
import 'package:star_sticker/presentation/widgets/grid_widget.dart';

import '../../utils/item_builder.dart';
import '../provider/category_provider.dart';
import '../provider/sticker_provider.dart';

class FilteredWidget extends StatefulWidget {
  const FilteredWidget({
    super.key,
    required this.scrollController,
    this.onStickerSelected,
  });

  final ScrollController scrollController;
  final Function(Sticker sticker)? onStickerSelected;

  @override
  State<FilteredWidget> createState() => _FilteredWidgetState();
}

class _FilteredWidgetState extends State<FilteredWidget> {
  @override
  void initState() {
    super.initState();
    // Add scroll listener for lazy loading
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent - 200) {
      log('Triggering lazy load...');
      final catProvider = context.read<CategoryProvider>();
      final stickerProvider = context.read<StickerProvider>();

      // Only load more for regular categories (not favorites or recents)
      if (catProvider.currentCategory != 'favorite' &&
          catProvider.currentCategory != 'Recents') {
        final categoryName = catProvider.categories
            .firstWhere(
                (category) => category.id == catProvider.currentCategory)
            .name;

        log('Category: $categoryName, hasMore: ${stickerProvider.hasMoreForCategory(categoryName)}, isLoading: ${stickerProvider.isLoadingMore}');

        if (stickerProvider.hasMoreForCategory(categoryName) &&
            !stickerProvider.isLoadingMore) {
          log('Loading more stickers for $categoryName');
          stickerProvider.loadMoreStickers(categoryName);
        }
      }
    }
  }

  // Future<void> _loadCollections() async {
  //   final provider = context.read<CollectionProvider>();
  //   await provider.fetchCollectionsByUser();
  // }

  // void _handleCategoryChange(String newCategory) {
  //   setState(() {
  //     widget.onCategoryChanged(newCategory);
  //     recentSelected = newCategory == 'Recents';
  //   });
  // }

  // Map<String, List<Sticker>> _getFilteredStickers() {
  //   final favorites = context.watch<StickerProvider>().favoriteStickers;

  //   if (selectedCategory == 'Recents') {
  //     return widget.allStickerList;
  //   } else if (selectedCategory == 'favorite') {
  //     return {'favorite': favorites};
  //   } else {
  //     return {
  //       selectedCategory: widget.allStickerList[selectedCategory] ?? [],
  //     };
  //   }
  // }

  List<Widget> _buildStickerSection({
    required String id,
    required String name,
    required List<Sticker> stickers,
    bool isLocked = true,
    bool showCount = false,
    bool isViewOnly = false,
  }) {
    final stickerProvider = context.watch<StickerProvider>();

    return [
      CategoryWidget(
        category: Category(id: id, name: name, imagePath: '', price: 0),
        stickerCount: stickers.length,
        showCount: showCount,
      ),
      GridWidget(
        stickers: stickers,
        scrollController: widget.scrollController,
        isViewOnly: isViewOnly,
        isLocked: isLocked,
        showLockIcon: true,
        onStickerSelected: widget.onStickerSelected,
        isLoading: stickerProvider.isLoadingMore,
        hasMore: stickerProvider.hasMoreForCategory(name),
      ),
    ];
  }

  List<Widget> _buildCollectionSection() {
    final collectionProvider = context.watch<CollectionProvider>();
    final collections = collectionProvider.collections;

    return [
      CategoryWidget(
        category: Category(
            id: 'collections', name: 'Bộ sưu tập', imagePath: '', price: 0),
        stickerCount: collections.length,
        showCount: false,
      ),
      ...collections.expand((collection) {
        return _buildStickerSection(
          id: 'collection_${collection.id}',
          name: collection.name,
          stickers: collection.stickers,
          showCount: true,
        );
      }),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return GestureDetector(
                onTap: () {
                  showAddCollectionModal(
                      context, context.read<CollectionProvider>());
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.black),
                  ),
                ),
              );
            },
            childCount: 1,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();
    final stickerProvider = context.watch<StickerProvider>();
    return Expanded(
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
          scrollbars: defaultTargetPlatform == TargetPlatform.macOS,
        ),
        child: CustomScrollView(
          controller: widget.scrollController,
          slivers: catProvider.currentCategory == 'favorite'
              ? [
                  ..._buildStickerSection(
                    id: 'favorite',
                    name: 'Yêu thích',
                    stickers: stickerProvider.filteredStickers,
                    isLocked: false,
                  ),
                  // ..._buildCollectionSection(),
                ]
              : catProvider.currentCategory == 'Recents'
                  ? [
                      ..._buildStickerSection(
                        id: 'Recents',
                        name: 'Gần đây',
                        stickers: stickerProvider.filteredStickers,
                        isLocked: false,
                      ),
                    ]
                  : _buildStickerSection(
                      id: catProvider.currentCategory,
                      name: catProvider.categories
                          .firstWhere((category) =>
                              category.id == catProvider.currentCategory)
                          .name,
                      stickers: stickerProvider.filteredStickers,
                      isLocked: false,
                    ),
        ),
      ),
    );
  }
}
