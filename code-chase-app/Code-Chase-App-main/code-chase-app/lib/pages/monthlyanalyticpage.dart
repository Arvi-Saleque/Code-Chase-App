import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/monthlyanalyticalchart.dart';
import '../components/fetch_last_30_days_data.dart';

class MonthlyAnalyticsPage extends StatefulWidget {
  const MonthlyAnalyticsPage({super.key});

  @override
  State<MonthlyAnalyticsPage> createState() => _MonthlyAnalyticsPageState();
}

class _MonthlyAnalyticsPageState extends State<MonthlyAnalyticsPage> {
  final FetchLast31DaysData _fetcher = FetchLast31DaysData();
  late User user;
  bool isLoading = true;

  // Data for the chart
  List<int> problemsSolved = [];
  List<int> timeSpent = [];
  List<String> phaseNames = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _loadMonthlyAnalytics();
  }

  Future<void> _loadMonthlyAnalytics() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch the last 31 days data
      List<Map<String, dynamic>> last31DaysStats =
      await _fetcher.getLast31DaysData(userId: user.uid);

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
        problemsSolved = problems.reversed.toList();
        timeSpent = times.reversed.toList();
        phaseNames = phases.reversed.toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error loading monthly analytics: $e");
      setState(() {
        isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Monthly Analytics'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: MonthlyAnalyticsChart(
          problemsSolved: problemsSolved,
          timeSpent: timeSpent,
          phaseNames: phaseNames,
        ),
      ),
    );
  }
}
