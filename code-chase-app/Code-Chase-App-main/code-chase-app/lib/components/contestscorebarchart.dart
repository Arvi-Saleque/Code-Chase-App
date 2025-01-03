import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ContestScoreBarChart extends StatelessWidget {
  final List<int> scores; // Contest scores
  final List<String> contestNames; // Contest names for X-axis

  const ContestScoreBarChart({
    super.key,
    required this.scores,
    required this.contestNames,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          barGroups: scores.asMap().entries.map((entry) {
            final index = entry.key;
            final score = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: score.toDouble(),
                  color: Colors.green,
                  width: 20,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  value < contestNames.length
                      ? contestNames[value.toInt()]
                      : '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}