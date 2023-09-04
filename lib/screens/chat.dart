import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cookie_wrapper/cookie.dart';
import 'package:researchtool/api/user_info.dart';
import 'package:researchtool/main.dart';
import 'package:researchtool/model/message.dart';

class Chat extends StatefulWidget {
  const Chat({
    super.key,
  });

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

  int chatId = -1;
  List<ChatMessage> messages = [];
  bool isLoginButtonHovered = false;
  bool isSignUpButtonHovered = false;

  TextEditingController reportNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //checkLogin();
  }

  void checkLogin() async {
    var cookie = Cookie.create();

    var accessToken = cookie.get('access_token');
    var refreshToken = cookie.get('refresh_token');

    if (accessToken != null && refreshToken != null) {
      final userNameImg = await UserInfo.getUserInfo(accessToken, refreshToken);
      if (userNameImg.isEmpty) {
        MyFluroRouter.router.navigateTo(context, "/auth/login");
      }
      setState(() {
        userName = userNameImg['name'];
        userImg = userNameImg['user_image'];
        login = true;
      });
    } else {}
  }

  @override
  void dispose() {
    textcontroller.dispose();

    super.dispose();
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
        messageProduct: "",
      ));
      messages.add(ChatMessage(
        messageContent: "",
        messageType: "model",
        messageProduct: "",
      ));
    });

    final userChat = userInput.trim();

    textcontroller.clear();
    int id;
    List<String> exampleList = [];
    blinkingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        if (messages.last.messageContent.isEmpty) {
          messages.last.messageContent = "|";
        } else {
          messages.last.messageContent = "";
        }
      });
    });
    // bool isFirstData = true;
    // String cleanedResponse = "";
    await Future.delayed(const Duration(milliseconds: 1000));
    blinkingTimer?.cancel();
    if (isFirstData) {
      _addBotMessage(
          "딥러닝 사전학습 언어모델 기술 동향 보고서에 따르면 Large Language Model은 Transformer 기반의 모델입니다. Transformer 모델은 2017년에 기계 번역 작업을 위해 도입된 딥러닝 모델의 한 유형입니다. 이 모델은 모델이 출력 시퀀스를 생성할 때 입력 시퀀스의 다른 부분에 집중할 수 있도록 하는 self attention 메커니즘을 기반으로 합니다. 트랜스포머 모델은 인코더-디코더 아키텍처로 구성되며, 인코더는 입력 시퀀스를 처리하고 디코더는 출력 시퀀스를 생성합니다. 트랜스포머 모델의 핵심 아이디어는 기존의 순환 신경망에 비해 입력 시퀀스의 장거리 종속성을 더 효과적으로 포착할 수 있다는 것입니다. 따라서 자연어 처리와 같이 순차적인 데이터와 관련된 작업에 특히 적합합니다.");
      isFirstData = false;
    } else {
      _addBotMessage('''
        대표적인 Transformer models은 다음과 같습니다 :
1. BERT (Bidirectional Encoder Representations from Transformers)
2. GPT (Generative Pre-trained Transformer)
3. XLNet (Generalized Autoregressive Pretraining for Language Understanding)
4. RoBERTa (A Robustly Optimized BERT Pretraining Approach)
5. ALBERT (A Lite BERT for Self-supervised Learning of Language Representations)
6. BART (Denoising Sequence-to-Sequence Pretraining for Natural Language Generation, Translation, and Comprehension)
7. ELECTRA (Pre-training Text Encoders as Discriminators Rather Than Generators)
8. T5 (Text-to-Text Transfer Transformer)
SOURCES:
Page 3: 데이터로부터 언어모델을 더욱 잘 학습하기 위한 많은 연구가 제안되었으며, 세부적으로 ERNIE, Whole Word Masking, MASS, UniLM, XLNet, SpanBERT, RoBERTa, ALBERT, BART, ELECTRA, UniLMv2 등이 있다[7-16].
Page 11: [7] J. Devlin et al., “BERT: Pre-training of deep bidirectional transformers for language understanding,” arXiv preprint arXiv:1810.04805, 2018.
Page 11: [10] Z. Yang et al., “XLNet: Generalized autoregressive pretraining for language understanding,” arXiv preprint 1906.08237, 2019.
Page 11: [12] Y. Liu et al., “RoBERTa: A Robustly Optimized BERT Pretraining Approach,” arXiv:1907.11692, 2019.
Page 11: [13] Z. Lan et al., “ALBERT: A Lite BERT for Self-supervised Learning of Language Representations,” in Int. Conf. Learning Representations, Addis Ababa, Ethiopia, May 2020.
Page 11: [14] M. Lewis et al., “Bart: Denoising sequence-to-sequence pretraining for natural language generation, translation, and comprehension.” arXiv preprint arXiv:1910.13461, 2019.
Page 11: [15] K. Clark et al., “ELECTRA: Pre-training Text Encoders as Discriminators Rather Than Generators.” in Int. Conf. Learning Representations, Addis Ababa, Ethiopia, May 2020.
Page 11: [16] H. Bao et al., “UniLMv2: Pseudo-Masked Language Models for Unified Language Model Pre-Training.” arXiv preprint arXiv:2002.12804, 2020.

''');
    }
    // await for (final message in ApiService.sendData(userChat, chatId)) {
    //   if (isFirstData) {
    // blinkingTimer?.cancel();
    //     messages.last.messageContent = "";
    //     isFirstData = false;
    //   }

    //   if (message.contains("@@@")) {
    //     cleanedResponse = message.replaceAll("@@@", "");

    //     messages.add(ChatMessage(
    //       messageContent: "",
    //       messageType: "model",
    //       messageProduct: cleanedResponse,
    //     ));
    //     messages.add(ChatMessage(
    //       messageContent: "",
    //       messageType: "model",
    //       messageProduct: "",
    //     ));
    //     continue;
    //   }
    //   if (message.contains("#####chat_id:")) {
    //     print("here");
    //     setState(() {
    //       _loading = false;
    //     });
    //     id = int.parse(message.split("#####ex_id:")[1].trim());
    //     exampleList = await ApiService.getExamples(id);

    //     if (chatId == -1) {
    //       chatId = int.parse(
    //           message.split("#####chat_id:")[1].split("#####")[0].trim());
    //     }
    //     continue; // id 값이 할당되었으므로 루프를 빠져나옴
    //   }
    //   setState(() {
    //     messages.last.messageContent += message;
    //   });
    // }

    setState(() {
      _loading = false;
      print("this");
      if (exampleList.isNotEmpty) {
        print("there");
      }
    });
  }

  void _handleNewChatPressed() {
    setState(() {
      _loading = false;
      messages.clear();
      chatId = -1;
    });
  }

  Future<void> _addBotMessage(String message) async {
    // Initialize a new bot message with an empty string

    for (var char in message.split('')) {
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        messages.last.messageContent += char;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 36,
                  ),
                  const Icon(Icons.circle, color: Colors.cyan, size: 18),
                  const Icon(Icons.circle, color: Colors.lightBlue, size: 18),
                  Icon(Icons.circle, color: Colors.indigo.shade700, size: 18),
                ],
              ),
              const Divider(color: Colors.grey, thickness: 1),
              SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
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
                          constraints: const BoxConstraints(maxHeight: 90),
                          child: TextField(
                            maxLines: null,
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
                              hintStyle: TextStyle(color: Colors.grey.shade600),
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
                      onPressed: _loading
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
  }

  Widget content(List<ChatMessage> message, bool onlyChat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: ListView.builder(
          itemCount: message.length,
          itemBuilder: ((context, index) {
            return SizedBox(
              child: Column(
                children: [
                  Align(
                    alignment: message[index].messageType == "model"
                        ? Alignment.topLeft
                        : Alignment.topRight,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: (message[index].messageType == "model")
                            ? Colors.grey.shade700
                            : Colors.transparent,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          textAlign: message[index].messageType == "model"
                              ? TextAlign.left
                              : TextAlign.right,
                          message[index].messageContent,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          })),
    );
  }

  //State 끝
}
