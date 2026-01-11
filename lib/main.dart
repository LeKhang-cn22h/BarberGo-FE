import 'package:barbergofe/app.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:barbergofe/services/fcm_service.dart';
import 'package:barbergofe/services/simple_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Nhận thông báo ngầm: ${message.messageId}");
}
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _restoreSession();
  final session = Supabase.instance.client.auth.currentSession;
  if (session != null) {
    print(' [MAIN] User đang đăng nhập, bắt đầu lấy FCM Token...');
    try {
      // Gọi service bạn vừa viết để lấy token và lưu vào bảng users/profiles
      await FcmService().initNotification();
    } catch (e) {
      print(' [MAIN] Lỗi khởi tạo FCM: $e');
    }
  } else {
    print('[MAIN] Chưa có user đăng nhập, bỏ qua lấy FCM Token');
  }

  final googleAuthService = GoogleAuthService();
  await googleAuthService.initialize();
  await SimpleNotificationService.init();

  runApp(MyApp(googleAuthService: googleAuthService));
}
/// Restore Supabase session từ AuthStorage
Future<void> _restoreSession() async {
  try {
    final accessToken = await AuthStorage.getAccessToken();
    final refreshToken = await AuthStorage.getRefreshToken();

    if (accessToken != null && refreshToken != null) {
      print('Restoring session from storage...');

      // Restore session vào Supabase
      await Supabase.instance.client.auth.setSession(refreshToken);

      print('Session restored successfully');
    } else {
      print(' No saved session found');
    }
  } catch (e) {
    print(' Failed to restore session: $e');
    // Nếu restore thất bại, clear storage
    await AuthStorage.clearAll();
  }
}