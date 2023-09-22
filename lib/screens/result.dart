import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:researchtool/api/project.dart';
import 'package:researchtool/main.dart';
import 'package:researchtool/model/dratf.dart';
import 'package:researchtool/model/data.dart';
import 'package:researchtool/screens/datasource.dart';
import 'package:researchtool/screens/chat.dart';
import 'package:researchtool/screens/draft.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen(
      {Key? key,
      required this.draftId,
      required this.projectName,
      required this.projectId})
      : super(key: key);

  final int draftId;
  final String projectName;
  final int projectId;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  int pageIndex = 0;
  int dataPageIndex = 0;
  late PageController dataPageController;

  PageController pageController = PageController(initialPage: 0);
  bool isTrained = false;
  int _uniqueIdCounter = 0; // 유니크한 ID를 위한 카운터
  int _uniqueIdYoutubeCounter = 0;
  int _uniqueIdFileCounter = 0;
  int _uniqueIdImageCounter = 0;

  //late
  late String projectName;
  late int draftId;

  //Data Source

  TextEditingController textInputController = TextEditingController();
  TextEditingController indexController = TextEditingController();
  FocusNode indexFocus = FocusNode();
  bool indexEdit = false;
  List<UrlContainer> urlContainers = [];

  List<UrlContainer> youtubeLinksContainers = [];
  List<FileData> _pickedFiles = [];
  List<FileData> _pickedImages = [];
  final List<FileData> _pickedAudio = [];
  //Delete
  List<int> deletedSugId = [];
  List<int> deletedAddId = [];

  bool dataSavingInProgress = false;

  late DraftModel _draftmodelProvider;
  @override
  void initState() {
    super.initState();
    dataPageController = PageController(keepPage: true);
    draftId = widget.draftId;
    projectName = widget.projectName;

    getDataSourcesfromServer();

    indexFocus.addListener(() {
      if (indexFocus.hasFocus) {
        //포커스노드가 포커스를 가지고 있을 때
        setState(() {
          indexEdit = true;
        });
      } else if (!indexFocus.hasFocus) {
        //포커스노드가 포커스를 가지고 있지 않을 때
        setState(() {
          indexEdit = false;
        });
      }
    });
    _draftmodelProvider = Provider.of<DraftModel>(context, listen: false);
    initDraft();
  }

  void initDraft() async {
    if (draftId == 0) {
      draftId = await _draftmodelProvider.genDraft(widget.projectId);
      _draftmodelProvider.getDraftStatusforState(draftId);
      setState(() {
        isTableVisible = true;
      });
    } else {
      _draftmodelProvider.getDraftStatusforState(draftId);
      setState(() {
        isTableVisible = true;
      });
    }
  }

  void getDataSourcesfromServer() async {
    //init
    urlContainers = [];
    youtubeLinksContainers = [];
    deletedSugId = [];
    deletedAddId = [];
    textInputController.text = "";
    _uniqueIdCounter = 0; // 유니크한 ID를 위한 카운터
    _uniqueIdYoutubeCounter = 0;
    _uniqueIdFileCounter = 0;
    _pickedFiles = [];
    _pickedImages = [];
    //Request
    Map datasource = await ProjectAPI.getDatasource(widget.projectId);

    for (final entry in datasource.entries) {
      if (entry.key == "suggestion") {
        for (final val in entry.value) {
          if (val["source"] == "youtube") {
            TextEditingController textContrlr = TextEditingController();

            textContrlr.text = val['link'];

            final suggestionId = val['id'];

            UrlContainer newContainer = UrlContainer(
              controller: textContrlr,
              id: _uniqueIdYoutubeCounter, // Assign a unique ID
              isYoutube: true,
              fromServer: true,
              suggestionId: suggestionId,
              onDelete: (id) {
                deletedSugId.add(suggestionId!);
                setState(() {
                  youtubeLinksContainers
                      .removeWhere((container) => container.id == id);
                });
              },
            );

            youtubeLinksContainers.add(newContainer);
            _uniqueIdYoutubeCounter++; // ID 증가
          } else {
            TextEditingController textContrlr = TextEditingController();
            textContrlr.text = val["link"];

            final suggestionId = val['id'];

            UrlContainer newContainer = UrlContainer(
              controller: textContrlr,
              id: _uniqueIdCounter, // Assign a unique ID
              fromServer: true,
              suggestionId: suggestionId,
              onDelete: (id) {
                deletedSugId.add(suggestionId!);
                setState(() {
                  urlContainers.removeWhere((container) => container.id == id);
                });
              },
            );

            urlContainers.add(newContainer);
            _uniqueIdCounter++; // ID 증가
          }
        }
      }
      // User's Add
      else if (entry.key == "web_pages") {
        if (entry.value.isNotEmpty) {
          for (final val in entry.value) {
            TextEditingController textContrlr = TextEditingController();
            textContrlr.text = val["source"];
            final serverId = val['id'];

            UrlContainer newContainer = UrlContainer(
              controller: textContrlr,
              id: _uniqueIdCounter, // Assign a unique ID
              fromServer: true,
              addId: serverId,
              onDelete: (id) {
                deletedAddId.add(serverId!);
                setState(() {
                  urlContainers.removeWhere((container) => container.id == id);
                });
              },
            );

            urlContainers.add(newContainer);
            _uniqueIdCounter++; // ID 증가
          }
        }
      } else if (entry.key == "text") {
        if (entry.value.isNotEmpty) {
          textInputController.text = entry.value[0]["source"];
        }
      } else if (entry.key == "files") {
        try {
          if (entry.value.isNotEmpty) {
            for (final pdfSource in entry.value) {
              String source = pdfSource["source"];
              int pdfId = pdfSource["id"];
              String pdfName = pdfSource["filename"];

              _pickedFiles.add(FileData(
                  fileListId: _uniqueIdFileCounter,
                  serverId: pdfId,
                  contents: PlatformFile(
                    name: pdfName,
                    size: 0,
                    identifier: source,
                  )));
              _uniqueIdFileCounter++;
              //_downloadFile(pdfSource, pdfId);
            }
          }
        } catch (e) {
          print(e);
        }
      } else if (entry.key == "images") {
        try {
          if (entry.value.isNotEmpty) {
            for (final imgSource in entry.value) {
              String imagesource = imgSource["source"];
              int imgId = imgSource["id"];
              String imgName = imgSource["filename"];

              _pickedImages.add(FileData(
                  fileListId: _uniqueIdImageCounter,
                  serverId: imgId,
                  contents: PlatformFile(
                    name: imgName,
                    size: 0,
                    identifier: imagesource,
                  )));
              _uniqueIdImageCounter++;
            }
          }
        } catch (e) {
          print(e);
        }
      } else if (entry.key == "youtube") {
        if (entry.value.isNotEmpty) {
          for (final val in entry.value) {
            TextEditingController textContrlr = TextEditingController();

            textContrlr.text = val['source'];
            final serverId = val['id'];

            UrlContainer newContainer = UrlContainer(
              controller: textContrlr,
              id: _uniqueIdYoutubeCounter, // Assign a unique ID
              isYoutube: true,
              addId: serverId,
              fromServer: true,
              onDelete: (
                id,
              ) {
                deletedAddId.add(serverId);
                setState(() {
                  youtubeLinksContainers
                      .removeWhere((container) => container.id == id);
                });
              },
            );

            youtubeLinksContainers.add(newContainer);
            _uniqueIdYoutubeCounter++; // ID 증가
          }
        }
      } else if (entry.key == "audio") {
        try {
          if (entry.value.isNotEmpty) {
            for (final audioSource in entry.value) {
              String source = audioSource["source"];
              int audioId = audioSource["id"];
              String audioName = audioSource["filename"];

              _pickedAudio.add(FileData(
                  fileListId: 0,
                  serverId: audioId,
                  contents: PlatformFile(
                    name: audioName,
                    size: 0,
                    identifier: source,
                  )));
//              _uniqueIdImageCounter++;
            }
          }
        } catch (e) {
          print(e);
        }
      }
    }
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        for (final file in result.files) {
          _pickedFiles.add(FileData(
              serverId: -1, contents: file, fileListId: _uniqueIdFileCounter));
          _uniqueIdFileCounter++;
        }
      });
    } else {}
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _pickedAudio.add(FileData(
            contents: result.files.single, serverId: -1, fileListId: 0));
      });
    } else {
      print('No file selected');
    }
  }

  Color getRandomColor() {
    final Random random = Random();
    final blueComponent = random.nextInt(156) + 100; // 파란색 계열 컴포넌트
    final redComponent = random.nextInt(256);
    final greenComponent = random.nextInt(256);
    return Color.fromRGBO(redComponent, greenComponent, blueComponent, 1.0);
  }

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
      allowMultiple: true,
    );

    if (result != null) {
      for (final image in result.files) {
        setState(() {
          _pickedImages.add(FileData(
              contents: image,
              serverId: -1,
              fileListId: _uniqueIdImageCounter));
        });
        _uniqueIdImageCounter++;
      }
    } else {}
  }

  @override
  void dispose() {
    textInputController.dispose();
    indexController.dispose();
    for (var container in urlContainers) {
      container.controller.dispose(); // 컨트롤러 해제
    }
    for (var container in youtubeLinksContainers) {
      container.controller.dispose(); // 컨트롤러 해제
    }
    pageController.dispose();
    dataPageController.dispose();
    super.dispose();
  }

  bool isBoxVisible = false;
  bool isTableVisible = false;
  void toggleBoxVisibility() {
    setState(() {
      isBoxVisible = !isBoxVisible;
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
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
                // 삭제 로직 실행
                bool deleteSuccess =
                    await ProjectAPI.deleteProject(widget.projectId);
                if (!mounted) return;
                if (deleteSuccess) {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  MyFluroRouter.router.navigateTo(context, "/");
                } else {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                }
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

  void _showSaveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check,
                color: Colors.green.shade800,
                size: 48,
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("저장"),
              ),
            ],
          ),
          content: const Text("저장이 완료되었습니다!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                setState(() {
                  dataPageIndex = 0;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade400,
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
  Widget build(BuildContext context) {
    super.build(context);
    bool isDesktop = MediaQuery.of(context).size.width > 700;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: const Color.fromRGBO(30, 34, 42, 1),
        drawerEnableOpenDragGesture: false,
        appBar: !isDesktop
            ? AppBar(
                leading: Builder(
                  builder: (context) => // Ensure Scaffold is in context
                      IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.grey,
                          ),
                          onPressed: () => Scaffold.of(context).openDrawer()),
                ),
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
              )
            : null,
        drawer: Drawer(
          backgroundColor: const Color.fromARGB(255, 36, 36, 36),
          child: Column(
            children: [
              pageButtonLayoutonMobile(height),
            ],
          ),
        ),
        body: Consumer<DraftModel>(
          builder: (context, provider, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              width < 700
                  ? Container(height: height / 24)
                  : SizedBox(child: pageButtonLayoutonBrowser(width)),
              if (width > 700)
                const Divider(
                  color: Colors.grey,
                  thickness: 0.1,
                  height: 0,
                ),
              SizedBox(
                width: width,
                height: height / 1.2,
                child: mainPageView(isDesktop, width, height, provider),
              )
            ],
          ),
        ));
  }

  Widget pageButtonLayoutonMobile(height) {
    double btnHeight = height > 500 ? height / 12 : 50;
    return SizedBox(
      height: height - 128,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    MyFluroRouter.router.navigateTo(context, "/");
                  },
                  child: const Image(
                    height: 48,
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  projectName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 12),
              Container(
                  width: 84,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    // border: Border.all(
                    //     color: _draftmodelProvider.embeddingComplete ||
                    //             _draftmodelProvider.isTrained
                    //         ? Colors.grey.shade400
                    //         : Colors.red.shade600)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _draftmodelProvider.embeddingComplete ||
                              _draftmodelProvider.isTrained
                          ? Icon(Icons.refresh,
                              size: 20, color: Colors.grey.shade400)
                          : SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.red.shade600),
                              ),
                            ),
                      Text(
                        "  학습중",
                        style: TextStyle(
                          fontSize: 12,
                          color: _draftmodelProvider.embeddingComplete ||
                                  _draftmodelProvider.isTrained
                              ? Colors.grey.shade400
                              : Colors.red.shade600,
                        ),
                      ),
                    ],
                  )),
              const SizedBox(width: 12),
              Container(
                  width: 84,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    // border: Border.all(
                    // color: _draftmodelProvider.embeddingComplete ||
                    //         _draftmodelProvider.isTrained
                    //     ? Colors.lightGreen
                    //     : Colors.grey.shade400)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.check,
                          size: 20,
                          color: _draftmodelProvider.embeddingComplete ||
                                  _draftmodelProvider.isTrained
                              ? Colors.lightGreen
                              : Colors.grey.shade400),
                      Text(
                        " 학습완료",
                        style: TextStyle(
                            fontSize: 12,
                            color: _draftmodelProvider.embeddingComplete ||
                                    _draftmodelProvider.isTrained
                                ? Colors.lightGreen
                                : Colors.grey.shade400),
                      ),
                    ],
                  )),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
              height: btnHeight,
              child: pageButton("내 문서", 0, Icons.edit_document)),
          SizedBox(
              height: btnHeight,
              child: pageButton("참고자료", 1, Icons.dataset_outlined)),
          SizedBox(
              height: btnHeight,
              child: pageButton("질문하기", 2, Icons.chat_outlined)),
          SizedBox(
              height: btnHeight,
              child: pageButton("삭제하기", 3, Icons.delete_outlined)),
          Flexible(child: Container()),
        ],
      ),
    );
  }

  Widget pageButtonLayoutonBrowser(width) {
    return SizedBox(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    MyFluroRouter.router.navigateTo(context, "/");
                  },
                  child: const Image(
                    height: 64,
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 512),
                      child: Text(
                        projectName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 84,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              // border: Border.all(
                              //     color:
                              //         _draftmodelProvider.embeddingComplete ||
                              //                 _draftmodelProvider.isTrained
                              //             ? Colors.grey.shade400
                              //             : Colors.red.shade600)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _draftmodelProvider.embeddingComplete ||
                                        _draftmodelProvider.isTrained
                                    ? Icon(Icons.refresh,
                                        size: 20, color: Colors.grey.shade400)
                                    : SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.red.shade600),
                                        ),
                                      ),
                                Text(
                                  "  학습중",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        _draftmodelProvider.embeddingComplete ||
                                                _draftmodelProvider.isTrained
                                            ? Colors.grey.shade400
                                            : Colors.red.shade600,
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(width: 8),
                        Container(
                            width: 84,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              //border: Border.all(
                              // color:
                              //     _draftmodelProvider.embeddingComplete ||
                              //             _draftmodelProvider.isTrained
                              //         ? Colors.lightGreen
                              //         : Colors.grey.shade400)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.check,
                                    size: 20,
                                    color:
                                        _draftmodelProvider.embeddingComplete ||
                                                _draftmodelProvider.isTrained
                                            ? Colors.lightGreen
                                            : Colors.grey.shade400),
                                Text(
                                  " 학습완료",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: _draftmodelProvider
                                                  .embeddingComplete ||
                                              _draftmodelProvider.isTrained
                                          ? Colors.lightGreen
                                          : Colors.grey.shade400),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
              width: 128,
              child: pageButton("내 문서", 0, Icons.edit_document, onWeb: true)),
          SizedBox(
              width: 128,
              child: pageButton("참고자료", 1, Icons.document_scanner_outlined,
                  onWeb: true)),
          SizedBox(
              width: 128,
              child: pageButton("질문하기", 2, Icons.chat_outlined, onWeb: true)),
          SizedBox(
              width: 128,
              child: pageButton("삭제하기", 3, Icons.delete_outlined, onWeb: true)),
        ],
      ),
    );
  }

  Widget pageButton(String title, int page, IconData iconData,
      {bool onWeb = false}) {
    final fontColor = pageIndex == page ? Colors.white : Colors.grey.shade700;
    final lineColor = pageIndex == page ? Colors.white : Colors.transparent;

    return InkWell(
      splashColor: const Color(0xFF204D7E),
      onTap: () {
        if (page == 3) {
          _showDeleteConfirmationDialog(context);
        } else {
          pageBtnOnTap(page);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: onWeb
            ? Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: <Widget>[
                        Icon(iconData, size: 18, color: fontColor),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: TextStyle(
                              color: fontColor,
                              fontWeight: pageIndex == page
                                  ? FontWeight.w500
                                  : FontWeight.w100),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Container(
                child: Stack(children: [
                  Row(
                    children: <Widget>[
                      Container(
                        width: 1,
                        color: lineColor,
                      ),
                      const SizedBox(width: 32),
                      Icon(iconData, size: 24, color: fontColor),
                      const SizedBox(width: 16),
                      Text(
                        title,
                        style: TextStyle(
                            color: fontColor,
                            fontSize: 14,
                            fontWeight: pageIndex == page
                                ? FontWeight.w500
                                : FontWeight.w100),
                      ),
                    ],
                  ),
                  Positioned(
                      right: 12,
                      top: 10,
                      child: Icon(Icons.arrow_forward_ios_outlined,
                          color: fontColor, size: 18))
                ]),
              ),
      ),
    );
  }

  Widget mainPageView(isWeb, width, height, provider) {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      children: <Widget>[
        pageItem(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                width > 700 ? MainAxisAlignment.end : MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width > 700 ? width / 5.5 : 0,
                height: height / 1.2,
                child: width > 700
                    ? Stack(children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          left: isTableVisible ? 0 : -200, // 왼쪽으로 이동하여 숨기거나 표시
                          top: 64,
                          child: isTableVisible
                              ? Container(
                                  height: height / 1.5,
                                  width: (width) / 6,
                                  decoration: BoxDecoration(
                                      color:
                                          const Color.fromARGB(255, 46, 50, 52),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              const Text("콘텐츠",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white)),
                                              const Spacer(),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    isTableVisible = false;
                                                  });
                                                },
                                                child: const Icon(Icons.cancel,
                                                    color: Colors.blue),
                                              ),
                                            ]),
                                        const Divider(color: Colors.grey),
                                        SizedBox(
                                            width: width / 5.5,
                                            height: height / 1.8,
                                            child: ListView.separated(
                                              separatorBuilder: (context,
                                                      index) =>
                                                  const SizedBox(height: 12),
                                              itemCount: provider.table.length,
                                              itemBuilder: (context, index) {
                                                Color titleColor = Colors.white;

                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                        255, 46, 50, 52),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    // border: Border.all(color: Colors.grey),
                                                  ),
                                                  width: double.infinity,
                                                  child: ExpansionTile(
                                                    initiallyExpanded: false,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    iconColor: Colors.grey,
                                                    // onExpansionChanged: (expanded) {
                                                    //   setState(() {
                                                    //     informationList[index]
                                                    //         .isExpanded = expanded;
                                                    //   });
                                                    // },
                                                    // leading: Checkbox(
                                                    //   activeColor: Colors.blue,
                                                    //   value: informationList[index]
                                                    //       .isSelected,
                                                    //   onChanged: (value) {
                                                    //     setState(() {
                                                    //       informationList[index]
                                                    //           .isSelected = value!;
                                                    //     });
                                                    //   },
                                                    // ),
                                                    title: Row(
                                                      children: [
                                                        // Image.network(
                                                        //   provider.table  [index]
                                                        //       .favicon_url,
                                                        //   width: 24,
                                                        // ),
                                                        // const SizedBox(width: 12),
                                                        SizedBox(
                                                          width: width / 10,
                                                          child: Text(
                                                            provider
                                                                .table[index],
                                                            style: TextStyle(
                                                                color:
                                                                    titleColor,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    children: [
                                                      SizedBox(
                                                        height: height / 4,
                                                        child:
                                                            ListView.separated(
                                                                separatorBuilder: (context,
                                                                        index) =>
                                                                    const SizedBox(
                                                                        height:
                                                                            12),
                                                                itemCount: provider
                                                                    .reference[
                                                                        index][
                                                                        "sources"]
                                                                    .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        jndex) {
                                                                  return Tooltip(
                                                                    preferBelow:
                                                                        true,
                                                                    verticalOffset:
                                                                        12,
                                                                    margin: EdgeInsets.only(
                                                                        left:
                                                                            24,
                                                                        right: width /
                                                                            2), //here you change the margin
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            12),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                20),
                                                                        color: Colors
                                                                            .black),
                                                                    textStyle:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .white70,
                                                                    ),
                                                                    message:
                                                                        "🔍 ${provider.reference[index]["sources"][jndex]['data']}",
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        final url =
                                                                            provider.reference[index]["sources"][jndex]["data_path"];
                                                                        if (await canLaunchUrl(
                                                                            Uri.parse(url))) {
                                                                          await launchUrl(
                                                                              Uri.parse(url)); // URL을 엽니다.
                                                                        } else {
                                                                          throw 'Could not launch $url';
                                                                        }
                                                                      },
                                                                      child: Container(
                                                                          decoration: BoxDecoration(color: const Color.fromARGB(255, 74, 78, 80), borderRadius: BorderRadius.circular(8)),
                                                                          child: Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child: Text(provider.reference[index]["sources"][jndex]["data_path"],
                                                                                style: const TextStyle(
                                                                                  color: Colors.white70,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                )),
                                                                          )),
                                                                    ),
                                                                  );
                                                                }),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              },
                                            ))
                                      ]),
                                    ),
                                  ),
                                )
                              : Container(),
                        ),
                        Positioned(
                            left: 2,
                            top: 12,
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isTableVisible = true;
                                  });
                                },
                                child: Icon(Icons.menu,
                                    color: isTableVisible
                                        ? Colors.white
                                        : Colors.grey,
                                    size: 32))),
                      ])
                    : Container(),
              ),
              Center(
                child: SizedBox(
                  width: isWeb ? (width) - (width) / 2.5 : width - width / 10,
                  height: height,
                  child: Draft(
                      draft: _draftmodelProvider.draft,
                      isTrained: _draftmodelProvider.isTrained,
                      projectName: widget.projectName,
                      draftId: draftId),
                ),
              ),
              if (isWeb)
                Container(
                    color: Colors.transparent,
                    width: (width) / 5,
                    height: height / 1.2,
                    child: Stack(children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        left: isBoxVisible ? 0 : 200, // 왼쪽으로 이동하여 숨기거나 표시

                        child: isBoxVisible
                            ? Container(
                                height: height / 1.5,
                                width: (width) / 5,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Column(children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Spacer(),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                isBoxVisible = false;
                                              });
                                            },
                                            child: const Icon(Icons.cancel,
                                                color: Colors.black),
                                          ),
                                          const SizedBox(width: 12),
                                        ]),
                                    const Text("곧 출시 예정이에요!"),
                                  ]),
                                ),
                              )
                            : Container(),
                      ),
                      if (!isBoxVisible)
                        Positioned(
                          top: 24,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color.fromARGB(255, 46, 50, 52),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                InkWell(
                                  child: ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (Rect bounds) =>
                                        const RadialGradient(
                                      center: Alignment.topCenter,
                                      stops: [.5, 1],
                                      colors: [
                                        Colors.indigo,
                                        Colors.cyan,
                                      ],
                                    ).createShader(bounds),
                                    child: const Icon(
                                      Icons.search,
                                      size: 28,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  onTap: () {
                                    // Handle search button press
                                  },
                                ),
                                InkWell(
                                  child: ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (Rect bounds) =>
                                        const RadialGradient(
                                      center: Alignment.topCenter,
                                      stops: [.5, 1],
                                      colors: [
                                        Colors.yellow,
                                        Colors.pink,
                                      ],
                                    ).createShader(bounds),
                                    child: const Icon(
                                      Icons.add_chart,
                                      size: 28,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  onTap: () {
                                    // Handle add chart button press
                                    //  toggleBoxVisibility(); // Toggle the box visibility
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ])),
            ])),
        pageItem(Padding(
          padding: EdgeInsets.symmetric(horizontal: width / 24),
          child: SizedBox(
            width: width,
            child: dataSavingInProgress
                ? const SpinKitFadingCircle(size: 36, color: Colors.blue)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Padding(
                            padding: EdgeInsets.only(
                                top: isWeb ? 36.0 : 0,
                                left: isWeb ? 36.0 : 0,
                                right: isWeb ? 36.0 : 0),
                            child: SizedBox(
                              height: 48,
                              // decoration: BoxDecoration(
                              //     border: Border.all(
                              //       color: Colors.white,
                              //       width: 2,
                              //     ),
                              //     borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              dataPageIndex = 0;

                                              dataPageController.animateToPage(
                                                  dataPageIndex,
                                                  duration: const Duration(
                                                      milliseconds: 1),
                                                  curve: Curves.easeInSine);
                                            });
                                          },
                                          child: Center(
                                              child: Text("Webpages",
                                                  style: TextStyle(
                                                    color: dataPageIndex == 0
                                                        ? Colors.blueAccent
                                                        : Colors.grey,
                                                    fontWeight:
                                                        dataPageIndex == 0
                                                            ? FontWeight.bold
                                                            : FontWeight.w300,
                                                    fontSize: 16,
                                                  )))),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              dataPageIndex = 1;
                                              dataPageController.animateToPage(
                                                  dataPageIndex,
                                                  duration: const Duration(
                                                      milliseconds: 1),
                                                  curve: Curves.easeInSine);
                                            });
                                          },
                                          child: Center(
                                              child: Text("Files",
                                                  style: TextStyle(
                                                    color: dataPageIndex == 1
                                                        ? Colors.blueAccent
                                                        : Colors.grey,
                                                    fontWeight:
                                                        dataPageIndex == 1
                                                            ? FontWeight.bold
                                                            : FontWeight.w300,
                                                    fontSize: 16,
                                                  )))),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              dataPageIndex = 2;
                                              dataPageController.animateToPage(
                                                  dataPageIndex,
                                                  duration: const Duration(
                                                      milliseconds: 1),
                                                  curve: Curves.easeInSine);
                                            });
                                          },
                                          child: Center(
                                              child: Text("Text",
                                                  style: TextStyle(
                                                    color: dataPageIndex == 2
                                                        ? Colors.blueAccent
                                                        : Colors.grey,
                                                    fontWeight:
                                                        dataPageIndex == 2
                                                            ? FontWeight.bold
                                                            : FontWeight.w300,
                                                    fontSize: 16,
                                                  )))),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              dataPageIndex = 3;
                                              dataPageController.animateToPage(
                                                  dataPageIndex,
                                                  duration: const Duration(
                                                      milliseconds: 1),
                                                  curve: Curves.easeInSine);
                                            });
                                          },
                                          child: Center(
                                              child: Text("Images",
                                                  style: TextStyle(
                                                    color: dataPageIndex == 3
                                                        ? Colors.blueAccent
                                                        : Colors.grey,
                                                    fontWeight:
                                                        dataPageIndex == 3
                                                            ? FontWeight.bold
                                                            : FontWeight.w300,
                                                    fontSize: 16,
                                                  )))),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              dataPageIndex = 4;
                                              dataPageController.animateToPage(
                                                  dataPageIndex,
                                                  duration: const Duration(
                                                      milliseconds: 1),
                                                  curve: Curves.easeInSine);
                                            });
                                          },
                                          child: Center(
                                              child: Text("Youtube",
                                                  style: TextStyle(
                                                    color: dataPageIndex == 4
                                                        ? Colors.blueAccent
                                                        : Colors.grey,
                                                    fontWeight:
                                                        dataPageIndex == 4
                                                            ? FontWeight.bold
                                                            : FontWeight.w300,
                                                    fontSize: 16,
                                                  )))),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              dataPageIndex = 5;
                                              dataPageController.animateToPage(
                                                  dataPageIndex,
                                                  duration: const Duration(
                                                      milliseconds: 1),
                                                  curve: Curves.easeInSine);
                                            });
                                          },
                                          child: Center(
                                              child: Text("Audio",
                                                  style: TextStyle(
                                                    color: dataPageIndex == 5
                                                        ? Colors.blueAccent
                                                        : Colors.grey,
                                                    fontWeight:
                                                        dataPageIndex == 5
                                                            ? FontWeight.bold
                                                            : FontWeight.w300,
                                                    fontSize: 16,
                                                  )))),
                                    ),
                                  ]),
                            )),
                        SizedBox(
                          height: height / 1.8,
                          width: width,
                          child: PageView(
                            controller: dataPageController,
                            children: [
                              pageItem(
                                SingleChildScrollView(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: height / 48,
                                        ),
                                        const Text(
                                          "Url",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isWeb ? width / 10 : 8,
                                          ),
                                          child: Column(
                                            children: urlContainers,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Center(
                                            child: InkWell(
                                                child: const Icon(
                                                  Icons.add_circle_rounded,
                                                  color: Colors.cyan,
                                                  size: 36,
                                                ),
                                                onTap: () {
                                                  TextEditingController
                                                      textContrlr =
                                                      TextEditingController();
                                                  setState(() {
                                                    UrlContainer newContainer =
                                                        UrlContainer(
                                                      controller: textContrlr,
                                                      id: _uniqueIdCounter, // Assign a unique ID
                                                      onDelete: (id) {
                                                        setState(() {
                                                          urlContainers
                                                              .removeWhere(
                                                                  (container) =>
                                                                      container
                                                                          .id ==
                                                                      id);
                                                        });
                                                      },
                                                    );

                                                    urlContainers
                                                        .add(newContainer);
                                                    _uniqueIdCounter++; // ID 증가
                                                  });
                                                })),
                                      ]),
                                ),
                              ),
                              pageItem(
                                Column(
                                  children: [
                                    SizedBox(
                                      height: height / 48,
                                    ),
                                    const Text(
                                      "Upload Files",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    InkWell(
                                      onTap: _pickFiles,
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 24,
                                          ),
                                          decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: const Text('파일 업로드',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                    ),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    if (_pickedFiles.isNotEmpty)
                                      SizedBox(
                                        height: height / 2,
                                        width:
                                            width > 700 ? width / 1.5 : width,
                                        child: GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width >
                                                              1000
                                                          ? 3
                                                          : 2, // 한 줄에 세 개의 열
                                                  mainAxisExtent: 156,
                                                  mainAxisSpacing: 12,
                                                  crossAxisSpacing: 12),
                                          itemCount: _pickedFiles.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 2,
                                                    color: Colors.teal),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(4)),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          getRandomColor(),
                                                          getRandomColor()
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                    ),
                                                    height: 64,
                                                  ),
                                                  Container(
                                                    height: 84,
                                                    color: Colors.transparent,
                                                    child: ListTile(
                                                      title: InkWell(
                                                          onTap: () async {
                                                            final url =
                                                                _pickedFiles[
                                                                        index]
                                                                    .contents
                                                                    .identifier!;
                                                            if (await canLaunchUrl(
                                                                Uri.parse(
                                                                    url))) {
                                                              await launchUrl(
                                                                  Uri.parse(
                                                                      url)); // URL을 엽니다.
                                                            } else {
                                                              throw 'Could not launch $url';
                                                            }
                                                          },
                                                          child: Text(
                                                              _pickedFiles[
                                                                      index]
                                                                  .contents
                                                                  .name,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                      // subtitle: Text(
                                                      //     '${_pickedFiles[index].contents.size} bytes',
                                                      // style:
                                                      //     const TextStyle(
                                                      //         color: Colors
                                                      //             .grey,
                                                      //         fontSize:
                                                      //             12)),
                                                      trailing: IconButton(
                                                        icon: const Icon(Icons
                                                            .delete_outline_rounded),
                                                        color:
                                                            Colors.red.shade500,
                                                        onPressed: () {
                                                          //서버에서 온 경우 서버꺼 삭제하려고
                                                          if (_pickedFiles[
                                                                      index]
                                                                  .serverId !=
                                                              -1) {
                                                            deletedAddId.add(
                                                                _pickedFiles[
                                                                        index]
                                                                    .serverId);
                                                          }
                                                          setState(() {
                                                            _pickedFiles.removeWhere((file) =>
                                                                file.fileListId ==
                                                                _pickedFiles[
                                                                        index]
                                                                    .fileListId);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              pageItem(
                                SingleChildScrollView(
                                  child: Column(children: [
                                    SizedBox(
                                      height: height / 48,
                                    ),
                                    const Text(
                                      "Text",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    SizedBox(height: height / 48),
                                    Container(
                                      height: height / 3,
                                      width: width > 700 ? width / 2 : width,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: TextField(
                                        maxLines: 200,
                                        controller: textInputController,
                                        cursorColor: Colors.grey,
                                        decoration: InputDecoration(
                                          //floatingLabelBehavior: FloatingLabelBehavior.always,
                                          hintText: "Text를 입력해주세요",
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
                                      ),
                                    )
                                  ]),
                                ),
                              ),
                              pageItem(
                                SizedBox(
                                  height: height / 2,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: height / 48,
                                      ),
                                      const Text(
                                        "Upload Images",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      InkWell(
                                        onTap: _pickImages,
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 24),
                                            decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: const Text('이미지 업로드',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w600))),
                                      ),

                                      const SizedBox(
                                        height: 24,
                                      ),
                                      if (_pickedImages.isNotEmpty)
                                        SizedBox(
                                          height: height / 2,
                                          width:
                                              width > 700 ? width / 1.5 : width,
                                          child: GridView.builder(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                1000
                                                            ? 3
                                                            : 2, // 한 줄에 세 개의 열
                                                    mainAxisExtent: 156,
                                                    mainAxisSpacing: 12,
                                                    crossAxisSpacing: 12),
                                            itemCount: _pickedImages.length,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 2,
                                                      color: Colors.teal),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(4)),
                                                ),
                                                child: Column(
                                                  children: [
                                                    _pickedImages[index]
                                                                .serverId ==
                                                            -1
                                                        ? Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  getRandomColor(),
                                                                  getRandomColor()
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                            ),
                                                            height: 64)
                                                        : SizedBox(
                                                            height: 64,
                                                            child:
                                                                Image.network(
                                                              _pickedImages[
                                                                      index]
                                                                  .contents
                                                                  .identifier!,
                                                              height: 64,
                                                              fit: BoxFit.cover,
                                                            )),
                                                    Container(
                                                      height: 84,
                                                      color: Colors.transparent,
                                                      child: ListTile(
                                                        title: InkWell(
                                                            onTap: () async {
                                                              final url =
                                                                  _pickedImages[
                                                                          index]
                                                                      .contents
                                                                      .identifier!;
                                                              if (await canLaunchUrl(
                                                                  Uri.parse(
                                                                      url))) {
                                                                await launchUrl(
                                                                    Uri.parse(
                                                                        url)); // URL을 엽니다.
                                                              } else {
                                                                throw 'Could not launch $url';
                                                              }
                                                            },
                                                            child: Text(
                                                                _pickedImages[
                                                                        index]
                                                                    .contents
                                                                    .name,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white))),
                                                        // subtitle: Text(
                                                        //     '${_pickedImages[index].contents.size} bytes',
                                                        // style:
                                                        //     const TextStyle(
                                                        //         color: Colors
                                                        //             .grey,
                                                        //         fontSize:
                                                        //             12)),
                                                        trailing: IconButton(
                                                          icon: const Icon(Icons
                                                              .delete_outline_rounded),
                                                          color: Colors
                                                              .red.shade500,
                                                          onPressed: () {
                                                            //서버에서 온 경우 서버꺼 삭제하려고
                                                            if (_pickedImages[
                                                                        index]
                                                                    .serverId !=
                                                                -1) {
                                                              deletedAddId.add(
                                                                  _pickedImages[
                                                                          index]
                                                                      .serverId);
                                                            }
                                                            setState(() {
                                                              _pickedImages.removeWhere((file) =>
                                                                  file.fileListId ==
                                                                  _pickedImages[
                                                                          index]
                                                                      .fileListId);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                      // (_pickedImage != null)
                                      //     ? Container(
                                      //         decoration: BoxDecoration(
                                      //           border: Border.all(
                                      //               width: 2,
                                      //               color: Colors.teal),
                                      //           borderRadius:
                                      //               const BorderRadius.all(
                                      //                   Radius.circular(20)),
                                      //           color: Colors.grey.shade200,
                                      //         ),
                                      //         height: 200,
                                      //         width: 400,
                                      //         child: ListTile(
                                      //           title: Text(_pickedImage!.name),
                                      //           // subtitle: Text(
                                      //           //     '${_pickedImage!.size} bytes'),
                                      //           trailing: const Icon(Icons
                                      //               .delete_outline_rounded),
                                      //           iconColor: Colors.red.shade500,
                                      //           onTap: () {
                                      //             setState(() {
                                      //               _pickedImage = null;
                                      //             });
                                      //           },
                                      //         ),
                                      //       )
                                      //     : GestureDetector(
                                      //         onTap: _pickImages,
                                      //         child: DropTarget(
                                      //           onDragEntered: (detail) {
                                      //             setState(() {
                                      //               _draggingImage = true;
                                      //             });
                                      //           },
                                      //           onDragExited: (detail) {
                                      //             setState(() {
                                      //               _draggingImage = false;
                                      //             });
                                      //           },
                                      //           onDragDone: (detail) async {
                                      //             if (detail.files.isNotEmpty) {
                                      //               XFile droppedFile =
                                      //                   detail.files.first;
                                      //               int fileSize =
                                      //                   await droppedFile
                                      //                       .length();
                                      //               PlatformFile file =
                                      //                   PlatformFile(
                                      //                 name: droppedFile.name,
                                      //                 path: droppedFile.path,
                                      //                 size: fileSize,
                                      //                 bytes: await droppedFile
                                      //                     .readAsBytes(),
                                      //               );

                                      //               setState(() {
                                      //                 _pickedImage = file;
                                      //                 _draggingImage = false;
                                      //               });
                                      //             }
                                      //           },
                                      //           child: Container(
                                      //             height: 200,
                                      //             width: 400,
                                      //             decoration: BoxDecoration(
                                      //               border: Border.all(
                                      //                   width: 2,
                                      //                   color: Colors.black),
                                      //               borderRadius:
                                      //                   const BorderRadius.all(
                                      //                       Radius.circular(
                                      //                           20)),
                                      //               color: _draggingImage
                                      //                   ? Colors.green.shade200
                                      //                   : Colors.grey.shade200,
                                      //             ),
                                      //             child: Center(
                                      //               child: _pickedImage == null
                                      //                   ? const Column(
                                      //                       mainAxisAlignment:
                                      //                           MainAxisAlignment
                                      //                               .center,
                                      //                       children: [
                                      //                         Icon(
                                      //                           Icons.image,
                                      //                           color:
                                      //                               Colors.grey,
                                      //                           size: 36,
                                      //                         ),
                                      //                         Text(
                                      //                           "이미지를 끌어서 놓거나 클릭하여 파일 선택",
                                      //                           style: TextStyle(
                                      //                               color: Colors
                                      //                                   .grey,
                                      //                               fontSize:
                                      //                                   14),
                                      //                         ),
                                      //                         Text(
                                      //                           "지원 파일 형식 : .png, .jpg",
                                      //                           style: TextStyle(
                                      //                               color: Colors
                                      //                                   .grey,
                                      //                               fontSize:
                                      //                                   12),
                                      //                         )
                                      //                       ],
                                      //                     )
                                      //                   : Text(
                                      //                       'Selected file: ${_pickedImage!.name}'),
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      // const SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                              pageItem(
                                SingleChildScrollView(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: height / 48,
                                        ),
                                        const Text(
                                          "Youtube Links",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isWeb ? width / 10 : 8,
                                          ),
                                          child: Column(
                                            children: youtubeLinksContainers,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Center(
                                            child: InkWell(
                                                child: const Icon(
                                                  Icons.add_circle_rounded,
                                                  color: Colors.red,
                                                  size: 36,
                                                ),
                                                onTap: () {
                                                  TextEditingController
                                                      textContrlr =
                                                      TextEditingController();
                                                  setState(() {
                                                    UrlContainer newContainer =
                                                        UrlContainer(
                                                      controller: textContrlr,
                                                      id: _uniqueIdYoutubeCounter, // Assign a unique ID
                                                      isYoutube: true,
                                                      onDelete: (id) {
                                                        setState(() {
                                                          youtubeLinksContainers
                                                              .removeWhere(
                                                                  (container) =>
                                                                      container
                                                                          .id ==
                                                                      id);
                                                        });
                                                      },
                                                    );

                                                    youtubeLinksContainers
                                                        .add(newContainer);
                                                    _uniqueIdYoutubeCounter++; // ID 증가
                                                  });
                                                })),
                                      ]),
                                ),
                              ),
                              pageItem(SizedBox(
                                  height: height / 2,
                                  child: Column(children: [
                                    SizedBox(
                                      height: height / 48,
                                    ),
                                    const Text(
                                      "Upload Audio",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    InkWell(
                                      onTap: _pickAudio,
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 24),
                                          decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: const Text('오디오 업로드',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w600))),
                                    ),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                    if (_pickedAudio.isNotEmpty)
                                      SizedBox(
                                        height: height / 2,
                                        width:
                                            width > 700 ? width / 1.5 : width,
                                        child: GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width >
                                                              1000
                                                          ? 3
                                                          : 2, // 한 줄에 세 개의 열
                                                  mainAxisExtent: 156,
                                                  mainAxisSpacing: 12,
                                                  crossAxisSpacing: 12),
                                          itemCount: _pickedAudio.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              clipBehavior: Clip.antiAlias,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 2,
                                                    color: Colors.teal),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(4)),
                                              ),
                                              child: Column(
                                                children: [
                                                  Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: [
                                                            getRandomColor(),
                                                            getRandomColor()
                                                          ],
                                                          begin:
                                                              Alignment.topLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                        ),
                                                      ),
                                                      height: 64),
                                                  Container(
                                                    height: 84,
                                                    color: Colors.transparent,
                                                    child: ListTile(
                                                      title: InkWell(
                                                          onTap: () async {
                                                            final url =
                                                                _pickedAudio[
                                                                        index]
                                                                    .contents
                                                                    .identifier!;
                                                            if (await canLaunchUrl(
                                                                Uri.parse(
                                                                    url))) {
                                                              await launchUrl(
                                                                  Uri.parse(
                                                                      url)); // URL을 엽니다.
                                                            } else {
                                                              throw 'Could not launch $url';
                                                            }
                                                          },
                                                          child: Text(
                                                              _pickedAudio[
                                                                      index]
                                                                  .contents
                                                                  .name,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                      // subtitle: Text(
                                                      //     '${_pickedImages[index].contents.size} bytes',
                                                      // style:
                                                      //     const TextStyle(
                                                      //         color: Colors
                                                      //             .grey,
                                                      //         fontSize:
                                                      //             12)),
                                                      trailing: IconButton(
                                                        icon: const Icon(Icons
                                                            .delete_outline_rounded),
                                                        color:
                                                            Colors.red.shade500,
                                                        onPressed: () {
                                                          //서버에서 온 경우 서버꺼 삭제하려고
                                                          if (_pickedAudio[
                                                                      index]
                                                                  .serverId !=
                                                              -1) {
                                                            deletedAddId.add(
                                                                _pickedAudio[
                                                                        index]
                                                                    .serverId);
                                                          }
                                                          setState(() {
                                                            _pickedAudio.removeWhere((file) =>
                                                                file.fileListId ==
                                                                _pickedAudio[
                                                                        index]
                                                                    .fileListId);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ])))
                            ],
                            onPageChanged: (index) =>
                                setState(() => dataPageIndex = index),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                dataSavingInProgress = true;
                              });
                              List<String> webPages = [];
                              //List<FileData> files = _pickedFiles;
                              List<PlatformFile> files = [];

                              List<String> text =
                                  textInputController.text.isEmpty
                                      ? []
                                      : [textInputController.text];
                              List<PlatformFile?> image = [];
                              List<String> youtube = [];
                              List<PlatformFile> audio = [];
                              for (final container in urlContainers) {
                                if (container.fromServer) {
                                  continue;
                                }
                                webPages.add(container.controller.text);
                              }
                              for (final container in youtubeLinksContainers) {
                                if (container.fromServer) {
                                  continue;
                                }
                                youtube.add(container.controller.text);
                              }
                              for (final file in _pickedFiles) {
                                if (file.serverId != -1) {
                                  continue;
                                }
                                files.add(file.contents);
                              }
                              for (final pickedImg in _pickedImages) {
                                if (pickedImg.serverId != -1) {
                                  continue;
                                }
                                image.add(pickedImg.contents);
                              }
                              for (final pickedAudio in _pickedAudio) {
                                if (pickedAudio.serverId != -1) {
                                  continue;
                                }
                                audio.add(pickedAudio.contents);
                              }
                              //TODO

                              await ProjectAPI.deleteDataSource(
                                  widget.projectId, deletedSugId, deletedAddId);

                              await ProjectAPI.addDataSource(widget.projectId,
                                  webPages, files, text, image, youtube, audio);

                              getDataSourcesfromServer();
                              setState(() {
                                dataSavingInProgress = false;
                              });
                              if (!mounted) return;
                              _showSaveConfirmationDialog(context);
                            },
                            child: Container(
                              width: width / 12 > 96 ? width / 12 : 96,
                              height:
                                  48, // Set the desired height for the button
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.indigo,
                                    Colors.blue,
                                  ], // 그라데이션 색상 설정
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "저장",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isWeb ? 12 : 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
          ),
        )),
        pageItem(Padding(
            padding: EdgeInsets.symmetric(horizontal: width / 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height / 24),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    width: isWeb ? (width) / 2 : width - width / 10,
                    child: Chat(projectId: widget.projectId),
                  ),
                ),
              ],
            ))),
      ],
      onPageChanged: (index) => setState(() {
        pageIndex = index;
        dataPageIndex = 0;
      }),
    );
  }

  pageBtnOnTap(int page) {
    setState(() {
      pageIndex = page;
      pageController.animateToPage(pageIndex,
          duration: const Duration(milliseconds: 10), curve: Curves.easeIn);
    });
  }

  Widget pageItem(Widget child) {
    double statusHeight = MediaQuery.of(context).padding.top;
    double height = MediaQuery.of(context).size.height;
    double minHeight = height - statusHeight; //- sliverMinHeight;

    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: minHeight,
        ),
        child: child,
      ),
    );
  }
}
