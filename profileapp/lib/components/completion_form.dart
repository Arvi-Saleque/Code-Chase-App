import 'package:flutter/material.dart';

class CompletionForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const CompletionForm({required this.onSubmit, super.key});

  @override
  _CompletionFormState createState() => _CompletionFormState();
}

class _CompletionFormState extends State<CompletionForm> {
  final _formKey = GlobalKey<FormState>();
  int numberOfAttempts = 0;
  String shortDescription = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete Problem Details'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number of Attempts
              TextFormField(
                decoration: const InputDecoration(labelText: 'Number of Attempts'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      int.parse(value) < 1) {
                    return 'Please enter a valid positive integer';
                  }
                  return null;
                },
                onSaved: (value) => numberOfAttempts = int.parse(value!),
              ),

              // Short Description
              TextFormField(
                decoration: const InputDecoration(labelText: 'Short Description'),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a short description';
                  }
                  return null;
                },
                onSaved: (value) => shortDescription = value!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save(); // Save the input data
              print('Submit button pressed');
              print(
                  'Completion Data: {attempts: $numberOfAttempts, description: $shortDescription}');
              widget.onSubmit({
                'attempts': numberOfAttempts,
                'description': shortDescription,
              });
              Navigator.pop(context); // Close the dialog after submission
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
