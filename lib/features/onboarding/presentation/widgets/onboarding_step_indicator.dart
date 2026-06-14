import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Onboarding step indicator showing progress through wizard.
class OnboardingStepIndicator extends StatelessWidget {
  const OnboardingStepIndicator({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Row(
        children: List.generate(
          totalSteps,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < totalSteps - 1 ? 8.0 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: index < currentStep
                      ? 1.0
                      : (index == currentStep ? 1.0 : 0.0),
                  minHeight: 3,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
