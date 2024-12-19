import 'package:flutter/material.dart';

class ProblemCard extends StatelessWidget {
  final Map<String, dynamic> problem;
  final void Function(String problemId) onDelete;
  final void Function(Map<String, dynamic> problem) onEdit;
  final void Function(Map<String, dynamic> updatedProblem) onToggleFavorite;
  final void Function(Map<String, dynamic> problem) onShowDetails;

  const ProblemCard({
    super.key,
    required this.problem,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleFavorite,
    required this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(problem['name'] ?? 'Problem Name'),
        subtitle: Text('Status: ${problem['status'] ?? 'Pending'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => onShowDetails(problem),
            ),
            IconButton(
              icon: Icon(
                problem['isFavorite'] == true ? Icons.star : Icons.star_border,
                color: problem['isFavorite'] == true ? Colors.orange : Colors.grey,
              ),
              onPressed: () {
                problem['isFavorite'] = !(problem['isFavorite'] ?? false);
                onToggleFavorite(problem);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => onEdit(problem),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(problem['id']),
            ),
          ],
        ),
      ),
    );
  }
}

