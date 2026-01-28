class Reminder {
  final int? id;
  final int habitId;
  final String time;
  final String? daysOfWeek;
  final bool enabled;

  Reminder({
    this.id,
    required this.habitId,
    required this.time,
    this.daysOfWeek,
    this.enabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'time': time,
      'days_of_week': daysOfWeek,
      'enabled': enabled ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      habitId: map['habit_id'],
      time: map['time'],
      daysOfWeek: map['days_of_week'],
      enabled: map['enabled'] == 1,
    );
  }
}
