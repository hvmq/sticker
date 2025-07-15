import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../provider/category_provider.dart';

class NavBarWidget extends StatefulWidget {
  final String currentCategory;
  final List<Category> categories;
  final Function(String categoryId, String categoryName) onTap;

  const NavBarWidget(
      {super.key,
      required this.categories,
      required this.onTap,
      required this.currentCategory});

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = [
      {'id': 'favorite', 'icon': Icons.favorite_border, 'name': 'Yêu thích'},
      {'id': 'Recents', 'icon': Icons.history, 'name': 'Gần đây'},
      ...widget.categories.map((cat) => {
            'id': cat.id,
            'imagePath': cat.imagePath,
            'name': cat.name,
          })
    ];

    return Consumer<CategoryProvider>(
        builder: (context, catProvider, child) => SizedBox(
              height: 48,
              child: Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    final scrollDelta = pointerSignal.scrollDelta.dy;
                    _scrollController.animateTo(
                      _scrollController.offset + scrollDelta,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: catProvider.hasMore
                      ? allItems.length + 1
                      : allItems.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (index == allItems.length) {
                      catProvider.loadCategories();
                      return Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          width: 20,
                          height: 20,
                          child: const CircularProgressIndicator());
                    }
                    final item = allItems[index];
                    final isSelected = item['id'] == widget.currentCategory;
                    return GestureDetector(
                      onTap: () => widget.onTap(
                          item['id'] as String, item['name'] as String),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 2,
                              color: isSelected
                                  ? Colors.black
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                        child: item['icon'] != null
                            ? Icon(item['icon'] as IconData,
                                color: isSelected ? Colors.black : Colors.grey)
                            : Image.network(
                                item['imagePath'] as String,
                                width: 30,
                                height: 30,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ));

    // return SingleChildScrollView(
    //   scrollDirection: Axis.horizontal,
    //   child: Row(
    //     children: allItems.map((item) {
    //       final isSelected = item['id'] == currentCategory;

    //       return GestureDetector(
    //         onTap: () => onTap(item['id'] as String, item['name'] as String),
    //         child: Container(
    //           margin: const EdgeInsets.symmetric(horizontal: 6),
    //           padding: const EdgeInsets.all(8),
    //           decoration: BoxDecoration(
    //             border: Border(
    //               bottom: BorderSide(
    //                 width: 2,
    //                 color: isSelected ? Colors.black : Colors.transparent,
    //               ),
    //             ),
    //           ),
    //           child: item['icon'] != null
    //               ? Icon(item['icon'] as IconData,
    //                   color: isSelected ? Colors.black : Colors.grey)
    //               : Image.network(
    //                   item['imagePath'] as String,
    //                   width: 30,
    //                   height: 30,
    //                 ),
    //         ),
    //       );
    //     }).toList(),
    //   ),
    // );
  }
}
