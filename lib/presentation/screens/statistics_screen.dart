import 'package:flutter/material.dart';

import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';
import 'package:loop_habit_tracker/data/repositories/habit_repository.dart';
import 'package:loop_habit_tracker/data/repositories/repetition_repository.dart';
import 'package:loop_habit_tracker/domain/usecases/calculate_habit_score.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final HabitRepository _habitRepository = HabitRepository();
  final RepetitionRepository _repetitionRepository = RepetitionRepository();
  final CalculateHabitScore _calculateHabitScore = CalculateHabitScore();

  bool _isLoading = true;
  int _totalHabits = 0;
  int _totalCompletions = 0;
  List<Map<String, dynamic>> _habitScores = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    final habits = await _habitRepository.getHabits();
    _totalHabits = habits.length;
    _totalCompletions = 0;
    _habitScores = [];

    for (var habit in habits) {
      final repetitions = await _repetitionRepository.getRepetitionsForHabit(
        habit.id!,
      );
      // Calculate completions counting only days where goal is met
      final Map<DateTime, double> dailyValues = {};
      for (var rep in repetitions) {
        final date = DateTime(
          rep.timestamp.year,
          rep.timestamp.month,
          rep.timestamp.day,
        );
        dailyValues[date] = (dailyValues[date] ?? 0.0) + (rep.value ?? 0.0);
      }

      for (var val in dailyValues.values) {
        if (habit.goalType == GoalType.targetCount && habit.goalValue != null) {
          if (val >= habit.goalValue!) {
            _totalCompletions++;
          }
        } else {
          if (val > 0) _totalCompletions++;
        }
      }
      final score = _calculateHabitScore(habit, repetitions, DateTime.now());
      _habitScores.add({'habit': habit, 'score': score});
    }

    // Sort habits by score in descending order
    _habitScores.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics Overview')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text(
                    'Overall Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Total Habits', _totalHabits.toString()),
                      _buildStatCard(
                        'Total Completions',
                        _totalCompletions.toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Habit Leaderboard',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (_habitScores.isEmpty)
                    const Center(child: Text('No habits to rank.'))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _habitScores.length,
                      itemBuilder: (context, index) {
                        final habitData = _habitScores[index];
                        final Habit habit = habitData['habit'];
                        final double score = habitData['score'];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: habit.color,
                              child: Text(
                                '#${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(habit.name),
                            trailing: Text(
                              '${score.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: habit.color),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
