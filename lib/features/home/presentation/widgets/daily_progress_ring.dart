import 'package:flutter/material.dart';

class DailyProgressRing extends StatelessWidget {
  const DailyProgressRing({
    required this.totalIntakeMl,
    required this.goalMl,
    required this.percentage,
    super.key,
  });

  final int totalIntakeMl;
  final int goalMl;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage >= 100 ? Colors.green : Colors.blue,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$totalIntakeMl ml',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'of $goalMl ml',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: percentage >= 100 ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
