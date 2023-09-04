import 'package:flutter/material.dart';
import 'package:cookie_wrapper/cookie.dart';
import 'package:researchtool/api/project.dart';
import 'package:researchtool/api/user_info.dart';
import 'package:researchtool/main.dart';
import 'package:researchtool/model/landing_text.dart';
import 'package:researchtool/model/project.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //final bool _loading = false;

  bool isExpansion = false;

  bool login = false;

  String? userName;
  String? userImg;

  bool isLoginButtonHovered = false;
  bool isSignUpButtonHovered = false;

  String projectNamevalueText = "";
  LandingText landingtext = LandingText(
      title: "Mission",
      content_text: "Make AI more useful to save people time and energy");
  @override
  void initState() {
    super.initState();
    checkLogin(context);
  }

  void checkLogin(BuildContext context) async {
    var cookie = Cookie.create();
    // cookie.set('access_token',
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJleHAiOjE3Mjk3OTgwNzIsImlhdCI6MTY5Mzc5ODA3Mi4xNDgxMzR9.8amMkPHOdkIGZFuX70AxcEM4MioWxpXRoPdrTw7rX8g');
    // cookie.set('refresh_token',
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo3LCJleHAiOjE3Mjk3OTgwNzIsImlhdCI6MTY5Mzc5ODA3Mi4xNDgxMzQsInR5cGUiOiJyZWZyZXNoIn0.4SVhFVvUbqvtoDsLJCABfnwBkpa-G3FMiKORSeC3Oqk');
    var accessToken = cookie.get('access_token');
    var refreshToken = cookie.get('refresh_token');

    if (accessToken != null && refreshToken != null) {
      final userNameImg = await UserInfo.getUserInfo(accessToken, refreshToken);

      if (userNameImg.isEmpty) {
        await MyFluroRouter.router.navigateTo(context, "/auth/login");
      } else {
        projectList =
            await ProjectAPI.getProjectList(accessToken, refreshToken);
        setState(() {
          userName = userNameImg['name'];
          userImg = userNameImg['user_image'];
          login = true;
        });
      }
    } else {
      RenderLandingText();
    }
  }

  Future<void> RenderLandingText() async {
    List<LandingText> landingtextList = [
      LandingText(
          title: "자료조사 Assistant",
          content_text: "생성 AI를 통해 자료조사에 걸리는 시간을 줄이세요!"),
      LandingText(
          title: "자료 수집",
          content_text: "Semantic Search를 통해 여러 웹사이트, 플랫폼에서 적절한 자료를 제안해드려요"),
      LandingText(
          title: "자료 분석",
          content_text: "수집한 자료를 학습한 Custom GPT가 더 정확한 답변을 해드려요"),
      LandingText(
          title: "자료 정리",
          content_text: "프로젝트의 주제/목적과 수집한 자료를 바탕으로 GPT가 1차 초안을 작성해드려요")
    ];
    while (!login) {
      for (final ltext in landingtextList) {
        landingtext = LandingText(title: ltext.title, content_text: "");
        await StreamingLandingText(ltext.content_text);
        await Future.delayed(const Duration(milliseconds: 3000));
      }
    }
  }

  Future<void> StreamingLandingText(String landerString) async {
    // Initialize a new bot message with an empty string

    for (var char in landerString.split('')) {
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        landingtext.content_text += char;
      });
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.red.shade800,
                size: 48,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("삭제하기"),
              ),
            ],
          ),
          content: const Text("프로젝트를 삭제하시겠습니까? 이 작업은 취소할 수 없습니다."),
          actions: [
            TextButton(
              onPressed: () async {
                bool deleteSuccess = await ProjectAPI.deleteProject(id);

                if (deleteSuccess) {
                  var cookie = Cookie.create();
                  var accessToken = cookie.get('access_token');
                  var refreshToken = cookie.get('refresh_token');

                  projectList = await ProjectAPI.getProjectList(
                      accessToken!, refreshToken!);
                  setState(() {});
                }

                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.red.shade800),
                child: const Text(
                  '삭제',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade400,
                ),
                child: const Text(
                  '취소',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// void _showSettingsDialog(BuildContext context, String accessToken) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Row(
//             children: [
//               Icon(
//                 Icons.settings,
//                 color: Colors.grey,
//                 size: 48,
//               ),
//               const Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Text("설정"),
//               ),
//             ],
//           ),
//           content: Row(children: [

//           ]),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 bool deleteSuccess = await ProjectAPI.deleteProject(id);

//                 if (deleteSuccess) {
//                   var cookie = Cookie.create();
//                   var accessToken = cookie.get('access_token');
//                   var refreshToken = cookie.get('refresh_token');

//                   projectList = await ProjectAPI.getProjectList(
//                       accessToken!, refreshToken!);
//                   setState(() {});
//                 }

//                 Navigator.of(context).pop(); // 다이얼로그 닫기
//               },
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     color: Colors.red.shade800),
//                 child: const Text(
//                   '삭제',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // 다이얼로그 닫기
//               },
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(8),
//                   color: Colors.grey.shade400,
//                 ),
//                 child: const Text(
//                   '취소',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

  @override
  void dispose() {
    super.dispose();
  }

  List<ProjectInstance> projectList = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            drawerEnableOpenDragGesture: false,
            appBar: (MediaQuery.of(context).size.width < 600)
                ? AppBar(
                    title: const Image(
                      height: 36,
                      image: AssetImage('assets/images/weblogo.png'),
                      fit: BoxFit.contain,
                    ),
                    leading: Builder(
                      builder: (context) => // Ensure Scaffold is in context
                          IconButton(
                              icon: const Icon(
                                Icons.menu,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer()),
                    ),
                  )
                : null,
            drawer: Drawer(
              backgroundColor: const Color.fromARGB(255, 36, 36, 36),
              child: baseUI(context),
            ),
            body: Row(
              children: [
                MediaQuery.of(context).size.width > 600
                    ? Container(
                        width: 256,
                        color: const Color.fromARGB(255, 36, 36, 36),
                        child: baseUI(context))
                    : Container(),
                Expanded(child: content()),
              ],
            )));
  }

  Widget content() {
    return login
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 12,
              ),
              Padding(
                padding: const EdgeInsets.all(36.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("My Projects",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: projectList.length, // 프로젝트 카드의 개수
                        itemBuilder: (context, index) {
                          return ProjectCard(
                            projectList[index].project_name,
                            projectList[index].id,
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 10,
                      left: MediaQuery.of(context).size.width / 32,
                      right: MediaQuery.of(context).size.width / 32),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(landingtext.title,
                            style: const TextStyle(
                                fontSize: 56,
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(landingtext.content_text,
                            style: const TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 3,
                        )
                      ],
                    ),
                  )),
            ],
          );
  }

  Widget baseUI(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 18),
        Container(
          width: 224,
          padding: const EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 15,
          ),
          child: const Image(
            image: AssetImage('assets/images/weblogo.png'),
            fit: BoxFit.cover,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "Demo",
            style: TextStyle(
              color: Colors.blueGrey,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 12),
        login ? UserInfoList(userName!, userImg!) : LoginButton(),
        Flexible(child: Container()),
        InkWell(
          onTap: () {
            login
                ? MyFluroRouter.router.navigateTo(
                    context,
                    "/build",
                  )
                : MyFluroRouter.router.navigateTo(context, "/auth/login",
                    routeSettings: const RouteSettings(arguments: false));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 30,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [
                  Colors.indigo,
                  Colors.cyan,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Text(
              "New Project",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "© 2023 audrey.AI. All Rights Reserved.",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget ProjectCard(String name, int id) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        child: Column(
          children: [
            Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.adjust_rounded,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
                Positioned(
                    right: 24,
                    child: InkWell(
                      onTap: () async {
                        _showDeleteConfirmationDialog(context, id);
                      },
                      child: const Icon(
                        Icons.delete_outlined,
                        color: Colors.grey,
                      ),
                    ))
              ],
            ),
            const Divider(
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  Widget LoginButton() {
    return Container(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  MyFluroRouter.router.navigateTo(context, "/auth/login",
                      routeSettings: const RouteSettings(arguments: false));
                },
                onHover: (value) {
                  setState(() {
                    isLoginButtonHovered = value;
                  });
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 30,
                    ),
                    decoration: BoxDecoration(
                        color: isLoginButtonHovered
                            ? const Color.fromARGB(255, 49, 85, 214) // 변경된 색상
                            : Colors.indigo,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text("Log in",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600))),
              ),
              InkWell(
                onTap: () {
                  MyFluroRouter.router.navigateTo(context, "/auth/login",
                      routeSettings: const RouteSettings(arguments: true));

                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const LoginScreen()),
                  // );
                },
                onHover: (value) {
                  setState(() {
                    isSignUpButtonHovered = value;
                  });
                },
                child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 30,
                    ),
                    decoration: BoxDecoration(
                        color: isSignUpButtonHovered
                            ? const Color.fromARGB(255, 49, 85, 214)
                            : Colors.indigo,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text("Sign up",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600))),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget UserInfoList(String name, String userImage) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
        iconColor: Colors.white70,
        initiallyExpanded: false,
        trailing: const Icon(Icons.expand_more_rounded),
        onExpansionChanged: (exapnsion) {
          setState(() {
            isExpansion = exapnsion;
          });
        },
        leading: Container(
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle, // BoxShape를 원으로 설정
            // 추가적인 스타일링을 원하는 경우 여기에 추가 가능
          ),
          child: ClipOval(
            child: Image.network(
              userImage,
              fit: BoxFit.cover,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromARGB(255, 46, 50, 52)),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              width: 1.0, color: Colors.white10), // 위쪽에 테두리 추가
                          // 나머지 방향에는 테두리가 없음
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          var cookie = Cookie.create();
                          // cookie.remove('access_token');
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 36, vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.settings,
                                  size: 28, color: Colors.white),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "Settings",
                                  style: TextStyle(color: Colors.white),
                                  overflow:
                                      TextOverflow.ellipsis, // 텍스트가 길면 자동으로 줄바꿈
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    LogOutBttn()
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget LogOutBttn() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(width: 1.0, color: Colors.white10), // 위쪽에 테두리 추가
          // 나머지 방향에는 테두리가 없음
        ),
      ),
      child: InkWell(
        onTap: () async {
          var cookie = Cookie.create();
          cookie.remove('access_token');
          cookie.remove('refresh_token');
          setState(() {
            login = false;
          });
          MyFluroRouter.router
              .navigateTo(context, '/', clearStack: true, replace: true);
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 36, vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.logout, size: 28, color: Colors.white),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  "Log out",
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis, // 텍스트가 길면 자동으로 줄바꿈
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //State 끝
}
