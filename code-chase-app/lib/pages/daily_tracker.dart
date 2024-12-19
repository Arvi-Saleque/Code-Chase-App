// Import necessary packages

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/multiselecttags.dart';


class DailyTrackerPage extends StatefulWidget {
  const DailyTrackerPage({super.key});

  @override
  State<DailyTrackerPage> createState() => _DailyTrackerPageState();
}

class _DailyTrackerPageState extends State<DailyTrackerPage> {
  // List to store problem details
  final List<Map<String, dynamic>> _dailyData = [];
  final CollectionReference _firestoreRef = FirebaseFirestore.instance.collection("problems");


  final FirebaseAuth _auth = FirebaseAuth.instance;

  late User user;

  // Variables for timer functionality
  Map<String, dynamic>? _currentProblem;
  Timer? _timer;
  int _elapsedTime = 0; // In seconds

  @override
  void initState() {
    super.initState();
    _loadProblemsFromFirebase();
  }

  // Method to load problems from Firebase
  void _loadProblemsFromFirebase() {
    _firestoreRef
        .where('user', isEqualTo: _auth.currentUser!.uid)
        .get()
        .then((querySnapshot) {
      final problems = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Save Firestore document ID locally
        return data;
      }).toList();

      if(mounted) {
        setState(() {
          _dailyData.clear();
          _dailyData.addAll(problems);
        });
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading problems: $error')),
      );
    });
  }

  // Method to save a problem to Firebase
  void _saveProblemToFirebase(Map<String, dynamic> problem) {
    problem['isFavorite'] = false;
    problem['user'] = _auth.currentUser!.uid;
    problem['updatedAt'] = Timestamp.now();

    _firestoreRef.add(problem).then((docRef) {
      problem['id'] = docRef.id; // Save Firestore document ID locally

    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving problem: $error')),
      );
    });
  }

  // Method to start the timer
  void _startTimer(Map<String, dynamic> problem) {
    if(mounted) {
      setState(() {
        _currentProblem = problem;
        _elapsedTime = 1; // Start from 1 second
      });
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if(mounted) {
        setState(() {
          _elapsedTime++;
        });
      }
    });
  }

  // Method to  stopthe timer
  void _stopTimer() {
    if (_currentProblem != null) {
      final actualMinutes = _elapsedTime ~/ 60;
      final actualHours = actualMinutes ~/ 60;
      final remainingMinutes = actualMinutes % 60;

      if(mounted) {
        setState(() {
          _currentProblem!['actualTime'] = _elapsedTime;
          int problemIndex = _dailyData.indexWhere((p) => p == _currentProblem);
          if (problemIndex != -1) {
            _dailyData[problemIndex] = _currentProblem!;
          }
        });
      }

      // Show additional form after stopping the timer
      _showRemainingFieldsForm(_currentProblem!);

      // Reset the timer and state
      _currentProblem = null;
      _elapsedTime = 0;
      _timer?.cancel();
    }
  }

  // Timer Overlay UI
  Widget _buildTimerOverlay() {
    final hours = _elapsedTime ~/ 3600;
    final minutes = (_elapsedTime % 3600) ~/ 60;
    final seconds = _elapsedTime % 60;

    return Center(
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(150),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 30,
                ),
              ),
              child: const Text(
                'Stop Timer',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProblemDetailsDialog(Map<String, dynamic> problem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            problem['name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (problem['platform'] != null)
                  Text('Platform: ${problem['platform']}',
                      style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                if (problem['url'] != null && problem['url']!.isNotEmpty)
                  Text(
                    'URL: ${problem['url']}',
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                const SizedBox(height: 8),
                if (problem['tags'] != null &&
                    (problem['tags'] as List).isNotEmpty)
                  Text('Tags: ${problem['tags'].join(', ')}',
                      style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                if (problem['status'] != null)
                  Text('Status: ${problem['status']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: problem['status'] == 'solved'
                            ? Colors.green
                            : problem['status'] == 'Skipped'
                            ? Colors.blue
                            : Colors.red,
                      )),
                const SizedBox(height: 8),
                Text('Time Taken: ${(problem['actualTime'] / 60).toStringAsFixed(2)} mins',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                if (problem['notes'] != null && problem['notes']!.isNotEmpty)
                  Text('Notes: ${problem['notes']}',
                      style: const TextStyle(fontSize: 16)),
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
      },
    );
  }

  void _toggleFavoriteProblem(Map<String, dynamic> problem) {
    final newStatus = !(problem['isFavorite'] ?? false); // Toggle the status
    if(mounted) {
      setState(() {
        problem['isFavorite'] = newStatus; // Update locally
      });
    }

    if (problem['id'] != null) {
      _firestoreRef.doc(problem['id']).update({'isFavorite': newStatus}).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorite status: $error')),
        );
      });
    }

  }

  // Show remaining fields form
  void _showRemainingFieldsForm(Map<String, dynamic> problem) {
    String platformText = problem['platform'] ?? 'CF';
    final TextEditingController urlController =
    TextEditingController(text: problem['url'] ?? 'none');
    List<String> selectedTags = (problem['tags'] ?? ['implementation']).cast<String>();
    final TextEditingController statusController = TextEditingController();
    final TextEditingController notesController =
    TextEditingController(text: problem['notes'] ?? 'basic implementaiotn');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complete Problem Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: platformText,
                  decoration: const InputDecoration(labelText: 'Platform'),
                  items: ['CF', 'LeetCode', 'CodeChef', 'HackerRank', 'Vjudge']
                      .map((platform) => DropdownMenuItem(
                    value: platform,
                    child: Text(platform),
                  ))
                      .toList(),
                  onChanged: (value) => platformText = value!,
                ),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'Problem URL'),
                ),
                MultiSelectTags(
                  availableTags: [
                    'DP',
                    'Greedy',
                    'Binary Search',
                    'Segment Tree',
                    'Graph',
                    'Shortest Path',
                    'String',
                    'Divide and Conquer',
                    'Math',
                    'Bit Manipulation',
                    'Adhoc',
                  ],
                  selectedTags: selectedTags,
                  onSelectionChanged: (newTags) {
                    selectedTags = newTags;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: statusController.text.isNotEmpty ? statusController.text : null,
                  items: ['solved', 'Attempted but not solved', 'Skipped']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    statusController.text = value!;
                  },
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (statusController.text.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Status is required!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }

                if(mounted) {
                  setState(() {
                    problem['platform'] = platformText;
                    problem['url'] = urlController.text;
                    problem['tags'] = selectedTags;
                    problem['status'] = statusController.text;
                    problem['notes'] = notesController.text;
                  });
                }
                _saveProblemToFirebase(problem);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracker'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ElevatedButton.icon(
              onPressed: _showAddProblemForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, size: 20, color: Colors.white,),
              label: const Text(
                'Add Problem',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          ListView.builder(
            itemCount: _dailyData.length,
            itemBuilder: (context, index) {
              final problem = _dailyData[index];
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            problem['name'],
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            label: Text('Rating: ${problem['rating']}'),
                            backgroundColor: Colors.blue[50],
                          ),
                          Chip(
                            label: Text(
                                'Time Taken: ${(problem['actualTime'] / 60).toStringAsFixed(2)} mins'),
                            backgroundColor: Colors.orange[50],
                          ),
                          if (problem['tags'] != null)
                            for (String tag in problem['tags'])
                              Chip(
                                label: Text(tag),
                                backgroundColor: Colors.purple[50],
                              ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () => _editProblem(problem),
                            icon: const Icon(Icons.edit, color: Colors.blue),
                          ),
                          IconButton(
                            onPressed: () => deleteProblem(problem),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                          IconButton(
                            onPressed: () => _showProblemDetailsDialog(problem),
                            icon: const Icon(Icons.info_outline,
                                color: Colors.blue),
                          ),
                          IconButton(
                            onPressed: () {
                              _toggleFavoriteProblem(problem);
                            },
                            icon: Icon(
                              problem['isFavorite'] == true ? Icons.star : Icons.star_border,
                              color: problem['isFavorite'] == true ? Colors.orange : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_currentProblem != null) _buildTimerOverlay(),
        ],
      ),
    );
  }

  // Method to show the simplified add problem form
  void _showAddProblemForm() {
    final TextEditingController nameController = TextEditingController();
    String? selectedRating;
    int? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Problem'),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Problem Name (Optional)',
                      hintText: 'Default: Problem Name',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedRating,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty/Rating',
                      hintText: 'based on Codeforces',
                    ),
                    items: [
                      for (int i = 800; i <= 3500; i += 100)
                        DropdownMenuItem(
                          value: i.toString(),
                          child: Text(i.toString()),
                        ),
                    ],
                    onChanged: (value) => selectedRating = value,
                  ),
                  DropdownButtonFormField<int>(
                    value: selectedTime,
                    decoration: const InputDecoration(
                      labelText: 'Expected Time',
                      hintText: 'Select time in minutes',
                    ),
                    items: [
                      for (int i = 5; i <= 180; i += 5)
                        DropdownMenuItem(
                          value: i,
                          child: Text('$i minutes'),
                        ),
                    ],
                    onChanged: (value) => selectedTime = value,
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
            TextButton(
              onPressed: () {
                if (selectedRating == null || selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select both difficulty and expected time!'),
                    ),
                  );
                  return;
                }

                final problem = {
                  'name': nameController.text.isEmpty
                      ? 'Problem Name'
                      : nameController.text,
                  'rating': int.parse(selectedRating!),
                  'expectedTime': selectedTime! * 60, // Convert minutes to seconds
                  'actualTime': 0,
                };

                if(mounted) {
                  setState(() {
                    _dailyData.add(problem);
                  });
                }
                Navigator.pop(context);
                _startTimer(problem);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Edit problem
  void _editProblem(Map<String, dynamic> problem) {
    final TextEditingController nameController =
    TextEditingController(text: problem['name']);
    final TextEditingController ratingController =
    TextEditingController(text: problem['rating'].toString());
    final TextEditingController actualTimeController =
    TextEditingController(text: (problem['actualTime'] ~/ 60).toString());
    String platformText = problem['platform'] ?? 'CF';
    final TextEditingController urlController =
    TextEditingController(text: problem['url'] ?? 'none');
    List<String> selectedTags = (problem['tags'] ?? ['implementation']).cast<String>();
    final TextEditingController statusController =
    TextEditingController(text: problem['status'] ?? '');
    final TextEditingController notesController =
    TextEditingController(text: problem['notes'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Problem'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Problem Name'),
                ),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(labelText: 'Difficulty/Rating'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: actualTimeController,
                  decoration: const InputDecoration(labelText: 'Expected Time (minutes)'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: platformText,
                  decoration: const InputDecoration(labelText: 'Platform'),
                  items: ['CF', 'LeetCode', 'CodeChef', 'HackerRank', 'Vjudge']
                      .map((platform) => DropdownMenuItem(
                    value: platform,
                    child: Text(platform),
                  ))
                      .toList(),
                  onChanged: (value) => platformText = value!,
                ),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'URL'),
                ),
                MultiSelectTags(
                  availableTags: [
                    'DP',
                    'Greedy',
                    'Binary Search',
                    'Segment Tree',
                    'Graph',
                    'Shortest Path',
                    'String',
                    'Divide and Conquer',
                    'Math',
                    'Bit Manipulation',
                    'Adhoc',
                  ],
                  selectedTags: selectedTags,
                  onSelectionChanged: (newTags) {
                    selectedTags = newTags;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: statusController.text.isNotEmpty ? statusController.text : null,
                  items: ['solved', 'Attempted but not solved', 'Skipped']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    statusController.text = value!;
                  },
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if(mounted) {
                  setState(() {
                    problem['name'] = nameController.text;
                    problem['rating'] =
                        int.tryParse(ratingController.text) ?? problem['rating'];
                    problem['actualTime'] =
                        (int.tryParse(actualTimeController.text) ?? 0) * 60;
                    problem['platform'] = platformText;
                    problem['url'] = urlController.text;
                    problem['tags'] = selectedTags;
                    if (problem['status'] != statusController.text){
                      problem['updatedAt'] = Timestamp.now();
                    }
                    problem['status'] = statusController.text;
                    problem['notes'] = notesController.text;

                    if (problem['id'] != null) {
                      _firestoreRef.doc(problem['id']).update({...problem}).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating problem: $error')),
                        );
                      });
                    }
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteProblem(Map<String, dynamic> problem) {
    if (problem['id'] != null) {
      _firestoreRef.doc(problem['id']).delete().then((_) {
        if(mounted) {
          setState(() {
            _dailyData.remove(problem);
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Problem deleted successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting problem: $error')),
        );
      });
    } else {
      if(mounted) {
        setState(() {
          _dailyData.remove(problem);
        });
      }
    }
  }

}