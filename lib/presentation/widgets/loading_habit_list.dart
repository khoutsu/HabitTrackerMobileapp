import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:loop_habit_tracker/core/themes/app_colors.dart';

class LoadingHabitList extends StatelessWidget {
  const LoadingHabitList({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6, // Show 6 shimmer placeholders
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.white,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16.0,
                          color: AppColors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12.0,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: false,
                    onChanged: null,
                    activeColor: Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
