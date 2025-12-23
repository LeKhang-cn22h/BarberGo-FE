import 'dart:convert';
import 'package:http/http.dart' as http;
import 'endpoints/api_config.dart';
import 'endpoints/auth_endpoint.dart';
 class AuthApi{
   Future<String> register({
     required String email,
     required String password,
     required String fullName,
     String? phone,
   }) async {
     final url = ApiConfig.getUrl(AuthEndpoint.authRegister);
     print(' POST: $url');

     try {
       final response = await http.post(
         Uri.parse(url),
         headers: await ApiConfig.getHeaders(),
         body: jsonEncode({
           'email': email,
           'password': password,
           'full_name': fullName,
           if (phone != null) 'phone': phone,
         }),
       ).timeout(ApiConfig.timeout);

       print('Status: ${response.statusCode}');
       print(' Body: ${response.body}');

       if (response.statusCode == 200) {
         print(' Register API Success');
         return response.body;
       } else {
         final errorData = jsonDecode(response.body);
         throw Exception(errorData['detail'] ?? 'Registration failed');
       }
     } catch (e) {
       print(' Register API Error: $e');
       rethrow;
     }
   }

   // ==================== LOGIN ====================

   Future<String> login({
     required String email,
     required String password,
   }) async {
     final url = ApiConfig.getUrl(AuthEndpoint.authLogin);
     print('POST: $url');

     try {
       final response = await http.post(
         Uri.parse(url),
         headers:await ApiConfig.getHeaders(),
         body: jsonEncode({
           'email': email,
           'password': password,
         }),
       ).timeout(ApiConfig.timeout);

       print('Status: ${response.statusCode}');

       if (response.statusCode == 200) {
         print('Login API Success');
         return response.body;
       } else if (response.statusCode == 403) {
         final errorData = jsonDecode(response.body);
         throw Exception(errorData['detail'] ?? 'Email not confirmed');
       } else {
         final errorData = jsonDecode(response.body);
         throw Exception(errorData['detail'] ?? 'Login failed');
       }
     } catch (e) {
       print(' Login API Error: $e');
       rethrow;
     }
   }
    Future<String?> loginGG({
     required String id_token
 }) async{
     final url =ApiConfig.getUrl(AuthEndpoint.googlelogin);
     print('POST: $url');
     try{
        final response= await http.post(Uri.parse(url),
            headers:await ApiConfig.getHeaders(),
            body: jsonEncode({
              'id_token':id_token
            })
        ).timeout(ApiConfig.timeout);
        print('Status: ${response.statusCode}');
        if (response.statusCode == 200) {
          return response.body;
        } else {
          print(' API Error: ${response.body}');
          throw Exception('Google login failed: ${response.statusCode} - ${response.body}');
        }
     }catch (e){
       print('Login GG API Error: $e');
       rethrow;
     }
    }

   // ==================== FORGOT PASSWORD ====================

   Future<String> forgotPassword({required String email}) async {
     final url = ApiConfig.getUrl(AuthEndpoint.authForgotPassword);
     print('POST: $url');

     try {
       final response = await http.post(
         Uri.parse(url),
         headers:await ApiConfig.getHeaders(),
         body: jsonEncode({'email': email}),
       ).timeout(ApiConfig.timeout);

       if (response.statusCode == 200) {
         return response.body;
       } else {
         final errorData = jsonDecode(response.body);
         throw Exception(errorData['detail'] ?? 'Failed to send reset email');
       }
     } catch (e) {
       print(' Forgot Password API Error: $e');
       rethrow;
     }
   }

   // ==================== RESET PASSWORD ====================

   Future<String> resetPassword({
     required String email,
     required String token,
     required String newPassword,
   }) async {
     final url = ApiConfig.getUrl(AuthEndpoint.authResetPassword);
     print('POST: $url');

     try {
       final response = await http.post(
         Uri.parse(url),
         headers:await ApiConfig.getHeaders(),
         body: jsonEncode({
           'email': email,
           'token': token,
           'new_password': newPassword,
         }),
       ).timeout(ApiConfig.timeout);

       if (response.statusCode == 200) {
         return response.body;
       } else {
         final errorData = jsonDecode(response.body);
         throw Exception(errorData['detail'] ?? 'Password reset failed');
       }
     } catch (e) {
       print('Reset Password API Error: $e');
       rethrow;
     }
   }

   // ==================== RESEND CONFIRMATION ====================

   Future<String> resendConfirmation({required String email}) async {
     final url = ApiConfig.getUrl(AuthEndpoint.authResendConfirmation);
     print('🌐 POST: $url');

     try {
       final response = await http.post(
         Uri.parse(url),
         headers:await ApiConfig.getHeaders(),
         body: jsonEncode({'email': email}),
       ).timeout(ApiConfig.timeout);

       if (response.statusCode == 200) {
         return response.body;
       } else {
         final errorData = jsonDecode(response.body);
         throw Exception(errorData['detail'] ?? 'Failed to resend email');
       }
     } catch (e) {
       print('Resend Confirmation API Error: $e');
       rethrow;
     }
   }

   // ==================== LOGOUT ====================

   Future<void> logout() async {
     print('ℹClient-side logout (no API call)');
     // Backend không có endpoint logout
   }
 }