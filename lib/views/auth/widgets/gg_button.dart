import 'package:barbergofe/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
class GgButton extends StatelessWidget {
  final AuthViewModel authViewModel;

  const GgButton({super.key, required this.authViewModel});

  @override
  Widget build(BuildContext context) {
    final googleAuthService = Provider.of<GoogleAuthService>(context);

    return Center(
      child: Column(
        children: [
          ElevatedButton(onPressed: () async {
           final success= await authViewModel.loginWithGG();
           if (success){
             context.goNamed('home');
           }else if(!success && context.mounted){
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Đăng nhập thất bại')),
             );
           }
          }, child:
          Text("Đăng nhập Google"),
          ),
        ],
      ),
    );
  }
}
