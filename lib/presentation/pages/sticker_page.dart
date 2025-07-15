import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_sticker/presentation/provider/sticker_provider.dart';
import 'package:star_sticker/presentation/widgets/thumb_widget.dart';

import '../widgets/filtered_widget.dart';

// ignore: must_be_immutable
class StickerPage extends StatefulWidget {
  const StickerPage({
    super.key,
    required this.onStickerSelected,
    required this.scrollController,
  });

  final ScrollController scrollController;
  final Function(String stickerUrl)? onStickerSelected;

  @override
  State<StickerPage> createState() => _StickerPageState();
}

class _StickerPageState extends State<StickerPage> {
  bool isRecentSelected = false;
  String currentCategory = '';
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = widget.scrollController;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenSize = MediaQuery.of(context).size.width;
    final stiProvider = context.watch<StickerProvider>();

    return Column(
      children: [
        ThumbWidget(),
        // Padding(
        //   padding: EdgeInsets.only(
        //       top: screenSize * 0.02, bottom: screenSize * 0.01),
        //   child: SearchWidget(),
        // ),
        FilteredWidget(
          scrollController: scrollController,
          onStickerSelected: (sticker) async {
            widget.onStickerSelected?.call(sticker.imagePath);
            await stiProvider.saveToRecentAndReload(sticker);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
