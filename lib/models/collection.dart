import 'package:star_sticker/models/sticker.dart';

class Collection {
  final int id;
  final int createdBy;
  final String name;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? stickersCount;
  final List<Sticker> stickers;

  Collection({
    required this.id,
    required this.createdBy,
    required this.name,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
    this.stickersCount,
    required this.stickers,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    final int id = json['id'];
    final List<Sticker> stickers = (json['stickers'] as List<dynamic>? ?? [])
        .map((stickerJson) => Sticker.fromJson(stickerJson, collectionId: id))
        .toList();

    return Collection(
      id: id,
      createdBy: int.parse(json['created_by'].toString()),
      name: json['name'],
      slug: json['slug'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      stickersCount: json['stickers_count'],
      stickers: stickers,
    );
  }

  Collection copyWith({
    int? id,
    int? createdBy,
    String? name,
    String? slug,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? stickersCount,
    List<Sticker>? stickers,
  }) {
    return Collection(
      id: id ?? this.id,
      createdBy: createdBy ?? this.createdBy,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stickersCount: stickersCount ?? this.stickersCount,
      stickers: stickers ?? this.stickers,
    );
  }

  factory Collection.empty() {
    return Collection(
      id: -1,
      createdBy: -1,
      name: '',
      slug: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      stickers: [],
      stickersCount: 0,
    );
  }
}
