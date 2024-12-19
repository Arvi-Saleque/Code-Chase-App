import 'package:http/http.dart' as http;
import 'dart:convert';

class FetchData {
  // Fetch all-time stats
  Future<Map<String, dynamic>> fetchUserData(String handle) async {
    final String apiUrl = 'https://codeforces.com/api/user.rating?handle=$handle';
    final String submissionsUrl = 'https://codeforces.com/api/user.status?handle=$handle';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      final response2 = await http.get(Uri.parse(submissionsUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final data2 = jsonDecode(response2.body);
        if (data['status'] == 'OK') {
          final List<dynamic> contests = data['result'] as List<dynamic>;
          final List<dynamic> submissions = data2['result'] as List<dynamic>;

          final int totalContests = contests.length;

          // Calculate unique problems solved
          final Set<String> uniqueProblems = {};
          for (var submission in submissions) {
            if (submission['verdict'] == 'OK') {
              final problem = submission['problem'];
              final problemKey = '${problem['contestId']}-${problem['index']}';
              uniqueProblems.add(problemKey);
            }
          }


          // Calculate total problems solved and average solved per day
          final startTimestamp = contests.first['ratingUpdateTimeSeconds'] * 1000; // in ms
          final startDate = DateTime.fromMillisecondsSinceEpoch(startTimestamp);
          final currentDate = DateTime.now();

          // Days between first contest and today
          final daysActive = currentDate.difference(startDate).inDays;

          // Assuming an average of 3 problems solved per contest
          final int totalProblemsSolved = uniqueProblems.length;
          final double avgProblemsPerDay =
          daysActive > 0 ? totalProblemsSolved / daysActive : 0;

          return {
            'success': true,
            'data': {
              'totalContests': totalContests,
              'totalProblemsSolved': totalProblemsSolved,
              'avgSolvedPerDay': avgProblemsPerDay,
            },
          };
        } else {
          return {'success': false, 'error': data['comment']};
        }
      } else {
        return {'success': false, 'error': 'HTTP Status Code: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Fetch latest contests
  Future<Map<String, dynamic>> fetchContests(String handle, int limit) async {
    final String apiUrl = 'https://codeforces.com/api/user.rating?handle=$handle';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final List<dynamic> contests = data['result'] as List<dynamic>;
          final latestContests = contests.reversed.take(limit).map((contest) {
            final int oldRating = contest['oldRating'];
            final int newRating = contest['newRating'];
            final int change = newRating - oldRating;
            return {
              'name': contest['contestName'],
              'rank': contest['rank'],
              'oldRating': oldRating,
              'newRating': newRating,
              'change': change > 0 ? '+$change' : '$change',
            };
          }).toList();

          return {'success': true, 'data': latestContests};
        } else {
          return {'success': false, 'error': data['comment']};
        }
      } else {
        return {'success': false, 'error': 'HTTP Status Code: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
