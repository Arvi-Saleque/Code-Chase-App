import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/contest_services.dart';
import '../components/contest.dart';

class ContestPage extends StatefulWidget {
  const ContestPage({super.key});

  @override
  _ContestPageState createState() => _ContestPageState();
}

class _ContestPageState extends State<ContestPage> {
  late Future<List<Contest>> _futureContests;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _futureContests = ContestService().fetchUpcomingContests();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {}); // Refreshes the countdown every second
      }
    });
  }

  Future<void> _refreshContests() async {
    setState(() {
      _futureContests = ContestService().fetchUpcomingContests();
    });
  }

  String _formatCountdown(int startTime) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remainingSeconds = startTime - now;

    if (remainingSeconds <= 0) return 'Starts soon!';

    final days = remainingSeconds ~/ (24 * 3600);
    final hours = (remainingSeconds % (24 * 3600)) ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;

    return '${days.toString().padLeft(2, '0')}d:${hours.toString().padLeft(2, '0')}h:${minutes.toString().padLeft(2, '0')}m:${seconds.toString().padLeft(2, '0')}s';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Contests'),
        backgroundColor: Colors.teal.shade600,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          image: const DecorationImage(
            image: AssetImage('lib/images/img.png'), // Add a subtle pattern
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white70,
              BlendMode.lighten,
            ),
          ),
        ),
        child: FutureBuilder<List<Contest>>(
          future: _futureContests,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            } else if (snapshot.hasData) {
              var contests = snapshot.data!;
              if (contests.isEmpty) {
                return const Center(
                  child: Text(
                    'No upcoming contests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                );
              }

              // Sort contests by start time
              contests.sort(
                      (a, b) => a.startTimeSeconds.compareTo(b.startTimeSeconds));

              return RefreshIndicator(
                onRefresh: _refreshContests,
                child: ListView.builder(
                  itemCount: contests.length,
                  itemBuilder: (context, index) {
                    final contest = contests[index];
                    final startDate = DateTime.fromMillisecondsSinceEpoch(
                      contest.startTimeSeconds * 1000,
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      elevation: 4,
                      shadowColor: Colors.teal.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contest.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Starts: ${startDate.toLocal()}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Duration: ${Duration(seconds: contest.durationSeconds).inHours} hours',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Countdown: ${_formatCountdown(contest.startTimeSeconds)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final url =
                                      'https://codeforces.com/contest/${contest.id}';
                                  try {
                                    await _launchUrl(url);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                          Text('Could not open URL: $e')),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.open_in_new,
                                  color: Colors.white,
                                ),
                                label: const Text('Open'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return const Center(
                child: Text(
                  'No contests available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}