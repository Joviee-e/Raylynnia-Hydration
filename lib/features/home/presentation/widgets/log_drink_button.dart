import 'package:flutter/material.dart';

class LogDrinkButton extends StatefulWidget {
  const LogDrinkButton({
    required this.onLog,
    super.key,
  });

  final Function(int volumeMl) onLog;

  @override
  State<LogDrinkButton> createState() => _LogDrinkButtonState();
}

class _LogDrinkButtonState extends State<LogDrinkButton> {
  int _selectedVolume = 250;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Log a Drink',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                // Volume selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildVolumeButton(200),
                    _buildVolumeButton(250),
                    _buildVolumeButton(500),
                  ],
                ),
                const SizedBox(height: 16),
                // Custom volume slider
                Text('Volume: $_selectedVolume ml'),
                Slider(
                  value: _selectedVolume.toDouble(),
                  min: 100,
                  max: 1000,
                  divisions: 18,
                  onChanged: (value) {
                    setState(() {
                      _selectedVolume = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Log button
                ElevatedButton.icon(
                  onPressed: () {
                    widget.onLog(_selectedVolume);
                  },
                  icon: const Icon(Icons.local_drink),
                  label: const Text('Log Drink'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeButton(int volume) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _selectedVolume = volume;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: _selectedVolume == volume ? Colors.blue : null,
      ),
      child: Text(
        '$volume ml',
        style: TextStyle(
          color: _selectedVolume == volume ? Colors.white : null,
        ),
      ),
    );
  }
}
