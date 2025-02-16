import 'package:flutter/material.dart';
import 'package:mediwise/Health%20Mobile%20App/login%20page/Screen/login.dart';
import 'package:mediwise/Health%20Mobile%20App/login%20page/Services/authentication.dart';
import 'package:mediwise/Health%20Mobile%20App/login%20page/widget/button.dart';
import 'package:mediwise/Health%20Mobile%20App/login%20page/widget/snack_bar.dart';
import 'package:mediwise/Health%20Mobile%20App/login%20page/widget/text_field.dart';
// import 'package:mediwise/Health%20Mobile%20App/pages/health_app_main_page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void signUpUser() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthServices().signUpUser(
      email: emailController.text,
      password: passController.text,
      name: nameController.text,
    );

    if (res == "Success") {

      showSnackBar(context, "Sign up successful!");

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
      
    } else {
      showSnackBar(context, res);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Image.asset("assets/health/signup.jpeg",
                      fit: BoxFit.contain),
                ),
                const SizedBox(height: 20),
                TextInpute(
                  textEditingController: nameController,
                  hintText: "Enter your Name",
                  icon: Icons.person,
                ),
                TextInpute(
                  textEditingController: emailController,
                  hintText: "Enter your Email",
                  icon: Icons.mail,
                ),
                TextInpute(
                  textEditingController: passController,
                  hintText: "Enter your Password",
                  isPass: true,
                  icon: Icons.lock,
                ),
                MyButton(
                  onTab: signUpUser,
                  data: isLoading ? "Signing Up..." : "Sign Up",
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        " Log In",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
