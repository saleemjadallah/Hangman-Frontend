import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/models/achievement.dart';

class AchievementBadge extends StatefulWidget {
  final Achievement achievement;
  final double size;
  final bool showProgress;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.size = 80,
    this.showProgress = true,
    this.onTap,
  });

  @override
  State<AchievementBadge> createState() => _AchievementBadgeState();
}

class _AchievementBadgeState extends State<AchievementBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.achievement.isUnlocked) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.achievement.isUnlocked ? _scaleAnimation.value : 1.0,
            child: Transform.rotate(
              angle: widget.achievement.isUnlocked ? _rotationAnimation.value : 0,
              child: Container(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Badge shape
                    CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: BadgeShapePainter(
                        shape: widget.achievement.badgeShape,
                        isUnlocked: widget.achievement.isUnlocked,
                        gradientColors: widget.achievement.gradientColors,
                        progress: widget.achievement.progress,
                        showProgress: widget.showProgress && !widget.achievement.isUnlocked,
                      ),
                    ),
                    // Glass effect overlay
                    if (widget.achievement.isUnlocked)
                      ClipPath(
                        clipper: BadgeShapeClipper(
                          shape: widget.achievement.badgeShape,
                          size: widget.size,
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Icon
                    Icon(
                      widget.achievement.icon,
                      size: widget.size * 0.4,
                      color: widget.achievement.isUnlocked
                          ? Colors.white
                          : Colors.grey.shade600,
                    ),
                    // Lock overlay for locked achievements
                    if (!widget.achievement.isUnlocked && widget.achievement.isSecret)
                      Icon(
                        Icons.lock,
                        size: widget.size * 0.25,
                        color: Colors.grey.shade700,
                      ),
                    // Rarity indicator
                    if (widget.achievement.isUnlocked)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRarityColor().withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: _getRarityColor().withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ..._getRarityStars(),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ).animate(
                onComplete: (controller) {
                  if (widget.achievement.isUnlocked) {
                    controller.repeat(reverse: true);
                  }
                },
              ).shimmer(
                duration: const Duration(seconds: 2),
                color: widget.achievement.isUnlocked
                    ? Colors.white.withOpacity(0.3)
                    : Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getRarityColor() {
    switch (widget.achievement.rarity) {
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

  List<Widget> _getRarityStars() {
    final starCount = widget.achievement.rarity.index + 1;
    return List.generate(
      starCount,
      (index) => Icon(
        Icons.star,
        size: 8,
        color: Colors.white,
      ),
    );
  }
}

class BadgeShapePainter extends CustomPainter {
  final String shape;
  final bool isUnlocked;
  final List<Color> gradientColors;
  final double progress;
  final bool showProgress;

  BadgeShapePainter({
    required this.shape,
    required this.isUnlocked,
    required this.gradientColors,
    required this.progress,
    required this.showProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create path based on shape
    final path = _createShapePath(size, shape);

    // Background paint
    final bgPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = isUnlocked
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ).createShader(Rect.fromCircle(center: center, radius: radius))
          : LinearGradient(
              colors: [Colors.grey.shade800, Colors.grey.shade700],
            ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, bgPaint);

    // Border paint
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isUnlocked
            ? [gradientColors.first.withOpacity(0.8), gradientColors.last]
            : [Colors.grey.shade600, Colors.grey.shade500],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, borderPaint);

    // Progress indicator for locked achievements
    if (showProgress && progress > 0 && progress < 1) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [Colors.blue.shade300, Colors.blue.shade500],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      final progressPath = Path();
      progressPath.addArc(
        Rect.fromCircle(center: center, radius: radius - 8),
        -math.pi / 2,
        2 * math.pi * progress,
      );
      canvas.drawPath(progressPath, progressPaint);
    }
  }

  Path _createShapePath(Size size, String shape) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    switch (shape) {
      case 'circle':
        path.addOval(Rect.fromCircle(center: center, radius: radius - 4));
        break;
      case 'hexagon':
        for (int i = 0; i < 6; i++) {
          final angle = (math.pi / 3) * i - math.pi / 2;
          final x = center.dx + (radius - 4) * math.cos(angle);
          final y = center.dy + (radius - 4) * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        break;
      case 'diamond':
        path.moveTo(center.dx, center.dy - radius + 4);
        path.lineTo(center.dx + radius - 4, center.dy);
        path.lineTo(center.dx, center.dy + radius - 4);
        path.lineTo(center.dx - radius + 4, center.dy);
        path.close();
        break;
      case 'star':
        final outerRadius = radius - 4;
        final innerRadius = outerRadius * 0.5;
        for (int i = 0; i < 10; i++) {
          final angle = (math.pi / 5) * i - math.pi / 2;
          final r = i.isEven ? outerRadius : innerRadius;
          final x = center.dx + r * math.cos(angle);
          final y = center.dy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        break;
      default:
        path.addOval(Rect.fromCircle(center: center, radius: radius - 4));
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BadgeShapeClipper extends CustomClipper<Path> {
  final String shape;
  final double size;

  BadgeShapeClipper({
    required this.shape,
    required this.size,
  });

  @override
  Path getClip(Size size) {
    return _createShapePath(size, shape);
  }

  Path _createShapePath(Size size, String shape) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    switch (shape) {
      case 'circle':
        path.addOval(Rect.fromCircle(center: center, radius: radius - 4));
        break;
      case 'hexagon':
        for (int i = 0; i < 6; i++) {
          final angle = (math.pi / 3) * i - math.pi / 2;
          final x = center.dx + (radius - 4) * math.cos(angle);
          final y = center.dy + (radius - 4) * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        break;
      case 'diamond':
        path.moveTo(center.dx, center.dy - radius + 4);
        path.lineTo(center.dx + radius - 4, center.dy);
        path.lineTo(center.dx, center.dy + radius - 4);
        path.lineTo(center.dx - radius + 4, center.dy);
        path.close();
        break;
      case 'star':
        final outerRadius = radius - 4;
        final innerRadius = outerRadius * 0.5;
        for (int i = 0; i < 10; i++) {
          final angle = (math.pi / 5) * i - math.pi / 2;
          final r = i.isEven ? outerRadius : innerRadius;
          final x = center.dx + r * math.cos(angle);
          final y = center.dy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        break;
      default:
        path.addOval(Rect.fromCircle(center: center, radius: radius - 4));
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}