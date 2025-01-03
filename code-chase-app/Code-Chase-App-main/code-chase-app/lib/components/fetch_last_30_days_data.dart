import 'package:cloud_firestore/cloud_firestore.dart';
import 'DayStatisticsHelper.dart';

class FetchLast31DaysData {
  final DayStatisticsHelper _dayHelper = DayStatisticsHelper();

  // Fetch stats for the last 31 days
  Future<List<Map<String, dynamic>>> getLast31DaysData({required String userId}) async {
    List<Map<String, dynamic>> last31DaysStats = [];
    DateTime today = DateTime.now().toUtc();
    DateTime startDate = today.subtract(Duration(days: 31));

    // Fetch all solved problems for the last 31 days in one query
    List<Map<String, dynamic>> allProblems = await _dayHelper.getMonthlyStatistics(
      startDate: startDate,
      endDate: today.add(Duration(days: 1)), // Include today
      userId: userId,
    );

    // Group problems by date
    Map<String, List<Map<String, dynamic>>> groupedProblems = {};

    for (var problem in allProblems) {
      String date = (problem['updatedAt'] as Timestamp).toDate().toUtc().toIso8601String().split('T')[0];
      groupedProblems.putIfAbsent(date, () => []).add(problem);
    }

    // Generate statistics for each day in the last 31 days
    for (int i = 0; i < 31; i++) {
      DateTime targetDate = today.subtract(Duration(days: i));
      String dateKey = targetDate.toIso8601String().split('T')[0];

      int solvedCount = 0;
      int totalTimeInSeconds = 0;

      // Process problems for the specific day
      if (groupedProblems.containsKey(dateKey)) {
        for (var problem in groupedProblems[dateKey]!) {
          if(problem['status'] == 'solved') {
            solvedCount++;
          }
          totalTimeInSeconds += (problem['actualTime'] as num?)?.toInt() ?? 0;
        }
      }

      // Add result for the day
      last31DaysStats.add({
        'date': dateKey,
        'dayOfWeek': _getDayOfWeek(targetDate),
        'solvedCount': solvedCount,
        'timeTaken': (totalTimeInSeconds / 60).round(),
      });
    }

    return last31DaysStats;
  }

  // Helper function to get day of the week
  String _getDayOfWeek(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }
}
