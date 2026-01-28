import 'package:flutter/material.dart';
import 'package:loop_habit_tracker/data/models/skip_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';
import 'package:loop_habit_tracker/core/themes/app_colors.dart';

class CalendarHeatmap extends StatefulWidget {
  final Color habitColor;
  final List<Repetition> repetitions;
  final List<Skip> skips;
  final Function(DateTime)? onDateLongPress;

  const CalendarHeatmap({
    super.key,
    required this.habitColor,
    required this.repetitions,
    required this.skips,
    this.onDateLongPress,
  });

  @override
  State<CalendarHeatmap> createState() => _CalendarHeatmapState();
}

class _CalendarHeatmapState extends State<CalendarHeatmap> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, int> _events = {};
  Set<DateTime> _skippedDays = {};

  @override
  void initState() {
    super.initState();
    _processDates();
  }

  @override
  void didUpdateWidget(covariant CalendarHeatmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repetitions != widget.repetitions ||
        oldWidget.skips != widget.skips) {
      _processDates();
    }
  }

  void _processDates() {
    _events = {};
    for (var rep in widget.repetitions) {
      final date = DateTime(
        rep.timestamp.year,
        rep.timestamp.month,
        rep.timestamp.day,
      );
      _events[date] = (_events[date] ?? 0) + 1;
    }

    _skippedDays = {};
    for (var skip in widget.skips) {
      final date = DateTime(
        skip.timestamp.year,
        skip.timestamp.month,
        skip.timestamp.day,
      );
      _skippedDays.add(date);
    }
    setState(() {});
  }

  Color _getHeatmapColor(DateTime day) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    if (_skippedDays.contains(dateOnly)) {
      return AppColors.divider;
    }
    if (_events.containsKey(dateOnly)) {
      // Standard completion = solid color
      return widget.habitColor;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          locale: Localizations.localeOf(context).toString(),
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(_focusedDay.year - 5, 1, 1),
          lastDay: DateTime.utc(_focusedDay.year + 5, 12, 31),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            // Adjust styles for grid consistency if needed
            defaultTextStyle: Theme.of(context).textTheme.bodySmall!,
            weekendTextStyle: Theme.of(context).textTheme.bodySmall!,
            todayTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: widget.habitColor,
              fontWeight: FontWeight.bold,
            ),
            todayDecoration: BoxDecoration(
              // Minimal today indicator if not completed
              border: Border.all(color: widget.habitColor),
              borderRadius: BorderRadius.circular(8),
              shape: BoxShape.rectangle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final isCompleted = _events.containsKey(
                DateTime(day.year, day.month, day.day),
              );
              final isSkipped = _skippedDays.contains(
                DateTime(day.year, day.month, day.day),
              );
              final fillColor = _getHeatmapColor(day);
              final textColor = isCompleted
                  ? Colors.white
                  : Theme.of(context).textTheme.bodySmall!.color;

              return GestureDetector(
                onLongPress: () {
                  if (widget.onDateLongPress != null) {
                    widget.onDateLongPress!(day);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: fillColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: textColor,
                      fontWeight: isCompleted || isSkipped
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
            todayBuilder: (context, day, focusedDay) {
              // Ensure today uses the same logic but maybe with a highlight if not completed
              final isCompleted = _events.containsKey(
                DateTime(day.year, day.month, day.day),
              );
              final fillColor = _getHeatmapColor(day);
              final textColor = isCompleted ? Colors.white : widget.habitColor;

              return GestureDetector(
                onLongPress: () {
                  if (widget.onDateLongPress != null) {
                    widget.onDateLongPress!(day);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: fillColor,
                    shape: BoxShape.circle,
                    border: isCompleted
                        ? null
                        : Border.all(
                            color: widget.habitColor,
                            width: 1.5,
                          ), // Highlight today
                  ),
                  child: Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
