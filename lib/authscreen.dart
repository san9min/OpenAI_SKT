import 'package:researchtool/main.dart';
import 'package:flutter/material.dart';
import 'dart:html';
import 'package:cookie_wrapper/cookie.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String? accessToken;
  String? refreshToken;

  @override
  void initState() {
    super.initState();
    var uri =
        Uri.dataFromString(window.location.href); //converts string to a uri

    Map<String, String> params =
        uri.queryParameters; // query parameters automatically populated
    accessToken =
        params['access_token']!; // return value of parameter "param1" from uri
    refreshToken =
        params['refresh_token']!; // return value of parameter "param1" from uri
    if (accessToken != '' && refreshToken != '') {
      storeAndRoute(accessToken, refreshToken);
    }
  }

  void storeAndRoute(accTok, refTok) {
    var cookie = Cookie.create();

    // Create a session cookie:

    cookie.set('access_token', accTok);
    cookie.set('refresh_token', refTok);

    MyFluroRouter.router.navigateTo(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromRGBO(30, 34, 42, 1),
    );
  }
}
