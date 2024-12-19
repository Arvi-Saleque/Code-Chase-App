import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../components/summerycard.dart';
import '../components/fetchdata.dart';

class ContestPerformancePage extends StatefulWidget {
  const ContestPerformancePage({super.key});

  @override
  _ContestPerformancePageState createState() => _ContestPerformancePageState();
}

class _ContestPerformancePageState extends State<ContestPerformancePage> {
  final TextEditingController _handleController = TextEditingController();
  final TextEditingController _limitController = TextEditingController(text: '10');
  bool _isLoadingStats = false;
  bool _isLoadingContests = false;

  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _contests = [];
  String _error = '';

  Future<void> _fetchStats() async {
    final handle = _handleController.text.trim();

    if (handle.isEmpty) {
      setState(() {
        _error = 'Handle cannot be empty!';
        _stats = {};
        _contests = [];
      });
      return;
    }

    setState(() {
      _isLoadingStats = true;
      _stats = {};
      _error = '';
    });

    final fetchData = FetchData();
    final response = await fetchData.fetchUserData(handle);

    setState(() {
      _isLoadingStats = false;
      if (response['success']) {
        _stats = response['data'];
      } else {
        _error = response['error'];
      }
    });
  }

  Future<void> _fetchContests() async {
    final handle = _handleController.text.trim();
    final limitText = _limitController.text.trim();
    final int limit = int.tryParse(limitText) ?? 10;

    if (limit <= 0) {
      setState(() {
        _error = 'Number of contests must be greater than 0!';
        _contests = [];
      });
      return;
    }

    setState(() {
      _isLoadingContests = true;
      _contests = [];
      _error = '';
    });

    final fetchData = FetchData();
    final response = await fetchData.fetchContests(handle, limit);

    setState(() {
      _isLoadingContests = false;
      if (response['success']) {
        _contests = List<Map<String, dynamic>>.from(response['data']);
      } else {
        _error = response['error'];
      }
    });
  }

  Widget _buildGraph() {
    if (_contests.isEmpty) {
      return const Center(
        child: Text('No contest data available to display the graph.'),
      );
    }

    // Extract the data for the graph
    final List<FlSpot> spots = _contests
        .asMap()
        .entries
        .map((entry) {
      final index = entry.key.toDouble(); // x-coordinate
      final ratingChange = double.parse(entry.value['change']); // y-coordinate // y-coordinate
      return FlSpot(index, ratingChange);
    }).toList();

    final double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contest Performance Graph',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                      ),
                  ),
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                          // Format X-axis values
                          return Text(
                            'C${value.toInt() + 1}', // Contest index as "C1", "C2", ...
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 2,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                minY: minY - 10, // Add some padding below
                maxY: maxY + 10, // Add some padding above
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contest Performance'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Summary of All Contests',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _handleController,
                      decoration: InputDecoration(
                        labelText: 'Enter Codeforces Handle',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _fetchStats(),
                    child: const Text('Fetch Data'),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total Contests',
                    value: '${_stats['totalContests'] ?? 0}',
                    icon: Icons.event,
                    color: Colors.blue,
                    height: 170,
                    valueFontSize: 15,
                    titleFontSize: 12,
                  ),
                ),
                Expanded(
                  child: SummaryCard(
                    title: 'Total Problems',
                    value: '${_stats['totalProblemsSolved'] ?? 0}',
                    icon: Icons.account_balance_wallet_outlined,
                    color: Colors.blue,
                    height: 170,
                    valueFontSize: 15,
                    titleFontSize: 12,
                  ),
                ),
                Expanded(
                  child: SummaryCard(
                    title: 'Avg Problems Solved/Day:',
                    value: _stats['avgSolvedPerDay'] != null
                        ? _stats['avgSolvedPerDay'].toStringAsFixed(2)
                        : '0',
                    icon: Icons.account_tree,
                    color: Colors.blue,
                    height: 170,
                    valueFontSize: 15,
                    titleFontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _limitController,
                      decoration: InputDecoration(
                        labelText: 'No of Contests',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.list),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoadingContests ? null : _fetchContests,
                    child: const Text('Fetch Contests'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            if (_isLoadingContests)
              const Center(child: CircularProgressIndicator())
            else if (_contests.isNotEmpty)
              _buildGraph(),
              ListView.builder(
                shrinkWrap: true, // Ensures the list takes only the needed space
                physics: const NeverScrollableScrollPhysics(), // Delegate scrolling to parent
                itemCount: _contests.length,
                itemBuilder: (context, index) {
                  final contest = _contests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(contest['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rank: ${contest['rank']}'),
                          Text('Old Rating: ${contest['oldRating']}'),
                          Text('New Rating: ${contest['newRating']}'),
                          Text(
                            'Rating Change: ${contest['change']}',
                            style: TextStyle(
                              color: contest['change'].startsWith('+')
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
