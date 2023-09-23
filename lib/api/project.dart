// 프로젝트에 대한 모든 API
import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart' as http;
import 'package:cookie_wrapper/cookie.dart';
import 'package:researchtool/model/data.dart';
import 'package:researchtool/model/project.dart';
import 'package:researchtool/screens/create.dart';
import 'package:web_browser_detect/web_browser_detect.dart'; // 파일 경로를 조작하기 위한 패키지

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
            project_name: project["project_name"],
            id: project['id'],
            purpose: project['purpose']));
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
      http.post(Uri.parse('$url$projectId/suggestion'),
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

  static void selectSuggestion(int projectId, List<Information> selectedList) {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    List<int> suggestionSelection = [];
    for (final suggestionLink in selectedList) {
      suggestionSelection.add(suggestionLink.id);
    }
    var body = {
      "suggestion_selection": suggestionSelection,
    };
    try {
      http.put(Uri.parse('$url$projectId/suggestion'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken"
          },
          body: json.encode(body));
    } catch (error) {
      print(error);
    }
  }

  // Return Message(Model Output)
  static Future<String> addDataSource(
      projectId, webPages, files, text, image, youtube, audio) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    Uri addDataSourceUrl = Uri.parse("$url$projectId/datasource");
    var request = http.MultipartRequest('POST', addDataSourceUrl);

    for (var file in files) {
      if (file != null) {
        try {
          Uint8List uploadfile = file.bytes;
          var multipartFile = http.MultipartFile.fromBytes(
            'files', // 서버에서 사용할 파일 필드 이름
            uploadfile,
            filename: file.name, // 파일 이름
          );
          request.files.add(multipartFile);
        } catch (e) {
          print('파일 변환 중 오류 발생: $e');
        }
      }
    }

    for (var file in image) {
      if (file != null) {
        try {
          Uint8List uploadfile = file.bytes;
          var multipartFile = http.MultipartFile.fromBytes(
            'images', // 서버에서 사용할 파일 필드 이름
            uploadfile,
            filename: file.name, // 파일 이름
          );
          request.files.add(multipartFile);
        } catch (e) {
          print('파일 변환 중 오류 발생: $e');
        }
      }
    }

    for (var file in audio) {
      if (file != null) {
        try {
          Uint8List uploadfile = file.bytes;
          var multipartFile = http.MultipartFile.fromBytes(
            'audio', // 서버에서 사용할 파일 필드 이름
            uploadfile,
            filename: file.name, // 파일 이름
          );
          request.files.add(multipartFile);
        } catch (e) {
          print('파일 변환 중 오류 발생: $e');
        }
      }
    }

    var body = {"web_pages": webPages, "text": text, "youtube": youtube};
    body.removeWhere((key, value) => value.isEmpty);

    try {
      for (final key in body.keys) {
        for (final element in body[key]) {
          request.fields[key] = element;
        }
      }
    } catch (e) {
      print(e);
    }

    request.headers.addAll({
      "Content-Type": "multipart/form-data",
      'Authorization': 'Bearer $accessToken'
    });

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        //final res = jsonDecode(response);
        return "";
      } else {
        return "";
      }
    } catch (error) {
      return "";
    }
  }

  static Future<String> deleteDataSource(
      int projectId, List<int> delsugSources, List<int> deladdSources) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    Uri DataSourceUrl = Uri.parse("$url$projectId/datasource");
    var body = json.encode(
        {"delete_id": deladdSources, "delete_suggestion_id": delsugSources});
    try {
      await http.delete(DataSourceUrl,
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
          body: body);

      return "suceess";
    } catch (e) {
      print(e);
      return "";
    }
  }

  static Stream<String> genDraft(int proejctId) async* {
    final apiUrl = Uri.parse("$url$proejctId/draft");

    final browser = Browser().browser;
    final isUnusualBrower =
        !browser.contains("Safari") && !browser.contains("Chrome");

    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');

    final request = http.Request("POST", apiUrl)
      ..headers["Content-Type"] = "application/json"
      ..headers['Authorization'] = 'Bearer $accessToken';

    final client =
        isUnusualBrower ? http.Client() : FetchClient(mode: RequestMode.cors);

    try {
      final response = await client.send(request);
      final stream = response.stream.transform(utf8.decoder);
      //time out 테스트 해봐야함
      final streamResponse =
          stream.timeout(const Duration(seconds: 45), onTimeout: (event) {
        throw TimeoutException("Server response timed out");
      });

      await for (final message in streamResponse) {
        yield message;
      }
    } on TimeoutException {
      yield "잘모르는 내용입니다."; // Handle the timeout error
    } catch (error) {
      yield "잘모르는 내용입니다.";
    } finally {
      client.close();
    }
  }

  static Stream<String> reGenDraft(int draftId) async* {
    final apiUrl = Uri.parse("${url}draft/$draftId/regenerate");

    final browser = Browser().browser;
    final isUnusualBrower =
        !browser.contains("Safari") && !browser.contains("Chrome");

    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');

    final request = http.Request("PUT", apiUrl)
      ..headers["Content-Type"] = "application/json"
      ..headers['Authorization'] = 'Bearer $accessToken';

    final client =
        isUnusualBrower ? http.Client() : FetchClient(mode: RequestMode.cors);

    try {
      final response = await client.send(request);
      final stream = response.stream.transform(utf8.decoder);
      //time out 테스트 해봐야함
      final streamResponse =
          stream.timeout(const Duration(seconds: 45), onTimeout: (event) {
        throw TimeoutException("Server response timed out");
      });

      await for (final message in streamResponse) {
        yield message;
      }
    } on TimeoutException {
      yield "잘모르는 내용입니다."; // Handle the timeout error
    } catch (error) {
      yield "잘모르는 내용입니다.";
    } finally {
      client.close();
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
    Map returnValue = {};
    try {
      final response = await http.get(
        Uri.parse('${url}draft/$draftId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
      );

      final decodedResponse = utf8.decode(response.bodyBytes);

      returnValue = jsonDecode(decodedResponse);

      return returnValue;
    } catch (e) {
      print(e);
      return returnValue;
    }
  }

  // static Future<Map> getDraftStatus(int draftId) async {
  //   var cookie = Cookie.create();
  //   var accessToken = cookie.get('access_token');
  //   String status = "WAIT";
  //   Map returnValue = {};
  //   try {
  //     while (status != "COMPLETE") {
  //       final response = await http.get(
  //         Uri.parse('${url}draft/$draftId/queue'),
  //         headers: {
  //           "Content-Type": "application/json",
  //           "Authorization": "Bearer $accessToken"
  //         },
  //       );

  //       if (response.statusCode == 200) {
  //         // 응답 파싱
  //         final data = jsonDecode(response.body);
  //         final newStatus = data['status'];

  //         status = newStatus;

  //         if (status == "COMPLETE") {
  //           final decodedResponse = utf8.decode(response.bodyBytes);

  //           returnValue = jsonDecode(decodedResponse);
  //           break;
  //         }
  //       }
  //       // 1초마다 재시도
  //       await Future.delayed(const Duration(seconds: 1));
  //     }
  //   } catch (error) {
  //     print(error);
  //   }

  //   return returnValue;
  // }

  static Future<Map> getDatasource(int projectId) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    try {
      final response = await http.get(
        Uri.parse("$url$projectId/datasource"),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      final res = jsonDecode(response.body);

      return res;
    } catch (error) {
      return {};
    }
  }

  static Future<bool> editOnlyDraft(int draftId, String draft) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    var body = {"draft": draft};
    try {
      http.put(Uri.parse('${url}draft/$draftId'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken"
          },
          body: json.encode(body));
      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  static Future<String> editDraftwithAI(
      int draftId, String draftPart, String query) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');

    var body = {"draft_part": draftPart, "query": query};
    try {
      final response = await http.post(Uri.parse('${url}draft/$draftId'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken"
          },
          body: json.encode(body));

      final decodedResponse = utf8.decode(response.bodyBytes);

      final res = jsonDecode(decodedResponse);

      final editbyAI = res['draft'];
      return editbyAI;
    } catch (error) {
      print(error);
      return draftPart;
    }
  }

  static void downloadDraft(int draftId, String projectName) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    try {
      final response = await http.get(
        Uri.parse("${url}draft/$draftId/download"),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        // PDF 파일 데이터를 Uint8List로 변환
        final pdfData = Uint8List.fromList(response.bodyBytes);

        // 브라우저 다운로드 대화 상자 열기
        final blob = html.Blob([pdfData]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..target = 'blank' // 새 창에서 열릴 수 있도록 설정
          ..download = '$projectName.pdf' // 다운로드 파일 이름 설정
          ..click();

        // 사용이 끝난 URL과 Blob 객체 제거
        html.Url.revokeObjectUrl(url);
      } else {
        // 다운로드 실패 시 에러 메시지 출력
        print('PDF 다운로드 실패 - 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<DalleImage> genImage(int draftId) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');

    try {
      final response = await http.post(
        Uri.parse('${url}draft/$draftId/image'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
      );

      final res = jsonDecode(response.body);

      return DalleImage(imageId: res['id'], link: res['link']);
    } catch (error) {
      print(error);
      return DalleImage(imageId: -1, link: "");
    }
  }

  static Future<List<DalleImage>> getImage(int draftId) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');

    try {
      final response = await http.get(
        Uri.parse('${url}draft/$draftId/image'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
      );

      final res = jsonDecode(response.body);
      List<DalleImage> result = [];
      for (final res_i in res) {
        result.add(DalleImage(imageId: res_i['id'], link: res_i['link']));
      }
      return result;
    } catch (error) {
      print(error);
      return [];
    }
  }

  static void selectImage(int draftId, int imageId) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');

    var body = {"image_id": imageId};
    try {
      await http.put(Uri.parse('${url}draft/$draftId/image'),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $accessToken"
          },
          body: jsonEncode(body));
    } catch (error) {}
  }
}
