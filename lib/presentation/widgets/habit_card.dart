import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart'; // Import for HapticFeedback
import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';
import 'package:loop_habit_tracker/data/repositories/repetition_repository.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';
import 'package:loop_habit_tracker/data/models/frequency_model.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final int streak;
  final List<Repetition> repetitionsToday;
  final VoidCallback onStateChanged;
  final Map<String, num>? goalProgress;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.streak,
    required this.repetitionsToday,
    required this.onStateChanged,
    this.goalProgress,
  });

  Future<void> _showNumericInputDialog(BuildContext context) async {
    final textController = TextEditingController();
    final repetitionRepository = RepetitionRepository();
    print(
      'HabitCard:_showNumericInputDialog: Attempting to show dialog for habit ID: ${habit.id}',
    );

    double? value;
    try {
      value = await showDialog<double>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.enterValueFor(habit.name)),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText:
                  AppLocalizations.of(context)!.valueLabel +
                  (habit.numericUnit != null ? ' (${habit.numericUnit})' : ''),
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.add),
              onPressed: () {
                final double? enteredValue = double.tryParse(
                  textController.text,
                );
                if (enteredValue != null) {
                  Navigator.of(context).pop(enteredValue);
                } else {
                  // Optionally show an error or just pop without value
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      );
      print(
        'HabitCard:_showNumericInputDialog: Dialog dismissed. Returned value: $value',
      );
    } catch (e) {
      print('HabitCard:_showNumericInputDialog: Error showing dialog: $e');
    }

    if (value != null) {
      print(
        'HabitCard:_showNumericInputDialog: Creating repetition for habit ID: ${habit.id} with value: $value',
      );
      await repetitionRepository.createRepetition(
        Repetition(habitId: habit.id!, timestamp: DateTime.now(), value: value),
      );
      print('HabitCard:_showNumericInputDialog: Repetition created.');
    } else {
      print(
        'HabitCard:_showNumericInputDialog: No valid value entered or dialog cancelled.',
      );
    }
  }

  Future<void> _handleCompletion(BuildContext context) async {
    final repetitionRepository = RepetitionRepository();
    final today = DateTime.now();

    // Check if goal is met
    bool isGoalMet = repetitionsToday.isNotEmpty;
    if (habit.goalType == GoalType.targetCount && habit.goalValue != null) {
      double total = repetitionsToday.fold(
        0.0,
        (sum, rep) => sum + (rep.value ?? 0.0),
      );
      isGoalMet = total >= habit.goalValue!;
    } else {
      // For non-numeric or boolean, presence implies completion
      // But for numeric without goal, we might treat any val as done?
      // Let's stick to: if numeric, existence is not enough if goal exists.
      // If goal doesn't exist, existence is enough.
      isGoalMet = repetitionsToday.isNotEmpty;
    }

    if (isGoalMet) {
      // If goal met, ask to un-complete (delete all for today)
      // Maybe confirmation dialog? For now keeping it snappy.
      await repetitionRepository.deleteRepetitionsOnDate(habit.id!, today);
    } else {
      // If not completed (or partial), add more
      switch (habit.habitType) {
        case HabitType.yesNo:
          print(
            'HabitCard: Handling completion for habit ID: ${habit.id} on date: $today',
          );
          await repetitionRepository.createRepetition(
            Repetition(habitId: habit.id!, timestamp: today, value: 1),
          );
          break;
        case HabitType.numeric:
          print(
            'HabitCard: Showing numeric input dialog for habit ID: ${habit.id}',
          );
          await _showNumericInputDialog(context);
          break;
        case HabitType.timed:
          await _showTimerDialog(context);
          break;
      }
    }
    onStateChanged();
  }

  Future<void> _showTimerDialog(BuildContext context) async {
    final repetitionRepository = RepetitionRepository();
    // Use a stateful builder to update the timer in the dialog
    double durationInMinutes = 0.0;

    final result = await showDialog<double>(
      context: context,
      barrierDismissible:
          false, // Prevent closing by tapping outside to ensure timer is handled
      builder: (context) {
        // Prepare initial duration from numericUnit (which now stores timer duration in minutes)
        int initialSeconds = 0;
        if (habit.habitType == HabitType.timed && habit.numericUnit != null) {
          final durationInMinutes = int.tryParse(habit.numericUnit!);
          if (durationInMinutes != null) {
            initialSeconds = durationInMinutes * 60;
          }
        }

        return _TimerDialog(
          habitName: habit.name,
          initialSeconds: initialSeconds,
        );
      },
    );

    if (result != null && result > 0) {
      await repetitionRepository.createRepetition(
        Repetition(
          habitId: habit.id!,
          timestamp: DateTime.now(),
          value: result,
        ), // Storing minutes
      );
      print('HabitCard: Timer repetition created: $result minutes');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isCompleted = repetitionsToday.isNotEmpty;
    if (habit.goalType == GoalType.targetCount) {
      if (goalProgress != null &&
          goalProgress!['goal'] != null &&
          goalProgress!['goal']! > 0) {
        isCompleted = goalProgress!['current']! >= goalProgress!['goal']!;
      } else if (habit.goalValue != null) {
        double total = repetitionsToday.fold(
          0.0,
          (sum, rep) => sum + (rep.value ?? 0.0),
        );
        isCompleted = total >= habit.goalValue!;
      }
    }
    final color = habit.color;

    // Determine the text to show for the value
    String valueText = '';
    if (isCompleted && habit.habitType != HabitType.yesNo) {
      final totalValue = repetitionsToday.fold<double>(
        0,
        (sum, rep) => sum + (rep.value ?? 0),
      );
      if (habit.habitType == HabitType.numeric) {
        valueText = totalValue.toStringAsFixed(1);
        if (habit.numericUnit != null && habit.numericUnit!.isNotEmpty) {
          valueText += ' ${habit.numericUnit}';
        }
      }
    }

    // Logic to calculate frequency string (restored)
    final l10n = AppLocalizations.of(context)!;
    final frequency = habit.frequency;
    String frequencyText = '';

    if (frequency.type == FrequencyType.daily) {
      if (frequency.value == 'weekdays') {
        frequencyText = l10n.weekdays;
      } else if (frequency.value == 'weekends') {
        frequencyText = l10n.weekends;
      } else {
        frequencyText = l10n.everyday;
      }
    } else if (frequency.type == FrequencyType.weekly &&
        frequency.value != null) {
      // Handling raw string manually since WeekdayUtility might not be easily importable or was failing
      // If the string is comma separated numbers "1,2,3"
      try {
        final parts = frequency.value!
            .split(',')
            .where((s) => s.isNotEmpty)
            .map(int.tryParse)
            .whereType<int>()
            .toList();
        if (parts.isNotEmpty) {
          final List<String> dayNames = [
            l10n.mon,
            l10n.tue,
            l10n.wed,
            l10n.thu,
            l10n.fri,
            l10n.sat,
            l10n.sun,
          ];
          parts.sort();
          frequencyText = parts.map((d) => dayNames[d - 1]).join(', ');
        }
      } catch (e) {
        frequencyText = l10n.custom;
      }
    } else if (frequency.type == FrequencyType.monthly) {
      frequencyText = l10n.monthly;
      if (frequency.value != null && frequency.value!.contains(':')) {
        final parts = frequency.value!.split(':');
        if (parts.length > 1 && parts[1].isNotEmpty) {
          final monthIndices =
              parts[1]
                  .split(',')
                  .map((e) => int.tryParse(e))
                  .where((e) => e != null)
                  .cast<int>()
                  .toList()
                ..sort();

          final List<String> monthNames = [
            l10n.jan,
            l10n.feb,
            l10n.mar,
            l10n.apr,
            l10n.may,
            l10n.jun,
            l10n.jul,
            l10n.aug,
            l10n.sep,
            l10n.oct,
            l10n.nov,
            l10n.dec,
          ];
          if (monthIndices.length != 12) {
            final monthString = monthIndices
                .map((i) => monthNames[i - 1])
                .join(', ');
            frequencyText += ' ($monthString)';
          }
        }
      } else if (frequency.value != null) {
        final isThai = l10n.localeName == 'th';
        frequencyText += isThai
            ? ' (วันที่ ${frequency.value})'
            : ' (Day ${frequency.value})';
      }
    } else if (frequency.type == FrequencyType.custom) {
      // ... (simplified custom logic)
      frequencyText = l10n.custom;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored Strip on the left
              Container(width: 6, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        habit.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Frequency Text (Sub-header)
                      if (frequencyText.isNotEmpty)
                        Text(
                          frequencyText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Stats Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (streak > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$streak',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.orange[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (valueText.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                valueText,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Goal Progress Bar
                      if (goalProgress != null) ...[
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Goal',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  '${goalProgress!['current']!.toStringAsFixed(0)} / ${goalProgress!['goal']!.toStringAsFixed(0)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value:
                                  (goalProgress!['current']! /
                                          goalProgress!['goal']!)
                                      .clamp(0.0, 1.0),
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Check Button Area
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _handleCompletion(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isCompleted ? color : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted
                            ? color
                            : theme.colorScheme.onSurfaceVariant.withOpacity(
                                0.3,
                              ),
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerDialog extends StatefulWidget {
  final String habitName;
  final int initialSeconds;

  const _TimerDialog({required this.habitName, this.initialSeconds = 0});

  @override
  State<_TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<_TimerDialog> {
  Timer? _timer;
  late int _seconds;
  late int _currentGoalSeconds;
  bool _isRunning = false;
  late bool _isCountdown;

  @override
  void initState() {
    super.initState();
    _currentGoalSeconds = widget.initialSeconds;
    _seconds = widget.initialSeconds;
    _isCountdown = widget.initialSeconds > 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_isCountdown) {
          if (_seconds > 0) {
            _seconds--;
          } else {
            _pauseTimer();
            // Optional: Haptic feedback or sound here
          }
        } else {
          _seconds++;
        }
      });
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _seconds = _currentGoalSeconds;
    });
  }

  Future<void> _editTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _seconds ~/ 3600,
        minute: (_seconds % 3600) ~/ 60,
      ),
      helpText: AppLocalizations.of(context)!.selectDuration,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _currentGoalSeconds = picked.hour * 3600 + picked.minute * 60;
        _seconds = _currentGoalSeconds;
        _isCountdown = _currentGoalSeconds > 0;
      });
    }
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.timerTitle(widget.habitName)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _isRunning ? null : _editTime,
            child: Text(
              _formatTime(_seconds),
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFeatures: [const FontFeature.tabularFigures()],
                color: _isCountdown && _seconds == 0
                    ? Colors.green
                    : (_isRunning ? null : theme.colorScheme.primary),
                decoration: _isRunning ? null : TextDecoration.underline,
                decorationStyle: TextDecorationStyle.dashed,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton.filledTonal(
                onPressed: _seconds == 0 && _isCountdown
                    ? null
                    : (_isRunning ? _pauseTimer : _startTimer),
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                iconSize: 32,
              ),
              IconButton.outlined(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer?.cancel();
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            _timer?.cancel();
            // Calculate elapsed
            double elapsedMinutes;
            if (_isCountdown) {
              int elapsedSeconds = widget.initialSeconds - _seconds;
              // If finished (0), strictly it's the full duration
              elapsedMinutes = elapsedSeconds / 60.0;
            } else {
              elapsedMinutes = _seconds / 60.0;
            }

            Navigator.of(context).pop(elapsedMinutes);
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }
}
