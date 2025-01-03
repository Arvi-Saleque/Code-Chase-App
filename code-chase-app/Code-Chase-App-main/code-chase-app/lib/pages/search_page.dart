import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/my_textfield.dart';
import '../components/my_button.dart';
import 'find_friends_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController emailController = TextEditingController();

  void searchUsers() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showErrorMessage('Please enter an email');
      return;
    }

    try {
      // Search query only based on email
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: emailController.text.trim())
          .get();

      final searchResults = querySnapshot.docs.map((doc) => doc.data()).toList();

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FindFriendsPage(searchResults: querySnapshot.docs),
          ),
        );
      }
    } catch (e) {
      showErrorMessage('Error: $e');
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Search Friends'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Search for Friends',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Email Input Field
                MyTextfield(
                  controller: emailController,
                  hintText: 'Enter Email',
                  obscureText: false,
                  prefixIcon: Icons.email,
                ),
                const SizedBox(height: 30),
                // Search Button
                MyButton(
                  text: 'Find Friends',
                  onTap: searchUsers,
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
