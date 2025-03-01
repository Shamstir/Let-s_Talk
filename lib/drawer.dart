import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lets_talk/login%20page.dart';
import 'package:lets_talk/profile%20page.dart';
import 'package:lets_talk/setting.dart';

class MyDraw extends StatefulWidget {
  const MyDraw({super.key});

  @override
  State<MyDraw> createState() => _MyDrawState();
}

class _MyDrawState extends State<MyDraw> {
  String username = "Loading...";
  String userEmail = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          username = userData['username'] ?? "Unknown User";
          userEmail = userData['email'] ?? "No Email";
        });
      } else {
        setState(() {
          username = "User Not Found";
          userEmail = "Email Not Found";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          // Glassmorphic Blur Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),

          Column(
            children: [
              // User Profile Section
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.black54],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: AssetImage('assets/user.png'), // User image
                ),
                accountName: Text(
                  username,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  userEmail,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              // Navigation Items
              _buildDrawerItem(Icons.home, "Home", () => Navigator.pop(context)),
              _buildDrawerItem(Icons.person, "Profile",
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()))),
              _buildDrawerItem(Icons.settings, "Settings",
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()))),

              // Gradient Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 1,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.grey, Colors.transparent],
                    ),
                  ),
                ),
              ),

              // Logout Button
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                onTap: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Custom ListTile Widget
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      hoverColor: Colors.white10,
      onTap: onTap,
    );
  }
}
