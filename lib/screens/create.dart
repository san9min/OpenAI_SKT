import 'package:jumping_dot/jumping_dot.dart';
import 'package:researchtool/api/project.dart';
import 'package:researchtool/main.dart';
import 'package:flutter/material.dart';
import 'package:footer/footer.dart';
import 'package:footer/footer_view.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildScreen extends StatefulWidget {
  const BuildScreen({Key? key}) : super(key: key);

  @override
  State<BuildScreen> createState() => _BuildScreenState();
}

class _BuildScreenState extends State<BuildScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController purposeController = TextEditingController();
  TextEditingController projectNameController = TextEditingController();
  FocusNode suggestionFocus = FocusNode();
  FocusNode purposeFocus = FocusNode();
  bool isLoading = false;
  bool getSuggestion = false;
  bool indexRender = false;
  String projectName = "";
  late int projectId;
  @override
  void initState() {
    super.initState();
    purposeFocus.addListener(() {
      setState(() {});
    });
    //var cookie = Cookie.create();
  }

  @override
  void dispose() {
    purposeFocus.dispose();
    purposeController.dispose();
    super.dispose();
  }

  List<Information> informationList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(30, 34, 42, 1),
        appBar: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: InkWell(
            onTap: () {
              MyFluroRouter.router.navigateTo(context, "/");
            },
            child: const Image(
              height: 32,
              image: AssetImage('assets/images/weblogo.png'),
              fit: BoxFit.contain,
            ),
          ),
          backgroundColor: const Color(0x44000000),
          elevation: 0,
        ),
        body: FooterView(
          footer: Footer(
            backgroundColor: const Color.fromARGB(255, 81, 85, 91),
            padding: const EdgeInsets.all(5.0),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'Copyright © 2023 audrey. AI. All Rights Reserved.',
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12.0,
                        color: Colors.white),
                  ),
                ]),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                projectName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ),
            getSuggestion
                ? Column(
                    children: [
                      const Text(
                        "Suggestion",
                        style: TextStyle(
                            color: Colors.cyan,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      const Text(
                          "다음과 같이 자료를 찾아봤어요!\n 원하시는 자료를 선택해주시면 선택하신 자료를 Assistant가 학습해 보고서 작성을 도와드려요",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(
                        height: 12,
                      ),
                      SelectableRegion(
                        selectionControls: materialTextSelectionControls,
                        focusNode:
                            suggestionFocus, // initialized to FocusNode()
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width / 1.5,
                            height: MediaQuery.of(context).size.height / 1.5,
                            child: MediaQuery.of(context).size.width < 700
                                ? ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 12),
                                    itemCount: informationList.length,
                                    itemBuilder: (context, index) {
                                      bool isExpanded =
                                          informationList[index].isExpanded;

                                      Color titleColor = isExpanded
                                          ? Colors.black
                                          : Colors.white;

                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        width: double.infinity,
                                        child: ExpansionTile(
                                          initiallyExpanded:
                                              informationList[index].isExpanded,
                                          clipBehavior: Clip.antiAlias,
                                          backgroundColor: Colors.white,
                                          iconColor: Colors.black,
                                          onExpansionChanged: (expanded) {
                                            setState(() {
                                              informationList[index]
                                                  .isExpanded = expanded;
                                            });
                                          },
                                          leading: Checkbox(
                                            activeColor: Colors.cyan,
                                            value: informationList[index]
                                                .isSelected,
                                            onChanged: (value) {
                                              setState(() {
                                                informationList[index]
                                                    .isSelected = value!;
                                              });
                                            },
                                          ),
                                          title: Row(
                                            children: [
                                              Image.network(
                                                informationList[index]
                                                    .favicon_url,
                                                width: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              SizedBox(
                                                width: 175,
                                                child: Text(
                                                  informationList[index].title,
                                                  style: TextStyle(
                                                      color: titleColor,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(informationList[index]
                                                  .content),
                                            ),
                                            Center(
                                              child: InkWell(
                                                // InkWell을 사용하여 텍스트를 터치 가능하게 만듭니다.
                                                onTap: () async {
                                                  final url =
                                                      informationList[index]
                                                          .url;
                                                  if (await canLaunchUrl(
                                                      Uri.parse(url))) {
                                                    await launchUrl(Uri.parse(
                                                        url)); // URL을 엽니다.
                                                  } else {
                                                    throw 'Could not launch $url';
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 4.0),
                                                  child: Text(
                                                    informationList[index].url,
                                                    style: const TextStyle(
                                                        color: Colors.blue,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        1000
                                                    ? 3
                                                    : 2, // 한 줄에 세 개의 열
                                            mainAxisExtent: 320,
                                            mainAxisSpacing: 12,
                                            crossAxisSpacing: 12),
                                    itemCount: informationList.length,
                                    itemBuilder: (context, index) {
                                      bool isExpanded =
                                          informationList[index].isExpanded;

                                      Color titleColor = isExpanded
                                          ? Colors.black
                                          : Colors.white;
                                      return Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border:
                                                Border.all(color: Colors.grey)),
                                        child: ExpansionTile(
                                          clipBehavior: Clip.antiAlias,
                                          initiallyExpanded:
                                              informationList[index].isExpanded,
                                          iconColor: Colors.black,
                                          backgroundColor: Colors.white,
                                          onExpansionChanged: (expanded) {
                                            setState(() {
                                              informationList[index]
                                                  .isExpanded = expanded;
                                            });
                                          },
                                          leading: Checkbox(
                                            activeColor: Colors.cyan,
                                            value: informationList[index]
                                                .isSelected,
                                            onChanged: (value) {
                                              setState(() {
                                                informationList[index]
                                                    .isSelected = value!;
                                              });
                                            },
                                          ),
                                          title: Row(
                                            children: [
                                              Image.network(
                                                informationList[index]
                                                    .favicon_url,
                                                width: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              SizedBox(
                                                width: 175,
                                                child: Text(
                                                  informationList[index].title,
                                                  style: TextStyle(
                                                      color: titleColor,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                          children: [
                                            Column(children: [
                                              SizedBox(
                                                height: 236,
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Text(
                                                          informationList[index]
                                                              .content),
                                                    )),
                                              ),
                                              Center(
                                                child: InkWell(
                                                  // InkWell을 사용하여 텍스트를 터치 가능하게 만듭니다.
                                                  onTap: () async {
                                                    final url =
                                                        informationList[index]
                                                            .url;
                                                    if (await canLaunchUrl(
                                                        Uri.parse(url))) {
                                                      await launchUrl(Uri.parse(
                                                          url)); // URL을 엽니다.
                                                    } else {
                                                      throw 'Could not launch $url';
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 4.0),
                                                    child: Text(
                                                      informationList[index]
                                                          .url,
                                                      style: const TextStyle(
                                                          color: Colors.blue,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]),
                                          ],
                                        ),
                                      );
                                    },
                                  )),
                      ),
                      CreateButton(),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!indexRender && !isLoading)
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width > 700
                                  ? MediaQuery.of(context).size.width / 2
                                  : MediaQuery.of(context).size.width / 1.2,
                              alignment: Alignment.center,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Project Name",
                                      style: TextStyle(
                                          color: Colors.cyan,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  const Text("프로젝트 이름을 정해주세요",
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 14)),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: projectNameController,
                                    cursorColor: Colors.grey.shade600,
                                    decoration: const InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 1.0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 1.0,
                                        ),
                                      ),
                                      hintText: "프로젝트 이름을 입력해주세요",
                                      contentPadding: EdgeInsets.all(18.0),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  )
                                ],
                              ),
                            ),
                          ),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width > 700
                                ? MediaQuery.of(context).size.width / 2
                                : MediaQuery.of(context).size.width / 1.2,
                            height: isLoading
                                ? MediaQuery.of(context).size.height / 2
                                : MediaQuery.of(context).size.height / 1.2,
                            alignment: Alignment.center,
                            child: isLoading
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      JumpingDots(
                                        numberOfDots: 3,
                                        color: Colors.cyan,
                                        animationDuration:
                                            const Duration(milliseconds: 500),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        indexRender
                                            ? "관련 자료를 찾고 있습니다..."
                                            : "목차를 생성 중입니다...",
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        indexRender
                                            ? "Table of Contents"
                                            : "Topic | Purpose",
                                        style: const TextStyle(
                                            color: Colors.cyan,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          indexRender
                                              ? "다음과 같이 목차를 작성해봤어요.\n목차를 기준으로 관련 자료를 수집하고 초안을 작성해요! 필요하신 경우 수정해주세요"
                                              : "해당 프로젝트의 주제/ 목적을 알려주세요. \nAssistant가 목차와 관련 자료를 찾아드려요!",
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14)),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2.5,
                                        child: TextField(
                                          controller: purposeController,
                                          maxLines: null,
                                          focusNode: purposeFocus,
                                          decoration: InputDecoration(
                                            //floatingLabelBehavior: FloatingLabelBehavior.always,
                                            labelText:
                                                indexRender ? "목차" : "Purpose",
                                            labelStyle: TextStyle(
                                              color: purposeFocus.hasFocus
                                                  ? Colors.lightBlueAccent
                                                  : Colors.grey,
                                            ),

                                            hintStyle: TextStyle(
                                                color: Colors.grey.shade600),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 1.0,
                                              ),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 1.0,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.transparent,
                                                width: 1.0,
                                              ),
                                            ),
                                          ),
                                          cursorColor: Colors.grey.shade600,
                                        ),
                                      ),
                                      CreateButton(),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],
                    ),
                  ),
          ],
        ));
  }

  Widget CreateButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 48,
          horizontal: MediaQuery.of(context).size.width > 700
              ? MediaQuery.of(context).size.width / 8
              : MediaQuery.of(context).size.width / 4),
      child: Center(
        child: InkWell(
          onTap: () async {
            if (getSuggestion) {
              List<Information> selectedInformationList =
                  informationList.where((info) => info.isSelected).toList();

              MyFluroRouter.router.navigateTo(
                  context, "/add/data/$projectName/manual",
                  routeSettings: RouteSettings(arguments: {
                    "selectedInformationList": selectedInformationList,
                    "projectName": projectName
                  }));
            } else if (projectNameController.text.isNotEmpty &&
                purposeController.text.isNotEmpty &&
                !indexRender) {
              setState(() {
                isLoading = true;
              });

              final indexResponse = await ProjectAPI.createProject(
                  projectNameController.text, purposeController.text);

              setState(() {
                projectName = projectNameController.text;
                indexRender = true;
                isLoading = false;
                purposeController.text = indexResponse['table'];
                projectId = indexResponse['projectId'];
              });
            } else if (purposeController.text.isNotEmpty && indexRender) {
              setState(() {
                isLoading = true;
              });
              ProjectAPI.postSuggestion(projectId, purposeController.text);
              final suggestionResponse =
                  await ProjectAPI.getSuggestion(projectId);

              suggestionResponse.forEach((key, value) {
                switch (key) {
                  case 'youtube':
                    List<dynamic> youtubeData = suggestionResponse['youtube'];
                    // YouTube 데이터 처리 코드
                    for (var item in youtubeData) {
                      informationList.add(Information(
                          'youtube',
                          item['title'],
                          item['description'],
                          item['link'],
                          "https://www.gstatic.com/youtube/img/branding/favicon/favicon_144x144.png",
                          false,
                          false));
                    }
                    break;

                  case 'google':
                    List<dynamic> googleData = suggestionResponse['google'];
                    // Google 데이터 처리 코드
                    for (var item in googleData) {
                      informationList.add(Information(
                          'google',
                          item['title'],
                          item['description'],
                          item['link'],
                          "https://www.google.com/favicon.ico",
                          false,
                          false));
                    }

                    break;

                  case 'kostat':
                    List<dynamic> kostatData = suggestionResponse['kostat'];
                    for (var item in kostatData) {
                      informationList.add(Information(
                          'kostat',
                          item['title'],
                          item['description'],
                          item['link'],
                          "https://kostat.go.kr/img/logo/favicon.png",
                          false,
                          false));
                    }

                    break;

                  case 'naver':
                    List<dynamic> naverData = suggestionResponse['naver'];
                    for (var item in naverData) {
                      informationList.add(Information(
                          'naver',
                          item['title'],
                          item['description'],
                          item['link'],
                          "https://www.naver.com/favicon.ico?1",
                          false,
                          false));
                    }

                    break;

                  default:
                    // 알 수 없는 키에 대한 처리

                    break;
                }
              });

              setState(() {
                getSuggestion = true;
                isLoading = false;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 64,
              horizontal: MediaQuery.of(context).size.width / 16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [
                  Colors.indigo,
                  Colors.cyan,
                ], // 그라데이션 색상 설정
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Text(
              "Continue",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class Information {
  final String source;
  final String title;
  final String content;
  final String favicon_url;
  final String url;

  bool isSelected;
  bool isExpanded;

  Information(this.source, this.title, this.content, this.url, this.favicon_url,
      this.isSelected, this.isExpanded);
}
