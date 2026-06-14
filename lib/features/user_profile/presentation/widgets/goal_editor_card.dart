import 'package:flutter/material.dart';

class GoalEditorCard extends StatefulWidget {
  const GoalEditorCard({
    required this.currentGoal,
    required this.onGoalChanged,
    required this.isSaving,
    super.key,
  });

  final int currentGoal;
  final ValueChanged<int> onGoalChanged;
  final bool isSaving;

  @override
  State<GoalEditorCard> createState() => _GoalEditorCardState();
}

class _GoalEditorCardState extends State<GoalEditorCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentGoal.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Goal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGoalButton(1500, '1.5L'),
                _buildGoalButton(2000, '2L'),
                _buildGoalButton(2500, '2.5L'),
                _buildGoalButton(3000, '3L'),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              enabled: !widget.isSaving,
              decoration: InputDecoration(
                hintText: 'Custom goal (ml)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
            if (widget.isSaving)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalButton(int ml, String label) {
    return ElevatedButton(
      onPressed: widget.isSaving
          ? null
          : () {
              _controller.text = ml.toString();
              widget.onGoalChanged(ml);
            },
      child: Text(label),
    );
  }
}
