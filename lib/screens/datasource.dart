import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:footer/footer.dart';
import 'package:footer/footer_view.dart';
import 'package:researchtool/api/project.dart';
import 'package:researchtool/main.dart';
import 'package:researchtool/model/data.dart';
import 'package:researchtool/screens/create.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DataSourceScreen extends StatefulWidget {
  const DataSourceScreen(
      {Key? key,
      required this.selectedUrls,
      required this.projectName,
      required this.projectId})
      : super(key: key);

  final List<Information> selectedUrls;
  final String projectName;
  final int projectId;
  @override
  State<DataSourceScreen> createState() => _DataSourceScreenState();
}

class _DataSourceScreenState extends State<DataSourceScreen>
    with SingleTickerProviderStateMixin {
  bool _dragging = false;
  bool _draggingImage = false;
  bool _draggingAudio = false;
  bool generation = false;
  ScrollController scrollController = ScrollController();
  PageController pageController = PageController(initialPage: 0);
  late List<Information> suggestedLinks;
  late int projectId;
  final double sliverMinHeight = 80.0, sliverMaxHeight = 140.0;
  int pageIndex = 0;

  int _uniqueIdCounter = 0; // 유니크한 ID를 위한 카터
  int _uniqueIdYoutubeCounter = 0;
  int _uniqueIdFileCounter = 0;
  int _uniqueIdImageCounter = 0;
  //Data Source

  final List<FileData> _pickedFiles = [];
  final List<FileData> _pickedImages = [];
  PlatformFile? _pickedAudio;
  TextEditingController textInputController = TextEditingController();
  List<UrlContainer> urlContainers = [];
  List<UrlContainer> youtubeLinksContainers = [];
  @override
  void initState() {
    super.initState();
    suggestedLinks = widget.selectedUrls;
    projectId = widget.projectId;
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      for (final file in result.files) {
        setState(() {
          _pickedFiles.add(FileData(
              fileListId: _uniqueIdFileCounter, serverId: -1, contents: file));
        });
        _uniqueIdFileCounter++;
      }
    } else {
      print('No file selected');
    }
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["mp3", "mp4", "mpeg", "m4a", "wav"],
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _pickedAudio = result.files.single;
      });
    } else {
      print('No file selected');
    }
  }

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
      allowMultiple: true,
    );

    if (result != null) {
      for (final file in result.files) {
        setState(() {
          _pickedImages.add(FileData(
              fileListId: _uniqueIdImageCounter, serverId: -1, contents: file));
        });
        _uniqueIdImageCounter++;
      }
    } else {
      print('No file selected');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    textInputController.dispose();
    for (var container in urlContainers) {
      container.controller.dispose(); // 컨트롤러 해제
    }
    for (var container in youtubeLinksContainers) {
      container.controller.dispose(); // 컨트롤러 해제
    }
    super.dispose();
  }

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
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                widget.projectName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width > 800
                        ? MediaQuery.of(context).size.width / 12
                        : 12,
                    vertical: 24),
                child: generation
                    ? Center(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height / 1.5,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SpinKitFadingCircle(size: 36, color: Colors.blue)
                            ],
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (suggestedLinks.isNotEmpty)
                            const Text(
                              "Selected References ✓",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20),
                            ),
                          const SizedBox(height: 12),
                          if (suggestedLinks.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width / 12,
                              ),
                              child: SizedBox(
                                height: 96,
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: MediaQuery.of(context)
                                                      .size
                                                      .width >
                                                  1000
                                              ? 4
                                              : 2, // 한 줄에 세 개의 열
                                          mainAxisSpacing: 12,
                                          mainAxisExtent: 36,
                                          crossAxisSpacing: 12),
                                  itemCount: suggestedLinks.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () async {
                                        final url = suggestedLinks[index].url;
                                        if (await canLaunchUrl(
                                            Uri.parse(url))) {
                                          await launchUrl(
                                              Uri.parse(url)); // URL을 엽니다.
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 46, 50, 52),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          height: 36,
                                          constraints: const BoxConstraints(
                                              maxHeight: 36),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(width: 12),
                                              Image.network(
                                                suggestedLinks[index]
                                                    .favicon_url,
                                                width: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              SizedBox(
                                                width: 128,
                                                child: Text(
                                                  suggestedLinks[index].url,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                                    );
                                  },
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          const Text(
                            "Add References +",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 20),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          const Text(
                              "Agent가 학습할 자료를 추가해주세요!\n추가하신 자료를 학습해 더 정확한 작성을 도와드려요.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          const SizedBox(
                            height: 12,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width / 12),
                            child: pageButtonLayout(),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            child: dataPageView(),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          CreateButton(),
                          const SizedBox(
                            height: 12,
                          ),
                        ],
                      ))),
          ],
        ));
  }

  Widget CreateButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height / 48,
          horizontal: MediaQuery.of(context).size.width / 8),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: InkWell(
              onTap: () async {
                setState(() {
                  generation = true;
                });
                List<String> webPages = [];
                List<PlatformFile?> files = [];
                List<String> text = textInputController.text.isEmpty
                    ? []
                    : [textInputController.text];
                List<PlatformFile?> image = [];
                List<String> youtube = [];
                List<PlatformFile?> audio = [];

                for (final container in urlContainers) {
                  webPages.add(container.controller.text);
                }
                for (final container in youtubeLinksContainers) {
                  youtube.add(container.controller.text);
                }

                for (final pickedFile in _pickedFiles) {
                  files.add(pickedFile.contents);
                }

                for (final pickedImage in _pickedImages) {
                  image.add(pickedImage.contents);
                }
                if (_pickedAudio != null) {
                  audio.add(_pickedAudio);
                }
                await ProjectAPI.addDataSource(
                    projectId, webPages, files, text, image, youtube, audio);
                if (!mounted) return;
                MyFluroRouter.router.navigateTo(
                  context,
                  '/edit/${Uri.encodeFull(widget.projectName)}/$projectId/0',
                );
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
                      Colors.lightBlue,
                    ], // 그라데이션 색상 설정
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Text(
                  "Generate",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget pageButtonLayout() {
    return SizedBox(
      height: sliverMinHeight / 2,
      child: Row(
        children: <Widget>[
          Expanded(child: pageButton("Webpages", 0)),
          Expanded(child: pageButton("Files", 1)),
          Expanded(child: pageButton("Text", 2)),
          Expanded(child: pageButton("Images", 3)),
          Expanded(child: pageButton("Youtube", 4)),
          Expanded(child: pageButton("Audio", 5)),
        ],
      ),
    );
  }

  Widget pageButton(String title, int page) {
    final fontColor =
        pageIndex == page ? Colors.lightBlue : const Color(0xFF9E9E9E);
    final lineColor = pageIndex == page ? Colors.lightBlue : Colors.transparent;

    return InkWell(
      splashColor: const Color(0xFF204D7E),
      onTap: () => pageBtnOnTap(page),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                    color: fontColor,
                    fontWeight: pageIndex == page
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
            ),
          ),
          Container(
            height: 1,
            color: lineColor,
          ),
        ],
      ),
    );
  }

  pageBtnOnTap(int page) {
    setState(() {
      pageIndex = page;
      pageController.animateToPage(pageIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCirc);
    });
  }

  Widget dataPageView() {
    return PageView(
      physics: const RangeMaintainingScrollPhysics(),
      controller: pageController,
      children: <Widget>[
        pageItem(Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 24,
              horizontal: MediaQuery.of(context).size.width / 12),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 48,
                  ),
                  const Text(
                    "Url",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width > 1000
                          ? MediaQuery.of(context).size.width / 10
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
                                UrlContainer newContainer = UrlContainer(
                                  controller: textContrlr,
                                  id: _uniqueIdCounter, // Assign a unique ID
                                  onDelete: (id) {
                                    setState(() {
                                      urlContainers.removeWhere(
                                          (container) => container.id == id);
                                    });
                                  },
                                );

                                urlContainers.add(newContainer);
                                _uniqueIdCounter++; // ID 증가
                              });
                            })),
                ]),
          ),
        )),
        pageItem(Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 24,
              horizontal: MediaQuery.of(context).size.width / 12),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Column(
              children: [
                const Text(
                  "Upload Files",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(
                  height: 24,
                ),
                GestureDetector(
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
                        List<XFile> droppedFiles = detail.files;
                        for (final droppedFile in droppedFiles) {
                          int fileSize = await droppedFile.length();
                          String extension =
                              droppedFile.name.split('.').last.toLowerCase();

                          if (extension == 'pdf') {
                            PlatformFile file = PlatformFile(
                              name: droppedFile.name,
                              path: droppedFile.path,
                              size: fileSize,
                              bytes: await droppedFile.readAsBytes(),
                            );

                            setState(() {
                              _pickedFiles.add(FileData(
                                  fileListId: _uniqueIdFileCounter,
                                  serverId: -1,
                                  contents: file));
                              _dragging = false;
                              _uniqueIdFileCounter++;
                            });
                          } else {
                            // PDF가 아닌 파일은 처리하지 않음
                            // showDialog(
                            //   context: context,
                            //   builder: (context) {
                            //     return AlertDialog(
                            //       title: const Text('파일 형식 오류'),
                            //       content:
                            //           const Text('PDF 파일만 업로드할 수 있습니다.'),
                            //       actions: [
                            //         TextButton(
                            //           onPressed: () {
                            //             Navigator.of(context).pop();
                            //           },
                            //           child: const Text('확인'),
                            //         ),
                            //       ],
                            //     );
                            //   },
                            // );
                          }
                        }

                        // PDF 파일인지 확인
                      }
                    },
                    child: Container(
                      height: 240,
                      width: 500,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color: _dragging
                            ? Colors.green.shade200
                            : Colors.grey.shade200,
                      ),
                      child: Center(
                          child: _pickedFiles.isEmpty
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload_file_outlined,
                                      color: Colors.grey,
                                      size: 36,
                                    ),
                                    Text(
                                      "파일을 끌어서 놓거나 클릭하여 파일 선택",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                    ),
                                    Text(
                                      "지원 파일 형식 : .pdf",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    )
                                  ],
                                )
                              : ListView.builder(
                                  itemCount: _pickedFiles.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                          _pickedFiles[index].contents.name),
                                      subtitle: Text(
                                          '${_pickedFiles[index].contents.size} bytes'),
                                      trailing: const Icon(
                                          Icons.delete_outline_rounded),
                                      iconColor: Colors.red.shade500,
                                      onTap: () {
                                        setState(() {
                                          _pickedFiles.removeWhere((element) =>
                                              element.fileListId ==
                                              _pickedFiles[index].fileListId);
                                        });
                                      },
                                    );
                                  })),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        )),
        pageItem(Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 24,
              horizontal: MediaQuery.of(context).size.width / 12),
          child: SingleChildScrollView(
            child: Column(children: [
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
              SizedBox(height: MediaQuery.of(context).size.height / 48),
              Container(
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width > 700
                    ? MediaQuery.of(context).size.width / 2
                    : MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  maxLines: 200,
                  controller: textInputController,
                  cursorColor: Colors.grey,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    //floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: "Text를 입력해주세요",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
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
        )),
        pageItem(Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 24,
              horizontal: MediaQuery.of(context).size.width / 12),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Column(
              children: [
                const Text(
                  "Upload Images",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(
                  height: 24,
                ),
                GestureDetector(
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
                        List<XFile> droppedFiles = detail.files;
                        for (final droppedFile in droppedFiles) {
                          int fileSize = await droppedFile.length();
                          String extension =
                              droppedFile.name.split('.').last.toLowerCase();

                          // PNG 및 JPG 이미지 파일만 허용
                          if (extension == 'png' ||
                              extension == 'jpg' ||
                              extension == 'jpeg') {
                            PlatformFile file = PlatformFile(
                              name: droppedFile.name,
                              path: droppedFile.path,
                              size: fileSize,
                              bytes: await droppedFile.readAsBytes(),
                            );
                            setState(() {
                              _pickedImages.add(FileData(
                                  fileListId: _uniqueIdImageCounter,
                                  serverId: -1,
                                  contents: file));
                              _uniqueIdImageCounter++;
                              _draggingImage = false;
                            });
                          } else {}
                        }
                      }
                    },
                    child: Container(
                      height: 240,
                      width: 500,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color: _draggingImage
                            ? Colors.green.shade200
                            : Colors.grey.shade200,
                      ),
                      child: Center(
                          child: _pickedImages.isEmpty
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                      size: 36,
                                    ),
                                    Text(
                                      "이미지를 끌어서 놓거나 클릭하여 파일 선택",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                    ),
                                    Text(
                                      "지원 파일 형식 : .png, .jpg",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    )
                                  ],
                                )
                              : ListView.builder(
                                  itemCount: _pickedImages.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                          _pickedImages[index].contents.name),
                                      subtitle: Text(
                                          '${_pickedImages[index].contents.size} bytes'),
                                      trailing: const Icon(
                                          Icons.delete_outline_rounded),
                                      iconColor: Colors.red.shade500,
                                      onTap: () {
                                        setState(() {
                                          _pickedImages.removeWhere((element) =>
                                              element.fileListId ==
                                              _pickedImages[index].fileListId);
                                        });
                                      },
                                    );
                                  })),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        )),
        pageItem(Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 24,
              horizontal: MediaQuery.of(context).size.width / 12),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 48,
                  ),
                  const Text(
                    "Youtube Links",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width > 1000
                          ? MediaQuery.of(context).size.width / 10
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
                                UrlContainer newContainer = UrlContainer(
                                  controller: textContrlr,
                                  id: _uniqueIdYoutubeCounter, // Assign a unique ID
                                  isYoutube: true,
                                  onDelete: (id) {
                                    setState(() {
                                      youtubeLinksContainers.removeWhere(
                                          (container) => container.id == id);
                                    });
                                  },
                                );

                                youtubeLinksContainers.add(newContainer);
                                _uniqueIdYoutubeCounter++; // ID 증가
                              });
                            })),
                ]),
          ),
        )),
        pageItem(Padding(
          padding: EdgeInsets.symmetric(
              vertical: MediaQuery.of(context).size.height / 24,
              horizontal: MediaQuery.of(context).size.width / 12),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Column(
              children: [
                const Text(
                  "Upload audio",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(
                  height: 24,
                ),
                GestureDetector(
                  onTap: _pickAudio,
                  child: DropTarget(
                    onDragEntered: (detail) {
                      setState(() {
                        _draggingAudio = true;
                      });
                    },
                    onDragExited: (detail) {
                      setState(() {
                        _draggingAudio = false;
                      });
                    },
                    onDragDone: (detail) async {
                      if (detail.files.isNotEmpty) {
                        XFile droppedFile = detail.files.first;

                        int fileSize = await droppedFile.length();
                        String extension =
                            droppedFile.name.split('.').last.toLowerCase();

                        // PNG 및 JPG 이미지 파일만 허용
                        if (extension == 'mp3' ||
                            extension == "mp4" ||
                            extension == "mpeg" ||
                            extension == "m4a" ||
                            extension == "wav") {
                          PlatformFile file = PlatformFile(
                            name: droppedFile.name,
                            path: droppedFile.path,
                            size: fileSize,
                            bytes: await droppedFile.readAsBytes(),
                          );
                          setState(() {
                            _pickedAudio = file;
                            _draggingAudio = false;
                          });
                        } else {}
                      }
                    },
                    child: Container(
                      height: 240,
                      width: 500,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                        color: _draggingAudio
                            ? Colors.green.shade200
                            : Colors.grey.shade200,
                      ),
                      child: Center(
                          child: _pickedAudio == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                      size: 36,
                                    ),
                                    Text(
                                      "오디오를 끌어서 놓거나 클릭하여 파일 선택",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                    ),
                                    Text(
                                      "지원 파일 형식 : .mp3, .mp4, .mpeg, m4a, .wav",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    )
                                  ],
                                )
                              : ListTile(
                                  title: Text(_pickedAudio!.name),
                                  subtitle: Text('${_pickedAudio!.size} bytes'),
                                  trailing:
                                      const Icon(Icons.delete_outline_rounded),
                                  iconColor: Colors.red.shade500,
                                  onTap: () {
                                    setState(() {
                                      _pickedAudio = null;
                                    });
                                  },
                                )),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        )),
      ],
      onPageChanged: (index) => setState(() => pageIndex = index),
    );
  }

  Widget pageItem(Widget child) {
    double statusHeight = MediaQuery.of(context).padding.top;
    double height = MediaQuery.of(context).size.height;
    double minHeight = height - statusHeight - sliverMinHeight;

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      child: child,
    );
  }
}

class UrlContainer extends StatefulWidget {
  final int id;
  final Function(
    int,
  ) onDelete;
  final TextEditingController controller;
  bool isYoutube;
  bool fromServer;
  int? addId;
  int? suggestionId;
  UrlContainer(
      {required this.controller,
      required this.id,
      required this.onDelete,
      this.isYoutube = false,
      this.fromServer = false,
      this.addId,
      this.suggestionId,
      Key? key})
      : super(key: key);

  @override
  State<UrlContainer> createState() => _UrlContainerState();
}

class _UrlContainerState extends State<UrlContainer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: widget.fromServer
                        ? () async {
                            if (await canLaunchUrl(
                                Uri.parse(widget.controller.text))) {
                              await launchUrl(Uri.parse(
                                  widget.controller.text)); // URL을 엽니다.
                            } else {
                              throw 'Could not launch ${widget.controller.text}';
                            }
                          }
                        : null,
                    child: SizedBox(
                      height:
                          42, // Set the desired height for both TextField and Button
                      child: TextField(
                        style: TextStyle(
                            color: widget.fromServer
                                ? Colors.white
                                : Colors.black),
                        enabled: !widget.fromServer,
                        controller: widget.controller,
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          hintText: widget.isYoutube
                              ? "https://www.youtube.com/watch?v=example"
                              : "https://example.com",
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: widget.fromServer
                              ? const Color.fromARGB(255, 46, 50, 52)
                              : Colors.white,
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
                          contentPadding: const EdgeInsets.all(8.0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    widget.onDelete(widget.id);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 12,
                    height: 42, // Set the desired height for the button
                    decoration: BoxDecoration(
                      color: widget.isYoutube || widget.fromServer
                          ? Colors.red
                          : const Color(0x44000000), //const Color(0xFF2A364B),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        widget.fromServer ? "삭제" : "취소",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}
