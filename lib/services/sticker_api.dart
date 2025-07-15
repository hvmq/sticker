import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:star_sticker/models/sticker.dart';
import 'package:star_sticker/utils/base_url.dart';

import '../sticker_sdk.dart';
import '../utils/pagination_helper.dart';

class StickerApi {
  StickerApi._(); // private constructor

  static final String _baseUrl = BaseUrl.stickerUrl;
  static final Map<String, String> _headers = {
    'apikey': BaseUrl.apiKey,
    'Authorization': 'Bearer ${BaseUrl.apiKey}',
  };

  static Future<List<Sticker>> fetchStickersByCategory(
      String categoryName, int page) async {
    final uri =
        Uri.parse('$_baseUrl?category=$categoryName&page=$page&per_page=30');
    debugPrint('[API] GET $uri');

    final response = await http.get(uri, headers: _headers);
    debugPrint('[API] Response status: ${response.statusCode}');
    debugPrint('[API] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data']?['data'] ?? [];
      return (data as List).map((e) => Sticker.fromJson(e)).toList();
    } else {
      throw Exception(
        'API - Failed to load stickers by category name: ${response.statusCode} ${response.body}',
      );
    }
  }

  static Future<List<Sticker>> fetchAllStickersByCategory(String categoryName) {
    return fetchPaginatedApi<Sticker>(
      buildUri: (page) =>
          Uri.parse('$_baseUrl?category=$categoryName&page=$page'),
      headers: _headers,
      fromJson: (json) => Sticker.fromJson(json),
    );
  }

  /// Lọc premium sau khi fetch tất cả
  static Future<List<Sticker>> fetchPremiumStickers() async {
    final uri = Uri.parse(_baseUrl);
    debugPrint('[API] GET $uri');
    // debugPrint('[API] Headers: $_headers');

    final response = await http.get(uri, headers: _headers);
    debugPrint('[API] Response status: ${response.statusCode}');
    debugPrint('[API] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data']['data'] as List;
      final premium = data
          .map((e) => Sticker.fromJson(e))
          .where((s) => s.isPremium)
          .toList();
      return premium;
    } else {
      throw Exception(
          'API - Failed to load premium stickers: ${response.statusCode} ${response.body}');
    }
  }

  /// POST Upload sticker (POST multipart)
  static Future<bool> uploadUserSticker({
    required int createdBy,
    required File imageFile,
  }) async {
    const int customCategoryId = 11;

    final uri = Uri.parse(_baseUrl);
    debugPrint('[Sticker API] POST (multipart) $uri');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_headers)
      ..fields['created_by'] = createdBy.toString()
      ..fields['category_id'] = customCategoryId.toString()
      ..files
          .add(await http.MultipartFile.fromPath('image_path', imageFile.path));

    try {
      final response =
          await request.send().timeout(const Duration(seconds: 10));
      debugPrint('[Sticker API] Response status: ${response.statusCode}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } on TimeoutException catch (_) {
      debugPrint('[Sticker API] Timeout sau 10s');
      return false;
    } catch (e) {
      debugPrint('[Sticker API] Lỗi: $e');
      return false;
    }
  }

  /// GET /sticker/favorite?created_by=xxx
  static Future<List<Sticker>> fetchFavorites() async {
    final userId = StickerSDK.userId;
    final uri = Uri.parse('$_baseUrl/favorite?created_by=$userId');
    debugPrint('[API] GET $uri');
    // debugPrint('[API] Headers: $_headers');

    final response = await http.get(uri, headers: _headers);
    debugPrint('[API] Response status: ${response.statusCode}');
    debugPrint('[API] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      return data.map((e) => Sticker.fromJson(e)).toList();
    } else {
      throw Exception(
          'API - Failed to load favorite stickers: ${response.statusCode} ${response.body}');
    }
  }

  /// POST /sticker/favorite/{id}
  static Future<bool> toggleFavoriteSticker({
    required String stickerId,
  }) async {
    final userId = StickerSDK.userId;
    final uri = Uri.parse('$_baseUrl/favorite/$stickerId');

    debugPrint('[API] POST $uri');
    // debugPrint('[API] Headers: $_headers');
    debugPrint('[API] Body: ${jsonEncode({'created_by': userId})}');

    final response = await http.post(
      uri,
      headers: {
        ..._headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'created_by': userId}),
    );

    debugPrint('[API] Response status: ${response.statusCode}');
    debugPrint('[API] Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
          'API - Failed to toggle favorite: ${response.statusCode} ${response.body}');
    }

    final body = jsonDecode(response.body);
    final isFavorite = body['data']?['is_favorite'] ?? false;
    return isFavorite;
  }
}
