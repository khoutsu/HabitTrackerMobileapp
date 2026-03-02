import 'package:flutter/material.dart';

class Reminder {
  final int? id;
  final int habitId;
  final TimeOfDay time;
  final List<int>? daysOfWeek; // 1-7 (Mon-Sun), null means every day
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
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'days_of_week': daysOfWeek?.join(','),
      'enabled': enabled ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['time'] as String).split(':');
    return Reminder(
      id: map['id'],
      habitId: map['habit_id'],
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      daysOfWeek:
          map['days_of_week'] != null &&
              (map['days_of_week'] as String).isNotEmpty
          ? (map['days_of_week'] as String)
                .split(',')
                .map((e) => int.parse(e))
                .toList()
          : [],
      enabled: map['enabled'] == 1,
    );
  }

  Reminder copyWith({
    int? id,
    int? habitId,
    TimeOfDay? time,
    List<int>? daysOfWeek,
    bool? enabled,
  }) {
    return Reminder(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      time: time ?? this.time,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      enabled: enabled ?? this.enabled,
    );
  }
}
