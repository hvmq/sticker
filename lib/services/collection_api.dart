import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/collection.dart';
import '../utils/base_url.dart';

class CollectionApi {
  CollectionApi._();

  static final String _baseUrl = BaseUrl.stickerUrl;
  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'apikey': BaseUrl.apiKey,
    'Authorization': 'Bearer ${BaseUrl.apiKey}',
  };

  static Future<Collection> createCollection({
    required int userId,
    required String name,
  }) async {
    final uri = Uri.parse('$_baseUrl/collection');
    debugPrint('[API] POST $uri');

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'created_by': userId,
        'name': name,
      }),
    );

    debugPrint('[API] Response: ${response.statusCode} ${response.body}');

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['status'] == 201) {
      return Collection.fromJson(body['data']);
    } else if (response.statusCode == 422 || body['status'] == 409) {
      throw Exception('Tên bộ sưu tập đã tồn tại');
    } else {
      throw Exception('Không thể tạo bộ sưu tập. Mã lỗi: ${response.statusCode}');
    }
  }

  static Future<void> addStickerToCollection({
    required int collectionId,
    required int userId,
    required String stickerId,
  }) async {
    final url = Uri.parse('$_baseUrl/collection/$collectionId');
    debugPrint('[API] POST $url');
    debugPrint('[API] Body: {created_by: $userId, sticker_id: $stickerId}');

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'created_by': userId,
        'sticker_id': stickerId,
      }),
    );

    debugPrint('[API] Status: ${response.statusCode}');
    debugPrint('[API] Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to add sticker to collection: ${response.body}');
    }
  }

  static Future<void> updateStickerInCollection({
    required int collectionId,
    required int userId,
    required String newStickerId,
    required String oldStickerId,
  }) async {
    final url = Uri.parse('$_baseUrl/collection/$collectionId');
    debugPrint('[API] PUT $url');
    debugPrint('[API] Body: {created_by: $userId, sticker_id: $newStickerId, old_sticker_id: $oldStickerId}');

    final response = await http.put(
      url,
      headers: _headers,
      body: jsonEncode({
        'created_by': userId,
        'sticker_id': newStickerId,
        'old_sticker_id': oldStickerId,
      }),
    );

    debugPrint('[API] Status: ${response.statusCode}');
    debugPrint('[API] Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update sticker in collection: ${response.body}');
    }
  }

  static Future<void> deleteCollection(int collectionId) async {
    final url = Uri.parse('$_baseUrl/collection/remove/$collectionId');
    debugPrint('[API] DELETE $url');

    final response = await http.delete(
      url,
      headers: _headers,
    );

    debugPrint('[API] Status: ${response.statusCode}');
    debugPrint('[API] Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete collection: ${response.body}');
    }
  }

  static Future<List<Collection>> getCollectionsByUser(int userId) async {
    final uri = Uri.parse('$_baseUrl/collection?created_by=$userId');
    debugPrint('[API] GET $uri');

    final response = await http.get(uri, headers: _headers);
    debugPrint('[API] Response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final list = json['data'] as List;
      return list.map((e) => Collection.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load collections: ${response.statusCode}');
    }
  }

  static Future<void> updateCollection({
    required int collectionId,
    required int userId,
    required String name,
  }) async {
    final url = Uri.parse('$_baseUrl/collection/$collectionId');
    debugPrint('[API] PUT $url');

    final response = await http.put(
      url,
      headers: _headers,
      body: jsonEncode({
        'created_by': userId,
        'name': name,
      }),
    );

    debugPrint('[API] Status: ${response.statusCode}');
    debugPrint('[API] Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Cập nhật bộ sưu tập thất bại: ${response.body}');
    }
  }

  static Future<void> removeStickerFromCollection({
    required int collectionId,
    required String stickerId,
    required int userId,
  }) async {
    final url = Uri.parse('$_baseUrl/collection/$collectionId/sticker/$stickerId');
    debugPrint('[API] DELETE $url');

    final response = await http.delete(
      url,
      headers: _headers,
      body: jsonEncode({'created_by': userId}),
    );

    debugPrint('[API] Status: ${response.statusCode}');
    debugPrint('[API] Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to remove sticker from collection: ${response.body}');
    }
  }
}
