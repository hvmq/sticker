import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:star_sticker/models/category.dart';
import 'package:star_sticker/utils/base_url.dart';

import '../utils/pagination_helper.dart';

class CategoryApi {
  const CategoryApi._(); // private constructor

  static final String _baseUrl = '${BaseUrl.stickerUrl}/category';

  static final Map<String, String> _headers = {
    'apikey': BaseUrl.apiKey,
    'Authorization': 'Bearer ${BaseUrl.apiKey}',
  };

  /// GET /sticker/category
  static Future<List<Category>> fetchCategories({int page = 1}) async {
    final uri = Uri.parse('$_baseUrl?page=$page&per_page=20');
    debugPrint('[API] GET $uri');
    // debugPrint('[API] Headers: $_headers');

    final response = await http.get(uri, headers: _headers);

    debugPrint('[API] Response status: ${response.statusCode}');
    debugPrint('[API] Response body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data']?['data'] ?? [];

      return (data as List).map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception(
          'API - Failed to load categories. Status: ${response.statusCode}');
    }
  }

  static Future<List<Category>> fetchAllCategories() async {
    return fetchPaginatedApi<Category>(
        buildUri: (page) => Uri.parse('$_baseUrl?page=$page'),
        headers: _headers,
        fromJson: (json) => Category.fromJson(json));
  }

  /// POST /sticker/category
  static Future<Category> createCategory(Category category) async {
    final uri = Uri.parse(_baseUrl);
    final bodyJson = jsonEncode(category.toJson());

    debugPrint('[API] POST $uri');
    // debugPrint('[API] Headers: $_headers');
    debugPrint('[API] Body: $bodyJson');

    final response = await http.post(
      uri,
      headers: {
        ..._headers,
        'Content-Type': 'application/json',
      },
      body: bodyJson,
    );

    debugPrint('[API] Response status: ${response.statusCode}');
    debugPrint('[API] Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final json = decoded['data'];
      return Category.fromJson(json);
    } else {
      throw Exception(
          'API - Failed to create category: ${response.statusCode} ${response.body}');
    }
  }
}
