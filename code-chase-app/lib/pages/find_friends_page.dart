import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'FriendDetailsPage.dart';

class FindFriendsPage extends StatelessWidget {
  final List<QueryDocumentSnapshot> searchResults;

  const FindFriendsPage({super.key, required this.searchResults});

  Future<void> addFriend(String friendId, BuildContext context) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUserId.isEmpty || friendId.trim().isEmpty || currentUserId == friendId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Invalid user data')),
      );
      return;
    }

    try {
      final friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get();

      if (!friendDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Friend ID does not exist')),
        );
        return;
      }
      // Add friend to current user's friends array
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'friends': FieldValue.arrayUnion([friendId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend added successfully!')),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find Friends',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Pattern
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('/lib/images/pattern.png'),
                fit: BoxFit.cover,
                opacity: 0.2, // Subtle effect
              ),
            ),
          ),
          // Content
          searchResults.isEmpty
              ? const Center(
            child: Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final userDoc = searchResults[index];
              final userData = userDoc.data() as Map<String, dynamic>;
              String friendId = userDoc.id;

              return _animatedUserCard(context, userData, friendId, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _animatedUserCard(BuildContext context, Map<String, dynamic> userData,
      String friendId, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + index * 100), // Staggered animation
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
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
            children: [
              Row(
                children: [
                  // Avatar with Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Text(
                        userData['name']?.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          userData['email'] ?? 'No Email',
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
              const SizedBox(height: 16),
              // Goals Display
              Wrap(
                spacing: 12,
                children: [
                  _goalChip('Daily Goals', userData['dailygoals'] ?? 0),
                  _goalChip('Weekly Goals', userData['weeklygoals'] ?? 0),
                ],
              ),
              const SizedBox(height: 16),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionButton(
                    icon: Icons.person_add,
                    label: 'Add Friend',
                    color: Colors.green,
                    onTap: () => addFriend(friendId, context),
                  ),
                  _actionButton(
                    icon: Icons.info_outline,
                    label: 'Details',
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FriendDetailsPage(id: friendId),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _goalChip(String label, int value) {
    return Chip(
      label: Text(
        '$label: $value',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.blueAccent,
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
