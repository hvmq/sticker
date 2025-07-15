import 'dart:convert';
import 'package:http/http.dart' as http;

/// Generic response model cho API phân trang
class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });
}

/// Hàm dùng chung để gọi API phân trang và trả về toàn bộ danh sách
Future<List<T>> fetchPaginatedApi<T>({
  required Uri Function(int page) buildUri,
  required Map<String, String> headers,
  required T Function(Map<String, dynamic>) fromJson,
  String dataKey = 'data',
  String paginatorKey = 'paginator',
}) async {
  int currentPage = 1;
  int lastPage = 1;
  final List<T> allItems = [];

  do {
    final uri = buildUri(currentPage);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Pagination API failed: ${response.statusCode} ${response.body}');
    }

    final body = jsonDecode(response.body);
    final dataList = body['data']?[dataKey] ?? [];
    final paginator = body['data']?[paginatorKey];

    allItems.addAll((dataList as List).map((e) => fromJson(e)).toList());

    currentPage = paginator['current_page'] + 1;
    lastPage = paginator['last_page'];
  } while (currentPage <= lastPage);

  return allItems;
}
