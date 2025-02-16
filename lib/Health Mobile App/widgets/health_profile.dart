import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediwise/Health%20Mobile%20App/widgets/settings.dart';
import 'package:shimmer/shimmer.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    getUserID();
  }

  void getUserID() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  void navigateToSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage2(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: navigateToSettings,
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) => skeletonLoader()),
                      ),
                    ),
                  );
                }
                Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

                return FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        BounceInDown(
                          child: const CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage("assets/doctor/doc4.png"),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildInfoCard("Username", "name", Icons.person, userData),
                        buildInfoCard("Unique ID", "uid", Icons.lock, userData, isEditable: false),
                        buildInfoCard("Email", "email", Icons.email, userData),
                        buildInfoCard("Blood Group", "bloodGroup", Icons.bloodtype, userData),
                        buildInfoCard("Allergies", "allergies", Icons.warning, userData),
                        buildInfoCard("Current Medications", "medications", Icons.medical_services, userData),
                        const SizedBox(height: 20),
                        buildReportCard(userData["diagnosisReport"] ?? "No report"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget buildInfoCard(String label, String field, IconData icon, Map<String, dynamic> userData, {bool isEditable = true}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Colors.white.withOpacity(0.8),
      shadowColor: Colors.blueAccent.withOpacity(0.2),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[600])),
        subtitle: Text(userData[field] ?? "None",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        trailing: isEditable
            ? IconButton(
                icon: Icon(Icons.edit, color: Colors.grey[600]),
                onPressed: () {},
              )
            : Icon(Icons.lock, color: Colors.grey[400]),
      ),
    );
  }

  Widget buildReportCard(String report) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Complete Diagnosis Report",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent)),
            const SizedBox(height: 10),
            Text(report, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget skeletonLoader() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}
