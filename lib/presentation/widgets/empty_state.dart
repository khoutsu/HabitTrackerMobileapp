import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loop_habit_tracker/l10n/app_localizations.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String imagePath;

  const EmptyState({
    super.key,
    required this.message,
    this.imagePath = 'assets/images/empty.svg', // Default image
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // If you have an SVG image:
          // SvgPicture.asset(
          //   imagePath,
          //   height: 200,
          //   width: 200,
          //   placeholderBuilder: (context) => const Icon(Icons.all_inbox, size: 100),
          // ),

          // Using an icon as a placeholder:
          Icon(
            Icons.all_inbox,
            size: 150,
            color: theme.colorScheme.primary.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.noHabitsYet,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
