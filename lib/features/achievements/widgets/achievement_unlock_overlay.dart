import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../../shared/models/achievement.dart';
import '../../../shared/widgets/glass_container.dart';
import 'achievement_badge.dart';

class AchievementUnlockOverlay extends StatefulWidget {
  final List<Achievement> unlockedAchievements;
  final VoidCallback onDismiss;

  const AchievementUnlockOverlay({
    super.key,
    required this.unlockedAchievements,
    required this.onDismiss,
  });

  static void show({
    required BuildContext context,
    required List<Achievement> achievements,
  }) {
    if (achievements.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => AchievementUnlockOverlay(
        unlockedAchievements: achievements,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<AchievementUnlockOverlay> createState() => _AchievementUnlockOverlayState();
}

class _AchievementUnlockOverlayState extends State<AchievementUnlockOverlay>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  late AnimationController _badgeAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _badgeRotationAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _badgeAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5),
    ));

    _badgeRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _badgeAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _badgeAnimationController.repeat();
    _confettiController.play();

    // Auto-advance through achievements if multiple
    if (widget.unlockedAchievements.length > 1) {
      _startAutoAdvance();
    }
  }

  void _startAutoAdvance() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _currentIndex < widget.unlockedAchievements.length - 1) {
        setState(() {
          _currentIndex++;
        });
        _animationController.reset();
        _animationController.forward();
        _confettiController.play();
        _startAutoAdvance();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    _badgeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.unlockedAchievements[_currentIndex];

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: achievement.gradientColors +
                  [Colors.white, Colors.yellow, Colors.pink],
              numberOfParticles: 30,
              gravity: 0.3,
              emissionFrequency: 0.05,
              maxBlastForce: 20,
              minBlastForce: 8,
            ),
          ),
          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: GlassContainer(
                      width: MediaQuery.of(context).size.width * 0.85,
                      padding: const EdgeInsets.all(32),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          achievement.gradientColors.first.withOpacity(0.3),
                          achievement.gradientColors.last.withOpacity(0.3),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            'ACHIEVEMENT UNLOCKED!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 2,
                            ),
                          ).animate().fadeIn(
                            delay: const Duration(milliseconds: 300),
                          ).slideY(
                            begin: -0.5,
                            end: 0,
                            delay: const Duration(milliseconds: 300),
                          ),
                          const SizedBox(height: 24),
                          // Badge with rotation
                          AnimatedBuilder(
                            animation: _badgeRotationAnimation,
                            builder: (context, child) {
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..rotateY(_badgeRotationAnimation.value),
                                child: AchievementBadge(
                                  achievement: achievement,
                                  size: 120,
                                  showProgress: false,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Achievement name
                          Text(
                            achievement.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(
                            delay: const Duration(milliseconds: 600),
                          ),
                          const SizedBox(height: 8),
                          // Rarity badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getRarityColor(achievement.rarity)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getRarityColor(achievement.rarity)
                                    .withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ..._getRarityStars(achievement.rarity),
                                const SizedBox(width: 8),
                                Text(
                                  achievement.rarity.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getRarityColor(achievement.rarity),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().scale(
                            delay: const Duration(milliseconds: 800),
                            duration: const Duration(milliseconds: 300),
                          ),
                          const SizedBox(height: 16),
                          // Description
                          Text(
                            achievement.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(
                            delay: const Duration(milliseconds: 900),
                          ),
                          const SizedBox(height: 16),
                          // Sarcastic message
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              achievement.sarcasticUnlockMessage,
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ).animate().fadeIn(
                            delay: const Duration(milliseconds: 1000),
                          ).shimmer(
                            delay: const Duration(milliseconds: 1200),
                            duration: const Duration(seconds: 2),
                            color: Colors.white.withOpacity(0.3),
                          ),
                          if (widget.unlockedAchievements.length > 1) ...[
                            const SizedBox(height: 16),
                            Text(
                              '${_currentIndex + 1} of ${widget.unlockedAchievements.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_currentIndex == widget.unlockedAchievements.length - 1)
                                ElevatedButton(
                                  onPressed: widget.onDismiss,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'AWESOME!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ).animate().scale(
                                  delay: const Duration(milliseconds: 1200),
                                  duration: const Duration(milliseconds: 300),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  List<Widget> _getRarityStars(AchievementRarity rarity) {
    final starCount = rarity.index + 1;
    return List.generate(
      starCount,
      (index) => Icon(
        Icons.star,
        size: 12,
        color: _getRarityColor(rarity),
      ).animate().scale(
        delay: Duration(milliseconds: 800 + (index * 100)),
        duration: const Duration(milliseconds: 200),
      ),
    );
  }
}