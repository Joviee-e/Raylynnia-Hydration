import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: List.generate(
          totalSteps,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < totalSteps - 1 ? 8.0 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: index < currentStep
                      ? 1.0
                      : (index == currentStep ? 0.5 : 0.0),
                  minHeight: 4,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
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
