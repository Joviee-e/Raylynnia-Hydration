import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
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

    return WillPopScope(
      onWillPop: () async {
        if (state.currentStep > 0) {
          viewModel.previousStep();
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            OnboardingStepIndicator(
              currentStep: state.currentStep,
              totalSteps: 4,
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
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
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
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    onBack: () {
                      viewModel.previousStep();
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
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
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    onBack: () {
                      viewModel.previousStep();
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
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
                      if (success && mounted) {
                        context.go(RouteNames.home);
                      }
                    },
                    onBack: () {
                      viewModel.previousStep();
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
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
      ),
    );
  }

}
