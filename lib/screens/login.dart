import 'package:researchtool/main.dart';
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  final String userEmail; // Add this variable to store user email
  final bool isSignup;
  const LoginScreen({Key? key, this.userEmail = '', this.isSignup = false})
      : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String accessCode = '';
  FocusNode emailFocus = FocusNode();
  TextEditingController emailaddressController = TextEditingController();
  late bool isSingUp;
  @override
  void initState() {
    super.initState();
    isSingUp = widget.isSignup;
    emailaddressController.text = widget.userEmail;
    emailFocus.addListener(() {
      setState(() {});
    });
    //FocusScope.of(context).requestFocus(emailFocus);
  }

  bool isVaild = true;
  bool isEmailValid(String email) {
    // 이메일 정규 표현식
    String emailPattern =
        r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$';

    RegExp regExp = RegExp(emailPattern);

    return regExp.hasMatch(email);
  }

  @override
  void dispose() {
    emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(30, 34, 42, 1),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width > 1000
              ? MediaQuery.of(context).size.width * 0.3
              : MediaQuery.of(context).size.width > 700
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width * 0.7,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            InkWell(
              onTap: () {
                MyFluroRouter.router.navigateTo(context, "/");

                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(builder: (context) => const Chat()),
                //   (route) => false,
                // );
              },
              child: const Image(
                height: 128,
                width: 128,
                image: AssetImage("assets/images/logo.png"),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            isSingUp
                ? const Text("회원가입",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24))
                : const Text("Welcome",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24)),
            const SizedBox(
              height: 12,
            ),
            if (isSingUp)
              const Text(
                '가입 시 이메일 인증이 필요합니다.\n보안을 위해 본인 확인용으로만 사용됩니다.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            const SizedBox(
              height: 12,
            ),

            //회원가입
            SizedBox(
              height: 48,
              width: MediaQuery.of(context).size.width > 1000
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width > 700
                      ? MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width * 0.7,
              child: TextField(
                controller: emailaddressController,
                focusNode: emailFocus,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  //floatingLabelBehavior: FloatingLabelBehavior.always,

                  labelText: "Email address",

                  labelStyle: TextStyle(
                    color: emailFocus.hasFocus
                        ? Colors.lightBlueAccent
                        : Colors.grey,
                  ),
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
                      color: Colors.cyan,
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
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            if (!isVaild)
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                    ),
                    Text("이메일 형식이 올바르지 않습니다",
                        style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            InkWell(
              onTap: () {
                if (emailaddressController.text.isNotEmpty) {
                  if (isEmailValid(emailaddressController.text)) {
                    isSingUp
                        ? MyFluroRouter.router.navigateTo(context,
                            "/auth/signup/${emailaddressController.text}",
                            routeSettings: RouteSettings(
                                arguments: emailaddressController.text))
                        : MyFluroRouter.router.navigateTo(context,
                            "/auth/login/password/${emailaddressController.text}",
                            routeSettings: RouteSettings(
                                arguments: emailaddressController.text));
                  } else {
                    setState(() {
                      isVaild = false;
                    });
                  }
                }
              },
              child: Container(
                height: 48,
                width: MediaQuery.of(context).size.width > 1000
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width > 700
                        ? MediaQuery.of(context).size.width * 0.5
                        : MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4), color: Colors.blue),
                child: const Center(
                    child: Text("계속하기",
                        style: TextStyle(color: Colors.white, fontSize: 16))),
              ),
            ),
            const SizedBox(
              height: 12,
            ),

            isSingUp
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text("계정이 이미 있으신가요?",
                          style: TextStyle(color: Colors.grey)),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isSingUp = false;
                          });
                        },
                        child: const Text("로그인",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600)),
                      )
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text("계정이 없으신가요?",
                          style: TextStyle(color: Colors.grey)),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isSingUp = true;
                          });
                        },
                        child: const Text("회원가입",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600)),
                      )
                    ],
                  ),
            const SizedBox(
              height: 24,
            ),
            const Row(children: [
              Expanded(
                child: Divider(
                  color: Colors.grey,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "OR",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey,
                ),
              ),
            ]),
            const SizedBox(
              height: 24,
            ),
            //구글 계정
            SizedBox(
              height: 48,
              width: MediaQuery.of(context).size.width > 1000
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width > 700
                      ? MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width * 0.7,
              child: ElevatedButton.icon(
                onPressed: () {
                  Uri uri = Uri.parse(
                    "https://chat-profile.audrey.kr/api/user/google/login/",
                  );

                  launchUrl(uri,
                      mode: LaunchMode.inAppWebView,
                      webViewConfiguration: const WebViewConfiguration(),
                      webOnlyWindowName: "_self");
                },
                icon: const Row(
                  children: [
                    Image(
                      image: AssetImage("assets/images/google.png"),
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 8),
                  ],
                ),
                label: const Text('구글 계정으로 시작하기',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: const BorderSide(color: Colors.black54)),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
