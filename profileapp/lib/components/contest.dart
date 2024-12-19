class Contest {
  final int id; // Unique contest identifier
  final String name;
  final int startTimeSeconds;
  final int durationSeconds;

  Contest({
    required this.id,
    required this.name,
    required this.startTimeSeconds,
    required this.durationSeconds,
  });

  factory Contest.fromJson(Map<String, dynamic> json) {
    return Contest(
      id: json['id'], // Assuming the API provides an 'id' field
      name: json['name'],
      startTimeSeconds: json['startTimeSeconds'],
      durationSeconds: json['durationSeconds'],
    );
  }
}
