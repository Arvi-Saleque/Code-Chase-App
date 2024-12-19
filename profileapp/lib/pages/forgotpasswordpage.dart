import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool _isLoading = false;

  void resetPassword() async {
    if (emailController.text.isEmpty) {
      showErrorMessege('Please enter your email');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      showErrorMessege('Password reset email sent! Check your inbox.');
    } catch (e) {
      showErrorMessege('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void showErrorMessege(String msg) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Center(
            child: Text(
              msg,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter your email to reset your password',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              MyTextfield(
                controller: emailController,
                hintText: 'Enter Email',
                obscureText: false,
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      text: 'Reset Password',
                      onTap: resetPassword,
                      color: Colors.blueAccent,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
