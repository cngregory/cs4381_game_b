import 'package:flutter/material.dart';

import 'game_screen.dart';

void main() {
  runApp(const GameBApp());
}

class GameBApp extends StatelessWidget {
  const GameBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Game B',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}