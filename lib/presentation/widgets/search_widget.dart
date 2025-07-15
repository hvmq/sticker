import "package:flutter/material.dart";

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double screenSize = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 40,
      child: TextFormField(
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black,
        onChanged: (String query) {
          // print('search query: $query');
          // if (query.trim().isEmpty) {
          //   onEmpty();
          // } else {
          //   final match = categories.firstWhere(
          //     (cate) {
          //       String name = '';
          //       for (var i = 0; i < categoriesName.length; i++) {
          //         if (cate == categoriesName[i].id) {
          //           name = categoriesName[i].name;
          //           break;
          //         }
          //       }
          //       final words = name.toLowerCase().split(RegExp(r'\s+'));
          //       return words.any((word) => word.contains(query.toLowerCase()));
          //     },
          //     orElse: () => '',
          //   );

          //   if (match.isNotEmpty) {
          //     onMatched(match);
          //   }
          // }
        },
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide.none,
          ),
          hintText: 'Search stickers',
          filled: true,
          fillColor: Colors.grey[100],
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: screenSize * 0.03),
            child: const Icon(Icons.search, color: Colors.grey),
          ),
          prefixIconConstraints: const BoxConstraints(),
        ),
      ),
    );
  }
}
