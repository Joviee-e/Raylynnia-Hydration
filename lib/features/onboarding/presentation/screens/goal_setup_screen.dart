import 'package:flutter/material.dart';

/// Goal setup screen - fourth step of onboarding.
/// Collects daily hydration goal and requests notification permission.
class GoalSetupScreen extends StatefulWidget {
  const GoalSetupScreen({
    required this.initialGoal,
    required this.onGoalChanged,
    required this.onComplete,
    required this.onBack,
    required this.isLoading,
    required this.error,
    super.key,
  });

  final int initialGoal;
  final ValueChanged<int> onGoalChanged;
  final VoidCallback onComplete;
  final VoidCallback onBack;
  final bool isLoading;
  final String? error;

  @override
  State<GoalSetupScreen> createState() => _GoalSetupScreenState();
}

class _GoalSetupScreenState extends State<GoalSetupScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialGoal.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Daily Goal',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'How much water should you drink daily?',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // Quick preset buttons
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildPresetButton(context, 1500, '1.5L'),
                    _buildPresetButton(context, 2000, '2L'),
                    _buildPresetButton(context, 2500, '2.5L'),
                    _buildPresetButton(context, 3000, '3L'),
                  ],
                ),
                const SizedBox(height: 32),
                // Custom input
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Custom goal (ml)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      final goal = int.tryParse(value);
                      if (goal != null && goal > 0) {
                        widget.onGoalChanged(goal);
                      }
                    }
                  },
                ),
                const SizedBox(height: 32),
                // Error message
                if (widget.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                // Notification permission info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ready to Start?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'ll request permission to send you hydration reminders. You can change this anytime in Settings.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.isLoading ? null : widget.onBack,
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.isLoading ? null : widget.onComplete,
                        child: widget.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Finish'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetButton(BuildContext context, int ml, String label) {
    return ElevatedButton(
      onPressed: () {
        _controller.text = ml.toString();
        widget.onGoalChanged(ml);
      },
      child: Text(label),
    );
  }
}
