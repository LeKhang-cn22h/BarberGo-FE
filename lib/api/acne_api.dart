//api/acne_api.dart
import 'dart:io';
import 'package:http/http.dart' as http;

class AcneApi {
  static const baseUrl = "http://192.168.1.11:8000";

  Future<String> detectAcne({
    required File left,
    required File front,
    required File right,
  }) async {
    print('🌐 Gửi request tới: $baseUrl/acne/detect');

    final uri = Uri.parse("$baseUrl/acne/detect");

    final request = http.MultipartRequest("POST", uri);

    request.files.add(await http.MultipartFile.fromPath("left_image", left.path));
    request.files.add(await http.MultipartFile.fromPath("front_image", front.path));
    request.files.add(await http.MultipartFile.fromPath("right_image", right.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response.body;
  }
}
