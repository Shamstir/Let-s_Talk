import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'drawer.dart';
import 'login page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? username = 'User';
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allUsers = []; // All registered users
  List<Map<String, dynamic>> filteredUsers = []; // Filtered users for search

  @override
  void initState() {
    super.initState();
    getdata();
    fetchUsers();
  }

  // Load username from SharedPreferences
  Future<void> getdata() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      username = pref.getString('username') ?? "User";
    });
  }

  // Fetch all users from Firestore
  Future<void> fetchUsers() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> users = snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
        'email': doc['email'],
      };
    }).toList();

    setState(() {
      allUsers = users;
      filteredUsers = users; // Initially, show all users
    });
  }

  // Filter users based on search query
  void filterUsers(String query) {
    List<Map<String, dynamic>> results = allUsers.where((user) {
      return user['name'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUsers = results;
    });
  }

  // Logout Function
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Soft background
      appBar: AppBar(
        title: const Text("Let's Talk",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: MyDraw(),
      body: Column(
        children: [
          // Welcome Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Welcome, $username",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search Users',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterUsers, // Update list when typing
            ),
          ),
          const SizedBox(height: 10),

          // User List
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text("No users found"))
                : ListView.builder(
              itemCount: filteredUsers.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.person, color: Colors.black54),
                    ),
                    title: Text(
                      filteredUsers[index]['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                    subtitle: Text(
                      filteredUsers[index]['email'],
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 14),
                    ),
                    onTap: () {
                      // Open chat with selected user
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
