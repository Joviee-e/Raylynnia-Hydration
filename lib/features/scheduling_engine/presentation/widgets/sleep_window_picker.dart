import 'package:flutter/material.dart';

class SleepWindowPicker extends StatelessWidget {
  const SleepWindowPicker({
    required this.wakeTime,
    required this.sleepTime,
    required this.onWakeTimeChanged,
    required this.onSleepTimeChanged,
    super.key,
  });

  final Duration wakeTime;
  final Duration sleepTime;
  final ValueChanged<Duration> onWakeTimeChanged;
  final ValueChanged<Duration> onSleepTimeChanged;

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Future<void> _showTimePicker(
    BuildContext context,
    Duration currentTime,
    ValueChanged<Duration> onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentTime.inHours,
        minute: currentTime.inMinutes.remainder(60),
      ),
    );

    if (picked != null) {
      final newDuration = Duration(hours: picked.hour, minutes: picked.minute);
      onTimeSelected(newDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showTimePicker(context, wakeTime, onWakeTimeChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wake',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(wakeTime),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => _showTimePicker(context, sleepTime, onSleepTimeChanged),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sleep',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDuration(sleepTime),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
