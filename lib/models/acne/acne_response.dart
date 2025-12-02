// //models/acne/acne_reponse.dart
// class AcneResponseData {
//   final int totalAcne;
//
//   AcneResponseData({required this.totalAcne});
//
//   factory AcneResponseData.fromJson(Map<String, dynamic> json) {
//     return AcneResponseData(totalAcne: json['totalAcne']);
//   }
// }
//
// class AcneResponse {
//   final AcneResponseData data;
//
//   AcneResponse({required this.data});
//
//   factory AcneResponse.fromJson(Map<String, dynamic> json) {
//     return AcneResponse(data: AcneResponseData.fromJson(json['data']));
//   }
// }
class AcneResponseData {
  final int totalAcne;

  AcneResponseData({required this.totalAcne});

  factory AcneResponseData.fromJson(Map<String, dynamic> json) {
    return AcneResponseData(
      totalAcne: json['total_acne'] ?? 0, // ✅ ĐỔI THÀNH 'total_acne' VÀ THÊM ?? 0
    );
  }
}

class AcneResponse {
  final bool success; // ✅ THÊM FIELD success
  final AcneResponseData data;

  AcneResponse({
    required this.success,
    required this.data,
  });

  factory AcneResponse.fromJson(Map<String, dynamic> json) {
    return AcneResponse(
      success: json['success'] ?? false, // ✅ THÊM success
      data: AcneResponseData.fromJson(json['data']),
    );
  }
}