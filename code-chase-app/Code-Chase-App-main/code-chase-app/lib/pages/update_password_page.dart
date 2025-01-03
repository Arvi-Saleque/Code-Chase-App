import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  _UpdatePasswordPageState createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _updatePassword() async {
    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      _showMessage("New passwords do not match!");
      return;
    }

    try {
      final user = _auth.currentUser!;
      final email = user.email!;
      final authCredential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text,
      );

      // Re-authenticate the user
      await user.reauthenticateWithCredential(authCredential);

      // Update password
      await user.updatePassword(_newPasswordController.text);
      _showMessage("Password updated successfully!");
    } catch (e) {
      _showMessage("Failed to update password: $e");
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Message"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MyTextfield(
              controller: _currentPasswordController,
              hintText: 'Current Password',
              obscureText: true,
              prefixIcon: Icons.lock,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            MyTextfield(
              controller: _newPasswordController,
              hintText: 'New Password',
              obscureText: true,
              prefixIcon: Icons.lock,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            MyTextfield(
              controller: _confirmNewPasswordController,
              hintText: 'Confirm New Password',
              obscureText: true,
              prefixIcon: Icons.lock,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            MyButton(
              text: 'Update Password',
              onTap: _updatePassword,
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
