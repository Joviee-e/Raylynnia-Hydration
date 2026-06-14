import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../domain/usecases/save_user_profile_usecase.dart';
import '../../../../domain/entities/user_schedule_preferences.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../../../../data/services/notification_manager.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showGoalBottomSheet(BuildContext context, ProfileState state, ProfileViewModel viewModel) {
    int tempGoal = state.userProfile?.dailyGoalMl ?? 2000;
    final controller = TextEditingController(text: tempGoal.toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
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
                      'Daily Goal',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a goal to match your daily activity and flow.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [1500, 2000, 2500, 3000].map((preset) {
                        final isSelected = tempGoal == preset;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              tempGoal = preset;
                              controller.text = preset.toString();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${(preset / 1000.0).toStringAsFixed(1)}L',
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
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Custom Goal (ml)',
                        labelStyle: const TextStyle(color: AppColors.outline),
                        floatingLabelStyle: const TextStyle(color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                      onChanged: (value) {
                        final val = int.tryParse(value);
                        if (val != null && val > 0) {
                          setSheetState(() {
                            tempGoal = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          await viewModel.updateDailyGoal(tempGoal);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Daily goal updated successfully.',
                                  style: TextStyle(fontFamily: 'Inter'),
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'SAVE GOAL',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditProfileBottomSheet(BuildContext context, ProfileState state, ProfileViewModel viewModel) {
    final nameController = TextEditingController(text: state.userProfile?.name ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
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
                      'Edit Profile',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: const TextStyle(color: AppColors.outline),
                        floatingLabelStyle: const TextStyle(color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          final newName = nameController.text.trim();
                          if (newName.isNotEmpty && state.userProfile != null) {
                            final updatedProfile = state.userProfile!.copyWith(name: newName);
                            // Use existing preferences or fallback
                            final preferences = state.preferences ?? const UserSchedulePreferences(
                              weekdayWakeTime: Duration(hours: 6),
                              weekdaySleepTime: Duration(hours: 22),
                              weekendWakeTime: Duration(hours: 8),
                              weekendSleepTime: Duration(hours: 23),
                              reminderIntervalMinutes: 60,
                            );
                            await getIt<SaveUserProfileUseCase>().execute(
                              profile: updatedProfile,
                              preferences: preferences,
                            );
                            await viewModel.loadProfile();
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Profile updated successfully.',
                                  style: TextStyle(fontFamily: 'Inter'),
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text(
                          'SAVE CHANGES',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Reset All Data?',
            style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This will permanently delete all your hydration logs, daily goals, sleep schedules, and reset onboarding. This action cannot be undone.',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.outline)),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = getIt<SharedPreferences>();
                await prefs.clear();
                try {
                  final logBox = Hive.box('hydration_logs');
                  await logBox.clear();
                } catch (_) {}
                try {
                  await getIt<NotificationManager>().cancelAll();
                } catch (_) {}
                if (context.mounted) {
                  Navigator.pop(context);
                  context.go(RouteNames.onboarding);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              child: const Text('RESET ALL'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);
    final profileViewModel = ref.read(profileViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.userProfile == null
              ? Center(
                  child: Text(
                    'No profile found',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account Summary Header
                        const Text(
                          'ACCOUNT',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: Text(
                                profileState.userProfile!.name,
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w200,
                                      color: AppColors.onSurface,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'PREMIUM',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onPrimaryContainer,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Maintaining stillness through ${(profileState.userProfile!.dailyGoalMl / 1000.0).toStringAsFixed(1)}L daily hydration. Member of the sanctuary.',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color: AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Bento Grid stats
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 120,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(Icons.water_drop_outlined, color: AppColors.primary, size: 24),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '84%',
                                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                fontFamily: 'Manrope',
                                                fontWeight: FontWeight.w300,
                                                fontSize: 28,
                                              ),
                                        ),
                                        const Text(
                                          'AVG CONSISTENCY',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.onSurfaceVariant,
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
                                height: 120,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(Icons.auto_awesome_outlined, color: AppColors.tertiary, size: 24),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '12',
                                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                fontFamily: 'Manrope',
                                                fontWeight: FontWeight.w300,
                                                fontSize: 28,
                                              ),
                                        ),
                                        const Text(
                                          'DAY STREAK',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.onSurfaceVariant,
                                            letterSpacing: 1.0,
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
                        const SizedBox(height: 40),

                        // Preferences Section
                        const Text(
                          'PREFERENCES',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SettingsRow(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          onTap: () => _showEditProfileBottomSheet(context, profileState, profileViewModel),
                        ),
                        _SettingsRow(
                          icon: Icons.local_drink_outlined,
                          title: 'Daily Goal',
                          trailingText: '${profileState.userProfile!.dailyGoalMl} ml',
                          onTap: () => _showGoalBottomSheet(context, profileState, profileViewModel),
                        ),
                        _SettingsRow(
                          icon: Icons.notifications_none,
                          title: 'Notification Preferences',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Silence is active. Reminders are configured automatically.',
                                  style: TextStyle(fontFamily: 'Inter'),
                                ),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // System Section
                        const Text(
                          'SYSTEM',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SettingsRow(
                          icon: Icons.storage_outlined,
                          title: 'Data Management (Reset)',
                          iconColor: AppColors.error,
                          onTap: () => _showResetConfirmDialog(context),
                        ),
                        _SettingsRow(
                          icon: Icons.info_outline,
                          title: 'App Info',
                          trailingText: 'Version 2.4.0',
                          onTap: () {},
                        ),
                        const SizedBox(height: 48),

                        // Sign Out Button
                        Center(
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: () => _showResetConfirmDialog(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.error,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                    side: BorderSide(
                                      color: AppColors.outlineVariant.withOpacity(0.15),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'SIGN OUT',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'VERSION 2.4.0 • LUMINOUS STILLNESS',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 8,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.outlineVariant,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80), // spacer for bottom nav bar
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.outline,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AppColors.outlineVariant.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
