import 'package:barbergofe/app.dart';
import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,  // Anon Key
  );
  await _restoreSession();

  final googleAuthService = GoogleAuthService();
  await googleAuthService.initialize();
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