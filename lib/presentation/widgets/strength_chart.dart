import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';

import 'package:loop_habit_tracker/l10n/app_localizations.dart';

class StrengthChart extends StatelessWidget {
  final Habit habit;
  final List<Repetition> repetitions;

  const StrengthChart({
    super.key,
    required this.habit,
    required this.repetitions,
  });

  @override
  Widget build(BuildContext context) {
    // Generate data points for the last 30 days
    List<FlSpot> spots = [];
    final now = DateTime.now();

    // 1. Group ALL repetitions by normalized date
    final Map<DateTime, double> dailyValues = {};
    for (var rep in repetitions) {
      final date = DateTime(
        rep.timestamp.year,
        rep.timestamp.month,
        rep.timestamp.day,
      );
      dailyValues[date] = (dailyValues[date] ?? 0.0) + (rep.value ?? 0.0);
    }

    // 2. Calculate Rolling Strength (Success Rate over the last 30 days relative to each point)
    // We want to plot 30 points: from (Today-29) to (Today).
    // For each day D, the score is the success rate in the window [D-29, D] (or start date if closer).

    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime habitStartDate = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );

    for (int i = 0; i < 30; i++) {
      // The date we are plotting for (x-axis value)
      // x=0 is 29 days ago. x=29 is today.
      // So plotDate = today - (29 - i) days
      DateTime plotDate = today.subtract(Duration(days: 29 - i));

      // If plotDate is before habit creation, score is 0
      if (plotDate.isBefore(habitStartDate)) {
        spots.add(FlSpot(i.toDouble(), 0));
        continue;
      }

      // Calculate score window for plotDate
      // Window ends at plotDate.
      // Window starts at max(habitStartDate, plotDate - 29 days).
      DateTime windowStart = plotDate.subtract(const Duration(days: 29));
      if (windowStart.isBefore(habitStartDate)) {
        windowStart = habitStartDate;
      }

      double windowProgress = 0.0;
      int windowScheduledDays = 0;

      DateTime iterator = windowStart;
      while (!iterator.isAfter(plotDate)) {
        final bool isScheduled = habit.frequency.shouldDoOnDay(
          iterator,
          habit.createdAt,
        );

        if (isScheduled) {
          windowScheduledDays++;

          // Calculate completion for this specific day
          double dailyRatio = 0.0;
          if (habit.goalType == GoalType.targetCount &&
              habit.goalValue != null &&
              habit.goalValue! > 0) {
            // Helper to handle goal period logic simply
            double currentTotal = 0.0;
            if (habit.goalPeriod == GoalPeriod.daily) {
              currentTotal = dailyValues[iterator] ?? 0.0;
            } else {
              // For complex periods, we simply fall back to checking if daily logic works
              // or re-implement the window sum.
              // To keep it responsive and fast, we'll try to use the daily values roughly
              // OR, stricly speaking, 'Strength' is usually purely daily consistency.
              // Let's stick to daily accumulation for the graph to show daily effort density.

              // BUT if Goal is Weekly, doing it once on Monday counts for the week?
              // Strength graphs usually plot "Did you meet the goal?".
              // Let's stick to: "Did you do enough today?" or "Did you add value?"
              // For simplicity and responsiveness:
              currentTotal = dailyValues[iterator] ?? 0.0;
            }
            dailyRatio = (currentTotal / habit.goalValue!).clamp(0.0, 1.0);
          } else {
            dailyRatio = (dailyValues[iterator] ?? 0.0) > 0 ? 1.0 : 0.0;
          }
          windowProgress += dailyRatio;
        }
        iterator = iterator.add(const Duration(days: 1));
      }

      double score = 0.0;
      if (windowScheduledDays > 0) {
        score = (windowProgress / windowScheduledDays) * 100;
      }
      spots.add(FlSpot(i.toDouble(), score));
    }

    // Enforce 0-100 scale for consistency in "Habit Strength"
    const double minY = 0;
    const double maxY = 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.ssid_chart_rounded, color: habit.color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.habitStrengthLast30Days,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 29,
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 7, // Show every 7th day
                      getTitlesWidget: (value, meta) {
                        final date = now.subtract(
                          Duration(days: (29 - value).toInt()),
                        );
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8.0,
                          child: Text(
                            '${date.day}/${date.month}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25, // Show 0, 25, 50, 75, 100
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                        );
                      },
                      reservedSize:
                          48, // Increased from 32 to 48 to fix overflow
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: habit.color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          habit.color.withOpacity(0.2),
                          habit.color.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        Theme.of(context).colorScheme.inverseSurface,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()}%',
                          TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
