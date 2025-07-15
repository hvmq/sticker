import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/category_provider.dart';
import '../provider/sticker_provider.dart';
import 'navbar_widget.dart';

// ignore: must_be_immutable
class ThumbWidget extends StatelessWidget {
  const ThumbWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double screenSize = MediaQuery.of(context).size.width;
    final catProvider = context.watch<CategoryProvider>();
    final stickerProvider = context.watch<StickerProvider>();

    return Row(
      children: [
        Expanded(
          child: NavBarWidget(
            currentCategory: catProvider.currentCategory,
            categories: catProvider.categories,
            onTap: (String id, String name) {
              catProvider.setCurrentCategory(id);

              if (id == 'Recents') {
                stickerProvider.loadRecentsStickers();
              } else if (id == 'favorite') {
                stickerProvider.loadFavoriteStickers();
              } else {
                stickerProvider.fetchStickersByCategory(name);
              }
            },
          ),
        ),
        SizedBox(width: screenSize * 0.02),
        // const AddStickerWidget(),
        // Padding(
        //   padding: EdgeInsets.only(left: screenSize * 0.03),
        //   child: ShopWidget(
        //     modalSetState: modalSetState,
        //     scrollController: scrollController,
        //     allStickerPro: allStickerPro,
        //     isRecentSelected: isRecentSelected,

        //     allcategory: allCategory,
        //   ),
        // ),
      ],
    );
  }
}
