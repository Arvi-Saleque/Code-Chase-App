import 'package:flutter/material.dart';
import '../components/contest.dart';
import 'contest_card.dart';

class ContestList extends StatelessWidget {
  final List<Contest> contests;

  const ContestList({super.key, required this.contests});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: contests.length,
      itemBuilder: (context, index) {
        final contest = contests[index];
        return ContestCard(contest: contest);
      },
    );
  }
}
