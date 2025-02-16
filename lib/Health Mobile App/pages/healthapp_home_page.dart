import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mediwise/Health%20Mobile%20App/Widgets/doctor_profile.dart';
import 'package:mediwise/Health%20Mobile%20App/Widgets/nearby_doctor.dart';
import 'package:mediwise/Health%20Mobile%20App/widgets/health_needs.dart';
import 'package:iconsax/iconsax.dart';

class HealthappHomePage extends StatefulWidget {
  const HealthappHomePage({super.key});

  @override
  State<HealthappHomePage> createState() => _HealthappHomePageState();
}

class _HealthappHomePageState extends State<HealthappHomePage> {
  bool _hasNotification = true;

  Future<DocumentSnapshot?> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    }
    return null;
  }

  void _showRoutineAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Daily Health Routine",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "🌅 Morning Routine:\n• Drink a glass of water\n• Stretch for 10 minutes\n• Eat a healthy breakfast",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                "🌞 Afternoon Routine:\n• Have a nutritious lunch\n• Take a short walk\n• Stay hydrated",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                "🌆 Evening Routine:\n• Engage in light exercises\n• Eat a balanced dinner\n• Relax before bedtime",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                "🌙 Night Routine:\n• Avoid screens before bed\n• Practice meditation\n• Ensure 7-8 hours of sleep",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _hasNotification = false;
                });
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot?>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("User data not found")));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0)),
                Text(
                  "Hi, ${userData?['name'] ?? 'User'}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "How are you feeling today?",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: _showRoutineAlert,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Iconsax.notification,
                        size: 25,
                      ),
                    ),
                  ),
                  if (_hasNotification)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 15),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                  color: Colors.white,
                ),
                child: const Icon(
                  Iconsax.search_normal,
                  size: 25,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(14),
            children: const [
              MedicalNewsSlider(),
              SizedBox(height: 20),
              Text(
                "Health Needs",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              HealthNeeds(),
              SizedBox(height: 20),
              Text(
                "Nearby Doctor",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              NearbyDoctor(),
            ],
          ),
        );
      },
    );
  }
}
