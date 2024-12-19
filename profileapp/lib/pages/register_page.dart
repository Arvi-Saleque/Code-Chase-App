import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:profileapp/components/my_button.dart';
import 'package:profileapp/components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  // Text editing controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserToFirestore(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      });
      showMessage('User info saved to Firestore!', backgroundColor: Colors.green);
    } catch (e) {
      showMessage('Failed to save user: $e', backgroundColor: Colors.red);
    }
  }


  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Rotates continuously
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Sign up method

  void signUserUp() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showMessage('Please fill in all the fields');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showMessage("Passwords don't match!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),

      );

      await saveUserToFirestore(userCredential.user!.uid);

      await userCredential.user?.sendEmailVerification();
      await FirebaseAuth.instance.signOut();

      _showVerificationPrompt();
    } catch (e) {
      showMessage('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showVerificationPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verify Your Email'),
          content: const Text(
            'A verification email has been sent to your email address. '
            'Please check your inbox and click the verification link to activate your account.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.currentUser?.reload();
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null && user.emailVerified) {
                  Navigator.pop(context); // Close the dialog
                  showMessage(
                    'Email verified! You can now log in.',
                    backgroundColor: Colors.green,
                  );
                } else {
                  showMessage(
                    'Your email is not verified yet. Please check your inbox.',
                    backgroundColor: Colors.redAccent,
                  );
                }
              },
              child: const Text('I Have Verified'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Return to login page
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  bool isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) && // At least one uppercase letter
        RegExp(r'[a-z]').hasMatch(password) && // At least one lowercase letter
        RegExp(r'[0-9]').hasMatch(password) && // At least one digit
        RegExp(r'[!@#$%^&*(),.?":{}|<>]')
            .hasMatch(password); // At least one special character
  }

  // Helper method to show error messages
  void showMessage(String msg, {Color backgroundColor = Colors.black87}) {
    if (!mounted) return;

    String formattedMessage = msg;
    if (msg.contains('email-already-in-use')) {
      formattedMessage = 'This email is already registered. Please log in.';
    } else if (msg.contains('weak-password')) {
      formattedMessage =
          'Password is too weak. Please use a stronger password.';
    } else if (msg.contains('invalid-email')) {
      formattedMessage = 'The email address is not valid. Please try again.';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Center(
            child: Text(
              formattedMessage,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
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
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25),
                    // Logo
                    const Icon(
                      Icons.track_changes_rounded,
                      size: 100,
                    ),

                    const SizedBox(height: 25),
                    // Welcome text
                    Text(
                      'Welcome To CODECHASE!',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 15),
                    // Full Name field
                    MyTextfield(
                      controller: nameController,
                      hintText: 'Enter Full Name',
                      obscureText: false,
                      prefixIcon: Icons.person,
                    ),

                    const SizedBox(height: 15),
                    // Email field
                    MyTextfield(
                      controller: emailController,
                      hintText: 'Enter Email',
                      obscureText: false,
                      prefixIcon: Icons.email,
                    ),

                    const SizedBox(height: 15),
                    // Password field
                    MyTextfield(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      prefixIcon: Icons.lock,
                    ),

                    const SizedBox(height: 15),
                    // Confirm password field
                    MyTextfield(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                      prefixIcon: Icons.lock,
                    ),

                    const SizedBox(height: 20),
                    // Sign up button
                    MyButton(
                      text: 'Sign Up',
                      onTap: signUserUp,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 30),
                    // Already have an account?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            'Login now!',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _animationController.value * 2 * pi,
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.sync,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
