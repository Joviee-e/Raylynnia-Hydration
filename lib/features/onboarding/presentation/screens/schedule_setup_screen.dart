import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
  bool _isWeekendSelected = false;



  String _getHourPart(Duration time) {
    final totalMinutes = time.inMinutes;
    final rawHour = (totalMinutes ~/ 60) % 24;
    final hour = rawHour == 0 ? 12 : (rawHour > 12 ? rawHour - 12 : rawHour);
    return hour.toString().padLeft(2, '0');
  }

  String _getMinutePart(Duration time) {
    final totalMinutes = time.inMinutes;
    final minute = totalMinutes % 60;
    return minute.toString().padLeft(2, '0');
  }

  String _getAmPmPart(Duration time) {
    final totalMinutes = time.inMinutes;
    final rawHour = (totalMinutes ~/ 60) % 24;
    return rawHour >= 12 ? 'PM' : 'AM';
  }

  Future<void> _selectTime(
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surfaceContainerLowest,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final newDuration = Duration(hours: picked.hour, minutes: picked.minute);
      onTimeSelected(newDuration);
    }
  }

  Duration _getCurrentWakeTime() {
    return _isWeekendSelected ? widget.weekendWakeTime : widget.weekdayWakeTime;
  }

  Duration _getCurrentSleepTime() {
    return _isWeekendSelected ? widget.weekendSleepTime : widget.weekdaySleepTime;
  }

  ValueChanged<Duration> _getCurrentWakeChanged() {
    return _isWeekendSelected ? widget.onWeekendWakeTimeChanged : widget.onWeekdayWakeTimeChanged;
  }

  ValueChanged<Duration> _getCurrentSleepChanged() {
    return _isWeekendSelected ? widget.onWeekendSleepTimeChanged : widget.onWeekdaySleepTimeChanged;
  }

  String _getHydrationWindowText() {
    final wake = _getCurrentWakeTime();
    final sleep = _getCurrentSleepTime();
    
    int wakeMin = wake.inMinutes;
    int sleepMin = sleep.inMinutes;
    
    int diffMin = sleepMin - wakeMin;
    if (diffMin < 0) {
      diffMin += 24 * 60; // sleep is on the next day
    }
    
    final hours = diffMin ~/ 60;
    final minutes = diffMin % 60;
    
    if (minutes == 0) {
      return '$hours hours';
    }
    return '$hours hours $minutes mins';
  }

  @override
  Widget build(BuildContext context) {
    final wakeTime = _getCurrentWakeTime();
    final sleepTime = _getCurrentSleepTime();

    return Scaffold(
      backgroundColor: Colors.transparent, // Flow container has background blooms
      body: SafeArea(
        child: Stack(
          children: [
            // Back Button on Top Left
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.onSurfaceVariant,
                  size: 24,
                ),
                onPressed: widget.onBack,
              ),
            ),

            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 72, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Editorial Header
                  Text(
                    'Set your rhythm',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w200,
                          color: AppColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Align your hydration window with your natural waking and resting cycles.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Toggle Switch Segment
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isWeekendSelected = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isWeekendSelected ? AppColors.primaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'WEEKDAY',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: !_isWeekendSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                                  letterSpacing: 1.0,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _isWeekendSelected = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: _isWeekendSelected ? AppColors.primaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'WEEKEND',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _isWeekendSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                                  letterSpacing: 1.0,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Custom Wake Up Card
                  GestureDetector(
                    onTap: () => _selectTime(context, wakeTime, _getCurrentWakeChanged()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColors.outlineVariant.withOpacity(0.15),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x052C3437),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.wb_sunny_outlined, color: AppColors.primary, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            'WAKE UP',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  color: AppColors.outline,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _getHourPart(wakeTime),
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                ':',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getMinutePart(wakeTime),
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getAmPmPart(wakeTime),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDim,
                                      letterSpacing: 1.0,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Custom Sleep Card
                  GestureDetector(
                    onTap: () => _selectTime(context, sleepTime, _getCurrentSleepChanged()),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColors.outlineVariant.withOpacity(0.15),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x052C3437),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.mode_night_outlined, color: AppColors.tertiary, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            'SLEEP',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  color: AppColors.outline,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _getHourPart(sleepTime),
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                ':',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getMinutePart(sleepTime),
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 60,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getAmPmPart(sleepTime),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.tertiary,
                                      letterSpacing: 1.0,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Hydration Window Summary Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hydration Window',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your ideal window is ${_getHydrationWindowText()}.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Overlapping Icons graphic
                        SizedBox(
                          width: 60,
                          height: 40,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryContainer,
                                    border: Border.all(color: AppColors.surfaceContainerHighest, width: 2),
                                  ),
                                  child: const Icon(Icons.coffee, size: 14, color: AppColors.onPrimaryContainer),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.tertiaryContainer,
                                    border: Border.all(color: AppColors.surfaceContainerHighest, width: 2),
                                  ),
                                  child: const Icon(Icons.bedtime, size: 14, color: AppColors.onTertiaryContainer),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Reminder Interval Slider
                  Text(
                    'REMINDER FREQUENCY',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: AppColors.outline,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Every ${widget.reminderIntervalMinutes} minutes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.outlineVariant.withOpacity(0.3),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.1),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: widget.reminderIntervalMinutes.toDouble(),
                      min: 30,
                      max: 180,
                      divisions: 10,
                      onChanged: (value) {
                        widget.onReminderIntervalChanged(value.toInt());
                      },
                    ),
                  ),

                  // Schedule preview text log if available
                  if (widget.computedSchedulePreview != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      widget.computedSchedulePreview!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ],
              ),
            ),

            // floating Complete button fixed at bottom
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: GestureDetector(
                onTap: widget.onNext,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9999),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDim],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F2C3437),
                        blurRadius: 32,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Complete Setup',
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.onPrimary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
