import 'package:flutter/material.dart';

class AddEditProblemForm extends StatefulWidget {
  final Map<String, dynamic> problem;
  final void Function(Map<String, dynamic> problem) onSave;

  const AddEditProblemForm({
    super.key,
    required this.problem,
    required this.onSave,
  });

  @override
  State<AddEditProblemForm> createState() => _AddEditProblemFormState();
}

class _AddEditProblemFormState extends State<AddEditProblemForm> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedRating;
  int? _selectedTime;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.problem['name'] ?? '';
    _selectedRating = widget.problem['rating']?.toString();
    _selectedTime = widget.problem['expectedTime'] != null
        ? (widget.problem['expectedTime'] ~/ 60)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.problem.isNotEmpty ? 'Edit Problem' : 'Add Problem'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Problem Name'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedRating,
              decoration: const InputDecoration(labelText: 'Difficulty/Rating'),
              items: [
                for (int i = 800; i <= 3500; i += 100)
                  DropdownMenuItem(value: i.toString(), child: Text(i.toString())),
              ],
              onChanged: (value) => setState(() => _selectedRating = value),
            ),
            DropdownButtonFormField<int>(
              value: _selectedTime,
              decoration: const InputDecoration(labelText: 'Expected Time'),
              items: [
                for (int i = 5; i <= 180; i += 5)
                  DropdownMenuItem(value: i, child: Text('$i minutes')),
              ],
              onChanged: (value) => setState(() => _selectedTime = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            final problem = {
              ...widget.problem,
              'name': _nameController.text.isNotEmpty
                  ? _nameController.text
                  : 'Problem Name',
              'rating': int.parse(_selectedRating ?? '800'),
              'expectedTime': (_selectedTime ?? 10) * 60,
            };
            widget.onSave(problem);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
