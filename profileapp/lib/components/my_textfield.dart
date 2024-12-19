import 'package:flutter/material.dart';

class MyTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData prefixIcon;
  final Color color;

  const MyTextfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.prefixIcon,
    this.color = Colors.blueGrey,
    TextInputType keyboardType = TextInputType.text,
  });

  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  late bool _isObscured; // State to manage password visibility

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText; // Initialize with the provided obscureText value
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscured, // Use the state to toggle visibility
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: widget.color,
          ),
          // Add the suffix icon for password visibility
          suffixIcon: widget.obscureText
              ? GestureDetector(
            onTapDown: (_) {
              // Show password on press
              setState(() {
                _isObscured = false;
              });
            },
            onTapUp: (_) {
              // Hide password when released
              setState(() {
                _isObscured = true;
              });
            },
            onTapCancel: () {
              // Ensure password is hidden if tap is canceled
              setState(() {
                _isObscured = true;
              });
            },
            child: Icon(
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
          )
              : null,
        ),
      ),
    );
  }
}
