import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ContestRankLineChart extends StatelessWidget {
  final List<int> ranks; // Contest ranks

  const ContestRankLineChart({super.key, required this.ranks});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
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
                  'C${value.toInt() + 1}', // Contest names
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Colors.red,
              spots: ranks.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.toDouble());
              }).toList(),
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}