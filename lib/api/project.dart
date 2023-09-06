// 프로젝트에 대한 모든 API

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cookie_wrapper/cookie.dart';
import 'package:researchtool/model/project.dart';

class ProjectAPI {
  static const String url = "https://chat-profile.audrey.kr/api/project/";

  static Future<List<ProjectInstance>> getProjectList(
      String accessToken, String refreshToken) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      String decodedResponse = utf8.decode(response.bodyBytes);

      List<ProjectInstance> projectList = [];
      for (final project in jsonDecode(decodedResponse)) {
        projectList.add(ProjectInstance(
            project_name: project["project_name"], id: project['id']));
      }
      return projectList;
    } catch (error) {
      return [];
    }
  }

//Return Table(Index)
  static Future<Map> createProject(String projectName, String purpose) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');

    var body = {
      "project_name": projectName,
      "purpose": purpose,
    };
    try {
      final response = await http.post(Uri.parse(url),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken"
          },
          body: json.encode(body));
      String decodedResponse = utf8.decode(response.bodyBytes);
      final res = jsonDecode(decodedResponse);

      return {"projectId": res['project_id'], "table": res['table']};
    } catch (error) {
      return {};
    }
  }

  static Future<bool> deleteProject(
    int projectId,
  ) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    try {
      await http.delete(
        Uri.parse("$url$projectId"),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      return true;
      //final res = jsonDecode(response.body);
    } catch (error) {
      return false;
    }
  }

  static void postSuggestion(int projectId, String table) {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');

    var body = {
      "table": table,
    };
    try {
      http.post(Uri.parse('$url$projectId/table'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken"
          },
          body: json.encode(body));
    } catch (error) {
      print(error);
    }
  }

  static Future<Map> getSuggestion(int projectId) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    String status = "WAIT";
    Map returnValue = {};
    try {
      while (status != "COMPLETE") {
        final response = await http.get(
          Uri.parse('$url$projectId/suggestion/queue'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken"
          },
        );

        if (response.statusCode == 200) {
          // 응답 파싱
          final data = jsonDecode(response.body);
          final newStatus = data['status'];

          status = newStatus;

          if (status == "COMPLETE") {
            final decodedResponse = utf8.decode(response.bodyBytes);
            returnValue = jsonDecode(decodedResponse);
            break;
          }
        }
        // 1초마다 재시도
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (error) {
      status = "Error";
    }

    return returnValue;
  }

  // Return Message(Model Output)
  static Future<Map> draftFirstCreate(projectId, suggestionSelection, webPages,
      files, text, image, youtube) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    Uri firstCreateUrl = Uri.parse("$url$projectId/draft/first");
    var body = {
      "suggestion_selection": suggestionSelection,
      "web_pages": webPages,
      "text": text,
      "youtube": youtube
    };
    body.removeWhere(
        (key, value) => key != suggestionSelection && value.isEmpty);

    try {
      final response = await http.post(
        firstCreateUrl,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
        body: json.encode(body),
      );

      final res = jsonDecode(response.body);
      return res;
    } catch (error) {
      return {};
    }
  }

  static Future<int> getProjectLastDraft(int projectId) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    try {
      final response = await http.get(
        Uri.parse("$url$projectId/draft"),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      final res = jsonDecode(response.body);
      if (res.isEmpty) {
        return -1;
      } else {
        return res[0]["id"];
      }
    } catch (error) {
      return -1;
    }
  }

  static Future<Map> getDraftStatus(int draftId) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    String status = "WAIT";
    Map returnValue = {};
    try {
      while (status != "COMPLETE") {
        final response = await http.get(
          Uri.parse('${url}draft/$draftId/queue'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken"
          },
        );

        if (response.statusCode == 200) {
          // 응답 파싱
          final data = jsonDecode(response.body);
          final newStatus = data['status'];

          status = newStatus;

          if (status == "COMPLETE") {
            final decodedResponse = utf8.decode(response.bodyBytes);

            returnValue = jsonDecode(decodedResponse);
            break;
          }
        }
        // 1초마다 재시도
        await Future.delayed(const Duration(seconds: 1));
      }
    } catch (error) {
      print(error);
    }

    return returnValue;
  }
}
