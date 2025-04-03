class LoginResponse {
  final String? token;
  final bool success;

  LoginResponse({this.token, required this.success});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];

    return LoginResponse(
      token: result?['token'] ?? '', // Tránh null error
      success: result?['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'success': success,
    };
  }
}
