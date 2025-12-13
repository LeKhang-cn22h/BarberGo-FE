import 'package:barbergofe/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

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
            await authViewModel.loginWithGG();
          }, child: Text("Login with Google"),
          ),
          // stream dùng để theo dõi trạng thái đăng nhập
          StreamBuilder<GoogleSignInAuthenticationEvent>(stream: googleAuthService.authEvents, builder: (context, snapshot) {
            if (snapshot.hasData){
              return Text('Auth event: ${snapshot.data}');
            }
            return SizedBox.shrink();
    }
    )

        ],
      ),
    );
  }
}
