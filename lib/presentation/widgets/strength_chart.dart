import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:loop_habit_tracker/data/models/habit_model.dart';
import 'package:loop_habit_tracker/data/models/repetition_model.dart';
import 'package:loop_habit_tracker/domain/usecases/calculate_habit_score.dart';
import 'dart:math'; // Added import for min and max
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
    final CalculateHabitScore calculateHabitScore = CalculateHabitScore();

    // Generate data points for the last 30 days
    List<FlSpot> spots = [];
    final now = DateTime.now();
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // Filter repetitions up to this date to calculate score for that day
      final dailyRepetitions = repetitions
          .where(
            (rep) => rep.timestamp.isBefore(date.add(const Duration(days: 1))),
          )
          .toList();

      final score = calculateHabitScore(habit, dailyRepetitions, date);
      spots.add(FlSpot((29 - i).toDouble(), score)); // x-axis from 0 to 29
    }

    if (spots.isEmpty) {
      // If no data points, create a dummy one for chart to show something
      spots.add(const FlSpot(0, 0));
    }

    double minY = spots.map((spot) => spot.y).reduce(min);
    double maxY = spots.map((spot) => spot.y).reduce(max);

    // Add some padding to Y axis
    minY = (minY - 10).clamp(0, 100).toDouble();
    maxY = (maxY + 10).clamp(0, 100).toDouble();

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
                minY: 0, // Always start at 0 for consistency
                maxY: 100, // Always end at 100 for percentage
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
