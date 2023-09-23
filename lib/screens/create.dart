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
  String topic = "";
  bool isLoading = false;
  bool getSuggestion = false;
  bool indexRender = false;
  String projectName = "";
  late int projectId;
  bool selectedInformationListisExeed = false;
  bool isAllSelected = false;
  List<String> candidate = [
    "전기자동차 시장 전망과 국내 자동차 동향",
    "어업 실태조사",
    "국내 제조업 동향",
    "농민 평균 소득과 국민 평균 소득의 비교"
  ];
  @override
  void initState() {
    super.initState();

    //var cookie = Cookie.create();
  }

  @override
  void dispose() {
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
                    'Copyright © 2023 audrey.AI. All Rights Reserved.',
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12.0,
                        color: Colors.white),
                  ),
                ]),
          ),
          children: [
            if (!isLoading)
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 24.0, left: 24.0, top: 24.0),
                  child: Text(
                    projectName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            if (!isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    topic,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  "",
                  style: TextStyle(
                    color: Colors.transparent,
                    fontSize: 24,
                  ),
                ),
              ),
            getSuggestion
                ? Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width > 700
                            ? MediaQuery.of(context).size.width * 0.6
                            : MediaQuery.of(context).size.width * 0.95,
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Suggestion",
                              //textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            const Text(
                                "다음과 같이 자료를 찾아봤어요!\n원하시는 자료를 선택해주시면 선택하신 자료를 Agent가 학습해 보고서 작성을 도와드려요!\n현재는 3개까지의 자료 선택을 지원해 드려요!",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(
                              height: 8,
                            ),
                            const Divider(color: Colors.grey),
                            // const SizedBox(
                            //   height: 8,
                            // ),
                            // SizedBox(
                            //   //width: MediaQuery.of(context).size.width ,
                            //   child: Row(
                            //     children: [
                            //       Checkbox(
                            //         checkColor: Colors.white,
                            //         activeColor: Colors.blue,
                            //         value: isAllSelected,
                            //         onChanged: (value) {
                            //           setState(() {
                            //             isAllSelected = !isAllSelected;
                            //             for (var item in informationList) {
                            //               item.isSelected = isAllSelected;
                            //             }
                            //           });
                            //         },
                            //       ),
                            //       Text(
                            //         isAllSelected ? '전체 해제' : '전체 선택',
                            //         style: const TextStyle(color: Colors.white),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            const SizedBox(
                              height: 12,
                            ),
                            SelectableRegion(
                              selectionControls: materialTextSelectionControls,
                              focusNode:
                                  suggestionFocus, // initialized to FocusNode()
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width > 700
                                      ? MediaQuery.of(context).size.width * 0.6
                                      : MediaQuery.of(context).size.width *
                                          0.95,
                                  height:
                                      MediaQuery.of(context).size.height / 1.2,
                                  child:
                                      //  MediaQuery.of(context).size.width < 700
                                      //     ?
                                      ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 12),
                                    itemCount: informationList.length,
                                    itemBuilder: (context, index) {
                                      // bool isExpanded =
                                      //     informationList[index].isExpanded;

                                      Color titleColor = Colors.white;
                                      //  isExpanded
                                      //     ? Colors.black
                                      //     : Colors.white;

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 46, 50, 52),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          // border: Border.all(color: Colors.grey),
                                        ),
                                        width: double.infinity,
                                        child: ExpansionTile(
                                          initiallyExpanded:
                                              informationList[index].isExpanded,
                                          clipBehavior: Clip.antiAlias,
                                          backgroundColor: Colors.transparent,
                                          iconColor: Colors.grey,
                                          onExpansionChanged: (expanded) {
                                            setState(() {
                                              informationList[index]
                                                  .isExpanded = expanded;
                                            });
                                          },
                                          leading: Checkbox(
                                            activeColor: Colors.blue,
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
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
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
                                              child: Text(
                                                informationList[index].content,
                                                style: const TextStyle(
                                                    color: Colors.white70),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                final url =
                                                    informationList[index].url;
                                                if (await canLaunchUrl(
                                                    Uri.parse(url))) {
                                                  await launchUrl(Uri.parse(
                                                      url)); // URL을 엽니다.
                                                } else {
                                                  throw 'Could not launch $url';
                                                }
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                child: Text(
                                                  informationList[index].url,
                                                  style: const TextStyle(
                                                      color: Colors.blue,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )),
                            ),
                            if (selectedInformationListisExeed)
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color: Colors.red),
                                    SizedBox(width: 12),
                                    Text("세개 이하의 자료를 선택해주세요!",
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            const SizedBox(
                              height: 12,
                            ),
                            CreateButton(),
                          ],
                        ),
                      ),
                    ),
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
                                  const Text("Name",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 12),
                                  TextField(
                                    style: const TextStyle(color: Colors.white),
                                    controller: projectNameController,
                                    cursorColor: Colors.grey.shade600,
                                    decoration: const InputDecoration(
                                      fillColor:
                                          Color.fromARGB(255, 46, 50, 52),
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
                                      hintText: "프로젝트 이름을 정해주세요",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      contentPadding: EdgeInsets.all(18.0),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
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
                                        color: Colors.blue,
                                        animationDuration:
                                            const Duration(milliseconds: 500),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        indexRender
                                            ? "관련 자료를 찾고 있습니다"
                                            : "목차를 생성 중입니다",
                                        style: const TextStyle(
                                            color: Colors.grey,
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
                                            : "Topic",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        indexRender
                                            ? "다음과 같이 목차를 작성해봤어요. \n목차를 기준으로 관련 자료를 수집하고 초안을 작성해요! 필요하신 경우 수정해주세요"
                                            : "프로젝트의 주제를 알려주세요. \nAgent가 목차를 작성하고 관련 자료를 찾아드려요",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      const SizedBox(height: 12),
                                      if (!indexRender)
                                        SizedBox(
                                          height: 36,
                                          child: GridView.builder(
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width >
                                                                  1000
                                                              ? 4
                                                              : 2, // 한 줄에 세 개의 열
                                                      mainAxisSpacing: 12,
                                                      mainAxisExtent: 36,
                                                      crossAxisSpacing: 12),
                                              itemCount: candidate.length,
                                              itemBuilder: (context, index) {
                                                return InkWell(
                                                    onTap: () {
                                                      purposeController.text =
                                                          candidate[index];
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade700,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                            candidate[index],
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                      ),
                                                    ));
                                              }),
                                        ),
                                      if (!indexRender)
                                        const SizedBox(height: 12),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        height: indexRender
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2.5
                                            : MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                4,
                                        child: TextField(
                                          style: const TextStyle(
                                              color: Colors.white),
                                          controller: purposeController,
                                          maxLines: 200,
                                          keyboardType: TextInputType.multiline,
                                          decoration: InputDecoration(
                                            //floatingLabelBehavior: FloatingLabelBehavior.always,
                                            hintText: indexRender
                                                ? "1.소제목 \n-구성1\n-구성2"
                                                : "주제를 알려주세요",

                                            hintStyle: const TextStyle(
                                                color: Colors.grey),
                                            filled: true,
                                            fillColor: const Color.fromARGB(
                                                255, 46, 50, 52),
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
              if (selectedInformationList.length > 3) {
                setState(() {
                  selectedInformationListisExeed = true;
                });
              } else {
                ProjectAPI.selectSuggestion(projectId, selectedInformationList);
                MyFluroRouter.router.navigateTo(
                    context, "/add/data/$projectName/$projectId/manual",
                    routeSettings: RouteSettings(arguments: {
                      "selectedInformationList": selectedInformationList,
                      "projectName": projectName,
                      "projectId": projectId
                    }));
              }
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
                topic = purposeController.text;
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
                          item['id'],
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
                          item['id'],
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
                          item['id'],
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
                          item['id'],
                          false,
                          false));
                    }

                    break;
                  case 'gallup':
                    List<dynamic> gallupData = suggestionResponse['gallup'];
                    for (var item in gallupData) {
                      informationList.add(Information(
                          'gallup',
                          item['title'],
                          item['description'],
                          item['link'],
                          "https://www.naver.com/favicon.ico?1",
                          item['id'],
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
              horizontal: MediaQuery.of(context).size.width / 24, //16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [
                  Colors.indigo,
                  Colors.blue,
                ], // 그라데이션 색상 설정
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              getSuggestion
                  ? "Add Reference"
                  : indexRender
                      ? "Search Reference"
                      : "Continue",
              style: const TextStyle(
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
  int id;
  bool isSelected;
  bool isExpanded;

  Information(this.source, this.title, this.content, this.url, this.favicon_url,
      this.id, this.isSelected, this.isExpanded);
}
