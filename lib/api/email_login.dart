import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailLogin {
  static const String url = "https://chat-profile.audrey.kr/api/user/login";

  static Future<String> login(String userEmail, String password) async {
    try {
      var usermail = {"email": userEmail, "password": password};

      final response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(usermail));
      //String redirectUrl = response.headers['location']![0];
      final res = jsonDecode(response.body);

      return res['message'];
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
      return "Error";
    }
  }
}
