import 'package:flutter/material.dart';
import 'package:star_sticker/models/sticker.dart';
import 'package:star_sticker/utils/item_builder.dart';

// ignore: must_be_immutable
class GridWidget extends StatefulWidget {
  GridWidget({
    super.key,
    required this.stickers,
    required this.scrollController,
    required this.isViewOnly,
    required this.isLocked,
    this.showLockIcon = false,
    this.onStickerSelected,
    this.isLoading = false,
    this.hasMore = true,
  });

  List<Sticker> stickers;
  ScrollController scrollController;
  bool isViewOnly = false;
  bool isLocked = false;
  bool showLockIcon = false;
  Function(Sticker sticker)? onStickerSelected;
  bool isLoading;
  bool hasMore;

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          // Show loading indicator at the end
          if (index == widget.stickers.length) {
            if (widget.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (!widget.hasMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Đã tải hết sticker',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final Sticker sticker = widget.stickers[index];

          return StickerItem(
            context,
            sticker,
            onStickerSelected: widget.onStickerSelected,
            onShowProDetail: () {},
            showLockIcon: widget.showLockIcon,
          );
        },
        childCount: widget.stickers.length +
            (widget.hasMore || widget.isLoading ? 1 : 0),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
    );
  }
}
