import 'package:flutter/material.dart';

enum FrequencyType { daily, weekly, monthly, custom }

// Helper to convert list of weekdays to a string and vice versa
class WeekdayUtility {
  static const List<String> weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static String toDatabaseString(List<int> selectedDays) {
    return selectedDays.join(',');
  }

  static List<int> fromDatabaseString(String dbString) {
    if (dbString.isEmpty) return [];
    return dbString.split(',').map(int.parse).toList();
  }
}

class Frequency {
  final FrequencyType type;
  // For daily: 'everyday', 'weekdays', 'weekends'
  // For weekly: comma-separated list of 1-7 (Mon-Sun), e.g., '1,3,5' for Mon, Wed, Fri
  // For monthly: 'first_monday', 'last_day_of_month', 'day_of_month:X'
  // For custom: 'every_x_days:X'
  final String? value;

  Frequency({required this.type, this.value});

  // Convert to database string
  String toDatabaseString() {
    return '${type.name}${value != null ? ':$value' : ''}';
  }

  // Create from database string
  factory Frequency.fromDatabaseString(String dbString) {
    final parts = dbString.split(':');
    final type = FrequencyType.values.firstWhere(
      (e) => e.name == parts[0],
      orElse: () => FrequencyType.daily, // Default to daily if not found
    );
    final value = parts.length > 1 ? parts.sublist(1).join(':') : null;
    return Frequency(type: type, value: value);
  }

  // Check if the habit should be done on a specific day
  bool shouldDoOnDay(DateTime date, DateTime startDate) {
    // Normalize dates to remove time components for accurate day comparison
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(startDate.year, startDate.month, startDate.day);

    switch (type) {
      case FrequencyType.daily:
        if (value == 'weekdays') {
          return d.weekday >= DateTime.monday && d.weekday <= DateTime.friday;
        } else if (value == 'weekends') {
          return d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;
        }
        return true; // Everyday
      case FrequencyType.weekly:
        if (value != null) {
          final selectedDays = WeekdayUtility.fromDatabaseString(value!);
          return selectedDays.contains(d.weekday);
        }
        return false; // Should not happen without value
      case FrequencyType.monthly:
        if (value != null) {
          int? dayOfMonth;
          List<int>? selectedMonths;

          if (value!.contains(':')) {
            final parts = value!.split(':');
            dayOfMonth = int.tryParse(parts[0]);
            if (parts.length > 1 && parts[1].isNotEmpty) {
              selectedMonths = parts[1]
                  .split(',')
                  .map((e) => int.tryParse(e) ?? 0)
                  .toList();
            }
          } else {
            dayOfMonth = int.tryParse(value!);
          }

          if (dayOfMonth == null) {
            return false; // Malformed monthly frequency, not scheduled
          }

          // Check Month match first
          if (selectedMonths != null &&
              selectedMonths.isNotEmpty &&
              !selectedMonths.contains(d.month)) {
            return false;
          }

          // Handle months shorter than the selected day (e.g. Feb)
          final lastDayThisMonth = DateTime(d.year, d.month + 1, 0).day;
          if (dayOfMonth > lastDayThisMonth) {
            return d.day == lastDayThisMonth;
          }
          return d.day == dayOfMonth;
        }
        return false; // If value is null for monthly, it's not scheduled
      case FrequencyType.custom:
        if (value != null && value!.startsWith('every_x_days:')) {
          final parts = value!.split(':');
          if (parts.length > 1) {
            final interval = int.tryParse(parts[1]);
            if (interval != null && interval > 0) {
              final diff = d.difference(s).inDays;
              return (diff % interval) == 0;
            }
          }
        }
        return true;
      default:
        return true;
    }
  }

  // Get the next due date for the habit (simplified for now)
  DateTime? getNextDueDate(DateTime lastCompletionDate) {
    // This method would be complex depending on frequency type and current date
    // For now, it's a placeholder.
    return lastCompletionDate.add(
      const Duration(days: 1),
    ); // Simple daily increment
  }
}
