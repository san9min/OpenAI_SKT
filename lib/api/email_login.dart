import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailLogin {
  static const String url = "https://chat-profile.audrey.kr/api/user/login";

  static Future<Map> login(String userEmail, String password) async {
    try {
      var usermail = {"email": userEmail, "password": password};

      final response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: json.encode(usermail));
      //String redirectUrl = response.headers['location']![0];
      final res = jsonDecode(response.body);

      return res;
    } catch (error) {
      print(error);
      return {"message": "Error"};
    }
  }
}
