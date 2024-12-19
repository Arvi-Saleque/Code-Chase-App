import 'package:cloud_firestore/cloud_firestore.dart';

class DayStatisticsHelper {
  final CollectionReference _problemsCollection =
  FirebaseFirestore.instance.collection('problems');

  // Fetch all statistics for the last 31 days for a user
  Future<List<Map<String, dynamic>>> getMonthlyStatistics({
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
  }) async {
    try {
      // Query to fetch all solved problems in the range
      Timestamp startTimestamp = Timestamp.fromDate(startDate);
      Timestamp endTimestamp = Timestamp.fromDate(endDate);

      print("Fetching problems between: $startTimestamp and $endTimestamp");

      QuerySnapshot snapshot = await _problemsCollection
          .where('user', isEqualTo: userId)
          .where('updatedAt', isGreaterThanOrEqualTo: startTimestamp)
          .where('updatedAt', isLessThan: endTimestamp)
          .where('status', isEqualTo: 'solved')
          .get();

      // Return the list of documents for processing
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching monthly statistics: $e");
      return [];
    }
  }
}
