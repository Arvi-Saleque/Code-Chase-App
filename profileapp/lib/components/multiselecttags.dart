import 'package:flutter/material.dart';

class MultiSelectTags extends StatefulWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final Function(List<String>) onSelectionChanged;

  const MultiSelectTags({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onSelectionChanged,
  });

  @override
  _MultiSelectTagsState createState() => _MultiSelectTagsState();
}

class _MultiSelectTagsState extends State<MultiSelectTags> {
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags); // Initialize with current selections
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _selectedTags.map((tag) {
            return Chip(
              label: Text(tag),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  _selectedTags.remove(tag);
                  widget.onSelectionChanged(_selectedTags);
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final List<String>? selected = await showDialog<List<String>>(
              context: context,
              builder: (context) {
                return _TagSelectionDialog(
                  availableTags: widget.availableTags,
                  selectedTags: _selectedTags,
                );
              },
            );
            if (selected != null) {
              setState(() {
                _selectedTags = selected;
                widget.onSelectionChanged(_selectedTags);
              });
            }
          },
          child: const Text("Select Tags"),
        ),
      ],
    );
  }
}

class _TagSelectionDialog extends StatefulWidget {
  final List<String> availableTags;
  final List<String> selectedTags;

  const _TagSelectionDialog({
    required this.availableTags,
    required this.selectedTags,
  });

  @override
  _TagSelectionDialogState createState() => _TagSelectionDialogState();
}

class _TagSelectionDialogState extends State<_TagSelectionDialog> {
  late List<String> _tempSelectedTags;

  @override
  void initState() {
    super.initState();
    _tempSelectedTags = List.from(widget.selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Tags"),
      content: SingleChildScrollView(
        child: Column(
          children: widget.availableTags.map((tag) {
            final isSelected = _tempSelectedTags.contains(tag);
            return CheckboxListTile(
              value: isSelected,
              title: Text(tag),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _tempSelectedTags.add(tag);
                  } else {
                    _tempSelectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, _tempSelectedTags);
          },
          child: const Text("Done"),
        ),
      ],
    );
  }
}
