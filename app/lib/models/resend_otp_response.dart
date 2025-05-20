class ResendOtpResponse {
  final int code;
  final String message;

  ResendOtpResponse({required this.code, required this.message});

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    return ResendOtpResponse(code: json["code"], message: json["message"]);
  }
}
