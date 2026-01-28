class Skip {
  final int? id;
  final int habitId;
  final DateTime timestamp;

  Skip({
    this.id,
    required this.habitId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Skip.fromMap(Map<String, dynamic> map) {
    return Skip(
      id: map['id'],
      habitId: map['habitId'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
