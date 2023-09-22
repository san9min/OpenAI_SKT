import 'package:flutter/material.dart';
import 'package:researchtool/api/email_login.dart';
import 'package:researchtool/main.dart';
import 'package:researchtool/screens/login.dart';
import 'package:cookie_wrapper/cookie.dart';

class EmailLoginScreen extends StatefulWidget {
  final String userEmail; // Add this variable to store user email

  const EmailLoginScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  String accessCode = '';
  FocusNode passwordFocus = FocusNode();
  TextEditingController passwordController = TextEditingController();
  bool wrongPassword = false;
  bool userNotExist = false;

  @override
  void initState() {
    super.initState();
    passwordFocus.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    passwordFocus.dispose();
    passwordController.dispose();
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
            const Text("로그인",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            const SizedBox(
              height: 24,
            ),
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
                      ? MediaQuery.of(context).size.width * 0.3
                      : MediaQuery.of(context).size.width > 700
                          ? MediaQuery.of(context).size.width * 0.5
                          : MediaQuery.of(context).size.width * 0.7,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12),
                    child: Text(
                      widget.userEmail,
                      textAlign: TextAlign.left,
                    ),
                  )),
              Positioned(
                  top: 12,
                  right: 12,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LoginScreen(userEmail: widget.userEmail)),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ))
            ]),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 48,
              width: MediaQuery.of(context).size.width > 1000
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width > 700
                      ? MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width * 0.7,
              child: TextField(
                controller: passwordController,
                focusNode: passwordFocus,
                obscureText: true,
                decoration: InputDecoration(
                  //floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: "Password",
                  labelStyle: TextStyle(
                    color: passwordFocus.hasFocus
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
            wrongPassword
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red),
                        Text("비밀번호가 올바르지 않습니다",
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  )
                : userNotExist
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.red),
                            Text("존재하지 않는 계정입니다.",
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      )
                    : Container(),
            InkWell(
              onTap: () async {
                wrongPassword = false;
                final res = await EmailLogin.login(
                    widget.userEmail, passwordController.text);

                if (res["message"] == 'wrong password') {
                  setState(() {
                    wrongPassword = true;
                  });
                } else if (res["message"] == "login successed") {
                  var cookie = Cookie.create();
                  cookie.set('access_token', res["access_token"]);
                  cookie.set('refresh_token', res["refresh_token"]);
                  if (!mounted) return;
                  MyFluroRouter.router.navigateTo(context, '/', replace: true);
                } else {
                  setState(() {
                    userNotExist = true;
                  });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("계정이 없으신가요?", style: TextStyle(color: Colors.grey)),
                InkWell(
                  onTap: () {
                    MyFluroRouter.router.navigateTo(context, "/auth/login",
                        routeSettings: const RouteSettings(arguments: true));
                  },
                  child: const Text("회원가입",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
