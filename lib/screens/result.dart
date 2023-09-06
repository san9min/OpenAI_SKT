import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:researchtool/main.dart';
import 'package:researchtool/model/dratf.dart';
import 'package:footer/footer_view.dart';
import 'package:footer/footer.dart';
import 'package:researchtool/screens/datasource.dart';
import 'package:researchtool/screens/chat.dart';
import 'package:researchtool/screens/draft.dart';

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

class _ResultScreenState extends State<ResultScreen> {
  int pageIndex = 0;
  int dataPageIndex = 0;
  PageController dataPageController = PageController(initialPage: 0);
  PageController pageController = PageController(initialPage: 0);
  bool isTrained = false;
  int _uniqueIdCounter = 0; // 유니크한 ID를 위한 카운터
  int _uniqueIdYoutubeCounter = 0;

  //late
  late String projectName;
  late int draftId;

  //Data Source
  PlatformFile? _pickedFile;
  PlatformFile? _pickedImage;
  TextEditingController textInputController = TextEditingController();
  TextEditingController indexController = TextEditingController();
  FocusNode indexFocus = FocusNode();
  bool indexEdit = false;
  List<UrlContainer> urlContainers = [];
  List<UrlContainer> youtubeLinksContainers = [];

  bool _dragging = false;
  bool _draggingImage = false;
  late DraftModel _draftmodelProvider;
  @override
  void initState() {
    super.initState();
    draftId = widget.draftId;
    projectName = widget.projectName;
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
    _draftmodelProvider.getDraftStatusforState(draftId);
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pickedFile = result.files.single;
      });
    } else {}
  }

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        _pickedImage = result.files.single;
      });
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
    super.dispose();
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
              onPressed: () {
                // 삭제 로직 실행

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(30, 34, 42, 1),
        drawerEnableOpenDragGesture: false,
        appBar: MediaQuery.of(context).size.width < 700
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pageButtonLayout(),
            ],
          ),
        ),
        body: Consumer<DraftModel>(
          builder: (context, provider, child) => FooterView(
            footer: Footer(
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
                          color: Color(0xFF162A49)),
                    ),
                  ]),
            ),
            children: [
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MediaQuery.of(context).size.width < 700
                      ? Container()
                      : SizedBox(width: 224, child: pageButtonLayout()),
                  SizedBox(
                    width: MediaQuery.of(context).size.width > 700
                        ? MediaQuery.of(context).size.width - 300
                        : MediaQuery.of(context).size.width / 1,
                    height: MediaQuery.of(context).size.height,
                    child: mainPageView(),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  Widget pageButtonLayout() {
    double btnHeight = MediaQuery.of(context).size.height > 500
        ? MediaQuery.of(context).size.height / 12
        : 50;
    return SizedBox(
      height: MediaQuery.of(context).size.height - 128,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 12,
          ),
          const Text("Assistant State",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              )),
          const SizedBox(
            height: 12,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 12),
              Container(
                  width: 84,
                  height: 36,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _draftmodelProvider.isTrained
                              ? Colors.grey.shade400
                              : Colors.red.shade600)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _draftmodelProvider.isTrained
                          ? Icon(Icons.refresh,
                              size: 18, color: Colors.grey.shade400)
                          : SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.red.shade600),
                              ),
                            ),
                      Text(
                        "  Training",
                        style: TextStyle(
                          fontSize: 12,
                          color: _draftmodelProvider.isTrained
                              ? Colors.grey.shade400
                              : Colors.red.shade600,
                        ),
                      ),
                    ],
                  )),
              const SizedBox(width: 12),
              Container(
                  width: 84,
                  height: 36,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _draftmodelProvider.isTrained
                              ? Colors.lightGreen
                              : Colors.grey.shade400)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.check,
                          size: 18,
                          color: _draftmodelProvider.isTrained
                              ? Colors.lightGreen
                              : Colors.grey.shade400),
                      Text(
                        " Trained",
                        style: TextStyle(
                            fontSize: 12,
                            color: _draftmodelProvider.isTrained
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
              child: pageButton("Draft Report", 0, Icons.edit_document)),
          SizedBox(
              height: btnHeight,
              child: pageButton("Data Sources", 1, Icons.dataset_outlined)),
          SizedBox(
              height: btnHeight,
              child: pageButton("My Reports", 2, Icons.sticky_note_2_outlined)),
          SizedBox(
              height: btnHeight,
              child: pageButton("Chat Data", 3, Icons.chat_outlined)),
          SizedBox(
              height: btnHeight,
              child: pageButton("삭제하기", 4, Icons.delete_outlined)),
          Flexible(child: Container()),
        ],
      ),
    );
  }

  Widget pageButton(String title, int page, IconData iconData) {
    final fontColor = pageIndex == page ? Colors.white : Colors.grey.shade700;
    final lineColor = pageIndex == page ? Colors.white : Colors.transparent;

    return InkWell(
      splashColor: const Color(0xFF204D7E),
      onTap: () {
        if (page == 4) {
          _showDeleteConfirmationDialog(context);
        } else {
          pageBtnOnTap(page);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Container(
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

  Widget mainPageView() {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: pageController,
      children: <Widget>[
        pageItem(Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (MediaQuery.of(context).size.width > 700)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: 256,
                        height: MediaQuery.of(context).size.height / 2,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8)),
                        child: SingleChildScrollView(
                            child: Column(children: [
                          const Text("목차",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              )),
                          TextField(
                              focusNode: indexFocus,
                              maxLines: null,
                              controller: indexController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: indexEdit
                                    ? Colors.white
                                    : Colors.transparent,
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              cursorColor: Colors.grey.shade600,
                              style: TextStyle(
                                  color:
                                      indexEdit ? Colors.black : Colors.white))
                        ])),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: 256,
                        height: MediaQuery.of(context).size.height / 4,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8)),
                        child: const SingleChildScrollView(
                            child: Column(children: [
                          Text("출처",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              )),
                          // TextField(
                          //     focusNode: indexFocus,
                          //     maxLines: null,
                          //     controller: indexController,
                          //     decoration: InputDecoration(
                          //       filled: true,
                          //       fillColor: indexEdit
                          //           ? Colors.white
                          //           : Colors.transparent,
                          //       border: const OutlineInputBorder(
                          //         borderSide: BorderSide(
                          //           color: Colors.transparent,
                          //           width: 1.0,
                          //         ),
                          //       ),
                          //       focusedBorder: const OutlineInputBorder(
                          //         borderSide: BorderSide(
                          //           color: Colors.transparent,
                          //           width: 1.0,
                          //         ),
                          //       ),
                          //       enabledBorder: const OutlineInputBorder(
                          //         borderSide: BorderSide(
                          //           color: Colors.transparent,
                          //           width: 1.0,
                          //         ),
                          //       ),
                          //     ),
                          //     cursorColor: Colors.grey.shade600,
                          //     style: TextStyle(
                          //         color:
                          //             indexEdit ? Colors.black : Colors.white))
                        ])),
                      ),
                    ],
                  ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width > 1000
                              ? 12.0
                              : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width > 700
                                  ? (MediaQuery.of(context).size.width) / 2
                                  : MediaQuery.of(context).size.width -
                                      MediaQuery.of(context).size.width / 10,
                              height: MediaQuery.of(context).size.height,
                              child: Draft(
                                  draft: _draftmodelProvider.draft,
                                  isTrained: _draftmodelProvider.isTrained),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ))),
        pageItem(Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 24),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.width > 1000 ? 36.0 : 0,
                      left: MediaQuery.of(context).size.width > 1000 ? 36.0 : 0,
                      right:
                          MediaQuery.of(context).size.width > 1000 ? 36.0 : 0),
                  child: SizedBox(
                    height: 48,
                    // decoration: BoxDecoration(
                    //     border: Border.all(
                    //       color: Colors.white,
                    //       width: 2,
                    //     ),
                    //     borderRadius: BorderRadius.circular(20)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: InkWell(
                                onTap: () {
                                  setState(() {
                                    dataPageIndex = 0;
                                    dataPageController.animateToPage(
                                        dataPageIndex,
                                        duration:
                                            const Duration(milliseconds: 1),
                                        curve: Curves.easeInSine);
                                  });
                                },
                                child: Center(
                                    child: Text("Website",
                                        style: TextStyle(
                                          color: dataPageIndex == 0
                                              ? Colors.cyan
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
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
                                        duration:
                                            const Duration(milliseconds: 1),
                                        curve: Curves.easeInSine);
                                  });
                                },
                                child: Center(
                                    child: Text("Files",
                                        style: TextStyle(
                                          color: dataPageIndex == 1
                                              ? Colors.cyan
                                              : Colors.grey,
                                          fontWeight: FontWeight.w300,
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
                                        duration:
                                            const Duration(milliseconds: 1),
                                        curve: Curves.easeInSine);
                                  });
                                },
                                child: Center(
                                    child: Text("Text",
                                        style: TextStyle(
                                          color: dataPageIndex == 2
                                              ? Colors.cyan
                                              : Colors.grey,
                                          fontWeight: FontWeight.w300,
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
                                        duration:
                                            const Duration(milliseconds: 1),
                                        curve: Curves.easeInSine);
                                  });
                                },
                                child: Center(
                                    child: Text("Image",
                                        style: TextStyle(
                                          color: dataPageIndex == 3
                                              ? Colors.cyan
                                              : Colors.grey,
                                          fontWeight: FontWeight.w300,
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
                                        duration:
                                            const Duration(milliseconds: 1),
                                        curve: Curves.easeInSine);
                                  });
                                },
                                child: Center(
                                    child: Text("Youtube",
                                        style: TextStyle(
                                          color: dataPageIndex == 4
                                              ? Colors.cyan
                                              : Colors.grey,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 16,
                                        )))),
                          ),
                        ]),
                  )),
              SizedBox(
                height: MediaQuery.of(context).size.height / 1.2,
                width: MediaQuery.of(context).size.width / 1,
                child: PageView(
                  controller: dataPageController,
                  children: [
                    pageItem(
                      SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 48,
                              ),
                              const Text(
                                "Url",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width > 1000
                                          ? MediaQuery.of(context).size.width /
                                              10
                                          : 8,
                                ),
                                child: Column(
                                  children: urlContainers,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (urlContainers.length < 5)
                                Center(
                                    child: InkWell(
                                        child: const Icon(
                                          Icons.add_circle_rounded,
                                          color: Colors.cyan,
                                          size: 36,
                                        ),
                                        onTap: () {
                                          TextEditingController textContrlr =
                                              TextEditingController();
                                          setState(() {
                                            UrlContainer newContainer =
                                                UrlContainer(
                                              controller: textContrlr,
                                              id: _uniqueIdCounter, // Assign a unique ID
                                              onDelete: (id) {
                                                setState(() {
                                                  urlContainers.removeWhere(
                                                      (container) =>
                                                          container.id == id);
                                                });
                                              },
                                            );

                                            urlContainers.add(newContainer);
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
                            height: MediaQuery.of(context).size.height / 48,
                          ),
                          const Text(
                            "Upload Files",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          (_pickedFile != null)
                              ? Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Colors.teal),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                    color: Colors.grey.shade200,
                                  ),
                                  height: 200,
                                  width: 400,
                                  child: ListTile(
                                    title: Text(_pickedFile!.name),
                                    subtitle:
                                        Text('${_pickedFile!.size} bytes'),
                                    trailing: const Icon(
                                        Icons.delete_outline_rounded),
                                    iconColor: Colors.red.shade500,
                                    onTap: () {
                                      setState(() {
                                        _pickedFile = null;
                                      });
                                    },
                                  ),
                                )
                              : GestureDetector(
                                  onTap: _pickFiles,
                                  child: DropTarget(
                                    onDragEntered: (detail) {
                                      setState(() {
                                        _dragging = true;
                                      });
                                    },
                                    onDragExited: (detail) {
                                      setState(() {
                                        _dragging = false;
                                      });
                                    },
                                    onDragDone: (detail) async {
                                      if (detail.files.isNotEmpty) {
                                        XFile droppedFile = detail.files.first;
                                        int fileSize =
                                            await droppedFile.length();
                                        PlatformFile file = PlatformFile(
                                          name: droppedFile.name,
                                          path: droppedFile.path,
                                          size: fileSize,
                                          bytes:
                                              await droppedFile.readAsBytes(),
                                        );

                                        setState(() {
                                          _pickedFile = file;
                                          _dragging = false;
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 200,
                                      width: 400,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2, color: Colors.black),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20)),
                                        color: _dragging
                                            ? Colors.green.shade200
                                            : Colors.grey.shade200,
                                      ),
                                      child: Center(
                                        child: _pickedFile == null
                                            ? const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.upload_file_outlined,
                                                    color: Colors.grey,
                                                    size: 36,
                                                  ),
                                                  Text(
                                                    "파일을 끌어서 놓거나 클릭하여 파일 선택",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14),
                                                  ),
                                                  Text(
                                                    "지원 파일 형식 : .pdf, .txt, .xlsx",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 12),
                                                  )
                                                ],
                                              )
                                            : Text(
                                                'Selected file: ${_pickedFile!.name}'),
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    pageItem(
                      SingleChildScrollView(
                        child: Column(children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 48,
                          ),
                          const Text(
                            "Text",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height / 48),
                          Container(
                            height: MediaQuery.of(context).size.height / 3,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: TextField(
                              maxLines: null,
                              controller: textInputController,
                              cursorColor: Colors.grey,
                              decoration: InputDecoration(
                                //floatingLabelBehavior: FloatingLabelBehavior.always,
                                hintText: "Text를 입력해주세요",
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade600),
                                filled: true,
                                fillColor: Colors.white,
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
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
                        height: MediaQuery.of(context).size.height / 2,
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 48,
                            ),
                            const Text(
                              "Upload Images",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            (_pickedImage != null)
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 2, color: Colors.teal),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                      color: Colors.grey.shade200,
                                    ),
                                    height: 200,
                                    width: 400,
                                    child: ListTile(
                                      title: Text(_pickedImage!.name),
                                      subtitle:
                                          Text('${_pickedImage!.size} bytes'),
                                      trailing: const Icon(
                                          Icons.delete_outline_rounded),
                                      iconColor: Colors.red.shade500,
                                      onTap: () {
                                        setState(() {
                                          _pickedImage = null;
                                        });
                                      },
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: _pickImages,
                                    child: DropTarget(
                                      onDragEntered: (detail) {
                                        setState(() {
                                          _draggingImage = true;
                                        });
                                      },
                                      onDragExited: (detail) {
                                        setState(() {
                                          _draggingImage = false;
                                        });
                                      },
                                      onDragDone: (detail) async {
                                        if (detail.files.isNotEmpty) {
                                          XFile droppedFile =
                                              detail.files.first;
                                          int fileSize =
                                              await droppedFile.length();
                                          PlatformFile file = PlatformFile(
                                            name: droppedFile.name,
                                            path: droppedFile.path,
                                            size: fileSize,
                                            bytes:
                                                await droppedFile.readAsBytes(),
                                          );

                                          setState(() {
                                            _pickedImage = file;
                                            _draggingImage = false;
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 200,
                                        width: 400,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2, color: Colors.black),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20)),
                                          color: _draggingImage
                                              ? Colors.green.shade200
                                              : Colors.grey.shade200,
                                        ),
                                        child: Center(
                                          child: _pickedImage == null
                                              ? const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.image,
                                                      color: Colors.grey,
                                                      size: 36,
                                                    ),
                                                    Text(
                                                      "이미지를 끌어서 놓거나 클릭하여 파일 선택",
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 14),
                                                    ),
                                                    Text(
                                                      "지원 파일 형식 : .png, .jpg",
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12),
                                                    )
                                                  ],
                                                )
                                              : Text(
                                                  'Selected file: ${_pickedImage!.name}'),
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    pageItem(
                      SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 48,
                              ),
                              const Text(
                                "Youtube Links",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width > 1000
                                          ? MediaQuery.of(context).size.width /
                                              10
                                          : 8,
                                ),
                                child: Column(
                                  children: youtubeLinksContainers,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (youtubeLinksContainers.length < 5)
                                Center(
                                    child: InkWell(
                                        child: const Icon(
                                          Icons.add_circle_rounded,
                                          color: Colors.red,
                                          size: 36,
                                        ),
                                        onTap: () {
                                          TextEditingController textContrlr =
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
                                                              container.id ==
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
                  ],
                  onPageChanged: (index) =>
                      setState(() => dataPageIndex = index),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 12 > 96
                      ? MediaQuery.of(context).size.width / 12
                      : 96,
                  height: 48, // Set the desired height for the button
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.indigo,
                        Colors.cyan,
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
                          fontSize:
                              MediaQuery.of(context).size.width > 600 ? 12 : 14,
                          fontWeight: FontWeight.bold,
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
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width > 1000 ? 36.0 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 12,
                      ),
                      const Text('My Reports',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          )),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        height: 512,
                        child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemCount: 0,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {},
                              child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 1.0, color: Colors.grey),
                                    ),
                                  ),
                                  width: double.infinity,
                                  child: const ListTile(
                                    leading: Icon(Icons.article_outlined,
                                        color: Colors.grey),
                                    title: Text(
                                        "Large Language Models and Generative AI",
                                        style: TextStyle(color: Colors.white)),
                                  )),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ))),
        pageItem(Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    width: MediaQuery.of(context).size.width > 700
                        ? (MediaQuery.of(context).size.width) / 2
                        : MediaQuery.of(context).size.width -
                            MediaQuery.of(context).size.width / 10,
                    child: const Chat(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ))),
      ],
      onPageChanged: (index) => setState(() => pageIndex = index),
    );
  }

  pageBtnOnTap(int page) {
    setState(() {
      pageIndex = page;
      pageController.animateToPage(pageIndex,
          duration: const Duration(milliseconds: 1), curve: Curves.bounceIn);
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
