import 'dart:async';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart'; // Added
import 'package:loop_habit_tracker/data/models/skip_model.dart';
import 'package:loop_habit_tracker/data/repositories/habit_repository.dart';
import 'package:loop_habit_tracker/data/repositories/repetition_repository.dart'; // Added
import 'package:loop_habit_tracker/data/repositories/skip_repository.dart';
import 'package:loop_habit_tracker/domain/usecases/calculate_streak.dart'; // Added
// Added
import 'package:loop_habit_tracker/domain/usecases/calculate_success_rate.dart'; // Moved to top
import 'package:loop_habit_tracker/presentation/screens/habit_form_screen.dart';
import 'package:loop_habit_tracker/presentation/widgets/calendar_heatmap.dart'; // Already there, but included for context
import 'package:loop_habit_tracker/presentation/widgets/frequency_chart.dart'; // Already there, but included for context
import 'package:loop_habit_tracker/presentation/widgets/strength_chart.dart'; // Already there, but included for context
import 'package:loop_habit_tracker/presentation/widgets/success_rate_pie_chart.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart'; // Added

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habit _currentHabit;
  final HabitRepository _habitRepository = HabitRepository();
  final RepetitionRepository _repetitionRepository = RepetitionRepository();
  final SkipRepository _skipRepository = SkipRepository();
  final CalculateStreak _calculateStreak = CalculateStreak();

  final CalculateSuccessRate _calculateSuccessRate = CalculateSuccessRate();

  List<Repetition> _repetitions = [];
  List<Skip> _skips = [];
  Map<String, int> _streaks = {'currentStreak': 0, 'longestStreak': 0};

  int _totalCompletions = 0;
  double _successRate = 0.0;

  // Timer state
  Timer? _timer;
  int _timerSeconds = 0;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _currentHabit = widget.habit;
    _initializeTimerState();
    _loadAllHabitData(); // Initial load
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeTimerState() {
    if (_currentHabit.habitType == HabitType.timed) {
      // numericUnit stores the total minutes for timed habits
      final totalMinutes = int.tryParse(_currentHabit.numericUnit ?? '0') ?? 0;
      _timerSeconds = totalMinutes * 60;
    }
  }

  Future<void> _loadAllHabitData() async {
    await _loadRepetitions();
    await _loadSkips();
    _calculateStatistics();
    if (mounted) {
      setState(() {}); // Update UI after loading and calculating
    }
  }

  Future<void> _loadRepetitions() async {
    final allRepetitions = await _repetitionRepository.getRepetitionsForHabit(
      _currentHabit.id!,
    );
    _repetitions = allRepetitions;
  }

  Future<void> _loadSkips() async {
    final allSkips = await _skipRepository.getSkipsForHabit(_currentHabit.id!);
    _skips = allSkips;
  }

  void _calculateStatistics() {
    _streaks = _calculateStreak(
      _currentHabit,
      _repetitions,
      _skips,
      DateTime.now(),
    );

    // Calculate completions based on whether the goal was met for each day
    int completionsCount = 0;
    final Map<DateTime, double> dailyValues = {};
    for (var rep in _repetitions) {
      final date = DateTime(
        rep.timestamp.year,
        rep.timestamp.month,
        rep.timestamp.day,
      );
      dailyValues[date] = (dailyValues[date] ?? 0.0) + (rep.value ?? 0.0);
    }

    // Count days meeting goal
    for (var val in dailyValues.values) {
      if (_currentHabit.goalType == GoalType.targetCount &&
          _currentHabit.goalValue != null) {
        if (val >= _currentHabit.goalValue!) {
          completionsCount++;
        }
      } else {
        if (val > 0) completionsCount++;
      }
    }
    _totalCompletions = completionsCount;

    // Calculate Success Rate based on Goal Accuracy on Scheduled Days
    // We do this locally to ensure we correctly capture "today" even if created just now
    DateTime startDate = _currentHabit.createdAt;
    DateTime endDate = DateTime.now();
    DateTime iterator = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    DateTime endDay = DateTime(endDate.year, endDate.month, endDate.day);

    double totalProgressRatio = 0.0;
    int scheduledDaysCount = 0;

    while (!iterator.isAfter(endDay)) {
      if (_currentHabit.frequency.shouldDoOnDay(
        iterator,
        startDate, // Pass original startDate for frequency alignment
      )) {
        scheduledDaysCount++;

        double dailyVal = dailyValues[iterator] ?? 0.0;
        double ratio = 0.0;
        if (_currentHabit.goalType == GoalType.targetCount &&
            _currentHabit.goalValue != null &&
            _currentHabit.goalValue! > 0) {
          ratio = (dailyVal / _currentHabit.goalValue!).clamp(0.0, 1.0);
        } else {
          ratio = dailyVal > 0 ? 1.0 : 0.0;
        }
        totalProgressRatio += ratio;
      }
      iterator = iterator.add(const Duration(days: 1));
    }

    if (scheduledDaysCount > 0) {
      _successRate = (totalProgressRatio / scheduledDaysCount) * 100;
    } else {
      _successRate = 0.0;
    }
  }

  // --- Timer Methods ---
  void _startTimer() {
    if (_timerSeconds <= 0) return;

    setState(() {
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isTimerRunning = false;
        });
        _completeTimedHabit();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _initializeTimerState();
    });
  }

  Future<void> _completeTimedHabit() async {
    // This method is called when the timer reaches 0
    // It creates a repetition for today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final totalDuration = (int.tryParse(_currentHabit.numericUnit ?? '0') ?? 0);

    // Check if the habit has already been completed today
    final hasCompletedToday = _repetitions.any(
      (rep) => isSameDay(rep.timestamp, today),
    );

    if (!hasCompletedToday) {
      final repetition = Repetition(
        habitId: _currentHabit.id!,
        timestamp: now,
        value: totalDuration.toDouble(), // Store the completed duration
      );
      await _repetitionRepository.createRepetition(repetition);
      await _loadAllHabitData(); // Reload data to reflect the new completion
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("'${_currentHabit.name}' completed for today!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Widget _buildStatisticItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color accentColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accentColor, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _editHabit() async {
    _timer?.cancel(); // Stop timer before editing
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => HabitFormScreen(habit: _currentHabit),
      ),
    );
    if (updated == true) {
      // Reload habit details after edit
      final reloadedHabit = (await _habitRepository.getHabits()).firstWhere(
        (h) => h.id == _currentHabit.id,
      );
      setState(() {
        _currentHabit = reloadedHabit;
        _initializeTimerState(); // Re-initialize timer with new duration if changed
      });
      await _loadAllHabitData(); // Reload all data for updated habit
    } else {
      // If editing was cancelled, resume timer if it was running
      if (_isTimerRunning) {
        _startTimer();
      }
    }
  }

  Future<void> _deleteHabit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteHabit),
        content: Text(
          AppLocalizations.of(
            context,
          )!.deleteHabitConfirmation(_currentHabit.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _habitRepository.deleteHabit(_currentHabit.id!);
      if (mounted) {
        Navigator.of(context).pop(true); // Pop with true to indicate deletion
      }
    }
  }

  Future<void> _onDateLongPress(DateTime date) async {
    await _handleDateAction(date);
  }

  Future<void> _handleDateAction(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    // Calculate current total for the day
    double currentTotal = 0.0;
    for (var rep in _repetitions) {
      if (isSameDay(rep.timestamp, dateOnly)) {
        currentTotal += (rep.value ?? 0.0);
      }
    }

    bool isGoalMet = false;
    if (_currentHabit.goalType == GoalType.targetCount &&
        _currentHabit.goalValue != null &&
        _currentHabit.goalValue! > 0) {
      isGoalMet = currentTotal >= _currentHabit.goalValue!;
    } else {
      // For non-numeric goals (or off), any repetition means done?
      // Assuming 'Regular' yesNo means 1 completion is enough if no numeric goal.
      // But if user sets numeric goal on YesNo, we respect it.
      isGoalMet = _repetitions.any((rep) => isSameDay(rep.timestamp, dateOnly));
    }

    final isSkipped = _skips.any((skip) => isSameDay(skip.timestamp, dateOnly));
    final l10n = AppLocalizations.of(context)!;

    if (isGoalMet) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cannotSkipCompleted)));
      return;
    }

    if (isSkipped) {
      // If skipped, confirm un-skip
      final confirmUnskip = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.unskipDay),
          content: Text(l10n.confirmUnskip),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.unskip),
            ),
          ],
        ),
      );

      if (confirmUnskip == true) {
        await _skipRepository.deleteSkip(_currentHabit.id!, dateOnly);
        await _loadAllHabitData();
      }
      return;
    }

    // Neither completed (fully) nor skipped: Offer Choice
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.chooseAction,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: Text(l10n.markAsDone),
                onTap: () async {
                  Navigator.of(context).pop(); // Close sheet
                  // Logic to complete remaining
                  double valueToInsert = 1.0;

                  if (_currentHabit.habitType == HabitType.numeric ||
                      _currentHabit.habitType == HabitType.yesNo) {
                    if (_currentHabit.goalType == GoalType.targetCount &&
                        _currentHabit.goalValue != null &&
                        _currentHabit.goalValue! > 0) {
                      // Calculate remaining needed
                      final remaining = _currentHabit.goalValue! - currentTotal;
                      valueToInsert = remaining > 0
                          ? remaining.toDouble()
                          : 0.0;
                    }
                  } else if (_currentHabit.habitType == HabitType.timed &&
                      _currentHabit.numericUnit != null) {
                    // For timed, usually we add the full duration?
                    // Or remainder? Timed usually doesn't accumulate multiple entries for same goal in this simple logic unless we track seconds.
                    // Let's assume we fill the target.
                    valueToInsert =
                        double.tryParse(_currentHabit.numericUnit!) ?? 0.0;
                  }

                  if (valueToInsert > 0) {
                    await _repetitionRepository.createRepetition(
                      Repetition(
                        habitId: _currentHabit.id!,
                        timestamp: DateTime.now().copyWith(
                          year: dateOnly.year,
                          month: dateOnly.month,
                          day: dateOnly.day,
                        ),
                        value: valueToInsert,
                      ),
                    );
                    await _loadAllHabitData();
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.skip_next, color: Colors.orange),
                title: Text(l10n.skipDay),
                subtitle: Text(l10n.confirmSkip),
                onTap: () async {
                  Navigator.of(context).pop(); // Close sheet
                  await _skipRepository.createSkip(
                    Skip(habitId: _currentHabit.id!, timestamp: dateOnly),
                  );
                  await _loadAllHabitData();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(l10n.cancel),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerSection() {
    if (_currentHabit.habitType != HabitType.timed) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0, // Minimalist: no elevation
      color: Theme.of(context).colorScheme.surface, // Match other cards
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _formatDuration(_timerSeconds),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: _currentHabit.color,
                fontSize: 60,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_isTimerRunning)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    onPressed: _startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    onPressed: _pauseTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text('Reset'),
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentHabit.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editHabit),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteHabit),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadAllHabitData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // --- Basic Habit Info Section ---
              if (_currentHabit.description != null &&
                  _currentHabit.description!.isNotEmpty)
                Text(
                  _currentHabit.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _currentHabit.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.color,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Text(
                AppLocalizations.of(context)!.createdOn(
                  _currentHabit.createdAt.toLocal().toIso8601String().split(
                    'T',
                  )[0],
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              // --- Statistics Section ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_rounded,
                          color: _currentHabit.color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.statistics,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildStatisticItem(
                            context,
                            Icons.local_fire_department_rounded,
                            '${_streaks['currentStreak']}',
                            AppLocalizations.of(context)!.currentStreak,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatisticItem(
                            context,
                            Icons.emoji_events_rounded,
                            '${_streaks['longestStreak']}',
                            AppLocalizations.of(context)!.maxStreak,
                            Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatisticItem(
                            context,
                            Icons.check_circle_rounded,
                            '$_totalCompletions',
                            AppLocalizations.of(context)!.totalCompletions,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                AppLocalizations.of(context)!.successRate,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: SuccessRatePieChart(
                  successRate: _successRate,
                  habitColor: _currentHabit.color,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                AppLocalizations.of(context)!.activityLog,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              // Calendar Heatmap
              CalendarHeatmap(
                habitColor: _currentHabit.color,
                repetitions: _repetitions,
                skips: _skips,
                onDateLongPress: _onDateLongPress,
              ),
              const SizedBox(height: 32),

              // Frequency Chart
              SizedBox(
                height: 250, // Increased height for labels
                child: FrequencyChart(
                  habitColor: _currentHabit.color,
                  repetitions: _repetitions,
                ),
              ),
              const SizedBox(height: 32),

              // Strength Chart
              SizedBox(
                height: 250, // Increased height
                child: StrengthChart(
                  habit: _currentHabit,
                  repetitions: _repetitions,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
