import 'package:chat_app/controllers/login_controller.dart';
import 'package:chat_app/helper/utils.dart';
import 'package:chat_app/models/user_details.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/pages/main_page.dart';
import 'package:chat_app/service/auth_services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  var userController = TextEditingController();
  var emailController = TextEditingController();
  var passWordController = TextEditingController();

  bool isLoading = false;
  AuthService authService = AuthService();

  checkSignUpData() {
    if (_formKey.currentState!.validate()) {
      registerUser(userController.text.trim(), emailController.text.trim(), "",
          passWordController.text.trim());
    }
  }

  UserDetails? userDetails;
  Future signUpWithGoogle() async {
    Provider.of<LoginController>(context, listen: false)
        .googleLogin()
        .then((value) {
      if (value == false) {
        Utils.showCustomSnackBar("Something went wrong");
      } else {
        userDetails = value;
        print("=== ${userDetails!.displayName}");
        registerUser(userDetails!.displayName!, userDetails!.email!,
            userDetails!.photoURL!, "123456");
      }
    });

    // print("===user=== ${googleSignInAccount!.displayName}");
  }

  Future registerUser(
      String userName, String emailId, String profile, String password) async {
    setState(() {
      isLoading = true;
    });
    await authService
        .registerWithEmailAndPassword(userName, emailId, profile, password)
        .then((value) {
      setState(() {
        isLoading = false;
      });
      if (value == true) {
        Utils.showCustomSnackBar('Successfully Registered',
            title: "Success", isError: false);
        Get.off(MainPage());
      } else {
        Utils.showCustomSnackBar(value.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                      Text("Create new account to chat and explore"),
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
                            "assets/images/register.png",
                          ),
                          fit: BoxFit.cover),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: userController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                label: Text("User Name"),
                                hintText: "Enter User Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "User name should not empty";
                                }
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            SizedBox(
                              height: 20,
                            ),
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
                          checkSignUpData();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "OR",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          signUpWithGoogle();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              "Sign Up with Google",
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
                    Text("Already have account ?"),
                    SizedBox(
                      width: 5,
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoginPage()));
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ))
                  ],
                ),*/
                      Text.rich(
                        TextSpan(
                            text: "Already have account? ",
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Login",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.off(LoginPage());
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
