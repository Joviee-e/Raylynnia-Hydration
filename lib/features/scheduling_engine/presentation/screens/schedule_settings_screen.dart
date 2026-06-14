import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../widgets/interval_slider.dart';
import '../widgets/schedule_preview_list.dart';
import '../widgets/sleep_window_picker.dart';

class ScheduleSettingsScreen extends ConsumerWidget {
  const ScheduleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(scheduleSettingsViewModelProvider);
    final scheduleViewModel = ref.read(scheduleSettingsViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Settings'),
        elevation: 0,
      ),
      body: scheduleState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekday settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekday Schedule',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (scheduleState.weekdayWakeTime != null)
                            SleepWindowPicker(
                              wakeTime: scheduleState.weekdayWakeTime!,
                              sleepTime: scheduleState.weekdaySleepTime!,
                              onWakeTimeChanged: scheduleViewModel.setWeekdayWakeTime,
                              onSleepTimeChanged: scheduleViewModel.setWeekdaySleepTime,
                            ),
                          if (scheduleState.weekdaySchedulePreview != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: SchedulePreviewList(
                                schedule: scheduleState.weekdaySchedulePreview!,
                                title: 'Weekday Reminders',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weekend settings
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekend Schedule',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (scheduleState.weekendWakeTime != null)
                            SleepWindowPicker(
                              wakeTime: scheduleState.weekendWakeTime!,
                              sleepTime: scheduleState.weekendSleepTime!,
                              onWakeTimeChanged: scheduleViewModel.setWeekendWakeTime,
                              onSleepTimeChanged: scheduleViewModel.setWeekendSleepTime,
                            ),
                          if (scheduleState.weekendSchedulePreview != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: SchedulePreviewList(
                                schedule: scheduleState.weekendSchedulePreview!,
                                title: 'Weekend Reminders',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reminder interval
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reminder Frequency',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          IntervalSlider(
                            value: scheduleState.reminderIntervalMinutes,
                            onChanged: scheduleViewModel.setReminderInterval,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error message
                  if (scheduleState.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        scheduleState.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: scheduleState.isSaving
                          ? null
                          : scheduleViewModel.saveSettings,
                      child: scheduleState.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Settings'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
