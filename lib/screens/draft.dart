import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown_selectionarea.dart';
import 'package:markdown_toolbar/markdown_toolbar.dart';
import 'package:provider/provider.dart';
import 'package:researchtool/model/dratf.dart';

class Draft extends StatefulWidget {
  const Draft({
    Key? key,
    required this.draft,
    required this.isTrained,
  }) : super(key: key);

  final String draft;
  final bool isTrained;
  @override
  State<Draft> createState() => _DraftState();
}

class _DraftState extends State<Draft> {
  bool isfirst = true;
  bool _loading = false;
  Timer? blinkingTimer;
  //
  bool isExpansion = false;
  bool isEdit = false;
  final textcontroller = TextEditingController();
  ScrollController markdownscroll = ScrollController();
  late final FocusNode markdownFocusnode;
  final TextEditingController markdownController = TextEditingController();
  String? userName;
  String? userImg;

  int chatId = -1;
  String modelText = '';
  TextEditingController modelTextcontroller = TextEditingController();
  TextEditingController reportNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    markdownController.addListener(() => setState(() {}));
    markdownFocusnode = FocusNode();
  }

  @override
  void dispose() {
    textcontroller.dispose();
    markdownController.dispose();
    markdownFocusnode.dispose();
    reportNameController.dispose();
    modelTextcontroller.dispose();
    super.dispose();
  }

  void sendMessage(userInput) async {
    // blinkingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
    //   setState(() {
    //     if (modelText.isEmpty) {
    //       modelText = "|";
    //     } else {
    //       modelText = "";
    //     }
    //   });
    // });
    // bool isFirstData = true;

    // await for (final message in ApiService.sendData(userChat, chatId)) {
    //   if (isFirstData) {
    //     blinkingTimer?.cancel();
    //     modelText = "";
    //     isFirstData = false;
    //   }
    //   if (message.contains("#####chat_id:")) {
    //     setState(() {
    //       _loading = false;
    //     });
    //     id = int.parse(message.split("#####ex_id:")[1].trim());

    //     if (chatId == -1) {
    //       chatId = int.parse(
    //           message.split("#####chat_id:")[1].split("#####")[0].trim());
    //     }
    //     continue; // id 값이 할당되었으므로 루프를 빠져나옴
    //   }
    //   setState(() {
    //     modelText += message;
    //   });
    // }

    // setState(() {
    //   _loading = false;
    // });
  }

  void _handleNewChatPressed() {
    setState(() {
      _loading = false;
      modelText = '';
      chatId = -1;
    });
  }

  void _showSetNewProjectNameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("저장하기"),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: reportNameController,
                  cursorColor: Colors.grey.shade600,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    hintText: "Report 이름을 입력해주세요",
                    contentPadding: EdgeInsets.all(18.0),
                  ),
                ),
                const SizedBox(
                  height: 12,
                )
              ],
            ),
          ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                reportNameController.text = "";
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), color: Colors.grey),
                child: const Text(
                  '취소',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (reportNameController.text.isNotEmpty) {
                  reportNameController.text = "";
                  Navigator.of(context).pop();
                  //Post request
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.indigo,
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
    return Consumer<DraftModel>(builder: (context, provider, child) {
      modelText = provider.draft;
      modelTextcontroller.text = provider.draft;
      return SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 12,
                                height: 24,
                              ),
                              const Icon(Icons.circle,
                                  color: Colors.cyan, size: 18),
                              const Icon(Icons.circle,
                                  color: Colors.lightBlue, size: 18),
                              Icon(Icons.circle,
                                  color: Colors.indigo.shade700, size: 18),
                            ],
                          ),
                          !provider.isTrained
                              ? Container()
                              : isEdit
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomCenter,
                                            child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    modelText =
                                                        markdownController.text;
                                                    isEdit = false;
                                                    provider
                                                        .setDraft(modelText);
                                                  });
                                                },
                                                child: const Icon(Icons.check,
                                                    color: Colors.lightBlue,
                                                    size: 24))),
                                        const SizedBox(width: 12),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Align(
                                            alignment: Alignment.bottomCenter,
                                            child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    markdownController.text =
                                                        modelText;
                                                    isEdit = true;
                                                    provider
                                                        .setDraft(modelText);
                                                  });
                                                },
                                                child: const Icon(Icons.edit,
                                                    color: Colors.white,
                                                    size: 22))),
                                        const SizedBox(width: 12),
                                        Align(
                                            alignment: Alignment.bottomCenter,
                                            child: InkWell(
                                                onTap: _handleNewChatPressed,
                                                child: const Icon(Icons.refresh,
                                                    color: Colors.white,
                                                    size: 24))),
                                        const SizedBox(width: 12),
                                        Align(
                                            alignment: Alignment.bottomCenter,
                                            child: InkWell(
                                                onTap: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: modelText));
                                                },
                                                child: const Icon(Icons.copy,
                                                    color: Colors.white,
                                                    size: 22))),
                                        const SizedBox(width: 12),
                                        Align(
                                            alignment: Alignment.bottomCenter,
                                            child: InkWell(
                                                onTap: () {
                                                  _showSetNewProjectNameDialog(
                                                      context);
                                                },
                                                child: const Icon(
                                                    Icons.save_outlined,
                                                    color: Colors.white,
                                                    size: 22))),
                                        const SizedBox(width: 12),
                                      ],
                                    )
                        ]),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 2,
                    height: 2,
                  ),
                  Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4)),
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: content(modelText)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              constraints: const BoxConstraints(
                maxHeight: 224,
              ),
              width: double.infinity,
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  children: [
                    Container(
                      height: 12,
                      color: Colors.transparent,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 96,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            reverse: true,
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 90),
                              child: TextField(
                                enabled: provider.isTrained,
                                onSubmitted: (text) {
                                  if (!_loading) {
                                    sendMessage(text);
                                  }
                                },
                                textInputAction: TextInputAction.go,
                                cursorColor: Colors.grey,
                                controller: textcontroller,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  hintText: "AI에게 요청해보세요",
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade600),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        ElevatedButton(
                          onPressed: _loading || !provider.isTrained
                              ? null
                              : () {
                                  sendMessage(textcontroller.text);
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(50, 50),
                            backgroundColor:
                                _loading ? Colors.grey : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.grey),
                              borderRadius:
                                  BorderRadius.circular(10), // 모서리를 둥글게 조정
                            ),
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget content(message) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: isEdit
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    MarkdownToolbar(
                      useIncludedTextField: false,
                      controller: markdownController,
                      focusNode: markdownFocusnode,
                    ),
                    TextField(
                      maxLines: null,
                      controller: markdownController, // Add the _controller
                      focusNode: markdownFocusnode, // Add the _focusNode
                    ),
                  ],
                ),
              )
            : Container(
                margin: const EdgeInsets.all(10.0),
                child: Markdown(
                  controller: markdownscroll,
                  data: message,
                  styleSheet: MarkdownStyleSheet(),
                ),
              ));
  }

  //State 끝
}
