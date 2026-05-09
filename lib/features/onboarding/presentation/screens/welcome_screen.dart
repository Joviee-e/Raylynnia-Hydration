import 'package:flutter/material.dart';

/// Welcome screen - first step of onboarding.
/// Introduces the app and its core value proposition.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.onProceed,
    super.key,
  });

  final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon/Logo placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.water_drop,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Raylynnia Hydration',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Stay hydrated automatically on your schedule.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                'Get personalized reminders that respect your wake time, sleep schedule, and weekday/weekend differences. No internet. No account. Just intelligent hydration.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onProceed,
                  child: const Text('Let\'s Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
