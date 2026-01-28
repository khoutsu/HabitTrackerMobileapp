class Repetition {
  final int? id;
  final int habitId;
  final DateTime timestamp;
  final double? value;

  Repetition({
    this.id,
    required this.habitId,
    required this.timestamp,
    this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'timestamp': timestamp.toIso8601String(),
      'value': value,
    };
  }

  factory Repetition.fromMap(Map<String, dynamic> map) {
    return Repetition(
      id: map['id'],
      habitId: map['habit_id'],
      timestamp: DateTime.parse(map['timestamp']),
      value: map['value'],
    );
  }
}
