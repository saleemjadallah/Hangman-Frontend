import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../shared/models/game_enums.dart';

class ScoreDisplay extends StatelessWidget {
  final int currentScore;
  final GameDifficulty difficulty;

  const ScoreDisplay({
    super.key,
    required this.currentScore,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getDifficultyColors(difficulty),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getDifficultyColors(difficulty)[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Score: $currentScore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getDifficultyColors(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return [Colors.green, Colors.lightGreen];
      case GameDifficulty.medium:
        return [Colors.orange, Colors.amber];
      case GameDifficulty.hard:
        return [Colors.red, Colors.deepOrange];
      case GameDifficulty.extreme:
        return [Colors.purple, Colors.deepPurple];
    }
  }
}