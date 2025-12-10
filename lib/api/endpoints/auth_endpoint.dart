class AuthEndpoint{

//endpoint auth
  /// POST /users/register - Đăng ký tài khoản mới
  static const String authRegister = "/users/register";

  /// POST /users/resend-confirmation - Gửi lại email xác nhận
  static const String authResendConfirmation = "/users/resend-confirmation";

  /// POST /users/login - Đăng nhập
  static const String authLogin = "/users/login";

  /// POST /users/forgot-password - Quên mật khẩu
  static const String authForgotPassword = "/users/forgot-password";

  /// POST /users/reset-password - Đặt lại mật khẩu
  static const String authResetPassword = "/users/reset-password";
}