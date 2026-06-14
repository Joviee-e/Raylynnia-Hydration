import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    required this.weeklyData,
    super.key,
  });

  final Map<DateTime, int> weeklyData;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Anchor to Monday of the current week
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    
    final List<MapEntry<DateTime, int>> orderedEntries = List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      final value = weeklyData.entries
          .firstWhere(
            (e) => e.key.year == date.year && e.key.month == date.month && e.key.day == date.day,
            orElse: () => MapEntry(date, 0),
          )
          .value;
      return MapEntry(date, value);
    });

    final maxVal = orderedEntries.fold<int>(
      2000, // baseline max so bars are scaled nicely
      (m, entry) => entry.value > m ? entry.value : m,
    );

    return SizedBox(
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: orderedEntries.map((entry) {
          final double fraction = maxVal > 0 ? entry.value / maxVal : 0.0;
          final double barHeight = max(fraction * 100, 8.0); // minimum 8px for visual feedback
          
          final isToday = entry.key.year == now.year &&
              entry.key.month == now.month &&
              entry.key.day == now.day;
          
          final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][entry.key.weekday - 1];

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // The Bar itself
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  width: 24,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: isToday ? AppColors.primary : AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      if (isToday)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Day label
                Text(
                  dayName.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 8,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isToday ? AppColors.primary : AppColors.outline,
                        letterSpacing: 0.5,
                      ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
