import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mediwise/Health%20Mobile%20App/login%20page/Screen/login.dart';
import 'package:concentric_transition/concentric_transition.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true); // ✅ Ensure onboarding is stored
    bool seen = prefs.getBool('seenOnboarding') ?? false;
    print("✅ Onboarding saved in SharedPreferences: $seen"); // 🔍 Debugging

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        radius: MediaQuery.of(context).size.width * 0.1,
        nextButtonBuilder: (context) => const Padding(
          padding: EdgeInsets.only(left: 3),
          child: Icon(Icons.navigate_next, size: 40),
        ),
        itemBuilder: (index) {
          final page = pages[index % pages.length];
          return SafeArea(child: _Page(page: page));
        },
        onFinish: () => _completeOnboarding(context), // ✅ Fix onboarding loop
      ),
    );
  }
}

class PageData {
  final String title;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  const PageData({
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.textColor,
  });
}

final pages = [
  const PageData(
    icon: Icons.health_and_safety,
    title: "Welcome to MediWise",
    bgColor: Color(0xff3b1791),
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.medical_services,
    title: "Get personalized health insights",
    bgColor: Color(0xfffab800),
    textColor: Color(0xff3b1790),
  ),
  const PageData(
    icon: Icons.local_hospital,
    title: "Connect with healthcare experts",
    bgColor: Color(0xffffffff),
    textColor: Color(0xff3b1790),
  ),
];

class _Page extends StatelessWidget {
  final PageData page;

  const _Page({required this.page});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(shape: BoxShape.circle, color: page.textColor),
          child: Icon(page.icon, size: 80, color: page.bgColor),
        ),
        Text(
          page.title,
          style: TextStyle(color: page.textColor, fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
