import 'dart:async';
import 'dart:convert';
import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart' as http;
import 'package:researchtool/model/message.dart';
import 'package:web_browser_detect/web_browser_detect.dart';
import 'package:cookie_wrapper/cookie.dart';

class ApiService {
  static const String Url = "https://chat-profile.audrey.kr/api/project/";

  static Stream<String> sendData(String userChat, int projectId) async* {
    final apiUrl = Uri.parse("$Url$projectId/qna");

    var data = {"question": userChat};
    var body = json.encode(data);
    final browser = Browser().browser;
    final isUnusualBrower =
        !browser.contains("Safari") && !browser.contains("Chrome");

    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');

    final request = http.Request("POST", apiUrl)
      ..headers["Content-Type"] = "application/json"
      ..headers['Authorization'] = 'Bearer $accessToken'
      ..body = body;
    final client =
        isUnusualBrower ? http.Client() : FetchClient(mode: RequestMode.cors);

    try {
      final response = await client.send(request);
      final stream = response.stream.transform(utf8.decoder);
      //time out 테스트 해봐야함
      final streamResponse =
          stream.timeout(const Duration(seconds: 15), onTimeout: (event) {
        throw TimeoutException("Server response timed out");
      });

      await for (final message in streamResponse) {
        yield message;
      }
    } on TimeoutException {
      yield "Error"; // Handle the timeout error
    } catch (error) {
      yield "Error on OpenAI";
    } finally {
      client.close();
    }
  }

  // static Future<List<String>> getExamples(int id) async {
  //   final apiUrl = Uri.parse("$Url/example/$id");
  //   try {
  //     final response = await http.get(apiUrl);
  //     List<String> examples = response.body.split("|");
  //     return examples;
  //   } catch (error) {
  //     return [];
  //   }
  // }

  static Future<List<ChatMessage>> getChat(int projectId) async {
    final apiUrl = Uri.parse("$Url$projectId/qna");
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    try {
      final response = await http.get(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
      );

      final res = jsonDecode(response.body);

      List<ChatMessage> messages = [];

      for (final conv in res["conversation"]) {
        messages.add(ChatMessage(
          messageContent: conv["user"],
          messageType: "user",
        ));

        messages.add(ChatMessage(
          messageContent: conv["model"],
          messageType: "model",
        ));
      }

      return messages;
    } catch (error) {
      return [];
    }
  }

  static Future<List<ChatMessage>> deleteChat(int projectId) async {
    final apiUrl = Uri.parse("$Url$projectId/qna");
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    try {
      await http.delete(
        apiUrl,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
      );

      return [];
    } catch (error) {
      return [];
    }
  }
}
