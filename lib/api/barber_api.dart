import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'endpoints/api_config.dart';
import '../core/utils/auth_storage.dart';
import '../models/barber/barber_model.dart';
import 'endpoints/barber_endpoint.dart';
import 'package:http_parser/http_parser.dart';
class BarberApi {

  // ==================== GET TOP BARBERS ====================
  Future<GetAllBarbersResponse> getTopBarbers({int limit = 2}) async {
    final url = Uri.parse(ApiConfig.getUrl(BarberEndpoint.barberGetTop)).replace(
      queryParameters: {'limit': limit.toString()},
    );

    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        print('Response type: ${jsonResponse.runtimeType}');

        // Xử lý khi API trả về List (mảng)
        if (jsonResponse is List) {
          print('API returned a List directly, converting to GetAllBarbersResponse');

          final List<BarberModel> barbersList = jsonResponse
              .map<BarberModel>((item) {
            print('Parsing barber item: $item');
            return BarberModel.fromJson(item);
          })
              .toList();

          print('Successfully parsed ${barbersList.length} barbers');

          return GetAllBarbersResponse(
            success: true,
            message: null,
            barbers: barbersList,
            statusCode: 200,
          );
        }
        // Xử lý khi API trả về Map (object)
        else if (jsonResponse is Map<String, dynamic>) {
          print('API returned a Map, using fromJson');
          return GetAllBarbersResponse.fromJson(jsonResponse);
        }
        // Trường hợp khác
        else {
          print('Unknown response format: ${jsonResponse.runtimeType}');
          throw Exception('Invalid response format from server');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get top barbers');
      }
    } catch (e) {
      print('Get top barbers error: $e');
      rethrow;
    }
  }

  // ==================== GET ALL AREAS ====================
  Future<List<String>> getAreas() async {
    final url = ApiConfig.getUrl(BarberEndpoint.barberGetAreas);
    print('GET: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers:await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          return jsonResponse.cast<String>();
        }
        return [];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get areas');
      }
    } catch (e) {
      print('Get areas error: $e');
      rethrow;
    }
  }
  // api/barber_api.dart
  Future<BarberGetResponse> getBarberById(String id) async {
    final url = ApiConfig.getUrlWithId(BarberEndpoint.barberGetById, id);
    print('GET: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers:await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        print('Response type: ${jsonResponse.runtimeType}');

        // Xử lý để lấy SINGLE barber
        BarberModel? barber;
        bool success = true;
        String? message;

        if (jsonResponse is List) {
          print('API returned a List for single barber');
          if (jsonResponse.isEmpty) {
            throw Exception('Barber not found');
          }
          barber = BarberModel.fromJson(jsonResponse.first);
        } else if (jsonResponse is Map<String, dynamic>) {
          print('API returned a Map for single barber');

          // Kiểm tra cấu trúc response
          if (jsonResponse.containsKey('success')) {
            success = jsonResponse['success'] ?? true;
            message = jsonResponse['message'];
          }

          // Tìm barber trong response
          if (jsonResponse['data'] != null) {
            final data = jsonResponse['data'];
            if (data is Map<String, dynamic>) {
              barber = BarberModel.fromJson(data);
            } else if (data is List && data.isNotEmpty) {
              barber = BarberModel.fromJson(data.first);
            }
          } else if (jsonResponse['barber'] != null && jsonResponse['barber'] is Map<String, dynamic>) {
            barber = BarberModel.fromJson(jsonResponse['barber']);
          } else {
            // Nếu response là barber object trực tiếp
            try {
              barber = BarberModel.fromJson(jsonResponse);
            } catch (e) {
              print('Cannot parse as barber: $e');
            }
          }
        }

        if (barber == null) {
          throw Exception('Barber data not found in response');
        }

        print(' Successfully parsed barber: ${barber.name}');

        // TRẢ VỀ BarberGetResponse với SINGLE barber
        return BarberGetResponse(
          success: success,
          message: message,
          barber: barber, // SINGLE barber
          statusCode: 200,
        );

      } else if (response.statusCode == 404) {
        throw Exception('Barber not found (404)');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get barber details');
      }
    } catch (e) {
      print('Get barber by ID error: $e');
      rethrow;
    }
  }
  //======update location barber=====
  Future<Map<String, dynamic>> updateBarberLocation({
    required String barberId,
    required double lat,
    required double lng,
  }) async {
    final url = Uri.parse(
      ApiConfig.getUrlWithId(
        BarberEndpoint.barberUpdateLocation,
        barberId,
      ),
    );

    try {
      final body = {
        "location": {
          "lat": lat,
          "lng": lng,
        }
      };

      final response = await http
          .patch(
        url,
        headers: await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
        body: jsonEncode(body),
      )
          .timeout(ApiConfig.timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Update barber location failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Update barber location error: $e');
      rethrow;
    }
  }


  // ==================== GET BARBERS BY AREA ====================
  Future<GetAllBarbersResponse> getBarbersByArea(String area) async {
    final url = Uri.parse(ApiConfig.getUrl(BarberEndpoint.barberGetByArea)).replace(
      queryParameters: {'area': area},
    );
    print('GET: $url');

    try {
      final response = await http.get(
        url,
        headers:await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Thêm debug

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        // Debug: In ra kiểu dữ liệu của response
        print('Response type: ${jsonResponse.runtimeType}');

        // Xử lý khi API trả về List (mảng)
        if (jsonResponse is List) {
          print('API returned a List directly, converting to GetAllBarbersResponse');

          // Convert List to List<BarberModel>
          final List<BarberModel> barbersList = jsonResponse
              .map<BarberModel>((item) => BarberModel.fromJson(item))
              .toList();

          // Tạo GetAllBarbersResponse từ List
          return GetAllBarbersResponse(
            success: true,
            message: null,
            barbers: barbersList,
            statusCode: 200,
          );
        }
        // Xử lý khi API trả về Map (object)
        else if (jsonResponse is Map<String, dynamic>) {
          print('API returned a Map, using fromJson');
          return GetAllBarbersResponse.fromJson(jsonResponse);
        }
        // Trường hợp khác
        else {
          print('Unknown response format: ${jsonResponse.runtimeType}');
          throw Exception('Invalid response format from server');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get barbers by area');
      }
    } catch (e) {
      print('Get barbers by area error: $e');
      rethrow;
    }
  }
  Future<GetAllBarbersResponse> getBarberByUser(String user_Id) async{
    final url =Uri.parse(ApiConfig.getUrlWithId(BarberEndpoint.barberGetofUser, user_Id));
    print('GET: $url');
    try{
      final response = await http.get(
        url,
        headers:await ApiConfig.getHeaders(
          token: await AuthStorage.getAccessToken(),
        ),
      ).timeout(ApiConfig.timeout);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonResponse = json.decode(response.body);

        // Debug: In ra kiểu dữ liệu của response
        print('Response type: ${jsonResponse.runtimeType}');

        // Xử lý khi API trả về List (mảng)
        if (jsonResponse is List) {
          print('API returned a List directly, converting to GetAllBarbersResponse');

          // Convert List to List<BarberModel>
          final List<BarberModel> barbersList = jsonResponse
              .map<BarberModel>((item) => BarberModel.fromJson(item))
              .toList();

          // Tạo GetAllBarbersResponse từ List
          return GetAllBarbersResponse(
            success: true,
            message: null,
            barbers: barbersList,
            statusCode: 200,
          );
        }
        // Xử lý khi API trả về Map (object)
        else if (jsonResponse is Map<String, dynamic>) {
          print('API returned a Map, using fromJson');
          return GetAllBarbersResponse.fromJson(jsonResponse);
        }
        // Trường hợp khác
        else {
          print('Unknown response format: ${jsonResponse.runtimeType}');
          throw Exception('Invalid response format from server');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get barbers by area');
      }
    } catch (e) {
      print('Get barbers by area error: $e');
      rethrow;
    }
  }
  Future<BarberUpdateResponse> updateBarber(
      String barberId,
      BarberUpdateRequest request,
      ) async {
    final url = Uri.parse(
      ApiConfig.getUrlWithId(BarberEndpoint.barberUpdateId, barberId),
    );

    print('🔵 [API] PUT $url');
    print('🔵 [API] Request data: ${request.toJson()}');

    try {
      final multipartRequest = http.MultipartRequest('PUT', url);

      final headers = await ApiConfig.getMultipartHeaders(
        token: await AuthStorage.getAccessToken(),
      );
      multipartRequest.headers.addAll(headers);

      if (request.name != null) {
        multipartRequest.fields['name'] = request.name!;
        print('🔵 [API] Added name: "${request.name}"');
      }

      if (request.address != null) {
        multipartRequest.fields['address'] = request.address!;
        print('🔵 [API] Added address: "${request.address}"');
      }

      if (request.area != null) {
        multipartRequest.fields['area'] = request.area!;
        print('🔵 [API] Added area: "${request.area}"');
      }

      if (request.rank != null) {
        multipartRequest.fields['rank'] = request.rank.toString();
        print('🔵 [API] Added rank: ${request.rank}');
      }

      if (request.status != null) {
        multipartRequest.fields['status'] = request.status.toString();
        print('🔵 [API] Added status: ${request.status}');
      }

      if (request.location != null) {
        final locationJson = jsonEncode(request.location!.toJson());
        multipartRequest.fields['location'] = locationJson;
        print('🔵 [API] Added location: $locationJson');
      }

      if (request.imagePath != null && request.imagePath!.isNotEmpty) {
        final file = File(request.imagePath!);
        if (await file.exists()) {
          final stream = http.ByteStream(file.openRead());
          final length = await file.length();
          final filename = request.imagePath!.split('/').last;

          final multipartFile = http.MultipartFile(
            'image',
            stream,
            length,
            filename: filename,
            contentType: MediaType('image', _getImageExtension(filename)),
          );

          multipartRequest.files.add(multipartFile);
          print('🔵 [API] Added image: $filename');
        }
      }

      print('🔵 [API] Sending request...');

      final streamedResponse = await multipartRequest.send().timeout(
        ApiConfig.uploadTimeout,
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('🔵 [API] Response status: ${response.statusCode}');
      print('🔵 [API] Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonResponse = json.decode(response.body);

        // ✅ KIỂM TRA RESPONSE FORMAT
        print('🔵 [API] Response type: ${jsonResponse.runtimeType}');

        // Backend trả về TRỰC TIẾP barber object (không có wrapper)
        // Cần wrap vào BarberUpdateResponse format
        final barberUpdateResponse = BarberUpdateResponse(
          success: true,
          message: 'Barber updated successfully',
          barber: BarberModel.fromJson(jsonResponse),
          statusCode: response.statusCode,
        );

        print('🔵 [API] Parsed barber: ${barberUpdateResponse.barber?.name}');

        return barberUpdateResponse;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Update barber failed');
      }
    } catch (e) {
      print('🔴 [API] Error: $e');
      rethrow;
    }
  }

  String _getImageExtension(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'webp':
        return 'webp';
      default:
        return 'jpeg';
    }
  }
  Future<void> deactivatedBarber(String barber_id) async{
    final url =Uri.parse(ApiConfig.getUrlWithIdAndAction(BarberEndpoint.barberDeactivateId, barber_id, 'deactivate'));
    print('deactivate $url');
    try{
      final response = await http.patch(url,
      headers: await ApiConfig.getHeaders(
        token: await AuthStorage.getAccessToken()
      ),
      ).timeout(ApiConfig.timeout);
    }catch (e){
      print('loi $e');
      rethrow;
    }

  }

}