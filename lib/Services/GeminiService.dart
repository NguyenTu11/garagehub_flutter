import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utils.dart';

class GeminiService {
  Future<String> askGemini(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('${Utils.baseUrl}/gemini/ask'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Utils.token}',
        },
        body: json.encode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'] ?? 'Không có phản hồi từ AI';
      }
      return 'Đã xảy ra lỗi khi kết nối với AI';
    } catch (e) {
      print('Error asking Gemini: $e');
      return 'Lỗi: $e';
    }
  }
}
