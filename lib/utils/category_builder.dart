import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:star_sticker/models/category.dart';
import '../presentation/provider/category_provider.dart';

String getCategoryName(BuildContext context, Category category) {
  final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

  // Nếu là bộ sưu tập (không nằm trong CategoryProvider) → trả luôn category.name
  final exists = categoryProvider.categories.any((cat) => cat.id == category.id);
  if (!exists) return category.name;

  final match = categoryProvider.categories
      .firstWhere((cat) => cat.id == category.id, orElse: () => category);

  return match.name;
}
