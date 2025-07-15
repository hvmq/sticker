import 'dart:convert';

import 'category.dart';

class Sticker {
  final String id;
  final String categoryId;
  final String imagePath;
  final bool isPremium;
  final String status;
  final int usedCount;
  final List<String> tags;
  final Category? category;
  final int createdBy;
  final int? collectionId;

  const Sticker(
      {required this.id,
      required this.categoryId,
      required this.imagePath,
      required this.isPremium,
      required this.status,
      required this.usedCount,
      required this.tags,
      this.category,
      required this.createdBy,
      this.collectionId});

  factory Sticker.empty() {
    return Sticker(
      id: '',
      imagePath: '',
      categoryId: '',
      isPremium: false,
      status: '',
      usedCount: 0,
      tags: [],
      createdBy: 0,
    );
  }

  factory Sticker.fromJson(Map<String, dynamic> json, {int? collectionId}) {
    return Sticker(
      id: json['id'].toString(),
      categoryId: json['category_id'].toString(),
      imagePath: json['image_path'] as String,
      isPremium: (json['is_premium'] == 1),
      status: json['status'] as String? ?? 'active',
      usedCount: json['used_count'] is int ? json['used_count'] : int.tryParse(json['used_count'].toString()) ?? 0,
      tags: _parseTags(json['tags']),
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      createdBy: json['created_by'] is int ? json['created_by'] : int.tryParse(json['created_by'].toString()) ?? 0,
      collectionId: collectionId,
    );
  }

  static List<Sticker> fromListJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Sticker.fromJson(json)).toList();
  }

  static List<String> _parseTags(dynamic rawTags) {
    try {
      if (rawTags is String) {
        final parsed = jsonDecode(rawTags);
        return (parsed as List).map((e) => e.toString()).toList();
      } else if (rawTags is List) {
        return rawTags.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'image_path': imagePath,
      'is_premium': isPremium ? 1 : 0,
      'status': status,
      'used_count': usedCount,
      'tags': jsonEncode(tags),
      'category': category?.toJson(), // nullable
      'created_by': createdBy,
    };
  }

  bool get isActive => status == 'active';
}
