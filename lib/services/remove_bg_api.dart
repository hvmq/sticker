import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:star_sticker/utils/base_url.dart';

class RemoveBgService {
  const RemoveBgService._();

  static final String _apiKey = BaseUrl.remove_bg_token;

  static Future<File?> removeBackground(File imageFile) async {
    // Header: thêm API key để xác thực.
    // File: gửi ảnh từ local (imageFile) với tên trường là image_file.
    // Field size=auto: để dịch vụ tự quyết định kích thước ảnh sau khi xử lý.
    final http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse('https://api.remove.bg/v1.0/removebg'))
          ..headers['X-Api-Key'] = _apiKey
          ..files.add(await http.MultipartFile.fromPath('image_file', imageFile.path))
          ..fields['size'] = 'auto';

    // Gửi request và nhận về response dưới dạng stream,
    // vì ảnh trả về là dạng nhị phân (binary).
    final http.StreamedResponse response = await request.send();
    print('Response data: ${response}');
    if (response.statusCode == 200) {
      // Đọc nội dung ảnh từ stream
      final Uint8List bytes = await response.stream.toBytes();
      // Tạo một file mới cùng thư mục với ảnh gốc, thêm hậu tố '_no_bg.png'
      final File file = File('${imageFile.path}_no_bg.png');
      await file.writeAsBytes(bytes);
      return file;
    } else {
      return null;
    }
  }
}
