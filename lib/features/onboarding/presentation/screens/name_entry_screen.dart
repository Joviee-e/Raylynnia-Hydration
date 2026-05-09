import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'What\'s your name?',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Let us personalize your experience.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  widget.onNameChanged(value);
                  setState(() {});
                },
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _controller.text.trim().isNotEmpty
                          ? widget.onNext
                          : null,
                      child: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
