import 'package:chat_app/controllers/login_controller.dart';
import 'package:chat_app/helper/user_preferences.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/main_page.dart';
import 'package:chat_app/pages/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  UserPreferences.preferences = await SharedPreferences.getInstance();
  if (kIsWeb) {
    //initialise fire base for web
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDFMSGgLMiyETdRREvN9lAUIEnVppp5ZbQ",
            // authDomain: "chatapp-cc237.firebaseapp.com",
            projectId: "chatapp-cc237",
            // storageBucket: "chatapp-cc237.appspot.com",
            messagingSenderId: "632567862739",
            appId: "1:632567862739:web:aa2a3c63b3493b8d3ccb26"));
  } else {
    //initialise fire base for android/ios
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LoginController(),
          child: SignUpPage(),
        )
      ],
      child: GetMaterialApp(
        title: 'Chat App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.teal,
        ),
        home: UserPreferences.preferences!.getBool("is_login") == null
            ? SignUpPage()
            : UserPreferences.preferences!.getBool("is_login")!
                ? MainPage()
                : LoginPage(),
      ),
    );
  }
}
