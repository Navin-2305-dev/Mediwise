import 'package:flutter/material.dart';
import 'package:mediwise/Health%20Mobile%20App/login%20page/Screen/sign_up.dart';
import 'package:mediwise/Health%20Mobile%20App/login%20page/Services/authentication.dart';
import 'package:mediwise/Health%20Mobile%20App/login%20page/widget/button.dart';
import 'package:mediwise/Health%20Mobile%20App/login%20page/widget/snack_bar.dart';
import 'package:mediwise/Health%20Mobile%20App/login%20page/widget/text_field.dart';
import 'package:mediwise/Health%20Mobile%20App/pages/health_app_main_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passController.dispose();
  }

  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthServices().loginUser(
      email: emailController.text,
      password: passController.text,
    );

    if (res == "success") {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HealthAppMainPage()),
      );
    } else {
      setState(() {
        isLoading = false;
      });

      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: deviceWidth,
                height: deviceHeight * 0.4, // Adjusted height dynamically
                child: Image.asset("assets/health/login.jpg", fit: BoxFit.contain),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: deviceHeight * 0.02),
                    TextInpute(
                      textEditingController: emailController,
                      hintText: "Enter your Email",
                      icon: Icons.mail,
                    ),
                    // SizedBox(height: deviceHeight * 0.015),
                    TextInpute(
                      textEditingController: passController,
                      hintText: "Enter your Password",
                      isPass: true,
                      icon: Icons.lock,
                    ),
                    // SizedBox(height: deviceHeight * 0.015),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    // SizedBox(height: deviceHeight * 0.02),
                    MyButton(onTab: loginUser, data: "Log In"),
                    SizedBox(height: deviceHeight * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            " Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
