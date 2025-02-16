import 'package:flutter/material.dart';
import 'package:mediwise/Health%20Mobile%20App/widgets/health_profile.dart';
import 'package:mediwise/Health%20Mobile%20App/pages/doctor_schedule_screen.dart';
import 'package:mediwise/Health%20Mobile%20App/pages/health_messages.dart';
import 'package:mediwise/Health%20Mobile%20App/pages/healthapp_home_page.dart';
import 'package:iconsax/iconsax.dart';

class HealthAppMainPage extends StatefulWidget {
  const HealthAppMainPage({super.key});

  @override
  State<HealthAppMainPage> createState() => _HealthAppMainPageState();
}

class _HealthAppMainPageState extends State<HealthAppMainPage> {
  int _selectedIndex = 0;
  final BottomNavigationBarType _bottomNavType = BottomNavigationBarType.fixed;

  final List<Widget> pages = [
    const HealthappHomePage(),
    const DoctorScheduleScreen(),
    const MyHomePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        type: _bottomNavType,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            activeIcon: Icon(Iconsax.home5),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.calendar),
            activeIcon: Icon(Iconsax.calendar5),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.message),
            activeIcon: Icon(Iconsax.message5),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}