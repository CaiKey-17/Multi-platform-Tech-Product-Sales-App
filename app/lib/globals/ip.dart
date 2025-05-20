class ApiConfig {
  //Run local
  // static const String ip = "<your_ip_here>";
  // static const String baseUrlSentiment = "http://$ip:5001";
  // static const String baseUrlAPI = "http://$ip:8080/api";
  // static const String baseUrlDetect = "http://$ip:5002/detect/";
  // static const String baseUrlWsc = "http://$ip:8080/ws";
  // static const String baseUrlWscHistory = "http://$ip:8080/api";

  //Deploy
  static const String baseUrlSentiment =
      "https://sentiment-analysics-production.up.railway.app";

  static const String baseUrlAPI =
      "https://backend-production-c478.up.railway.app/api";

  static const String baseUrlDetect =
      "https://detect-product-production.up.railway.app/detect/";

  static const String baseUrlWsc =
      "https://backend-production-c478.up.railway.app/ws";

  static const String baseUrlWscHistory =
      "https://backend-production-c478.up.railway.app/api";

  //
  static Uri getChatMessages(int senderId, int receiverId) {
    return Uri.parse('$baseUrlWscHistory/chat/messages/$senderId/$receiverId');
  }

  static Uri getChatContact(int currentUserId) {
    return Uri.parse('$baseUrlWscHistory/chat/contacts/$currentUserId');
  }
}
