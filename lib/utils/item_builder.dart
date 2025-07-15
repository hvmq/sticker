import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_sticker/models/sticker.dart';

import '../presentation/provider/collection_provider.dart';
import '../presentation/provider/sticker_provider.dart';
import '../presentation/widgets/sticker_preview_overlay.dart';

Widget StickerItem(
  BuildContext context,
  Sticker sticker, {
  Function(Sticker)? onStickerSelected,
  required VoidCallback onShowProDetail,
  bool showLockIcon = true,
}) {
  final stickerProvider = Provider.of<StickerProvider>(context, listen: false);

  void showPreviewOverlay() {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) => StickerPreviewOverlay(
        sticker: sticker,
        stickerProvider: stickerProvider,
        onDismiss: () => Navigator.of(context).pop(),
        onSend: (sticker) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          onStickerSelected?.call(sticker);
        },
      ),
    );
  }

  return GestureDetector(
    onTap: () => onStickerSelected?.call(sticker),
    onLongPress: showPreviewOverlay,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                sticker.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            if (sticker.isPremium && showLockIcon)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

void showDialogCollection(
    BuildContext context, CollectionProvider collectionProvider) {
  int sellect = 0; // Đưa ra ngoài StatefulBuilder

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Thêm vào bộ sưu tập',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.add_circle_outline_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: collectionProvider.collections.length,
                      itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  sellect = index;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: sellect == index
                                      ? Color(0xffE78503).withOpacity(0.1)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: sellect == index
                                        ? Color(0xffE78503)
                                        : Colors.grey.shade300,
                                    width: sellect == index ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // All emoji reactions for this style
                                    Expanded(
                                        child: Text(
                                            collectionProvider
                                                .collections[index].name,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black))),

                                    const SizedBox(width: 8),

                                    // Check mark
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: sellect == index
                                            ? Color(0xffE78503)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: sellect == index
                                              ? Color(0xffE78503)
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: sellect == index
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 12,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),
                  // Emoji styles in a single column (7 styles)

                  const SizedBox(height: 20),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffE78503),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void showPreviewWithOptions({
  required BuildContext rootContext,
  required Sticker sticker,
  Function(Sticker)? onStickerSelected,
  required StickerProvider stickerProvider,
  required CollectionProvider collectionProvider,
}) {
  showDialog(
    context: rootContext,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (dialogContext) {
      final screenSize = MediaQuery.of(dialogContext).size.width;
      final isLiked = stickerProvider.isFavorite(sticker.id);
      final collectionsContainSticker =
          collectionProvider.getCollectionsContainingSticker(sticker.id);
      final isExisted = collectionsContainSticker.isNotEmpty;

      Future<void> handleSelect() async {
        Navigator.of(dialogContext).pop();
        if (onStickerSelected != null) {
          onStickerSelected(sticker);
        }
        FocusScope.of(rootContext).unfocus();
      }

      return GestureDetector(
        onTap: () => Navigator.of(dialogContext).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: handleSelect,
                  child: Image.network(sticker.imagePath,
                      width: screenSize * 0.6, height: screenSize * 0.6),
                ),
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        iconColor: Colors.orangeAccent,
                        leading: const Icon(Icons.send),
                        title: const Text('Gửi sticker',
                            style: TextStyle(color: Colors.black)),
                        onTap: handleSelect,
                      ),
                      ListTile(
                        iconColor: Colors.orangeAccent,
                        leading: const Icon(Icons.collections_bookmark),
                        title: const Text('Thêm vào bộ sưu tập',
                            style: TextStyle(color: Colors.black)),
                        onTap: () {
                          _showCollectionDialog(
                            rootContext,
                            sticker,
                            collectionProvider,
                          );
                        },
                      ),
                      if (isExisted)
                        ListTile(
                          iconColor: Colors.orangeAccent,
                          leading:
                              const Icon(Icons.collections_bookmark_outlined),
                          title: const Text('Xoá khỏi bộ sưu tập',
                              style: TextStyle(color: Colors.black)),
                          onTap: () {
                            Navigator.of(dialogContext).pop();
                            _showCollectionDialog(
                              rootContext,
                              sticker,
                              collectionProvider,
                              isRemoveMode: isExisted,
                            );
                          },
                        ),
                      ListTile(
                        iconColor: Colors.orangeAccent,
                        leading: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border),
                        title: Text(
                          isLiked ? 'Bỏ yêu thích' : 'Yêu thích',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () async {
                          Navigator.of(dialogContext).pop();
                          await handleToggleFavorite(
                            context: rootContext,
                            stickerId: sticker.id,
                            stickerProvider: stickerProvider,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<void> handleToggleFavorite({
  required BuildContext context,
  required String stickerId,
  required StickerProvider stickerProvider,
}) async {
  try {
    await stickerProvider.toggleFavorite(stickerId: stickerId);
  } catch (_) {}
}

void handleStickerTap({
  required BuildContext context,
  required Sticker sticker,
  required bool isLocked,
  required bool isViewOnly,
  required VoidCallback onSelected,
  required VoidCallback onShowProDetail,
}) {
  if (sticker.isPremium) {
    if (isLocked) {
      onShowProDetail();
    }
    return;
  }

  // Sticker thường
  if (!isViewOnly) {
    onSelected();
  }
}

void _showCollectionDialog(
  BuildContext context,
  Sticker sticker,
  CollectionProvider collectionProvider, {
  bool isRemoveMode = false,
}) {
  // Danh sách các collection chứa sticker hiện tại
  final containingCollections =
      collectionProvider.getCollectionsContainingSticker(sticker.id);

  // Nếu là mode xoá => chỉ hiện các bộ có chứa sticker
  // Nếu là mode thêm => loại bỏ các bộ đã có sticker
  final collections = isRemoveMode
      ? containingCollections
      : collectionProvider.collections
          .where(
            (c) => !containingCollections.any((cc) => cc.id == c.id),
          )
          .toList();
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(isRemoveMode ? 'Xoá khỏi bộ sưu tập' : 'Chọn bộ sưu tập'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: collections.length + (isRemoveMode ? 1 : 1),
            itemBuilder: (context, index) {
              // Danh sách bộ sưu tập để thêm hoặc xoá
              if (index < collections.length) {
                final collection = collections[index];
                return ListTile(
                  title: Text(collection.name),
                  trailing: isRemoveMode
                      ? const Icon(Icons.remove_circle, color: Colors.red)
                      : null,
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      if (isRemoveMode) {
                        await collectionProvider.removeStickerFromCollection(
                          collectionId: collection.id,
                          stickerId: sticker.id,
                        );
                      } else {
                        await collectionProvider.addStickerToCollection(
                          collection.id,
                          sticker.id,
                        );
                      }
                    } catch (e) {
                      debugPrint('Lỗi xử lý: ${e.toString()}');
                    }
                  },
                );
              }

              // Chỉ hiển thị khi đang ở mode thêm
              if (!isRemoveMode) {
                return ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Tạo bộ sưu tập mới'),
                  onTap: () {
                    Navigator.pop(context);
                    showAddCollectionModal(context, collectionProvider);
                  },
                );
              }

              // Chỉ hiển thị khi đang ở mode xoá
              return ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Bỏ khỏi tất cả các bộ sưu tập'),
                onTap: () async {
                  Navigator.pop(context);
                  for (final collection in collections) {
                    await collectionProvider.removeStickerFromCollection(
                      collectionId: collection.id,
                      stickerId: sticker.id,
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Đã xoá khỏi tất cả bộ sưu tập')),
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

void showAddCollectionModal(BuildContext context, CollectionProvider provider) {
  final TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          'Thêm bộ sưu tập',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nhập tên bộ sưu tập',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final collectionName = controller.text.trim();
              if (collectionName.isNotEmpty) {
                try {
                  await provider.createNewCollection(collectionName);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tạo bộ sưu tập thành công')),
                  );
                } catch (e) {
                  debugPrint('[UI] ❌ Lỗi tạo collection: $e');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      e.toString().contains('tồn tại')
                          ? 'Tên bộ sưu tập đã tồn tại'
                          : 'Không thể tạo bộ sưu tập',
                    ),
                  ));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập tên bộ sưu tập')),
                );
              }
            },
            child: const Text('Lưu'),
          )
        ],
      );
    },
  );
}
