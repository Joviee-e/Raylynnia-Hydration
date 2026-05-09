import 'package:flutter/material.dart';

/// Schedule setup screen - third step of onboarding.
/// Configures wake/sleep times for weekday and weekend with live preview.
class ScheduleSetupScreen extends StatefulWidget {
  const ScheduleSetupScreen({
    required this.weekdayWakeTime,
    required this.weekdaySleepTime,
    required this.weekendWakeTime,
    required this.weekendSleepTime,
    required this.reminderIntervalMinutes,
    required this.onWeekdayWakeTimeChanged,
    required this.onWeekdaySleepTimeChanged,
    required this.onWeekendWakeTimeChanged,
    required this.onWeekendSleepTimeChanged,
    required this.onReminderIntervalChanged,
    required this.onNext,
    required this.onBack,
    required this.computedSchedulePreview,
    super.key,
  });

  final Duration weekdayWakeTime;
  final Duration weekdaySleepTime;
  final Duration weekendWakeTime;
  final Duration weekendSleepTime;
  final int reminderIntervalMinutes;
  final ValueChanged<Duration> onWeekdayWakeTimeChanged;
  final ValueChanged<Duration> onWeekdaySleepTimeChanged;
  final ValueChanged<Duration> onWeekendWakeTimeChanged;
  final ValueChanged<Duration> onWeekendSleepTimeChanged;
  final ValueChanged<int> onReminderIntervalChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final String? computedSchedulePreview;

  @override
  State<ScheduleSetupScreen> createState() => _ScheduleSetupScreenState();
}

class _ScheduleSetupScreenState extends State<ScheduleSetupScreen> {
  late bool _showWeekendSettings;

  @override
  void initState() {
    super.initState();
    _showWeekendSettings = false;
  }

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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Set Your Schedule',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tell us your typical wake and sleep times.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              // Weekday section
              _buildScheduleSection(
                context,
                title: 'Weekday',
                wakeTime: widget.weekdayWakeTime,
                sleepTime: widget.weekdaySleepTime,
                onWakeTimeChanged: widget.onWeekdayWakeTimeChanged,
                onSleepTimeChanged: widget.onWeekdaySleepTimeChanged,
              ),
              const SizedBox(height: 32),
              // Weekend section
              _buildScheduleSection(
                context,
                title: 'Weekend',
                wakeTime: widget.weekendWakeTime,
                sleepTime: widget.weekendSleepTime,
                onWakeTimeChanged: widget.onWeekendWakeTimeChanged,
                onSleepTimeChanged: widget.onWeekendSleepTimeChanged,
              ),
              const SizedBox(height: 32),
              // Reminder interval
              Text(
                'Reminder Frequency',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Every ${widget.reminderIntervalMinutes} minutes',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Slider(
                value: widget.reminderIntervalMinutes.toDouble(),
                min: 30,
                max: 180,
                divisions: 15,
                onChanged: (value) {
                  widget.onReminderIntervalChanged(value.toInt());
                },
              ),
              const SizedBox(height: 32),
              // Schedule preview
              if (widget.computedSchedulePreview != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Reminders',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.computedSchedulePreview!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      child: const Text('Next'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleSection(
    BuildContext context, {
    required String title,
    required Duration wakeTime,
    required Duration sleepTime,
    required ValueChanged<Duration> onWakeTimeChanged,
    required ValueChanged<Duration> onSleepTimeChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTimePickerButton(
                context,
                label: 'Wake',
                time: wakeTime,
                onTap: () => _showTimePicker(
                  context,
                  wakeTime,
                  onWakeTimeChanged,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimePickerButton(
                context,
                label: 'Sleep',
                time: sleepTime,
                onTap: () => _showTimePicker(
                  context,
                  sleepTime,
                  onSleepTimeChanged,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimePickerButton(
    BuildContext context, {
    required String label,
    required Duration time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDuration(time),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
