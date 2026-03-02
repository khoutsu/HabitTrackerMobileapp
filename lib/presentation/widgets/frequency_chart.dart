import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:loop_habit_tracker/core/themes/app_colors.dart';

import 'package:loop_habit_tracker/data/models/repetition_model.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';

class FrequencyChart extends StatelessWidget {
  final Color habitColor;
  final List<Repetition> repetitions;

  const FrequencyChart({
    super.key,
    required this.habitColor,
    required this.repetitions,
  });

  @override
  Widget build(BuildContext context) {
    // Group repetitions by day for a weekly view (last 7 days including today)
    Map<int, int> dailyCounts = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Initialize counts for last 7 days (including today)
    for (int i = 0; i < 7; i++) {
      final day = today.subtract(Duration(days: i));
      dailyCounts[day.weekday] = 0;
    }

    // Populate counts
    // We only care about reps in the window [today-6d, today]
    final startWindow = today.subtract(const Duration(days: 6));

    for (var rep in repetitions) {
      final repDay = DateTime(
        rep.timestamp.year,
        rep.timestamp.month,
        rep.timestamp.day,
      );

      // Check if repDay is within [startWindow, today] inclusive
      if (!repDay.isBefore(startWindow) && !repDay.isAfter(today)) {
        dailyCounts[repDay.weekday] = (dailyCounts[repDay.weekday] ?? 0) + 1;
      }
    }

    // Prepare data for BarChart
    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    // We want to show bars in order: Mon..Sun or Today-6..Today?
    // The previous implementation used x=1..7 (Mon..Sun).
    // This is a "Weekly Activity Pattern" chart.
    // So we iterate 1 to 7.

    for (int i = 1; i <= 7; i++) {
      // Weekday 1 is Monday, 7 is Sunday
      final count = dailyCounts[i] ?? 0;
      if (count > maxY) maxY = count.toDouble();
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: habitColor.withValues(alpha: 0.8),
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    if (maxY == 0) maxY = 1; // Prevent division by zero if no reps

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // Use surface color
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
              Icon(Icons.bar_chart_rounded, color: habitColor, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.frequencyLast7Days,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32), // More space for top labels
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY + (maxY * 0.25), // More padding for top labels
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        final l10n = AppLocalizations.of(context)!;
                        switch (value.toInt()) {
                          case 1:
                            text = l10n.mon;
                            break;
                          case 2:
                            text = l10n.tue;
                            break;
                          case 3:
                            text = l10n.wed;
                            break;
                          case 4:
                            text = l10n.thu;
                            break;
                          case 5:
                            text = l10n.fri;
                            break;
                          case 6:
                            text = l10n.sat;
                            break;
                          case 7:
                            text = l10n.sun;
                            break;
                          default:
                            text = '';
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Text(
                            text,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
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
                      showTitles: false,
                    ), // Hide left titles for cleaner look
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, meta) {
                        final count = dailyCounts[value.toInt()] ?? 0;
                        if (count == 0) return const SizedBox.shrink();

                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 0,
                          child: Text(
                            count.toString(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: habitColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: false, // Cleaner without grid
                ),
                borderData: FlBorderData(show: false), // No border
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) =>
                        Theme.of(context).colorScheme.inverseSurface,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toInt().toString(),
                        TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      );
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
