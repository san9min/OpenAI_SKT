import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:researchtool/api/api_service.dart';
import 'package:researchtool/model/dratf.dart';
import 'package:researchtool/model/message.dart';
import 'package:researchtool/widget/conversation.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key, required this.projectId}) : super(key: key);

  final int projectId;
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  bool isFirstData = true;

  bool _loading = false;
  Timer? blinkingTimer;
  bool isExpansion = false;

  final textcontroller = TextEditingController();

  bool login = false;

  String? userName;
  String? userImg;

  List<ChatMessage> messages = [];
  bool isLoginButtonHovered = false;
  bool isSignUpButtonHovered = false;

  TextEditingController promptController = TextEditingController();
  late ScrollController reverseChatController;

  @override
  void initState() {
    getChat(widget.projectId);
    reverseChatController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    textcontroller.dispose();
    reverseChatController.dispose();
    super.dispose();
  }

  void getChat(projectId) async {
    messages = await ApiService.getChat(projectId);
    setState(
      () {
        if (messages.isNotEmpty) {
          reverseChatController.animateTo(
            reverseChatController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.linear,
          );
        }
      },
    );
  }

  void _showSetPromptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Prompt"),
          content: Container(
            constraints: const BoxConstraints(
                maxHeight: 300, minWidth: 512, maxWidth: 512),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: promptController,
                  maxLines: 10,
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
                    hintText: "Prompt를 통해 Custom 해보세요!",
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
                promptController.text = "";
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
                if (promptController.text.isNotEmpty) {
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

  void sendMessage(userInput) async {
    if (userInput.trim().isEmpty) {
      return;
    }
    setState(() {
      _loading = true;

      messages.add(ChatMessage(
        messageContent: userInput,
        messageType: "user",
      ));
      messages.add(ChatMessage(
        messageContent: "",
        messageType: "model",
      ));
      reverseChatController.animateTo(
        reverseChatController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    });

    final userChat = userInput.trim();

    textcontroller.clear();

    blinkingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        if (messages.last.messageContent.isEmpty) {
          messages.last.messageContent = "|";
        } else {
          messages.last.messageContent = "";
        }
      });
    });
    bool isFirstData = true;

    await for (final message
        in ApiService.sendData(userChat, widget.projectId)) {
      if (isFirstData) {
        blinkingTimer?.cancel();
        messages.last.messageContent = "";
        isFirstData = false;
      }

      setState(() {
        messages.last.messageContent += message;
      });
    }

    setState(() {
      _loading = false;
      reverseChatController.animateTo(
        reverseChatController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DraftModel>(builder: (context, provider, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 36,
                    ),

                    const Spacer(), // 맨 오른쪽으로 이동하기 위한 Spacer 추가

                    InkWell(
                        onTap: () async {
                          messages =
                              await ApiService.deleteChat(widget.projectId);
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              // borderRadius: BorderRadius.circular(8),
                              // border: Border.all(color: Colors.white)
                              ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.refresh_outlined,
                                  color: Colors.white, size: 24),
                              SizedBox(width: 8),
                              Text(
                                "New Chat",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(
                      width: 12,
                    ),
                    InkWell(
                      onTap: () {
                        _showSetPromptDialog(context);
                      },
                      child: const Icon(
                        Icons.settings,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 24),
                  ],
                ),
                const Divider(color: Colors.grey, thickness: 1),
                SizedBox(
                    height: MediaQuery.of(context).size.height / 1.7,
                    child: content(messages, true)),
              ],
            ),
          ),
          Container(
            //padding: const EdgeInsets.only(top: 10),
            constraints: const BoxConstraints(
              maxHeight: 224,
            ),
            width: double.infinity,
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 96,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          reverse: true,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 56),
                            child: TextField(
                              maxLines: 20,
                              keyboardType: TextInputType.multiline,
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
                                hintText: "입력하신 자료와 관련된 질문을 해보세요!",
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
                        onPressed: _loading || !provider.embeddingComplete
                            ? null
                            : () {
                                sendMessage(textcontroller.text);
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(50, 50),
                          backgroundColor:
                              _loading || !provider.embeddingComplete
                                  ? Colors.grey
                                  : Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // 모서리를 둥글게 조정
                          ),
                        ),
                        child: Icon(
                          Icons.send,
                          color: _loading || !provider.embeddingComplete
                              ? Colors.grey
                              : Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  Container(
                    height: 12,
                    color: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget content(List<ChatMessage> message, bool onlyChat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: ListView.builder(
          controller: reverseChatController,
          itemCount: message.length,
          itemBuilder: ((context, index) {
            return SizedBox(
              child: Column(
                children: [
                  ConversationList(
                      name: "audrey",
                      messageText: message[index].messageContent,
                      imageURL: "assets/images/logo.png",
                      messageType: message[index].messageType)
                  // Align(
                  //   alignment: message[index].messageType == "model"
                  //       ? Alignment.topLeft
                  //       : Alignment.topRight,
                  //   child: Container(
                  //     width: MediaQuery.of(context).size.width,
                  //     decoration: BoxDecoration(
                  //       color: (message[index].messageType == "model")
                  //           ? Colors.grey.shade700
                  //           : Colors.transparent,
                  //     ),
                  //     padding: const EdgeInsets.all(16),
                  //     child: Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 24),
                  //       child: Text(
                  //         textAlign: message[index].messageType == "model"
                  //             ? TextAlign.left
                  //             : TextAlign.right,
                  //         message[index].messageContent,
                  //         style: const TextStyle(
                  //             fontSize: 15, color: Colors.white),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          })),
    );
  }

  //State 끝
}
