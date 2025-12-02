import 'dart:convert';
import 'dart:io';
import '../api/acne_api.dart';
import '../models/acne_response.dart';

class AcneService {
  final AcneApi api = AcneApi();

  Future<AcneResponse> detectAcne(
      File left, File front, File right) async {
    final jsonString =
    await api.detectAcne(left: left, front: front, right: right);

    final data = jsonDecode(jsonString);

    return AcneResponse.fromJson(data);
  }
}
