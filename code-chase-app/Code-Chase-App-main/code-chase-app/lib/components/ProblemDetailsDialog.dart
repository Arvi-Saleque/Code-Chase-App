import 'package:flutter/material.dart';

class ProblemDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> problem;

  const ProblemDetailsDialog({
    super.key,
    required this.problem,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        problem['name'] ?? 'Problem Details',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (problem['platform'] != null)
              Text(
                'Platform: ${problem['platform']}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 8),
            if (problem['url'] != null && problem['url'].isNotEmpty)
              GestureDetector(
                onTap: () {
                  // Handle URL navigation if required
                },
                child: Text(
                  'URL: ${problem['url']}',
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            const SizedBox(height: 8),
            if (problem['tags'] != null && (problem['tags'] as List).isNotEmpty)
              Text(
                'Tags: ${problem['tags'].join(', ')}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 8),
            if (problem['status'] != null)
              Text(
                'Status: ${problem['status']}',
                style: TextStyle(
                  fontSize: 16,
                  color: problem['status'] == 'solved'
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Time Taken: ${(problem['actualTime'] ?? 0) ~/ 60} mins',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (problem['notes'] != null && problem['notes'].isNotEmpty)
              Text(
                'Notes: ${problem['notes']}',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
