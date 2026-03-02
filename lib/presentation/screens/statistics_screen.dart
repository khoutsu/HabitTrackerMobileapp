import 'package:flutter/material.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';

import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/repositories/habit_repository.dart';
import 'package:loop_habit_tracker/data/repositories/repetition_repository.dart';
import 'package:loop_habit_tracker/domain/usecases/calculate_habit_score.dart';
import 'package:loop_habit_tracker/domain/usecases/calculate_streak.dart';
import 'package:provider/provider.dart';
import 'package:loop_habit_tracker/presentation/providers/habit_update_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final HabitRepository _habitRepository = HabitRepository();
  final RepetitionRepository _repetitionRepository = RepetitionRepository();
  final CalculateHabitScore _calculateHabitScore = CalculateHabitScore();
  final CalculateStreak _calculateStreak = CalculateStreak();

  bool _isLoading = true;
  int _totalHabits = 0;
  int _totalCompletions = 0;
  List<Map<String, dynamic>> _habitStats = [];
  Map<DateTime, int> _heatmapData = {};
  String _selectedSortOption = 'Score';

  int _lastUpdateCount = -1;

  @override
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for updates
    final updateCount = context.watch<HabitUpdateProvider>().updateCount;
    if (updateCount != _lastUpdateCount) {
      _lastUpdateCount = updateCount;
      _loadStatistics();
    }
  }

  Future<void> _loadStatistics() async {
    if (_habitStats.isEmpty && _totalHabits == 0) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
    }

    final habits = await _habitRepository.getHabits();
    // Use local variables to avoid race conditions
    int tempTotalHabits = habits.length;
    int tempTotalCompletions = 0;
    List<Map<String, dynamic>> tempStats = [];
    Map<DateTime, int> tempHeatmapData = {};

    final now = DateTime.now();

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

      // Calculate completions
      for (var val in dailyValues.values) {
        // Count any day with positive progress as a completion
        if (val > 0) {
          tempTotalCompletions++;
        }
      }
      final score = _calculateHabitScore(habit, repetitions, now);

      // Calculate streak
      final streakData = _calculateStreak(habit, repetitions, [], now);
      final currentStreak = streakData['currentStreak'] ?? 0;

      tempStats.add({'habit': habit, 'score': score, 'streak': currentStreak});

      // Calculate heatmap data
      // For each repetition, add to heatmap count for that day

      for (var date in dailyValues.keys) {
        if ((dailyValues[date] ?? 0) > 0) {
          tempHeatmapData[date] = (tempHeatmapData[date] ?? 0) + 1;
        }
      }
    }

    if (!mounted) return;

    setState(() {
      _totalHabits = tempTotalHabits;
      _totalCompletions = tempTotalCompletions;
      _habitStats = tempStats;
      _heatmapData = tempHeatmapData;
      _sortHabits();
      _isLoading = false;
    });
  }

  void _sortHabits() {
    if (_selectedSortOption == 'Score') {
      _habitStats.sort(
        (a, b) => (b['score'] as double).compareTo(a['score'] as double),
      );
    } else {
      _habitStats.sort(
        (a, b) => (b['streak'] as int).compareTo(a['streak'] as int),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context)!.statisticsOverview,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    AppLocalizations.of(context)!.statsExplanationTitle,
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.statsExplanationBody,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(AppLocalizations.of(context)!.close),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.overallSummary,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            AppLocalizations.of(context)!.totalHabits,
                            _totalHabits.toString(),
                            Icons.list_alt,
                            Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            AppLocalizations.of(context)!.totalCompletions,
                            _totalCompletions.toString(),
                            Icons.check_circle_outline,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      AppLocalizations.of(context)!.heatmap,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHeatmap(context),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.habitLeaderboard,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSortOption,
                              icon: const Icon(Icons.sort),
                              style: Theme.of(context).textTheme.bodyMedium,
                              borderRadius: BorderRadius.circular(12),
                              items: [
                                DropdownMenuItem(
                                  value: 'Score',
                                  child: Text(
                                    AppLocalizations.of(context)!.score,
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'Streak',
                                  child: Text(
                                    AppLocalizations.of(context)!.streak,
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedSortOption = value;
                                    _sortHabits();
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_habitStats.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.sentiment_dissatisfied,
                                size: 48,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.noHabitsToRank,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _habitStats.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final habitData = _habitStats[index];
                          final Habit habit = habitData['habit'];
                          final double score = habitData['score'];
                          final int streak = habitData['streak'];

                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: index < 3
                                      ? habit.color.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '#${index + 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: index < 3
                                        ? habit.color
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              title: Text(
                                habit.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: habit.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _selectedSortOption == 'Score'
                                      ? '${score.toStringAsFixed(1)}%'
                                      : '$streak ${AppLocalizations.of(context)!.days}',
                                  style: TextStyle(
                                    color: habit.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmap(BuildContext context) {
    // Show last 14 weeks (approx 3 months)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Align end date to satisfy the grid.
    // Usually heatmaps end on today or the end of current week.
    // Let's end on today.

    // We need 14 columns.
    // Grid flows: Column 0 (oldest) -> Column 13 (newest).
    // Each column has 7 rows (Mon -> Sun).

    // Calculate the start date of the whole grid.
    // The last cell (bottom-right or top-right depending on layout) should be today roughly.
    // If we want the last column to include today.
    // Let's say column 13 is the current week.
    // Today is some day in that week.

    // Easier way:
    // Generate widgets for 12 columns to fit better/scroll less

    // Visual settings
    final boxSize = 18.0;
    final spacing = 4.0;
    final bool isThai = Localizations.localeOf(context).languageCode == 'th';
    // Fix: Align labels correctly. Row 0 is Monday.
    final dayLabels = isThai
        ? ['จ', '', 'พ', '', 'ศ', '', '']
        : ['Mon', '', 'Wed', '', 'Fri', '', ''];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Labels
              Column(
                children: List.generate(7, (index) {
                  return Container(
                    height: boxSize,
                    margin: EdgeInsets.only(bottom: spacing),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      dayLabels[index],
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              // Heatmap Grid
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true, // Start from right (newest)
                  child: Row(
                    children: List.generate(12, (colIndex) {
                      // colIndex 0 = Newest week
                      // If reverse is true, the first child is on the right.
                      // So List[0] should be the NEWEST week (Current week).

                      // Calculate start of this week.
                      // If today is Wednesday, this week started on Monday (or Sunday).
                      // Let's map 1=Mon, 7=Sun.
                      int currentWeekday = now.weekday; // 1..7 (Mon..Sun)

                      // Start of current week (Monday)
                      DateTime currentWeekStart = today.subtract(
                        Duration(days: currentWeekday - 1),
                      );

                      // Week for this column:
                      DateTime weekStart = currentWeekStart.subtract(
                        Duration(days: colIndex * 7),
                      );

                      return Padding(
                        padding: EdgeInsets.only(left: spacing),
                        child: Column(
                          children: List.generate(7, (rowIndex) {
                            // rowIndex 0 = Mon, 6 = Sun
                            DateTime date = weekStart.add(
                              Duration(days: rowIndex),
                            );
                            // Show future days as empty cells to maintain grid shape

                            int count = _heatmapData[date] ?? 0;

                            // Color logic
                            // 0 -> empty color
                            // 1+ -> Shades of green (or primary color)
                            Color boxColor;
                            if (count == 0) {
                              boxColor = Theme.of(context).colorScheme.onSurface
                                  .withOpacity(0.05); // Lighter empty state
                            } else {
                              // Opacity/Intensity based on count
                              // Assuming max 5 habits/day is "a lot" for visual scaling
                              double intensity = (count / 5).clamp(0.2, 1.0);
                              boxColor = Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(intensity);
                            }

                            return Tooltip(
                              triggerMode: TooltipTriggerMode.tap,
                              message: '${date.day}/${date.month}: $count',
                              child: Container(
                                width: boxSize,
                                height: boxSize,
                                margin: EdgeInsets.only(bottom: spacing),
                                decoration: BoxDecoration(
                                  color: boxColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppLocalizations.of(context)!.statsDays} (${AppLocalizations.of(context)!.heatmapTimeRange})',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.heatmapLess,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.heatmapMore,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
