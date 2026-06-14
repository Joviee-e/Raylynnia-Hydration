import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialGoal.toString());
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasGoal = _controller.text.trim().isNotEmpty;
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Flow container has background blooms
      body: SafeArea(
        child: Stack(
          children: [
            // Back Button on Top Left
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.onSurfaceVariant,
                  size: 24,
                ),
                onPressed: widget.isLoading ? null : widget.onBack,
              ),
            ),

            // Content Body
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 72, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Daily Goal',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.w200,
                          color: AppColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How much water should you drink daily to maintain stillness?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Preset selectors
                  Text(
                    'QUICK PRESETS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: AppColors.outline,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildPresetButton(1500, '1.5 Liters'),
                      _buildPresetButton(2000, '2.0 Liters'),
                      _buildPresetButton(2500, '2.5 Liters'),
                      _buildPresetButton(3000, '3.0 Liters'),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Custom text input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CUSTOM GOAL (ML)',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: AppColors.outline,
                            ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                          boxShadow: [
                            if (_isFocused)
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              )
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.onSurface,
                                  ),
                              decoration: const InputDecoration(
                                hintText: 'Enter custom volume',
                                hintStyle: TextStyle(
                                  color: Color(0x332C3437),
                                  fontWeight: FontWeight.w300,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  final goal = int.tryParse(value);
                                  if (goal != null && goal > 0) {
                                    widget.onGoalChanged(goal);
                                  }
                                }
                              },
                              textInputAction: TextInputAction.done,
                            ),
                            // Animated bottom accent line
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                              height: _isFocused ? 2.5 : 1.0,
                              color: _isFocused ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Error messages
                  if (widget.error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Text(
                        widget.error!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Ready to start notification info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.primaryDim, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Ready to Start?',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'We\'ll request permission to send you silent, mindful hydration reminders. You can adjust your preferences anytime in Settings.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onPrimaryContainer.withValues(alpha: 0.8),
                                height: 1.45,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating Complete button fixed at bottom
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: AnimatedOpacity(
                opacity: hasGoal ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 300),
                child: AbsorbPointer(
                  absorbing: !hasGoal || widget.isLoading,
                  child: GestureDetector(
                    onTap: widget.onComplete,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDim],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F2C3437),
                            blurRadius: 32,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isLoading) ...[
                            const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Text(
                            widget.isLoading ? 'SAVING...' : 'FINISH',
                            style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              fontFamily: 'Inter',
                            ),
                          ),
                          if (!widget.isLoading) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check,
                              color: AppColors.onPrimary,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(int ml, String label) {
    final isSelected = _controller.text == ml.toString();
    return GestureDetector(
      onTap: () {
        _controller.text = ml.toString();
        widget.onGoalChanged(ml);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
