import 'package:flutter/material.dart';

import 'board_widget.dart';
import 'game.dart';
import 'piece.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Game engine = Game();
  String statusMessage = 'Tap "Throw Sticks" to begin.';

  bool _currentPlayerHasActivePiece() {
    for (final piece in engine.currentPlayer.pieces) {
      if (piece.isActive) return true;
    }
    return false;
  }

  int? get currentMoveValue {
    for (final value in engine.state.availableThrows) {
      if (value == Game.redXMove && !_currentPlayerHasActivePiece()) {
        continue;
      }

      if (value != 0) return value;
    }

    return null;
  }

  Color _playerColor(String playerName) {
    return playerName == 'Player 1'
        ? Colors.red.shade700
        : Colors.blue.shade700;
  }

  String _throwLabel(int? value) {
    if (value == null) return 'Throw Result: None';
    if (value == Game.redXMove) return 'Throw Result: Red X — Move Back';
    return 'Throw Result: $value';
  }

  void _throwSticks() {
    setState(() {
      final result = engine.throwSticks();

      if (result == Game.redXMove && !_currentPlayerHasActivePiece()) {
        engine.state.availableThrows.remove(Game.redXMove);
        statusMessage =
            '${engine.currentPlayer.name} got Red X, but has no active pieces. Throw again.';
      } else if (result == Game.redXMove) {
        statusMessage =
            '${engine.currentPlayer.name} got Red X. Move an active piece backward.';
      } else {
        statusMessage = '${engine.currentPlayer.name} rolled a $result.';
      }
    });
  }

  void _movePiece(Piece piece) {
    final moveValue = currentMoveValue;
    if (moveValue == null) return;

    try {
      setState(() {
        engine.movePiece(piece, moveValue);
        statusMessage = 'Piece moved successfully.';
      });
    } catch (_) {
      setState(() {
        statusMessage = 'Invalid move.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = engine.currentPlayer;
    final throwValue = currentMoveValue;
    final playerColor = _playerColor(currentPlayer.name);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game B'),
        centerTitle: true,
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7EFE5), Color(0xFFE8DCC8)],
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 360,
              child: Column(
                children: [
                  _InfoCard(
                    playerName: currentPlayer.name,
                    playerColor: playerColor,
                    throwLabel: _throwLabel(throwValue),
                    throwValue: throwValue,
                    sticks: engine.lastSticks,
                    statusMessage: statusMessage,
                    onThrow: throwValue != null ? null : _throwSticks,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _PieceButtons(
                      currentPlayerName: currentPlayer.name,
                      pieces: currentPlayer.pieces,
                      onPieceTap: _movePiece,
                      playerColor: playerColor,
                      canMove: throwValue != null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Center(
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: BoardWidget(
                      engine: engine,
                      onPieceTap: _movePiece,
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

class _InfoCard extends StatelessWidget {
  final String playerName;
  final Color playerColor;
  final String throwLabel;
  final int? throwValue;
  final List<bool> sticks;
  final String statusMessage;
  final VoidCallback? onThrow;

  const _InfoCard({
    required this.playerName,
    required this.playerColor,
    required this.throwLabel,
    required this.throwValue,
    required this.sticks,
    required this.statusMessage,
    required this.onThrow,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PlayerDot(color: playerColor),
                const SizedBox(width: 10),
                Text(
                  playerName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PlayerDot(color: Colors.red),
                SizedBox(width: 6),
                Text('Player 1'),
                SizedBox(width: 18),
                _PlayerDot(color: Colors.blue),
                SizedBox(width: 6),
                Text('Player 2'),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              throwLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _StickDisplay(sticks: sticks, value: throwValue),
            const SizedBox(height: 10),
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onThrow,
              icon: const Icon(Icons.casino),
              label: const Text('Throw Sticks'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerDot extends StatelessWidget {
  final Color color;

  const _PlayerDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _StickDisplay extends StatelessWidget {
  final List<bool> sticks;
  final int? value;

  const _StickDisplay({
    required this.sticks,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || sticks.isEmpty) {
      return const Text('No throw yet', style: TextStyle(color: Colors.black54));
    }

    return Wrap(
      spacing: 7,
      children: List.generate(5, (index) {
        final isRedXStick = index == 0;
        final isShowing = sticks[index];
        final redXMove = value == Game.redXMove;

        return Container(
          width: 18,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isShowing
                ? (isRedXStick && redXMove
                    ? Colors.red.shade700
                    : Colors.brown.shade700)
                : Colors.brown.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.brown.shade900),
          ),
          child: isRedXStick && isShowing
              ? const Text(
                  'X',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        );
      }),
    );
  }
}

class _PieceButtons extends StatelessWidget {
  final String currentPlayerName;
  final List<Piece> pieces;
  final void Function(Piece piece) onPieceTap;
  final Color playerColor;
  final bool canMove;

  const _PieceButtons({
    required this.currentPlayerName,
    required this.pieces,
    required this.onPieceTap,
    required this.playerColor,
    required this.canMove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              "$currentPlayerName's Pieces",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.0,
                children: pieces.asMap().entries.map((entry) {
                  final index = entry.key;
                  final piece = entry.value;

                  String label;
                  if (piece.completed) {
                    label = '✓ Piece ${index + 1}\nDone';
                  } else if (piece.position == null) {
                    label = 'Piece ${index + 1}\nStart';
                  } else {
                    label = 'Piece ${index + 1}\nStation ${piece.position}';
                  }

                  return ElevatedButton(
                    onPressed: !canMove || piece.completed
                        ? null
                        : () => onPieceTap(piece),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: playerColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade700,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}