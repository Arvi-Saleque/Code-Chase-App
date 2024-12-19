import 'dart:convert';
import 'package:http/http.dart' as http;
import '../components/contest.dart';

class ContestService {
  Future<List<Contest>> fetchUpcomingContests() async {
    final url = Uri.parse('https://codeforces.com/api/contest.list');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final contests = data['result'] as List;
          final upcomingContests = contests
              .where(
                  (contest) => contest['phase'] == 'BEFORE') // Filter upcoming
              .map((json) => Contest.fromJson(json))
              .toList();

          return upcomingContests;
        } else {
          throw Exception('Failed to load contests');
        }
      } else {
        throw Exception('Failed to connect to the API');
      }
    } catch (e) {
      throw Exception('Error fetching contests: $e');
    }
  }
}
