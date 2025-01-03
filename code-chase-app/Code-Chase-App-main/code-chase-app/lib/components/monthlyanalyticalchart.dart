import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:profileapp/components/summerycard.dart';

class MonthlyAnalyticsChart extends StatelessWidget {
  final List<int> problemsSolved; // Problems solved per phase
  final List<int> timeSpent; // Time spent per phase (in minutes)
  final List<String> phaseNames; // Phase names (P1, P2, ...)

  const MonthlyAnalyticsChart({
    super.key,
    required this.problemsSolved,
    required this.timeSpent,
    required this.phaseNames,
  });

  @override
  Widget build(BuildContext context) {
    final totalProblems = problemsSolved.reduce((a, b) => a + b);
    final totalTime = timeSpent.reduce((a, b) => a + b);
    final averageProblems =
    (totalProblems / problemsSolved.length).toStringAsFixed(2);
    final averageTime = (totalTime / timeSpent.length).toStringAsFixed(2);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Summary Cards
          const Text(
            'Monthly Overview',
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
                  valueFontSize: 15,
                  titleFontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryCard(
                  title: 'Total Time',
                  value: '$totalTime mins',
                  icon: Icons.timer,
                  color: Colors.green,
                  valueFontSize: 15,
                  titleFontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryCard(
                  title: 'Avg Problems/Phase',
                  value: averageProblems,
                  icon: Icons.bar_chart,
                  color: Colors.orange,
                  valueFontSize: 15,
                  titleFontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryCard(
                  title: 'Avg Time/Phase',
                  value: '$averageTime mins',
                  icon: Icons.schedule,
                  color: Colors.purple,
                  valueFontSize: 15,
                  titleFontSize: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Phase-wise Insights
          const Text(
            'Phase-wise Insights',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...problemsSolved.asMap().entries.map((entry) {
            final phaseIndex = entry.key;
            final problems = entry.value;
            final time = timeSpent[phaseIndex];
            final phaseName = phaseNames[phaseIndex];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    'P${phaseIndex + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  phaseName,
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

          // Bar Chart Section
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
                    barGroups: _generateBarGroups(problemsSolved),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < 0 || value.toInt() >= phaseNames.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                'P${value.toInt() + 1}', // Show phase index
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
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
