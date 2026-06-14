import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../viewmodels/onboarding_viewmodel.dart';
import '../widgets/onboarding_step_indicator.dart';
import 'welcome_screen.dart';
import 'name_entry_screen.dart';
import 'schedule_setup_screen.dart';
import 'goal_setup_screen.dart';

/// Main onboarding flow container.
/// Manages step navigation and coordinates all onboarding screens.
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() =>
      _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(onboardingViewModelProvider.notifier);
    final state = ref.watch(onboardingViewModelProvider);

    return PopScope(
      canPop: state.currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (state.currentStep > 0) {
          viewModel.previousStep();
          _pageController.previousPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Ambient Decorative Blooms (Editorial Serenity)
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer.withValues(alpha: 0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                  child: const SizedBox(),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tertiaryContainer.withValues(alpha: 0.1),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
                  child: const SizedBox(),
                ),
              ),
            ),

            // Content Shell
            Column(
              children: [
                // Render progress indicator only when currentStep > 0
                if (state.currentStep > 0)
                  SafeArea(
                    bottom: false,
                    child: OnboardingStepIndicator(
                      currentStep: state.currentStep,
                      totalSteps: 4,
                    ),
                  ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      // Prevent manual page swiping
                    },
                    children: [
                      // Step 0: Welcome
                      WelcomeScreen(
                        onProceed: () {
                          viewModel.nextStep();
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                      // Step 1: Name Entry
                      NameEntryScreen(
                        initialName: state.name,
                        onNameChanged: viewModel.setName,
                        onNext: () {
                          viewModel.nextStep();
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          );
                        },
                        onBack: () {
                          viewModel.previousStep();
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                      // Step 2: Schedule Setup
                      ScheduleSetupScreen(
                        weekdayWakeTime: state.weekdayWakeTime,
                        weekdaySleepTime: state.weekdaySleepTime,
                        weekendWakeTime: state.weekendWakeTime,
                        weekendSleepTime: state.weekendSleepTime,
                        reminderIntervalMinutes: state.reminderIntervalMinutes,
                        onWeekdayWakeTimeChanged: viewModel.setWeekdayWakeTime,
                        onWeekdaySleepTimeChanged: viewModel.setWeekdaySleepTime,
                        onWeekendWakeTimeChanged: viewModel.setWeekendWakeTime,
                        onWeekendSleepTimeChanged: viewModel.setWeekendSleepTime,
                        onReminderIntervalChanged:
                            viewModel.setReminderIntervalMinutes,
                        onNext: () {
                          viewModel.nextStep();
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          );
                        },
                        onBack: () {
                          viewModel.previousStep();
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          );
                        },
                        computedSchedulePreview: viewModel.buildSchedulePreviewText(),
                      ),
                      // Step 3: Goal Setup
                      GoalSetupScreen(
                        initialGoal: state.dailyGoalMl,
                        onGoalChanged: viewModel.setDailyGoalMl,
                        onComplete: () async {
                          final success = await viewModel.completeOnboarding();
                          if (success && context.mounted) {
                            context.go(RouteNames.home);
                          }
                        },
                        onBack: () {
                          viewModel.previousStep();
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          );
                        },
                        isLoading: state.isLoading,
                        error: state.error,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
