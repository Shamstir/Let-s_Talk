import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/chatpage.dart';
import 'package:lets_talk/login%20page.dart';
import 'drawer.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? username;
  String? userEmail;
  String? userId;
  String? userdocid;
  final TextEditingController searchController = TextEditingController();
  List<String> contacts = []; // Changed to List<String> for usernames
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String chatRoomId(String user1, String user2) {
    int user1Sum = user1[0].toLowerCase().codeUnits[0] + user1[1].toLowerCase().codeUnits[0];
    int user2Sum = user2[0].toLowerCase().codeUnits[0] + user2[1].toLowerCase().codeUnits[0];
    String id = user1Sum > user2Sum ? "$user1$user2" : "$user2$user1";
    print('Homepage chatRoomId - User1: $user1 (sum: $user1Sum), User2: $user2 (sum: $user2Sum), ID: $id');
    return id;
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => isLoading = true);
      await _fetchUserData();
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading data: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        errorMessage = 'No user signed in';
      });
      return;
    }

    try {
      userId = user.uid;
      print('Current user ID: $userId');
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDa = querySnapshot.docs.first;
        var userData = userDa.data() as Map<String, dynamic>;
        setState(() {
          username = userData['username'] ?? "Unknown User";
          userEmail = userData['email'] ?? "No Email";
          userdocid = userDa.id;
          contacts = List<String>.from(userData['contacts'] ?? []); // Load contacts array
        });
        print('Fetched user: $username, $userEmail, Contacts: $contacts');
      } else {
        setState(() {
          username = "User Not Found";
          userEmail = "Email Not Found";
          contacts = [];
        });
        print('User document not found for email: ${user.email}');
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        errorMessage = 'Error fetching user data: $e';
        username = user.displayName ?? 'User';
        userEmail = user.email ?? 'No Email';
        contacts = [];
      });
    }
  }

  Future<void> _addContact(String searchQuery) async {
    if (userId == null || userdocid == null || username == null) {
      setState(() {
        errorMessage = 'User not authenticated or document ID not set';
      });
      return;
    }

    if (searchQuery.isEmpty || searchQuery == username) {
      setState(() {
        errorMessage = searchQuery.isEmpty ? 'Search query cannot be empty' : 'Cannot add yourself as a contact';
      });
      return;
    }

    try {
      // Check if the searched username exists
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: searchQuery)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'User "$searchQuery" not found';
        });
        return;
      }

      // Get the document ID of the searched user
      String targetUserDocId = snapshot.docs.first.id;

      // Prevent duplicates
      if (contacts.contains(searchQuery)) {


          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User "$searchQuery" is already in your contacts'),
              duration: const Duration(seconds: 2), // How long the message stays
              backgroundColor: Colors.green, // Optional: Customize color
            ),
          );
          searchController.clear();
        return;
      }

      // Update the contacts array in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userdocid).update({
        'contacts': FieldValue.arrayUnion([searchQuery]),
      });

      // Update local contacts list
      setState(() {
        contacts.add(searchQuery);
        errorMessage = null; // Clear any previous error
        searchController.clear();
      });
      print('Added "$searchQuery" to contacts for user: $userdocid');
    } catch (e) {
      setState(() {
        errorMessage = 'Error adding contact: $e';
      });
      print('Error adding contact: $e');
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Let's Talk",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlue[400],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: MyDraw(),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Colors.lightBlue[400],
        ),
      )
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
          ),
        ),
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue[100]!.withOpacity(0.3),
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.lightBlue[100],
                    child: Text(
                      username?.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.lightBlue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back,",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        username ?? 'User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search for friends...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.lightBlue[300],
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                onSubmitted: (value) => _addContact(value), // Trigger on Enter
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8), // Fixed to 'bottom' below
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.lightBlue[100],
                        child: Text(
                          contacts[index].substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: Colors.lightBlue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        contacts[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.lightBlue[300],
                      ),
                      onTap: () {
                        if (userdocid == null) {
                          setState(() {
                            errorMessage = 'User document ID not set';
                          });
                          return;
                        }
                        String roomId = chatRoomId(userdocid!, contacts[index]);
                        print('Navigating to ChatPage - Sender: $userdocid, Receiver: ${contacts[index]}, RoomID: $roomId');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              receiverName: contacts[index],
                              receiverId: contacts[index], // Using username as ID for simplicity
                              senderid: username??'vin',
                              isgroup: false,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feature coming soon!')),
          );
        },
        backgroundColor: Colors.lightBlue[400],
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }
}