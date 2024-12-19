import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MarkedProblemsPage extends StatelessWidget {
  final CollectionReference _firestoreRef = FirebaseFirestore.instance.collection("problems");
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MarkedProblemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Problems'),
      ),
      body: StreamBuilder(
        stream: _firestoreRef
            .where('isFavorite', isEqualTo: true)
            .where('user', isEqualTo: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          return _buildPageContent(context, snapshot);
        },
      ),

    );
  }

  // Method to build the page content
  Widget _buildPageContent(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(child: Text('No favorite problems yet'));
    }

    // Safely extracting and casting data from snapshot
    final favoriteProblems = snapshot.data!.docs.map<Map<String, dynamic>>((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>, // Safely cast document data
      };
    }).toList();

    return _buildProblemList(context, favoriteProblems);
  }


  // Method to build the problem list
  Widget _buildProblemList(BuildContext context, List<Map<String, dynamic>> problems) {
    return ListView.builder(
      itemCount: problems.length,
      itemBuilder: (context, index) {
        return _buildProblemCard(context, problems[index]);
      },
    );
  }

  // Method to build individual problem card
  Widget _buildProblemCard(BuildContext context, Map<String, dynamic> problem) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Problem Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  problem['name'] ?? 'No name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  problem['status'] ?? 'Pending',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: problem['status'] == 'solved'
                        ? Colors.green
                        : problem['status'] == 'Skipped'
                        ? Colors.blue
                        : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Rating and Time Taken
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text('Platform: ${problem['platform'] ?? 'N/A'}'),
                  backgroundColor: Colors.green[50],
                ),
                Chip(
                  label: Text('Rating: ${problem['rating'] ?? 'N/A'}'),
                  backgroundColor: Colors.blue[50],
                ),
                Chip(
                  label: Text('Expected Time Was: ${problem['expectedTime'] / 60 ?? 'N/A'} mins'),
                  backgroundColor: Colors.red[50],
                ),
                Chip(
                  label: Text('Time Taken: ${(problem['actualTime'] / 60).toStringAsFixed(2) ?? 'N/A'} mins'),
                  backgroundColor: Colors.orange[50],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tags as Chips
            if (problem['tags'] != null && (problem['tags'] as List).isNotEmpty)
              Wrap(
                spacing: 8,
                children: (problem['tags'] as List).map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: Colors.purple[50],
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),

            // Delete Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _removeFromFavorites(context, problem),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // Method to build the problem details
  /*Widget _buildProblemDetails(Map<String, dynamic> problem) {
    final tags = (problem['tags'] ?? []).join(', ');
    final rating = problem['rating'] ?? 'N/A';
    final timeTaken = (problem['actualTime'] / 60).toStringAsFixed(2) ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rating: $rating'),
        Text('Tags: $tags'),
        Text('Time Taken: $timeTaken mins'),
      ],
    );
  }*/

  // Method to remove a problem from favorites
  void _removeFromFavorites(BuildContext context, Map<String, dynamic> problem) {
    if (problem['id'] == null) return;

    _firestoreRef.doc(problem['id']).update({'isFavorite': false}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problem removed from favorites')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

}

