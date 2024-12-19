import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User user;
  String userName = '';
  String institution = '';
  String programmingHandle = '';
  int dailyGoals = 0;
  int weeklyGoals = 0;
  int goals = 0;

  final List<String> universities = [
    'Bangladesh University of Engineering and Technology (BUET)',
    'Dhaka University',
    'Chittagong University',
    'Jahangirnagar University',
    'North South University',
    'BRAC University',
    'Independent University, Bangladesh (IUB)',
    'American International University-Bangladesh (AIUB)',
    'East West University',
    'Ahsanullah University of Science and Technology (AUST)',
    'Khulna University of Engineering and Technology (KUET)',
    'Rajshahi University of Engineering and Technology (RUET)',
    'Shahjalal University of Science and Technology (SUST)',
    'Islamic University of Technology (IUT)',
    'Bangladesh University of Professionals (BUP)',
    'Military Institute of Science and Technology (MIST)',
    'Jagannath University',
    'University of Dhaka',
    'University of Chittagong',
    'University of Rajshahi',
    'University of Barisal',
    'University of Comilla',
    'University of Khulna',
    'University of Mymensingh',
    'University of Sylhet',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      user = _auth.currentUser!;
      _fetchUserData();
    });
  }

  Future<void> _fetchUserData() async {
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        userName = data['name'] ?? user.displayName ?? '';
        institution = data['institution'] ?? '';
        programmingHandle = data['programminghandle'] ?? '';
        dailyGoals = data['dailygoals'] ?? 0; // New field
        weeklyGoals = data['weeklygoals'] ?? 0; // New field
      });
    }
  }


  Future<void> _editDropdownField(String field, String selectedValue) async {
    String tempValue = selectedValue.isNotEmpty ? selectedValue : universities.first;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                isExpanded: true,
                value: tempValue,
                items: universities.map((university) {
                  return DropdownMenuItem(
                    value: university,
                    child: Text(university),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    tempValue = value!;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (tempValue.isNotEmpty) {
                  await _firestore
                      .collection('users')
                      .doc(user.uid)
                      .update({field.toLowerCase(): tempValue});

                  setState(() {
                    institution = tempValue;
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


  Future<void> _editTextField(String field, dynamic currentValue) async {
    TextEditingController controller = TextEditingController();
    controller.text = currentValue.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: field.contains('Goals') // For numeric input validation
              ? TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: field),
          )
              : TextField(
            controller: controller,
            decoration: InputDecoration(labelText: field),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedValue = field.contains('Goals')
                    ? int.tryParse(controller.text)
                    : controller.text;

                if (updatedValue != null) {
                  // Convert field name to Firestore document keys
                  String firestoreField = field.toLowerCase().replaceAll(' ', '');

                  await _firestore
                      .collection('users')
                      .doc(user.uid)
                      .update({firestoreField: updatedValue});

                  setState(() {
                    if (field == 'Daily Goals') {
                      dailyGoals = updatedValue as int;
                    } else if (field == 'Weekly Goals') {
                      weeklyGoals = updatedValue as int;
                    } else if (field == 'Programming Handle') {
                      programmingHandle = updatedValue as String;
                    } else if (field == 'Goals') {
                      goals = updatedValue as int;
                    } else if (field == 'Name') {
                      userName = updatedValue as String;
                    }
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }



  void signOutUser() {
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile Page'),
        actions: [
          IconButton(
            onPressed: signOutUser,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildInfoField('Name', userName)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTextField('Name', userName),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildInfoField('Institution', institution)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editDropdownField('Institution', institution),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                    child: _buildInfoField('Programming Handle', programmingHandle)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTextField('Programming Handle', programmingHandle),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildInfoField('Daily Goals', dailyGoals.toString())),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTextField('Daily Goals', dailyGoals),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildInfoField('Weekly Goals', weeklyGoals.toString())),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTextField('Weekly Goals', weeklyGoals),
                ),
              ],
            ),
            const SizedBox(height: 20),

// My Friends Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/myFriends'); // Replace with your route
              },
              icon: const Icon(Icons.group, color: Colors.white),
              label: const Text('My Friends', style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 20),

// Search Friends Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/searchFriends'); // Replace with your route
              },
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text('Search Friends', style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
