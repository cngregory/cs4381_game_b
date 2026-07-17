enum GameMode { humanVsHuman, humanVsComputer }

enum Difficulty { easy, medium, hard }

class GameSettings {
  final GameMode mode;
  final Difficulty? difficulty;

  GameSettings({required this.mode, this.difficulty}) {
    if (mode == GameMode.humanVsComputer && difficulty == null) {
      throw ArgumentError('Human vs. Computer mode requires a difficulty.');
    }
  }

  bool get isHumanVsComputer => mode == GameMode.humanVsComputer;

  bool get isHumanVsHuman => mode == GameMode.humanVsHuman;
}
