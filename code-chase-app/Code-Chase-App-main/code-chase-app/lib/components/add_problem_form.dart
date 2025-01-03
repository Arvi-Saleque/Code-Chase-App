import 'package:flutter/material.dart';

class AddProblemForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AddProblemForm({required this.onSubmit, super.key});

  @override
  _AddProblemFormState createState() => _AddProblemFormState();
}

class _AddProblemFormState extends State<AddProblemForm> {
  final _formKey = GlobalKey<FormState>();
  String problemName = '';
  int problemDifficulty = 0;
  int estimatedMinutes = 0; // In minutes

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start a Problem'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Problem Name
              TextFormField(
                decoration: const InputDecoration(labelText: 'Problem Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a problem name';
                  }
                  return null;
                },
                onSaved: (value) => problemName = value!,
              ),
              // Problem Difficulty
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Problem Difficulty',
                  hintText: 'According to Codeforces (integer)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid integer';
                  }
                  return null;
                },
                onSaved: (value) => problemDifficulty = int.parse(value!),
              ),
              // Estimated Time
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Estimated Time (minutes)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Please enter a valid number of minutes';
                  }
                  return null;
                },
                onSaved: (value) => estimatedMinutes = int.parse(value!),
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
              _formKey.currentState!.save();
              widget.onSubmit({
                'problemName': problemName,
                'problemDifficulty': problemDifficulty,
                'estimatedMinutes': estimatedMinutes,
              });
            }
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}

