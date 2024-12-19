import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/weeklyanalyticalchart.dart';
import '../components/fetch_last_30_days_data.dart';

class WeeklyAnalyticsPage extends StatefulWidget {
  const WeeklyAnalyticsPage({super.key});

  @override
  State<WeeklyAnalyticsPage> createState() => _WeeklyAnalyticsPageState();
}

class _WeeklyAnalyticsPageState extends State<WeeklyAnalyticsPage> {
  final FetchLast31DaysData _fetcher = FetchLast31DaysData();
  late User user;
  bool isLoading = true;

  // Data for the chart
  List<int> problemsSolved = [];
  List<int> timeSpent = [];
  List<String> dayNames = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _loadWeeklyAnalytics();
  }

  Future<void> _loadWeeklyAnalytics() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch the last 31 days data
      List<Map<String, dynamic>> last31DaysStats =
      await _fetcher.getLast31DaysData(userId: user.uid);

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
        isLoading = false;
      });
    } catch (e) {
      print("Error loading weekly analytics: $e");
      setState(() {
        isLoading = false;
      });
    }

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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weekly Analytics'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Analytics'),
      ),
      body: WeeklyAnalyticsChart(
        problemsSolved: problemsSolved,
        timeSpent: timeSpent,
        dayNames: dayNames,
      ),
    );
  }
}

