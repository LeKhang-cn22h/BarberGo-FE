import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Stream<GoogleSignInAuthenticationEvent> get authEvents =>
      _googleSignIn.authenticationEvents;
  Future<void> initialize() async {
    await _googleSignIn.initialize(
      clientId: dotenv.env['Web_Client_ID']!,
      serverClientId: dotenv.env['Web_Client_ID']!, // optional
    );

    _googleSignIn.attemptLightweightAuthentication();
  }

  Future<void> signIn() async {
    await _googleSignIn.authenticate();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}