import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailSingUp {
  static const String url = "https://chat-profile.audrey.kr/api/user/email";
  static const String register_url =
      "https://chat-profile.audrey.kr/api/user/register";

  static void sendEmailCode(String userEmail) async {
    try {
      var usermail = {"email": userEmail};

      final response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(usermail));
      print(response.body);

      // if (response.statusCode == 401) {
      //   final refreshResponse = await http.get(Uri.parse(refreshUrl));

      //   print(refreshResponse);
      //   return false;
      // } else {
      //   return true;
      // }
    } catch (error) {
      //MyFluroRouter.navigatorKey.currentState?.pushNamed('/login');
      print(error);
    }
  }

  static Future<bool> checkEmailCode(String userEmail, String code) async {
    try {
      var usermail = {"email": userEmail, "code": code};

      final response = await http.put(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(usermail));
      final res = json.decode(response.body);
      if (res['message'] == "code verification success") {
        return true;
      } else {
        return false;
      }
      // if (response.statusCode == 401) {
      //   final refreshResponse = await http.get(Uri.parse(refreshUrl));

      //   print(refreshResponse);
      //   return false;
      // } else {
      //   return true;
      // }
    } catch (error) {
      //MyFluroRouter.navigatorKey.currentState?.pushNamed('/login');
      print(error);
      return false;
    }
  }

  static Future<Map> registerEmail(String userEmail, String password) async {
    try {
      var usermail = {"email": userEmail, "password": password};

      final response = await http.post(Uri.parse(register_url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(usermail));
      final res = json.decode(response.body);

      return res;

      // if (response.statusCode == 401) {
      //   final refreshResponse = await http.get(Uri.parse(refreshUrl));

      //   print(refreshResponse);
      //   return false;
      // } else {
      //   return true;
      // }
    } catch (error) {
      //MyFluroRouter.navigatorKey.currentState?.pushNamed('/login');
      print(error);
      return {};
    }
  }
}
