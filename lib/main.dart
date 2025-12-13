import 'package:barbergofe/app.dart';
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
  final googleAuthService = GoogleAuthService();
  await googleAuthService.initialize();
  runApp(MyApp(googleAuthService: googleAuthService));
}
