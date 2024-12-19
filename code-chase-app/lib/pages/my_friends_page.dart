import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'FriendDetailsPage.dart';

class MyFriendsAllPage extends StatefulWidget {
  const MyFriendsAllPage({super.key});

  @override
  State<MyFriendsAllPage> createState() => _MyFriendsAllPageState();
}

class _MyFriendsAllPageState extends State<MyFriendsAllPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> friendsData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    setState(() {
      isLoading = true;
    });

    try {
      String currentUserId = _auth.currentUser!.uid;

      // Fetch current user's document
      final userDoc =
      await _firestore.collection('users').doc(currentUserId).get();

      if (userDoc.exists) {
        List friendsList = userDoc.data()?['friends'] ?? [];

        // Fetch details of each friend
        List<Map<String, dynamic>> fetchedFriends = [];
        for (String friendId in friendsList) {
          final friendDoc =
          await _firestore.collection('users').doc(friendId).get();
          if (friendDoc.exists) {
            final friendData = friendDoc.data() as Map<String, dynamic>;
            friendData['id'] = friendDoc.id;
            fetchedFriends.add(friendData);
          }
        }

        setState(() {
          friendsData = fetchedFriends;
        });
      }
    } catch (e) {
      print("Error fetching friends: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'My Friends',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Pattern
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/pattern_bg.png'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
          ),
          // Content
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : friendsData.isEmpty
              ? const Center(
            child: Text(
              'No friends added yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            itemCount: friendsData.length,
            itemBuilder: (context, index) {
              final friend = friendsData[index];
              return _animatedFriendCard(friend, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _animatedFriendCard(Map<String, dynamic> friend, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + index * 100),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Gradient Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Text(
                        friend['name']?.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Institution
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friend['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Institution: ${friend['institution'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Goals as Chips
              Wrap(
                spacing: 8,
                children: [
                  _goalChip('Daily Goals', friend['dailygoals']),
                  _goalChip('Weekly Goals', friend['weeklygoals']),
                ],
              ),
              const SizedBox(height: 12),
              // View Details Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FriendDetailsPage(id: friend['id']),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  label: const Text('View Details', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalChip(String title, dynamic value) {
    return Chip(
      label: Text(
        '$title: ${value?.toString() ?? "0"}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.blueAccent,
    );
  }
}
