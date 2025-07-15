import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_sticker/models/category.dart';

import '../../utils/category_builder.dart';
import '../provider/category_provider.dart';

// ignore: must_be_immutable
class CategoryWidget extends StatefulWidget {
  final Category category;

  CategoryWidget({
    super.key,
    required this.category,
    required this.stickerCount,
    required this.showCount,
  });

  int stickerCount;
  bool showCount;

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.005,
            bottom: MediaQuery.of(context).size.height * 0.005),
        child: GestureDetector(
          onTap: () {
            // widget.isRecentSelected = widget.category.name == 'Recents';
            // widget.category.name != 'Recents';
            // widget.modalSetState(() {
            // widget.onCategoryChanged(widget.category.id);
            // widget.scrollController.jumpTo(0);
            // });
          },
          child: Consumer<CategoryProvider>(
            builder: (context, provider, _) {
              final categoryName = getCategoryName(context, widget.category);
              return widget.showCount
                  ? Text('$categoryName (${widget.stickerCount})',
                      style: const TextStyle(fontSize: 15, color: Colors.black))
                  : Row(
                      children: [
                        Text(categoryName,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.black)),
                        if (categoryName != 'Recents')
                          const Icon(Icons.chevron_right),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
