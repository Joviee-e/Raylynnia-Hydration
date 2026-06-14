import 'package:flutter/material.dart';
import '../../../../domain/entities/reminder_schedule.dart';

class SchedulePreviewList extends StatelessWidget {
  const SchedulePreviewList({
    required this.schedule,
    this.title = 'Reminders',
    super.key,
  });

  final ReminderSchedule schedule;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (schedule.times.isEmpty) {
      return Text(
        'No reminders scheduled',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: schedule.times.map((time) {
            final hour = time.hour.toString().padLeft(2, '0');
            final minute = time.minute.toString().padLeft(2, '0');
            return Chip(
              label: Text('$hour:$minute'),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }
}
