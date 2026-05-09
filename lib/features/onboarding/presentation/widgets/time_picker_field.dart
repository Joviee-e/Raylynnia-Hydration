import 'package:flutter/material.dart';

/// Reusable time picker field for onboarding.
/// Displays formatted time and triggers time picker dialog on tap.
class TimePickerField extends StatelessWidget {
  const TimePickerField({
    required this.label,
    required this.time,
    required this.onTimeSelected,
    super.key,
  });

  final String label;
  final Duration time;
  final ValueChanged<Duration> onTimeSelected;

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: time.inHours,
        minute: time.inMinutes.remainder(60),
      ),
    );

    if (picked != null) {
      final newDuration = Duration(hours: picked.hour, minutes: picked.minute);
      onTimeSelected(newDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showTimePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              _formatDuration(time),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
