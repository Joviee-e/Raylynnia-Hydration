import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../widgets/profile_header.dart';
import '../widgets/goal_editor_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);
    final profileViewModel = ref.read(profileViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.userProfile == null
              ? Center(
                  child: Text(
                    'No profile found',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile header
                      ProfileHeader(
                        userProfile: profileState.userProfile!,
                      ),
                      const SizedBox(height: 24),

                      // Goal editor
                      GoalEditorCard(
                        currentGoal: profileState.userProfile!.dailyGoalMl,
                        onGoalChanged: (newGoal) async {
                          profileViewModel.updateDailyGoal(newGoal);
                        },
                        isSaving: profileState.isSaving,
                      ),
                      const SizedBox(height: 24),

                      // Additional settings
                      Card(
                        child: ListTile(
                          title: const Text('Manage Schedule'),
                          subtitle: const Text('Adjust wake/sleep times and reminders'),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            // Navigate to schedule settings
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Card(
                        child: ListTile(
                          title: Text('About'),
                          subtitle: Text('Version 1.0.0'),
                          trailing: Icon(Icons.info_outline),
                        ),
                      ),

                      if (profileState.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              profileState.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
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
