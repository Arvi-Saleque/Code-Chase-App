import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/contest.dart';
import '../components/countdown_timer.dart';


class ContestCard extends StatelessWidget {
  final Contest contest;

  const ContestCard({super.key, required this.contest});

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open URL: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.fromMillisecondsSinceEpoch(
      contest.startTimeSeconds * 1000,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contest.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Starts: ${startDate.toLocal()}'),
            const SizedBox(height: 5),
            CountdownTimer(startTimeSeconds: contest.startTimeSeconds),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(context, 'https://codeforces.com/contest/${contest.id}'),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
