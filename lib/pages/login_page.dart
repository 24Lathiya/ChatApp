import 'package:chat_app/helper/utils.dart';
import 'package:chat_app/pages/main_page.dart';
import 'package:chat_app/pages/signup_page.dart';
import 'package:chat_app/service/auth_services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passWordController = TextEditingController();

  bool isLoading = false;
  AuthService authService = AuthService();

  Future checkLoginData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await authService
          .loginWithEmailAndPassword(
              emailController.text.trim(), passWordController.text.trim())
          .then((value) {
        setState(() {
          isLoading = false;
        });
        if (value == true) {
          Utils.showCustomSnackBar('Successfully Login',
              title: "Success", isError: false);
          Get.off(MainPage());
        } else {
          Utils.showCustomSnackBar(value.toString());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Chat App",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Text("Login now to see what they are talking"),
                      /* Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(
                            "assets/images/login.png",
                          ),
                          fit: BoxFit.cover)),
                ),*/
                      Image(
                          image: AssetImage(
                            "assets/images/login.png",
                          ),
                          fit: BoxFit.cover),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.email),
                                label: Text("Email"),
                                hintText: "Enter Email",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Email should not empty";
                                } else if (!GetUtils.isEmail(value)) {
                                  return "Incorrect email!";
                                }
                              },
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: passWordController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.password),
                                label: Text("Password"),
                                hintText: "Enter Password",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Password should not empty";
                                } else if (value.length < 6) {
                                  return "Password length should more than 5";
                                }
                              },
                              textInputAction: TextInputAction.go,
                              obscureText: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          checkLoginData();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      /*Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have account ?"),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SignUpPage()));
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                  ],
                )*/
                      Text.rich(
                        TextSpan(
                            text: "Don't have account? ",
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Sign Up",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.off(SignUpPage());
                                    }),
                            ]),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
