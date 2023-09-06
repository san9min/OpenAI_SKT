import 'dart:async';

import 'package:flutter/material.dart';
import 'package:researchtool/api/signup.dart';
import 'package:researchtool/main.dart';
import 'package:cookie_wrapper/cookie.dart';

class SignUpScreen extends StatefulWidget {
  final String userEmail;
  const SignUpScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool certification_3min = false;
  bool isCertified = false;
  bool passwordConfirmable = false;
  late Stream<int> timerStream;
  late StreamSubscription<int> timerSubscription;
  TextEditingController cert_controller = TextEditingController();
  FocusNode cert_focus = FocusNode();
  bool assertSame = true;
  String response = "";

  TextEditingController password1_controller = TextEditingController();
  FocusNode password1_focus = FocusNode();
  TextEditingController password2_controller = TextEditingController();
  FocusNode password2_focus = FocusNode();
  @override
  void initState() {
    super.initState();

    cert_focus.addListener(() {
      setState(() {});
    });
    password1_focus.addListener(() {
      setState(() {});
    });
    password2_focus.addListener(() {
      setState(() {});
    });
    //FocusScope.of(context).requestFocus(emailFocus);
  }

  @override
  void dispose() {
    // 화면이 나가면 타이머를 정리
    cert_focus.dispose();
    password1_focus.dispose();
    password2_focus.dispose();
    timerSubscription.cancel();
    password1_controller.dispose();
    password2_controller.dispose();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secondsRemaining = seconds % 60;
    if (secondsRemaining < 10) {
      return '$minutes:0$secondsRemaining';
    }
    return '$minutes:$secondsRemaining';
  }

  void startTimer() {
    //timerSubscription.cancel();
    int startTime = 180; // 3분에 해당하는 초
    timerStream = Stream<int>.periodic(
            const Duration(seconds: 1), (count) => startTime - count - 1)
        .take(startTime); // 시작 시간부터 0까지 카운트 다운
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(30, 34, 42, 1),
      body: Center(
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width > 1000
              ? MediaQuery.of(context).size.width * 0.35
              : MediaQuery.of(context).size.width > 700
                  ? MediaQuery.of(context).size.width * 0.6
                  : MediaQuery.of(context).size.width * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              const Text("회원가입",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24)),
              const SizedBox(
                height: 12,
              ),
              const Text(
                '가입 시 이메일 인증이 필요합니다.\n보안을 위해 본인 확인용으로만 사용됩니다.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(children: [
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        height: 48,
                        width: MediaQuery.of(context).size.width > 1000
                            ? MediaQuery.of(context).size.width * 0.25
                            : MediaQuery.of(context).size.width > 700
                                ? MediaQuery.of(context).size.width * 0.4
                                : MediaQuery.of(context).size.width * 0.7,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 12),
                          child: Text(
                            widget.userEmail,
                            textAlign: TextAlign.left,
                          ),
                        )),
                    if (isCertified)
                      const Positioned(
                          right: 12,
                          top: 12,
                          child: Icon(Icons.check, color: Colors.green)),
                  ]),
                  if (!isCertified)
                    const SizedBox(
                      width: 12,
                    ),
                  if (!isCertified)
                    InkWell(
                      onTap: () {
                        EmailSingUp.sendEmailCode(widget.userEmail);
                        setState(() {
                          startTimer();
                          certification_3min = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: certification_3min
                                ? const Color.fromRGBO(33, 150, 243, 0.25)
                                : Colors.blue,
                            border: Border.all(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        height: 48,
                        width: MediaQuery.of(context).size.width > 1000
                            ? MediaQuery.of(context).size.width * 0.05
                            : MediaQuery.of(context).size.width > 700
                                ? MediaQuery.of(context).size.width * 0.1
                                : MediaQuery.of(context).size.width * 0.2,
                        child: certification_3min
                            ? StreamBuilder<int>(
                                stream: timerStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    int remainingTime = snapshot.data!;
                                    if (remainingTime == 0) {
                                      return const Center(
                                          child: Text('재인증요청',
                                              style: TextStyle(
                                                  color: Colors.white)));
                                    }
                                    return Center(
                                      child: Text(formatTime(remainingTime),
                                          style: const TextStyle(
                                              color: Colors.white)
                                          //style: const TextStyle(fontSize: 24),
                                          ),
                                    );
                                  } else {
                                    return const Center(
                                        child: Text('3:00',
                                            style: TextStyle(
                                                color: Colors.white)));
                                  }
                                },
                              )
                            : const Center(
                                child: Text("인증요청",
                                    style: TextStyle(color: Colors.white))),
                      ),
                    )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              if (certification_3min && !isCertified)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    height: 48,
                    width: MediaQuery.of(context).size.width > 1000
                        ? MediaQuery.of(context).size.width * 0.25
                        : MediaQuery.of(context).size.width > 700
                            ? MediaQuery.of(context).size.width * 0.4
                            : MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      controller: cert_controller,
                      focusNode: cert_focus,
                      decoration: InputDecoration(
                        //floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: "인증번호",

                        labelStyle: TextStyle(
                          color: cert_focus.hasFocus
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
                    width: 12,
                  ),
                  InkWell(
                    onTap: () async {
                      isCertified = await EmailSingUp.checkEmailCode(
                          widget.userEmail, cert_controller.text);
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4)),
                      height: 48,
                      width: MediaQuery.of(context).size.width > 1000
                          ? MediaQuery.of(context).size.width * 0.05
                          : MediaQuery.of(context).size.width > 700
                              ? MediaQuery.of(context).size.width * 0.1
                              : MediaQuery.of(context).size.width * 0.2,
                      child: const Center(
                          child: Text("확인",
                              style: TextStyle(color: Colors.white))),
                    ),
                  )
                ]),
              const SizedBox(
                height: 12,
              ),
              if (isCertified)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4)),
                    height: 48,
                    width: MediaQuery.of(context).size.width > 1000
                        ? MediaQuery.of(context).size.width * 0.25
                        : MediaQuery.of(context).size.width > 700
                            ? MediaQuery.of(context).size.width * 0.4
                            : MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      controller: password1_controller,
                      focusNode: password1_focus,
                      obscureText: true,
                      decoration: InputDecoration(
                        //floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: "Password",

                        labelStyle: TextStyle(
                          color: password1_focus.hasFocus
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
                ]),
              const SizedBox(
                height: 12,
              ),
              if (isCertified && passwordConfirmable)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4)),
                    height: 48,
                    width: MediaQuery.of(context).size.width > 1000
                        ? MediaQuery.of(context).size.width * 0.25
                        : MediaQuery.of(context).size.width > 700
                            ? MediaQuery.of(context).size.width * 0.4
                            : MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      controller: password2_controller,
                      focusNode: password2_focus,
                      obscureText: true,
                      decoration: InputDecoration(
                        //floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: "Password Confirm",

                        labelStyle: TextStyle(
                          color: password2_focus.hasFocus
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
                ]),
              if (isCertified && passwordConfirmable && !assertSame)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red),
                      Text("비밀번호가 일치하지 않습니다",
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              const SizedBox(
                height: 8,
              ),
              Text(response, style: const TextStyle(color: Colors.red)),
              const SizedBox(
                height: 12,
              ),
              if (isCertified)
                InkWell(
                  onTap: () async {
                    if (!passwordConfirmable) {
                      setState(() {
                        passwordConfirmable = true;
                      });
                    } else {
                      if (password1_controller.text ==
                          password2_controller.text) {
                        final res = await EmailSingUp.registerEmail(
                            widget.userEmail, password2_controller.text);
                        if (res["message"] == "register successed") {
                          var cookie = Cookie.create();
                          cookie.set('access_token', res["access_token"]);
                          cookie.set('refresh_token', res["refresh_token"]);
                          if (!mounted) return;
                          MyFluroRouter.router
                              .navigateTo(context, '/', replace: true);
                        } else {
                          setState(() {
                            response = res['message'];
                          });
                        }
                      } else {
                        setState(() {
                          assertSame = false;
                        });
                      }
                    }
                  },
                  child: Container(
                    height: 48,
                    width: MediaQuery.of(context).size.width > 1000
                        ? MediaQuery.of(context).size.width * 0.25
                        : MediaQuery.of(context).size.width > 700
                            ? MediaQuery.of(context).size.width * 0.4
                            : MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.blue),
                    child: const Center(
                        child: Text("계속하기",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16))),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
