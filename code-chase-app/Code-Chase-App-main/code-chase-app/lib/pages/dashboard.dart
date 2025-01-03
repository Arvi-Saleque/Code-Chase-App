import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/fetch_last_30_days_data.dart';
import '../components/summerycard.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FetchLast31DaysData _fetcher = FetchLast31DaysData();
  late User user;
  String userName = '';
  File? _profileImage;
  bool _isLoading = true; // New loading state

  // Statistics
  List<Map<String, dynamic>> last31DaysStats = [];
  Map<String, dynamic> userGoals = {};
  int countProblemForTodayVar = 0;
  int timeSpentToday = 0;
  double avgTimeSolved = 0.0;
  int currentWeeklySolve = 0;
  int totalMonthlySolve = 0;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    String userId = user.uid;
    try {
      List<Map<String, dynamic>> stats =
          await _fetcher.getLast31DaysData(userId: userId);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (mounted) {
        setState(() {
          last31DaysStats = stats;
          userGoals = {
            'dailyGoals': userDoc.data()?['dailygoals'] ?? 0,
            'weeklyGoals': userDoc.data()?['weeklygoals'] ?? 0,
          };
          countProblemForTodayVar = stats[0]['solvedCount'];
          timeSpentToday = stats[0]['timeTaken'];
          avgTimeSolved = countProblemForTodayVar > 0
              ? timeSpentToday / countProblemForTodayVar
              : 0.0;
          currentWeeklySolve = _calculateWeeklySolve(stats);
          totalMonthlySolve = _calculateMonthlySolve(stats);
        });
      }
    } catch (e) {
      print("Error initializing data: $e");
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }

    await _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists && mounted) {
      setState(() {
        userName = userDoc.data()?['name'] ?? 'User';
      });
    }
  }

  int _calculateWeeklySolve(List<Map<String, dynamic>> stats) {
    int weeklySolve = 0;
    for (int i = 0; i < 7 && i < stats.length; i++) {
      weeklySolve += stats[i]['solvedCount'] as int;
    }
    return weeklySolve;
  }

  int _calculateMonthlySolve(List<Map<String, dynamic>> stats) {
    int monthlySolve = 0;
    for (var day in stats) {
      monthlySolve += day['solvedCount'] as int;
    }
    return monthlySolve;
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? _buildLoadingScreen() // Show loading animation
          : _buildDashboardContent(),
    );
  }

// Loading Screen UI
  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.white, // Clean background
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated Background Circle Pulsing Effect
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withOpacity(0.3),
                    Colors.blue.withOpacity(0.0)
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // Outer Ring with Circular Progress Animation
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                strokeWidth: 8.0,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                backgroundColor: Colors.blue.withOpacity(0.1),
              ),
            ),
            // Center Icon or Logo
            const Icon(
              Icons.dashboard, // Use any relevant icon or app logo
              size: 50,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

// Main Dashboard Content
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Summary Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Weekly Progress',
                    value: '$currentWeeklySolve/${userGoals['weeklyGoals']}',
                    icon: Icons.timeline,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SummaryCard(
                    title: 'Monthly Solved',
                    value: '$totalMonthlySolve',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                /*const SizedBox(width: 8),
                Expanded(
                  child: SummaryCard(
                    title: 'Streak',
                    value: '0',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),*/
              ],
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Summary Of Today',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Solved Today',
                    value: '$countProblemForTodayVar',
                    icon: Icons.today,
                    color: Colors.blue,
                    titleFontSize: 12,
                    valueFontSize: 18,
                  ),
                ),
                Expanded(
                  child: SummaryCard(
                    title: 'Time Spent Today',
                    value: '$timeSpentToday min',
                    icon: Icons.access_time,
                    color: Colors.green,
                    titleFontSize: 12,
                    valueFontSize: 15,
                  ),
                ),
                Expanded(
                  child: SummaryCard(
                    title: 'Avg Time/Problem',
                    value: '${avgTimeSolved.toStringAsFixed(2)} min',
                    icon: Icons.calculate,
                    color: Colors.orange,
                    titleFontSize: 12,
                    valueFontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildAnimatedProgressBar(countProblemForTodayVar, userGoals['dailyGoals']),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage('lib/images/profile.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${getGreeting()}, Mr. ${userName.isNotEmpty ? userName : 'User'}!',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(
                      Icons.analytics, 'Weekly Analytics', '/weekly'),
                  _buildDrawerItem(
                      Icons.calendar_month, 'Monthly Analytics', '/monthly'),
                  _buildDrawerItem(
                      Icons.show_chart, 'Contest Performance', '/contest'),
                  _buildDrawerItem(
                      Icons.favorite_sharp, 'Favorite Problems', '/favorite'),
                  _buildDrawerItem(
                      Icons.bookmark, 'Attempted Problem', '/attempted'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
    );
  }
}

// Animated Progress Bar Widget
Widget _buildAnimatedProgressBar(int solvedToday, int dailyGoals) {
  double progress = solvedToday / (dailyGoals > 0 ? dailyGoals : 1); // Avoid division by 0

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Daily Progress',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
      TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 2), // Animation duration
        curve: Curves.easeOutCubic, // Smooth curve animation
        tween: Tween(begin: 0.0, end: progress.clamp(0.0, 1.0)), // Clamp to 0-1
        builder: (context, value, child) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background Bar
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade300,
                ),
              ),
              // Animated Foreground Bar
              Container(
                height: 20,
                width: value * MediaQuery.of(context).size.width * 0.8, // Dynamic width
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.greenAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // Text showing progress percentage
              Positioned(
                left: 10,
                child: Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 8),
      // Display Solved vs Daily Goals
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Solved Today: $solvedToday',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            'Daily Goal: $dailyGoals',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ],
  );
}
