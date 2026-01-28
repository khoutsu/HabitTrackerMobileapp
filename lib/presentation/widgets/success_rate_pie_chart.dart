import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:loop_habit_tracker/core/themes/app_colors.dart';

import 'package:loop_habit_tracker/l10n/app_localizations.dart';

class SuccessRatePieChart extends StatelessWidget {
  final double successRate;
  final Color habitColor;

  const SuccessRatePieChart({
    super.key,
    required this.successRate,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    final double failedRate = 100 - successRate;

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
              Icon(Icons.pie_chart_rounded, color: habitColor, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.successRate,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: habitColor,
                          value: successRate,
                          title: '${successRate.toStringAsFixed(0)}%',
                          radius: 20,
                          showTitle: false, // Hide title in chart
                        ),
                        PieChartSectionData(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          value: failedRate,
                          title: '',
                          radius: 15,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIndicator(
                      context,
                      color: habitColor,
                      text: AppLocalizations.of(context)!.success,
                      value: '${successRate.toStringAsFixed(1)}%',
                    ),
                    const SizedBox(height: 12),
                    _buildIndicator(
                      context,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      text: AppLocalizations.of(context)!.missed,
                      value: '${failedRate.toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(
    BuildContext context, {
    required Color color,
    required String text,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
