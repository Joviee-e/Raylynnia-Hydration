import 'package:flutter/material.dart';

class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    required this.weeklyData,
    super.key,
  });

  final Map<DateTime, int> weeklyData;

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final entries = weeklyData.entries.toList();
    final maxValue = entries.fold<int>(
      0,
      (max, entry) => entry.value > max ? entry.value : max,
    );

    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: entries.map((entry) {
          final percentage = maxValue > 0 ? entry.value / maxValue : 0.0;
          final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][entry.key.weekday - 1];
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  width: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  height: (percentage * 150).toDouble(),
                ),
              ),
              const SizedBox(height: 8),
              Text(dayName, style: Theme.of(context).textTheme.labelSmall),
              Text('${entry.value} ml', style: Theme.of(context).textTheme.labelSmall),
            ],
          );
        }).toList(),
      ),
    );
  }
}
