import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/fetch_last_30_days_data.dart';
import '../components/monthlyanalyticalchart.dart';
import '../components/summerycard.dart';
import '../components/weeklyanalyticalchart.dart';

class FriendDetailsPage extends StatefulWidget {
  final String id;
  const FriendDetailsPage({super.key, required this.id});
  @override
  State<FriendDetailsPage> createState() => _FriendDetailsPageState();
}

class _FriendDetailsPageState extends State<FriendDetailsPage> {
  final FetchLast31DaysData _fetcher = FetchLast31DaysData();

  bool _isLoading1 = true;
  bool _isLoading2 = true;
  bool _isLoading3 = true;
  List<Map<String, dynamic>> last31DaysStats = [];
  Map<String, dynamic> userGoals = {};
  int countProblemForTodayVar = 0;
  int timeSpentToday = 0;
  double avgTimeSolved = 0.0;
  int currentWeeklySolve = 0;
  int totalMonthlySolve = 0;

  List<int> problemsSolved = [];
  List<int> timeSpent = [];
  List<String> dayNames = [];

  // Data for the chart
  List<int> problemsSolvedM = [];
  List<int> timeSpentM = [];
  List<String> phaseNames = [];


  @override
  void initState() {
    super.initState();
    _initializeData();
    _buildLoadingScreen();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading1 = true; // Start loading
    });
    List<Map<String, dynamic>> stats = [];
    String userId = widget.id;
    try {
      stats = await _fetcher.getLast31DaysData(userId: userId);

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
        _isLoading1 = false; // Stop loading
      });
    }

    setState(() {
      _isLoading2 = true; // Start loading
    });
    try {
      // Fetch the last 31 days data
      List<Map<String, dynamic>> last31DaysStats =
      await _fetcher.getLast31DaysData(userId: userId);

      DateTime today = DateTime.now();
      List<int> problems = [];
      List<int> times = [];
      List<String> days = [];

      for (int i = 0; i < 7; i++) {
        DateTime targetDate = today.subtract(Duration(days: i));
        String dateKey = targetDate.toIso8601String().split('T')[0];

        Map<String, dynamic> dayData = last31DaysStats.firstWhere(
              (day) => day['date'] == dateKey,
          orElse: () => {'solvedCount': 0, 'timeTaken': 0},
        );

        problems.add(dayData['solvedCount']);
        times.add(dayData['timeTaken']);
        days.add(_getDayWithDate(targetDate));
      }

      setState(() {
        problemsSolved = problems.reversed.toList();
        timeSpent = times.reversed.toList();
        dayNames = days.reversed.toList();
        _isLoading2 = false;
      });
    } catch (e) {
      print("Error loading weekly analytics: $e");
      setState(() {
        _isLoading2 = false;
      });
    }

    setState(() {
      _isLoading3 = true; // Start loading
    });
    try {
      // Fetch the last 31 days data
      List<Map<String, dynamic>> last31DaysStats =
      await _fetcher.getLast31DaysData(userId: userId);

      // Create phase-wise insights
      List<int> problems = List.generate(6, (_) => 0);
      List<int> times = List.generate(6, (_) => 0);
      List<String> phases = [];

      DateTime today = DateTime.now();
      for (int phaseIndex = 0; phaseIndex < 6; phaseIndex++) {
        DateTime phaseStart =
        today.subtract(Duration(days: (phaseIndex + 1) * 5));
        DateTime phaseEnd =
        today.subtract(Duration(days: phaseIndex * 5));

        String phaseName =
            '${phaseStart.month}/${phaseStart.day} - ${phaseEnd.month}/${phaseEnd.day}';
        phases.add(phaseName);

        for (var day in last31DaysStats) {
          DateTime dayDate = DateTime.parse(day['date']);
          if (dayDate.isAfter(phaseStart) && dayDate.isBefore(phaseEnd)) {
            problems[phaseIndex] += day['solvedCount'] as int;
            times[phaseIndex] += day['timeTaken'] as int;
          }
        }
      }

      setState(() {
        problemsSolvedM = problems.reversed.toList();
        timeSpentM = times.reversed.toList();
        phaseNames = phases.reversed.toList();
        _isLoading3 = false;
      });
    } catch (e) {
      print("Error loading monthly analytics: $e");
      setState(() {
        _isLoading3 = false;
      });
    }

    print("Data loaded successfully");
    print("Daily Goals: ${userGoals['dailyGoals']}");
    print("Weekly Goals: ${userGoals['weeklyGoals']}");
    print("Problems Solved: $problemsSolved");
    print("Time Spent: $timeSpent");
    print("Day Names: $dayNames");
    print("Problems Solved (Monthly): $problemsSolvedM");
    print("Time Spent (Monthly): $timeSpentM");
    print("Phase Names: $phaseNames");
    print("Count Problem For Today: $countProblemForTodayVar");
    print("Time Spent Today: $timeSpentToday");
    print("Avg Time Solved: $avgTimeSolved");
    print("Current Weekly Solve: $currentWeeklySolve");
    print("Total Monthly Solve: $totalMonthlySolve");


  }

  String _getDayWithDate(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return "${days[date.weekday - 1]} (${date.month}/${date.day})";
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

  @override
  Widget build(BuildContext context) {
      if(_isLoading1 || _isLoading2 || _isLoading3) {
        return _buildLoadingScreen();
      } else {
        return _buildDashboardContent();
      }
  }


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

  Widget _buildDashboardContent() {
    return Scaffold(
      body: DefaultTabController(
        length: 3, // Three tabs: Summary, Weekly, and Monthly
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Progress Dashboard'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Summary'),
                Tab(text: 'Weekly Analytics'),
                Tab(text: 'Monthly Analytics'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Tab 1: Summary Overview - Full Screen
              Padding(
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
                            value: '$currentWeeklySolve/${userGoals['weeklyGoals'] ?? 0}',
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: SummaryCard(
                            title: 'Streak',
                            value: '7',
                            icon: Icons.local_fire_department,
                            color: Colors.orange,
                          ),
                        ),
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
                            title: 'Avg Time/Solved',
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
                    _buildAnimatedProgressBar(
                        countProblemForTodayVar, userGoals['dailyGoals']),
                  ],
                ),
              ),

              // Tab 2: Weekly Analytics - Half Screen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Weekly Analytics',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: WeeklyAnalyticsChart(
                        problemsSolved: problemsSolved,
                        timeSpent: timeSpent,
                        dayNames: dayNames,
                      ),
                    ),
                  ],
                ),
              ),

              // Tab 3: Monthly Analytics - Half Screen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Monthly Analytics',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: MonthlyAnalyticsChart(
                        problemsSolved: problemsSolvedM,
                        timeSpent: timeSpentM,
                        phaseNames: phaseNames,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
