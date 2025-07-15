import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/sticker.dart';

class RecentStickerService {
  static const String _key = 'recent_sticker_ids';
  static const int _maxRecent = 100;

  static Future<void> saveToRecent(List<Sticker> newStickers) async {
    final prefs = await SharedPreferences.getInstance();

    // Load danh sách hiện tại
    final currentJson = prefs.getString(_key);
    final currentList = currentJson != null ? Sticker.fromListJson(json.decode(currentJson)) : <Sticker>[];

    // Gộp + ưu tiên sticker mới lên đầu, dùng Map để loại trùng
    final combinedList = [
      ...newStickers.reversed,
      ...currentList,
    ];

    final uniqueList = {for (var s in combinedList) s.id: s}.values.toList();

    // Giới hạn số lượng recent
    final limitedList = uniqueList.take(_maxRecent).toList();

    // Lưu lại
    final encoded = json.encode(limitedList.map((s) => s.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<List<Sticker>> getRecentList() async {
    final prefs = await SharedPreferences.getInstance();
    final localStickerList = prefs.getString(_key);
    if (localStickerList == null) return [];

    final decoded = json.decode(localStickerList);
    return Sticker.fromListJson(decoded);
  }
}
