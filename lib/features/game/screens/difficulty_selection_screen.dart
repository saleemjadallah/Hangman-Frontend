import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/animated_gradient_background.dart';
import '../../../shared/models/game_enums.dart';
import '../../../core/theme/app_theme.dart';

class DifficultySelectionScreen extends StatefulWidget {
  const DifficultySelectionScreen({super.key});

  @override
  State<DifficultySelectionScreen> createState() => _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animations = List.generate(
      4,
      (index) => CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.15,
          0.5 + index * 0.15,
          curve: Curves.elasticOut,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDifficultyCard({
    required GameDifficulty difficulty,
    required String title,
    required String description,
    required List<Color> gradientColors,
    required IconData icon,
    required int index,
    required String snarkyComment,
  }) {
    return ScaleTransition(
      scale: _animations[index],
      child: GlassContainer(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/game',
                arguments: difficulty,
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snarkyComment,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Choose Your Suffering'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _animations[0],
                child: GlassContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Select difficulty level based on your vocabulary confidence... or lack thereof',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    _buildDifficultyCard(
                      difficulty: GameDifficulty.easy,
                      title: 'Easy',
                      description: '4-6 letters • 8 wrong guesses • Hints provided',
                      gradientColors: [Colors.greenAccent, Colors.green],
                      icon: Icons.child_care,
                      index: 0,
                      snarkyComment: '"Perfect for beginners and quitters"',
                    ),
                    _buildDifficultyCard(
                      difficulty: GameDifficulty.medium,
                      title: 'Medium',
                      description: '6-8 letters • 6 wrong guesses • Minimal hints',
                      gradientColors: [Colors.orangeAccent, Colors.orange],
                      icon: Icons.person,
                      index: 1,
                      snarkyComment: '"For those who think they\'re smart"',
                    ),
                    _buildDifficultyCard(
                      difficulty: GameDifficulty.hard,
                      title: 'Hard',
                      description: '8+ letters • 4 wrong guesses • No hints',
                      gradientColors: [Colors.redAccent, Colors.red],
                      icon: Icons.whatshot,
                      index: 2,
                      snarkyComment: '"Prepare for vocabulary humiliation"',
                    ),
                    _buildDifficultyCard(
                      difficulty: GameDifficulty.extreme,
                      title: 'Extreme',
                      description: 'Obscure words • 3 guesses • Pure suffering',
                      gradientColors: [Colors.purpleAccent, Colors.deepPurple],
                      icon: Icons.dangerous,
                      index: 3,
                      snarkyComment: '"You must enjoy pain"',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}