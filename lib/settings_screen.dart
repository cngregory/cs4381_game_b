import 'package:flutter/material.dart';

import 'game_settings.dart';
import 'game_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  GameMode _selectedMode = GameMode.humanVsHuman;
  Difficulty _selectedDifficulty = Difficulty.easy;

  void _startGame() {
    final settings = GameSettings(
      mode: _selectedMode,
      difficulty: _selectedMode == GameMode.humanVsComputer
          ? _selectedDifficulty
          : null,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(settings: settings)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final computerMode = _selectedMode == GameMode.humanVsComputer;

    return Scaffold(
      appBar: AppBar(title: const Text('Game B Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Game Mode',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            RadioListTile<GameMode>(
              title: const Text('Human vs. Human'),
              value: GameMode.humanVsHuman,
              groupValue: _selectedMode,
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedMode = value;
                });
              },
            ),

            RadioListTile<GameMode>(
              title: const Text('Human vs. Computer'),
              value: GameMode.humanVsComputer,
              groupValue: _selectedMode,
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _selectedMode = value;
                });
              },
            ),

            if (computerMode) ...[
              const SizedBox(height: 24),
              Text(
                'Choose Difficulty',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<Difficulty>(
                initialValue: _selectedDifficulty,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Difficulty',
                ),
                items: Difficulty.values.map((difficulty) {
                  return DropdownMenuItem<Difficulty>(
                    value: difficulty,
                    child: Text(_difficultyLabel(difficulty)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedDifficulty = value;
                  });
                },
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startGame,
                child: const Text('Play'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _difficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}
