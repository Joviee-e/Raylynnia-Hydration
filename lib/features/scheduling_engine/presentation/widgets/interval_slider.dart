import 'package:flutter/material.dart';

class IntervalSlider extends StatelessWidget {
  const IntervalSlider({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Every $value minutes',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Slider(
          value: value.toDouble(),
          min: 30,
          max: 180,
          divisions: 15,
          label: '$value min',
          onChanged: (newValue) {
            onChanged(newValue.toInt());
          },
        ),
      ],
    );
  }
}
