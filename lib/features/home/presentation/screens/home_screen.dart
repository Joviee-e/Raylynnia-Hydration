import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../widgets/daily_progress_ring.dart';
import '../widgets/log_drink_button.dart';
import '../widgets/next_reminder_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeViewModel = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raylynnia Hydration'),
        elevation: 0,
      ),
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeState.userProfile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No profile found. Please set up your profile.'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to onboarding
                        },
                        child: const Text('Get Started'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Text(
                        'Hello, ${homeState.userProfile!.name}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),

                      // Daily Progress Ring
                      Center(
                        child: DailyProgressRing(
                          totalIntakeMl: homeState.getTotalIntakeMl(),
                          goalMl: homeState.userProfile!.dailyGoalMl,
                          percentage: homeState.getProgressPercentage(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Next Reminder
                      if (homeState.getNextReminderTime() != null)
                        NextReminderChip(
                          nextReminder: homeState.getNextReminderTime()!,
                        ),
                      const SizedBox(height: 24),

                      // Log Drink Button
                      LogDrinkButton(
                        onLog: (volumeMl) {
                          homeViewModel.logDrink(volumeMl);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Logged $volumeMl ml'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Today's Logs
                      Text(
                        'Today\'s Logs',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (homeState.todayLogs.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text('No logs yet today'),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: homeState.todayLogs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final log = homeState.todayLogs[index];
                            return Card(
                              child: ListTile(
                                title: Text('${log.volumeMl} ml'),
                                subtitle: Text(
                                  '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
    );
  }
}

