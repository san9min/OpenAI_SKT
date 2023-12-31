import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
//import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:provider/provider.dart';
import 'package:researchtool/authscreen.dart';
import 'package:researchtool/home.dart';
import 'package:researchtool/model/dratf.dart';
import 'package:researchtool/screens/create.dart';
import 'package:researchtool/screens/datasource.dart';
import 'package:researchtool/screens/email_login.dart';
import 'package:researchtool/screens/login.dart';
import 'package:researchtool/screens/result.dart';
import 'package:researchtool/screens/signup.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  MyFluroRouter.setupRouter();
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => DraftModel())],
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "aurdey",
        debugShowCheckedModeBanner: false,
        onGenerateRoute: MyFluroRouter.router.generator,
        //darkTheme: ThemeData.dark(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          unselectedWidgetColor: Colors.white,
          scaffoldBackgroundColor: const Color.fromARGB(255, 46, 50, 52),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 36, 36, 36),
          ),
          //  fontFamily: GoogleFonts.notoSans().fontFamily,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          shadowColor: Colors.transparent, // 그림자를 없앰
        ),
        home: const Home());
  }
}

class MyFluroRouter {
  static FluroRouter router = FluroRouter();

  static final Handler _HomePageHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) =>
          const Home());
  static final Handler _LoginPageHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    final args = context!.settings!.arguments;
    if (args != null) {
      return LoginScreen(
        isSignup: args as bool,
      );
    } else {
      return const LoginScreen();
    }
  });
  static final Handler _SignUpPageHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    final args = context!.settings!.arguments;
    return SignUpScreen(
      userEmail: args as String,
    );
  });
  static final Handler _EmailLoginPageHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    final args = context!.settings!.arguments;
    return EmailLoginScreen(
      userEmail: args as String,
    );
  });
  static final Handler _AddDataPageHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    final args = context!.settings!.arguments as Map;
    List<Information> selectedUrls = args["selectedInformationList"];
    String projectName = args["projectName"];
    int projectId = args["projectId"];

    return DataSourceScreen(
      selectedUrls: selectedUrls,
      projectName: projectName,
      projectId: projectId,
    );
  });
  static final Handler _BuildPageHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) =>
          const BuildScreen());

  static final Handler _AuthHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) =>
          const AuthScreen());

  static final Handler _ResultHandler = Handler(
      handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    String projectName = Uri.decodeFull(params['projectname'][0]);

    int projectId = int.parse(params['projectId'][0]);
    int draftId = int.parse(params['draftId'][0]);
    return ResultScreen(
      draftId: draftId,
      projectName: projectName,
      projectId: projectId,
    );
  });

  static void setupRouter() {
    router.define("/",
        handler: _HomePageHandler, transitionType: TransitionType.none);
    router.define("/callback",
        handler: _AuthHandler, transitionType: TransitionType.fadeIn);
    router.define("/auth/login",
        handler: _LoginPageHandler, transitionType: TransitionType.fadeIn);
    router.define("/auth/login/password/:useremail",
        handler: _EmailLoginPageHandler, transitionType: TransitionType.fadeIn);

    router.define("/auth/signup/:useremail",
        handler: _SignUpPageHandler, transitionType: TransitionType.fadeIn);
    router.define("/build",
        handler: _BuildPageHandler, transitionType: TransitionType.fadeIn);
    router.define("/add/data/:projectname/:projectId/:sourcetype",
        handler: _AddDataPageHandler, transitionType: TransitionType.fadeIn);

    router.define("/edit/:projectname/:projectId/:draftId",
        handler: _ResultHandler, transitionType: TransitionType.none);
  }
}
