import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int startTimeSeconds;

  const CountdownTimer({super.key, required this.startTimeSeconds});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late String _formattedTime;

  @override
  void initState() {
    super.initState();
    _formattedTime = _formatCountdown();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _formattedTime = _formatCountdown();
      });
    });
  }

  String _formatCountdown() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remainingSeconds = widget.startTimeSeconds - now;

    if (remainingSeconds <= 0) return 'Starts soon!';

    final days = remainingSeconds ~/ (24 * 3600);
    final hours = (remainingSeconds % (24 * 3600)) ~/ 3600;
    final minutes = (remainingSeconds % 3600) ~/ 60;
    final seconds = remainingSeconds % 60;

    return '${days.toString().padLeft(2, '0')}d:${hours.toString().padLeft(2, '0')}h:'
        '${minutes.toString().padLeft(2, '0')}m:${seconds.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Countdown: $_formattedTime',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.redAccent,
      ),
    );
  }
}
