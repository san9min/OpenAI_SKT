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
  bool isExpansion = false;

  bool login = false;
  String? userName;
  String? userImg;

  bool isLoginButtonHovered = false;
  bool isSignUpButtonHovered = false;

  LandingText landingtext = LandingText(title: "", content_text: "");

  @override
  void initState() {
    checkLogin(context);
    super.initState();
  }

  void checkLogin(BuildContext context) async {
    var cookie = Cookie.create();
    var accessToken = cookie.get('access_token');
    var refreshToken = cookie.get('refresh_token');

    if (accessToken != null) {
      final userNameImg =
          await UserInfo.getUserInfo(accessToken, refreshToken!);

      if (userNameImg.isEmpty) {
        if (!mounted) return;
        await MyFluroRouter.router.navigateTo(
          context,
          "/auth/login",
        );
      } else {
        final helperPl =
            await ProjectAPI.getProjectList(accessToken, refreshToken);
        setState(() {
          projectList = helperPl.reversed.toList();
          userName = userNameImg['name'];
          userImg = userNameImg['user_image'];
          login = true;
        });
      }
    } else {
      startLandingText();
    }
  }

  Future<void> startLandingText() async {
    List<LandingText> landingtextList = [
      LandingText(
          title: "자료조사 Tool",
          content_text: "온라인 자료조사, 이제 Generative AI와 함께하세요!"),
      LandingText(
          title: "당신만의 자료조사 Agent",
          content_text: "글, 그림부터 영상까지\n다양한 유형의 자료를 이해하고 질문에 답해드려요!"),
      LandingText(
          title: "당신만의 자료조사 Agent",
          content_text: "글 초안 작성부터 수정, 도표 생성까지 \n간단한 명령어로 자료를 보완해보세요!"),
      //LandingText(title: "당신만의 자료조사 Agent", content_text: "audrey를 통해 더 효")
    ];
    while (!login) {
      for (final ltext in landingtextList) {
        landingtext = LandingText(title: ltext.title, content_text: "");
        await streamingLandingText(ltext.content_text);
        await Future.delayed(const Duration(milliseconds: 3000));
      }
    }
  }

  Future<void> streamingLandingText(String landerString) async {
    await Future.delayed(const Duration(milliseconds: 100));
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
            InkWell(
              onTap: () async {
                bool deleteSuccess = await ProjectAPI.deleteProject(id);

                if (deleteSuccess) {
                  var cookie = Cookie.create();
                  var accessToken = cookie.get('access_token');
                  var refreshToken = cookie.get('refresh_token');

                  final helperPl = await ProjectAPI.getProjectList(
                      accessToken!, refreshToken!);

                  setState(() {
                    projectList = helperPl.reversed.toList();
                  });
                }

                Navigator.of(context).pop(); // 다이얼로그 닫기
                if (!mounted) return;
                MyFluroRouter.router.navigateTo(context, '/', replace: true);
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

  void _showSettingsDialog(BuildContext context, String accessToken) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(30, 34, 42, 1),
          title: const Row(
            children: [
              Icon(
                Icons.settings,
                color: Colors.grey,
                size: 48,
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "설정",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          content: SizedBox(
            height: 224,
            width: MediaQuery.of(context).size.width > 700
                ? MediaQuery.of(context).size.width / 3
                : 280,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 1,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Delete account",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        InkWell(
                          onTap: () {
                            var cookie = Cookie.create();
                            cookie.remove('access_token');
                            cookie.remove('refresh_token');
                            UserInfo.deleteUserInfo(accessToken);

                            Navigator.of(context).pop(); // 다이얼로그 닫기
                            if (!mounted) return;
                            MyFluroRouter.router
                                .navigateTo(context, '/', replace: true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.red.shade700,
                            ),
                            child: const Text(
                              '탈퇴',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.grey,
                    )
                  ],
                );
              },
            ),
          ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade800,
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
                    const Text("📝 나의 프로젝트",
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    const SizedBox(
                      height: 12,
                    ),
                    if (projectList.isEmpty)
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: MediaQuery.of(context).size.height / 1.5,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const Text(
                              //   "자료조사 Agent에게 도움을 받으세요",
                              //   style: TextStyle(color: Colors.grey, fontSize: 18),
                              // ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () {
                                  login
                                      ? MyFluroRouter.router.navigateTo(
                                          context,
                                          "/build",
                                        )
                                      : MyFluroRouter.router.navigateTo(
                                          context, "/auth/login",
                                          routeSettings: const RouteSettings(
                                              arguments: false));
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
                                        Colors.blue,
                                        Colors.lightBlue,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Text(
                                    "시작하기",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    if (projectList.isNotEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 1.4,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: projectList.length, // 프로젝트 카드의 개수
                          itemBuilder: (context, index) {
                            return projectListCard(
                              projectList[index].project_name,
                              projectList[index].id,
                              projectList[index].purpose,
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
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(landingtext.content_text,
                            style: const TextStyle(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 5,
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
                  Colors.lightBlue,
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

  // Widget ProjectCard(String name, int id) {
  //   return Padding(
  //     padding: const EdgeInsets.all(12.0),
  //     child: SizedBox(
  //       child: Column(
  //         children: [
  //           Stack(
  //             children: [
  //               InkWell(
  //                 onTap: () async {
  //                   int draftId = await ProjectAPI.getProjectLastDraft(id);
  //                   if (!mounted) return;
  //                   if (draftId == -1) {
  //                   } else {
  //                     MyFluroRouter.router
  //                         .navigateTo(context, '/edit/$name/$id',
  //                             routeSettings: RouteSettings(arguments: {
  //                               "draftId": draftId,
  //                               "projectName": name,
  //                               "projectId": id,
  //                             }));
  //                   }
  //                 },
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     Stack(
  //                       alignment: Alignment.center,
  //                       children: [
  //                         Container(
  //                           width: 18, // 원의 지름
  //                           height: 18, // 원의 지름
  //                           decoration: BoxDecoration(
  //                               shape: BoxShape.circle,
  //                               color: Colors.transparent, // 채워진 원의 색상
  //                               border:
  //                                   Border.all(width: 1, color: Colors.white)),
  //                         ),
  //                         Positioned(
  //                           left: 3, // 내부 원의 가로 위치 조절
  //                           top: 3, // 내부 원의 세로 위치 조절
  //                           child: Container(
  //                             width: 12, // 내부 원의 지름
  //                             height: 12, // 내부 원의 지름
  //                             decoration: const BoxDecoration(
  //                               shape: BoxShape.circle,
  //                               color: Colors.white, // 내부 원의 색상
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(
  //                       width: 12,
  //                     ),
  //                     Text(
  //                       name,
  //                       style: const TextStyle(
  //                           color: Colors.white,
  //                           fontSize: 18,
  //                           fontWeight: FontWeight.bold),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Positioned(
  //                   right: 24,
  //                   child: InkWell(
  //                     onTap: () async {
  //                       _showDeleteConfirmationDialog(context, id);
  //                     },
  //                     child: Container(
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 12, vertical: 3),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(8),
  //                         color: Colors.red.shade700,
  //                       ),
  //                       child: const Text(
  //                         'Delete',
  //                         style: TextStyle(color: Colors.white),
  //                       ),
  //                     ),
  //                   ))
  //             ],
  //           ),
  //           const Divider(
  //             color: Colors.grey,
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget projectListCard(String name, int id, String purpose) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () async {
            int draftId = await ProjectAPI.getProjectLastDraft(id);
            if (!mounted) return;
            if (draftId == -1) {
            } else {
              MyFluroRouter.router.navigateTo(
                context, '/edit/${Uri.encodeFull(name)}/$id/$draftId',
                // routeSettings: RouteSettings(arguments: {
                //   "draftId": draftId,
                //   "projectName": name,
                //   "projectId": id,
                // })
              );
            }
          },
          child: Card(
            elevation: 12.0,
            margin: const EdgeInsets.symmetric(
              horizontal: 6.0,
            ),
            child: Container(
              decoration:
                  const BoxDecoration(color: Color.fromARGB(244, 46, 50, 52)),
              child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 0.0),
                  leading: Container(
                    padding: const EdgeInsets.only(right: 12.0),
                    decoration: const BoxDecoration(
                        border: Border(
                            right:
                                BorderSide(width: 1.0, color: Colors.white24))),
                    child:
                        const Icon(Icons.circle, color: Colors.white, size: 18),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      //fontSize: 18,
                    ),
                  ),
                  subtitle: Row(
                    children: <Widget>[
                      const Icon(Icons.linear_scale_outlined,
                          color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Text(purpose,
                          style: TextStyle(color: Colors.grey.shade600))
                    ],
                  ),
                  trailing: InkWell(
                    onTap: () async {
                      _showDeleteConfirmationDialog(context, id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red.shade700,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )),
            ),
          ),
        ));
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
        //iconColor:
        initiallyExpanded: false,
        trailing: Icon(
          Icons.expand_more_rounded,
          color: isExpansion ? Colors.white : Colors.white70,
        ),
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
                        onTap: () {
                          var cookie = Cookie.create();
                          final accessToken = cookie.get("access_token");

                          _showSettingsDialog(context, accessToken!);
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
                    logOutButton()
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget logOutButton() {
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
          MyFluroRouter.router.navigateTo(
            context,
            '/',
          );
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
