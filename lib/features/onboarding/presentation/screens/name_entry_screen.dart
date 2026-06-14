import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Name entry screen - second step of onboarding.
/// Collects the user's name for personalization.
class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({
    required this.initialName,
    required this.onNameChanged,
    required this.onNext,
    required this.onBack,
    super.key,
  });

  final String initialName;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
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
    final hasName = _controller.text.trim().isNotEmpty;
    
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
                onPressed: widget.onBack,
              ),
            ),

            // Content Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Introduction Label
                  Text(
                    'INTRODUCTION',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          color: AppColors.primaryDim.withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 12),
                  // Large Title
                  Text(
                    'What should we\ncall you?',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w300,
                          height: 1.15,
                          color: AppColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 64),
                  
                  // Label & Large Minimalist Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR NAME',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: AppColors.outline,
                            ),
                      ),
                      const SizedBox(height: 8),
                      // Large input area with shadow and bottom accent
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                          boxShadow: [
                            if (_isFocused)
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.08),
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
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.onSurface,
                                  ),
                              decoration: const InputDecoration(
                                hintText: 'Enter name',
                                hintStyle: TextStyle(
                                  color: Color(0x332C3437),
                                  fontWeight: FontWeight.w300,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                              ),
                              onChanged: (value) {
                                widget.onNameChanged(value);
                                setState(() {});
                              },
                              textInputAction: TextInputAction.done,
                            ),
                            // Animated bottom accent line
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                              height: _isFocused ? 2.5 : 1.0,
                              color: _isFocused ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Description
                      Text(
                        'This is how Raylynnia will address you during your daily hydration rituals.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant.withOpacity(0.8),
                              fontWeight: FontWeight.w300,
                              fontSize: 13,
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // Floating Next Button fixed at bottom right
            Positioned(
              bottom: 24,
              right: 24,
              child: AnimatedOpacity(
                opacity: hasName ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 300),
                child: AbsorbPointer(
                  absorbing: !hasName,
                  child: FloatingActionButton.extended(
                    onPressed: widget.onNext,
                    elevation: 4,
                    highlightElevation: 2,
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    label: const Row(
                      children: [
                        Text(
                          'NEXT',
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 13,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: AppColors.onPrimary,
                          size: 16,
                        ),
                      ],
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
}
