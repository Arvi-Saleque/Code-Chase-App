import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:profileapp/components/summerycard.dart';

class WeeklyAnalyticsChart extends StatefulWidget {
  final List<int> problemsSolved; // Problems solved per day
  final List<int> timeSpent; // Time spent per day (in minutes)
  final List<String> dayNames;

  const WeeklyAnalyticsChart({
    super.key,
    required this.problemsSolved,
    required this.timeSpent,
    required this.dayNames,
  });

  @override
  State<WeeklyAnalyticsChart> createState() => _WeeklyAnalyticsChartState();
}

class _WeeklyAnalyticsChartState extends State<WeeklyAnalyticsChart> {
  User? user = FirebaseAuth.instance.currentUser;

  Future<int> fetchWeeklyGoals() async {
    try {
      String uid = user!.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return snapshot.data()?['weeklygoals'] ?? 0; // Default to 0 if not found
    } catch (e) {
      print('Error fetching weekly goals: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalProblems = widget.problemsSolved.reduce((a, b) => a + b);
    final totalTime = widget.timeSpent.reduce((a, b) => a + b);
    final averageProblems =
    (totalProblems / widget.problemsSolved.length).toStringAsFixed(2);
    final averageTime =
    (totalTime / widget.timeSpent.length).toStringAsFixed(2);

    return FutureBuilder<int>(
      future: fetchWeeklyGoals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        int weeklyGoals = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Problems',
                        value: '$totalProblems',
                        icon: Icons.check_circle,
                        color: Colors.blue,
                        titleFontSize: 12,
                        valueFontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SummaryCard(
                        title: 'Total Time',
                        value: '$totalTime mins',
                        icon: Icons.timer,
                        color: Colors.green,
                        titleFontSize: 12,
                        valueFontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SummaryCard(
                        title: 'Avg Problems/Day',
                        value: averageProblems,
                        icon: Icons.bar_chart,
                        color: Colors.orange,
                        titleFontSize: 12,
                        valueFontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SummaryCard(
                        title: 'Avg Time/Day',
                        value: '$averageTime mins',
                        icon: Icons.schedule,
                        color: Colors.purple,
                        titleFontSize: 12,
                        valueFontSize: 17,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildAnimatedProgressBar(totalProblems, weeklyGoals),
                const SizedBox(height: 30),
                const Text(
                  'Daily Insights',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...widget.problemsSolved.asMap().entries.map((entry) {
                  final dayIndex = entry.key;
                  final problems = entry.value;
                  final time = widget.timeSpent[dayIndex];
                  final dayName = widget.dayNames[dayIndex];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          dayName[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        dayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '$problems problems solved, $time mins spent',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 30),
                const Text(
                  'Summary Chart',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                AspectRatio(
                  aspectRatio: 1.7,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: _generateBarGroups(widget.problemsSolved),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() < 0 ||
                                      value.toInt() >= widget.dayNames.length) {
                                    return const SizedBox.shrink();
                                  }
                                  String dayAbbreviation =
                                  widget.dayNames[value.toInt()]
                                      .split(" ")[0][0];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Text(
                                      dayAbbreviation,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<int> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      );
    }).toList();
  }
}

// Animated Progress Bar Widget
Widget _buildAnimatedProgressBar(int solvedThisWeek, int weeklygoals) {
    double progress = solvedThisWeek / (weeklygoals > 0 ? weeklygoals : 1); // Avoid division by 0

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Weekly Progress',
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
      // Display Solved vs Weekly Goals
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Solved This Week: $solvedThisWeek',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            'Weekly Goal: $weeklygoals',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ],
  );
}