// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
//
//
// import '../models/category.dart';
// import '../models/sticker.dart';
// import '../presentation/provider/sticker_provider.dart';
//
// class SliverFutureBuilder extends StatelessWidget {
//   const SliverFutureBuilder({
//     super.key,
//     required this.category,
//     required this.buildSection,
//   });
//
//   final Category category;
//   final List<Widget> Function({
//   required String id,
//   required String name,
//   required List<Sticker> stickers,
//   bool isLocked,
//   bool showCount,
//   bool isViewOnly,
//   }) buildSection;
//
//   @override
//   Widget build(BuildContext context) {
//     return SliverToBoxAdapter(
//       child: FutureBuilder<List<Sticker>>(
//         future: context.read<StickerProvider>().fetchStickersByCategory(category.name),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Padding(
//               padding: EdgeInsets.all(16),
//               child: Center(child: CircularProgressIndicator()),
//             );
//           } else if (snapshot.hasError) {
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text('❌ Lỗi tải ${category.name}'),
//             );
//           } else {
//             final stickers = snapshot.data ?? [];
//
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: buildSection(
//                 id: category.id,
//                 name: category.name,
//                 stickers: stickers,
//                 isLocked: false,
//                 showCount: true,
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
