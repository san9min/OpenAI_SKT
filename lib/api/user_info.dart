import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserInfo {
  static const String url = "https://chat-profile.audrey.kr/api/user/userinfo";
  static const String refreshUrl =
      "https://chat-profile.audrey.kr/api/user/refresh";

  static Future<Map> getUserInfo(
      String accessToken, String refreshToken) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      String decodedResponse = utf8.decode(response.bodyBytes);

      return jsonDecode(decodedResponse);
      // if (response.statusCode == 401) {
      //   final refreshResponse = await http.get(Uri.parse(refreshUrl));

      //   print(refreshResponse);
      //   return false;
      // } else {
      //   return true;
      // }
    } catch (error) {
      //MyFluroRouter.navigatorKey.currentState?.pushNamed('/login');
      return {};
    }
  }

  static void deleteUserInfo(String accessToken) async {
    try {
      await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (error) {
      //MyFluroRouter.navigatorKey.currentState?.pushNamed('/login');
      print(error);
    }
  }
}
