import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final Duration duration;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.duration = const Duration(seconds: 5),
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  late List<Color> _colors;
  int _currentColorIndex = 0;

  @override
  void initState() {
    super.initState();
    _colors = widget.colors ??
        [
          AppTheme.primaryGradientStart,
          AppTheme.primaryGradientEnd,
          AppTheme.secondaryGradientStart,
          AppTheme.secondaryGradientEnd,
        ];

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentColorIndex = (_currentColorIndex + 1) % _colors.length;
        });
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  _colors[_currentColorIndex],
                  _colors[(_currentColorIndex + 1) % _colors.length],
                  _animation.value,
                )!,
                Color.lerp(
                  _colors[(_currentColorIndex + 2) % _colors.length],
                  _colors[(_currentColorIndex + 3) % _colors.length],
                  _animation.value,
                )!,
              ],
              transform: GradientRotation(_animation.value * 2 * 3.14159),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}