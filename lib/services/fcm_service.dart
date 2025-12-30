import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmService {
  final _supabase = Supabase.instance.client;
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Gọi hàm này ngay sau khi Login thành công (trong _handleLogin)
  Future<void> initNotification() async {
    // 1. Xin quyền
    await _firebaseMessaging.requestPermission();

    // 2. Lấy Token của máy này
    final fcmToken = await _firebaseMessaging.getToken();
    print(' FCM TOKEN: $fcmToken');

    // 3. Lưu lên Supabase nếu user đã đăng nhập
    final user = _supabase.auth.currentUser;
    if (user != null && fcmToken != null) {
      await _saveTokenToDatabase(user.id, fcmToken);
    }

    // 4. Lắng nghe tin nhắn khi app đang mở
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Nhận tin nhắn khi app mở: ${message.notification?.title}');
      // Ở đây có thể hiện SnackBar hoặc Dialog báo có đơn mới
    });
  }

  Future<void> _saveTokenToDatabase(String userId, String token) async {
    // Đảm bảo bảng profiles của bạn đã có cột 'fcm_token'
    try {
      await _supabase.from('users').update({
        'fcm_token': token,
      }).eq('id', userId);
      print(' Đã lưu FCM Token lên Supabase');
    } catch (e) {
      print(' Lỗi lưu token: $e');
    }
  }
}