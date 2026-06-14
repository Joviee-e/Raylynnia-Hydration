import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_header.dart';
import '../viewmodels/schedule_settings_viewmodel.dart';

class ScheduleSettingsScreen extends ConsumerStatefulWidget {
  const ScheduleSettingsScreen({super.key});

  @override
  ConsumerState<ScheduleSettingsScreen> createState() => _ScheduleSettingsScreenState();
}

class _ScheduleSettingsScreenState extends ConsumerState<ScheduleSettingsScreen> with WidgetsBindingObserver {
  int _activeSection = 0; // 0 for Rest Cycle, 1 for Reminders
  bool _isWeekend = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(scheduleSettingsViewModelProvider.notifier).checkExactAlarmPermission();
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(DateTime time) {
    final local = time.toLocal();
    final h = local.hour;
    final m = local.minute.toString().padLeft(2, '0');
    return '${h.toString().padLeft(2, '0')}:$m';
  }

  Future<void> _selectTime(BuildContext context, Duration initial, ValueChanged<Duration> onChanged) async {
    final initialTime = TimeOfDay(hour: initial.inHours, minute: initial.inMinutes % 60);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
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
      onChanged(Duration(hours: picked.hour, minutes: picked.minute));
    }
  }

  void _showIntervalBottomSheet(BuildContext context, ScheduleSettingsState state, ScheduleSettingsViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Reminder Interval',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select how frequently you would like to be reminded to sip.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [30, 45, 60, 90, 120].map((minutes) {
                  final isSelected = state.reminderIntervalMinutes == minutes;
                  return GestureDetector(
                    onTap: () {
                      viewModel.setReminderInterval(minutes);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$minutes Mins',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurface,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = ref.watch(scheduleSettingsViewModelProvider);
    final scheduleViewModel = ref.read(scheduleSettingsViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(),
      body: scheduleState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dual-tab Segment Selector
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeSection = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _activeSection == 0 ? AppColors.surfaceContainerLowest : Colors.transparent,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: _activeSection == 0
                                      ? const [
                                          BoxShadow(
                                            color: Color(0x052C3437),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'REST CYCLE',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                    color: _activeSection == 0 ? AppColors.primary : AppColors.outline,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _activeSection = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _activeSection == 1 ? AppColors.surfaceContainerLowest : Colors.transparent,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: _activeSection == 1
                                      ? const [
                                          BoxShadow(
                                            color: Color(0x052C3437),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'REMINDERS',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                    color: _activeSection == 1 ? AppColors.primary : AppColors.outline,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (_activeSection == 0) ...[
                      // Rest Cycle Tab Content
                      const Text(
                        'Rest Cycle',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 32,
                          fontWeight: FontWeight.w200,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your daily ritual of luminous stillness.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          fontStyle: FontStyle.italic,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Weekday / Weekend toggle
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isWeekend = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isWeekend ? AppColors.primaryContainer : Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'WEEKDAY',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: !_isWeekend ? AppColors.onPrimaryContainer : AppColors.outline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _isWeekend = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: _isWeekend ? AppColors.primaryContainer : Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'WEEKEND',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: _isWeekend ? AppColors.onPrimaryContainer : AppColors.outline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Visual rest cycle timeline card
                      _buildTimelineCard(scheduleState),
                      const SizedBox(height: 24),

                      // Time setup cards
                      _buildTimePickerCards(context, scheduleState, scheduleViewModel),
                      const SizedBox(height: 24),

                      // Info card tip
                      _buildInfoCard(
                        Icons.info_outline,
                        'Your hydration reminders will automatically adjust to these hours to ensure your rest remains uninterrupted.',
                      ),
                    ] else ...[
                      // Reminders Tab Content
                      const Text(
                        'Reminders',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 32,
                          fontWeight: FontWeight.w200,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Design your rhythmic hydration ritual.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Global Active Reminders toggle
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x052C3437),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Active Reminders',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Silent notifications for your wellness',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            Switch(
                              value: scheduleState.notificationsActive,
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                scheduleViewModel.setNotificationsActive(val);
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      val ? 'Reminders activated.' : 'Reminders muted for quiet rest.',
                                      style: const TextStyle(fontFamily: 'Inter'),
                                    ),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (Platform.isAndroid && !scheduleState.hasExactAlarmPermission) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.errorContainer.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.error,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Timing Accuracy Limited',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.error,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'To receive hydration reminders at the exact scheduled minutes, please grant the "Alarms & Reminders" permission. Otherwise, reminders might vary slightly to optimize battery life.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: scheduleViewModel.requestExactAlarmPermission,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                icon: const Icon(Icons.settings, size: 16),
                                label: const Text(
                                  'GRANT ALARMS & REMINDERS',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Bento grid: Next Alert and Interval cards
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 160,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.notifications_outlined, color: AppColors.primaryDim, size: 28),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getNextAlertTime(scheduleState),
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                              fontFamily: 'Manrope',
                                              fontWeight: FontWeight.w300,
                                              fontSize: 32,
                                            ),
                                      ),
                                      const Text(
                                        'NEXT ALERT',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onPrimaryContainer,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 160,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.hourglass_empty, color: AppColors.secondary, size: 28),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${scheduleState.reminderIntervalMinutes} Mins',
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                              fontFamily: 'Manrope',
                                              fontWeight: FontWeight.w300,
                                              fontSize: 22,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () => _showIntervalBottomSheet(context, scheduleState, scheduleViewModel),
                                        child: const Row(
                                          children: [
                                            Text(
                                              'Modify',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(Icons.edit, color: AppColors.primary, size: 12),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Today's schedule preview sessions list
                      _buildScheduleSessionList(scheduleState),
                    ],

                    const SizedBox(height: 32),

                    // Sticky/Floating Save Settings button
                    if (scheduleState.error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.errorContainer.withOpacity(0.5)),
                        ),
                        child: Text(
                          scheduleState.error!,
                          style: const TextStyle(fontFamily: 'Inter', color: AppColors.error, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    ElevatedButton(
                      onPressed: scheduleState.isSaving
                          ? null
                          : () async {
                              await scheduleViewModel.saveSettings();
                              if (context.mounted) {
                                if (ref.read(scheduleSettingsViewModelProvider).error == null) {
                                  ScaffoldMessenger.of(context).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Ritual settings saved successfully!',
                                        style: TextStyle(fontFamily: 'Inter'),
                                      ),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: scheduleState.isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'SAVE RITUAL SETTINGS',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                    const SizedBox(height: 80), // spacer for bottom nav bar
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildTimelineCard(ScheduleSettingsState state) {
    final wakeDur = _isWeekend ? state.weekendWakeTime : state.weekdayWakeTime;
    final sleepDur = _isWeekend ? state.weekendSleepTime : state.weekdaySleepTime;

    if (wakeDur == null || sleepDur == null) {
      return const SizedBox.shrink();
    }

    // Rest calculation
    int wakeMins = wakeDur.inMinutes;
    int sleepMins = sleepDur.inMinutes;
    int restMins = 0;
    if (sleepMins > wakeMins) {
      restMins = (24 * 60) - (sleepMins - wakeMins);
    } else {
      restMins = wakeMins - sleepMins;
    }
    final restH = restMins ~/ 60;
    final restM = restMins % 60;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x052C3437),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rest Cycle',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '24 HOUR VIEW',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${restH}h ${restM}m',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    'TOTAL REST',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          RestCycleTimeline(
            wakeTime: wakeDur,
            sleepTime: sleepDur,
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('00:00', style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: AppColors.outlineVariant)),
              Text('06:00', style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: AppColors.outlineVariant)),
              Text('12:00', style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: AppColors.outlineVariant)),
              Text('18:00', style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: AppColors.outlineVariant)),
              Text('24:00', style: TextStyle(fontFamily: 'Inter', fontSize: 9, color: AppColors.outlineVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerCards(BuildContext context, ScheduleSettingsState state, ScheduleSettingsViewModel viewModel) {
    final wakeDur = _isWeekend ? state.weekendWakeTime : state.weekdayWakeTime;
    final sleepDur = _isWeekend ? state.weekendSleepTime : state.weekdaySleepTime;

    if (wakeDur == null || sleepDur == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Sleep card
        GestureDetector(
          onTap: () => _selectTime(context, sleepDur, (newTime) {
            if (_isWeekend) {
              viewModel.setWeekendSleepTime(newTime);
            } else {
              viewModel.setWeekdaySleepTime(newTime);
            }
          }),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(color: AppColors.tertiaryContainer, shape: BoxShape.circle),
                      child: const Icon(Icons.bedtime, color: AppColors.onTertiaryContainer, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SLEEP AT',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDuration(sleepDur),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: AppColors.outline, size: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Wake card
        GestureDetector(
          onTap: () => _selectTime(context, wakeDur, (newTime) {
            if (_isWeekend) {
              viewModel.setWeekendWakeTime(newTime);
            } else {
              viewModel.setWeekdayWakeTime(newTime);
            }
          }),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
                      child: const Icon(Icons.sunny, color: AppColors.onPrimaryContainer, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WAKE AT',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDuration(wakeDur),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.edit, color: AppColors.outline, size: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withOpacity(0.25),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.onSecondaryContainer, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: AppColors.onSecondaryContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNextAlertTime(ScheduleSettingsState state) {
    final schedule = _isWeekend ? state.weekendSchedulePreview : state.weekdaySchedulePreview;
    if (schedule == null || schedule.times.isEmpty) {
      return '--:--';
    }
    final now = DateTime.now();
    for (final time in schedule.times) {
      if (time.isAfter(now)) {
        return _formatTimeOfDay(time);
      }
    }
    return _formatTimeOfDay(schedule.times.first);
  }

  Widget _buildScheduleSessionList(ScheduleSettingsState state) {
    final schedule = _isWeekend ? state.weekendSchedulePreview : state.weekdaySchedulePreview;
    if (schedule == null || schedule.times.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Text(
            'No reminders generated for this timeframe.',
            style: TextStyle(fontFamily: 'Inter', fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final times = schedule.times;

    // Identify next session
    int nextSessionIndex = -1;
    for (int i = 0; i < times.length; i++) {
      if (times[i].isAfter(now)) {
        nextSessionIndex = i;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Schedule",
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              '${times.length} SESSIONS',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: AppColors.outline,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: times.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final time = times[index];
            final bool isPast = time.isBefore(now) && index != nextSessionIndex;
            final bool isNext = index == nextSessionIndex;

            String subtitle = 'Upcoming session';
            if (isPast) {
              subtitle = 'Session completed';
            } else if (isNext) {
              final diff = time.difference(now).inMinutes;
              subtitle = 'Upcoming in ${diff}m';
            }

            // Custom session title based on index
            String title = 'Hydration Sip';
            if (index == 0) {
              title = 'Morning Start';
            } else if (index == times.length - 1) {
              title = 'Evening Quiet';
            } else if (index == (times.length ~/ 2)) {
              title = 'Midday Balance';
            }

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isNext ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
                border: isNext
                    ? Border.all(
                        color: AppColors.primary.withOpacity(0.15),
                        width: 1,
                      )
                    : null,
                boxShadow: isNext
                    ? const [
                        BoxShadow(
                          color: Color(0x052C3437),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        _formatTimeOfDay(time),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                          color: isNext ? AppColors.primary : AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 16,
                            fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                            color: isNext ? AppColors.onSurface : AppColors.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            color: isNext ? AppColors.primaryDim : AppColors.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isPast
                        ? Icons.check_circle
                        : (isNext ? Icons.water_drop : Icons.radio_button_unchecked),
                    color: isPast
                        ? AppColors.primary.withOpacity(0.4)
                        : (isNext ? AppColors.primary : AppColors.outlineVariant),
                    size: 20,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class RestCycleTimeline extends StatelessWidget {
  const RestCycleTimeline({
    required this.wakeTime,
    required this.sleepTime,
    super.key,
  });

  final Duration wakeTime;
  final Duration sleepTime;

  @override
  Widget build(BuildContext context) {
    final wakeHour = wakeTime.inHours;
    final sleepHour = sleepTime.inHours;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(24, (index) {
        final bool isAwake = sleepHour > wakeHour
            ? (index >= wakeHour && index < sleepHour)
            : (index >= wakeHour || index < sleepHour);

        double barHeight = 16.0;
        if (isAwake) {
          if (index == 12 || index == 13 || index == 17 || index == 18) {
            barHeight = 48.0;
          } else if (index == 14 || index == 15) {
            barHeight = 24.0;
          } else if (index >= 9 && index <= 21) {
            barHeight = 38.0;
          } else {
            barHeight = 28.0;
          }
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: barHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: isAwake
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primaryContainer, AppColors.tertiaryContainer],
                      )
                    : null,
                color: isAwake ? null : AppColors.surfaceContainerHigh,
              ),
            ),
          ),
        );
      }),
    );
  }
}
