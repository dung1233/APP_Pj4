class LoginResponse {
  final String? token;
  final bool success;

  LoginResponse({this.token, required this.success});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['result']?['token'], // ✅ Lấy token từ 'result'
      success: json['result']?['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'success': success,
    };
  }
}
