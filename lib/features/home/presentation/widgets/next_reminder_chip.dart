import 'package:flutter/material.dart';

class NextReminderChip extends StatelessWidget {
  const NextReminderChip({
    required this.nextReminder,
    super.key,
  });

  final DateTime nextReminder;

  @override
  Widget build(BuildContext context) {
    final hour = nextReminder.hour.toString().padLeft(2, '0');
    final minute = nextReminder.minute.toString().padLeft(2, '0');
    
    return Center(
      child: Card(
        color: Colors.lightBlue[50],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Next Reminder: $hour:$minute',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
